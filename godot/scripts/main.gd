extends Node3D

signal delivery_completed
signal combat_impact(kind: int, direction: Vector3)

# A single arena. All progress methods are also used by tests/smoke.gd.
enum Stage { PICKUP, VENT, GUARDIAN, ANCHORS, DELIVERY, COMPLETE }
enum GuardState { IDLE, TELEGRAPH, LUNGE, EXPOSED, RECOVER, CALM }
enum GuardAttack { CHARGE, SWEEP }

const PLAYER_START := Vector3(-12.0, 0.0, 1.0)
const PICKUP_POINT := Vector3(-3.5, 0.0, 1.0)
const VENT_POINT := Vector3(-1.5, 0.0, 0.0)
const VENT_CARGO_HEIGHT := 1.9
const GUARD_POINT := Vector3(2.0, 0.0, 0.0)
const ANCHOR_POINTS := [Vector3(0.5, 0.0, -2.0), Vector3(4.5, 0.0, -1.5)]
const SOCKET_POINT := Vector3(5.0, 0.0, 2.5)
const DELIVERED_CARGO_HEIGHT := 1.9
const MODEL_PATHS := ["res://assets/models/ilmek.glb", "res://assets/models/nefes.glb", "res://assets/models/kiskac.glb", "res://assets/models/membrane_room.glb", "res://assets/models/arrival_path.glb"]
const MEMBRANE_PRESENTATION = preload("res://scripts/membrane_presentation.gd")
const THIRD_PERSON_CAMERA = preload("res://scripts/third_person_camera.gd")
const DELIVERY_AUDIO = preload("res://scripts/delivery_audio.gd")
const PREFERENCES_STORE = preload("res://scripts/preferences_store.gd")
const COMBAT_FEEDBACK = preload("res://scripts/combat_feedback.gd")
const CHECKPOINT_STORE = preload("res://scripts/checkpoint_store.gd")
const DENIZ_VIGNETTE = preload("res://scripts/deniz_vignette.gd")
const GUARDIAN_SWEEP = preload("res://scripts/guardian_sweep.gd")
const MOVE_SPEED := 4.0
const DASH_SPEED := 13.0
const DASH_TIME := 0.20
const DASH_COOLDOWN := 0.48
const SWIPE_PIXELS := 105.0
const SWIPE_SECONDS := 0.18
const ASSIST_HOLD_SECONDS := 0.35
const ASSIST_PREPARE_PIXELS := 135.0
const ASSIST_READY_SECONDS := 2.0
const TRAIL_LIMIT := 50
const TRAIL_AGE := 2.0

var stage: Stage = Stage.PICKUP
var guard_state: GuardState = GuardState.IDLE
var guard_hits: int = 0
var anchor_count: int = 0
var has_cargo: bool = false
var paused: bool = false
var player_position: Vector3 = PLAYER_START
var guard_position: Vector3 = GUARD_POINT
var guard_direction: Vector3 = Vector3.LEFT
var _guard_from: Vector3 = GUARD_POINT
var _guard_to: Vector3 = GUARD_POINT
var _guard_timer: float = 0.0
var _guard_lunge_hit: bool = false
var _guard_attack: GuardAttack = GuardAttack.CHARGE
var _sweep_lesson_done := false
var _sweep_lesson_elapsed := 0.0
var _dwell: float = 0.0
var _dash_left: float = 0.0
var _dash_cooldown: float = 0.0
var _dash_direction: Vector3 = Vector3.RIGHT
var _dash_hit_this_dash: bool = false
var _move_vector: Vector2 = Vector2.ZERO
var _facing_direction: Vector3 = Vector3.RIGHT
var _touch_index: int = -1
var _mouse_owned: bool = false
var _contact_origin: Vector2 = Vector2.ZERO
var _contact_time_usec: int = 0
var _contact_dash_used: bool = false
var _elapsed: float = 0.0
var _trail_clock: float = 0.0
var reduce_motion: bool = false
var assisted_dash: bool = false
var _assist_hold: float = 0.0
var _assist_direction := Vector2.ZERO
var _assist_armed := Vector3.ZERO
var _assist_ready_left: float = 0.0
var _assist_released := false
var _trail_points: Array[Vector3] = []
var _trail_times: Array[float] = []

var _player: Node3D
var _cargo: Node3D
var _cargo_marker: Label3D
var _guardian: Node3D
var _guardian_seam: Node3D
var _guardian_seam_rest: Vector3
var _guardian_shells: Array[Node3D] = []
var _guardian_shell_rest: Array[Vector3] = []
var _guardian_shell_open: float = 0.0
var _camera: Camera3D
var _camera_rig: Node3D
var _orbit_owned: bool = false
var _trail_mesh: ImmediateMesh
var _trail_instance: MeshInstance3D
var _tether_mesh: ImmediateMesh
var _tether_instance: MeshInstance3D
var _telegraph_mesh: ImmediateMesh
var _telegraph_instance: MeshInstance3D
var _vent_ring: MeshInstance3D
var _vent_label: Label3D
var _capture_vent: bool = false
var _anchor_rings: Array[MeshInstance3D] = []
var _anchor_markers: Array[Node3D] = []
var _socket_ring: MeshInstance3D
var _socket_label: Label3D
var _socket_prompt_bucket: int = -1
var _status_label: Label
var _hint_label: Label
var _pause_panel: PanelContainer
var _resume_button: Button
var _capture_path: String = ""
var _capture_guardian_qa: bool = false
var _capture_exposed_qa: bool = false
var _capture_delivery_qa: bool = false
var _capture_before_delivery_qa: bool = false
var _capture_grayscale: bool = false
var _capture_profile: bool = false
var _capture_static: bool = false
var _capture_pause: bool = false
var _presentation: Node3D
var _delivery_audio: AudioStreamPlayer
var _audio_box: CheckBox
var _motion_box: CheckBox
var _assist_box: CheckBox
var _control_instructions: Label
var _settings_notice: Label
var _preferences = PREFERENCES_STORE.new()
var _preferences_path: String = "user://preferences_v1.json"
var _combat_feedback = COMBAT_FEEDBACK.new()
var _capture_impact: String = ""
var _checkpoint_path: String = "user://nefes_checkpoint_v1.json"
var _checkpoint_store = CHECKPOINT_STORE.new()
var _checkpoint_ready := false
var _checkpoint_attempt := 0
var _deniz_story: Control
var _capture_story := false
var _capture_sweep := false


func _ready() -> void:
	combat_impact.connect(_on_combat_impact)
	_build_world()
	_delivery_audio = DELIVERY_AUDIO.new()
	_delivery_audio.name = "DeliveryAudio"
	add_child(_delivery_audio)
	delivery_completed.connect(_delivery_audio.on_delivery)
	_build_ui()
	delivery_completed.connect(_on_delivery_story)
	_preferences.path = _preferences_path
	var preferences: Dictionary = _preferences.load_preferences()
	reduce_motion = preferences["reduce_motion"]
	assisted_dash = preferences.get("assisted_dash", false)
	_assist_box.set_pressed_no_signal(assisted_dash)
	_update_control_instructions()
	_delivery_audio.set_enabled(preferences["audio_enabled"])
	_motion_box.set_pressed_no_signal(reduce_motion)
	_audio_box.set_pressed_no_signal(_delivery_audio.enabled)
	_update_settings_notice()
	reset_game()
	# QA/capture must never resume or overwrite the player's real progress.
	_checkpoint_store.path = _checkpoint_path
	if _preferences_path.is_empty():
		_checkpoint_store.path = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			_checkpoint_store.path = ""
	var checkpoint: int = _checkpoint_store.load_checkpoint()
	_restore_checkpoint(checkpoint)
	_checkpoint_attempt = checkpoint
	_checkpoint_ready = true
	_update_settings_notice()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			_capture_path = argument.trim_prefix("--capture=")
		elif argument == "--capture-stage=guardian":
			_capture_guardian_qa = true
		elif argument == "--capture-stage=exposed":
			_capture_guardian_qa = true
			_capture_exposed_qa = true
		elif argument == "--capture-stage=complete":
			_capture_delivery_qa = true
		elif argument == "--capture-stage=delivery":
			_capture_before_delivery_qa = true
		elif argument == "--capture-grayscale":
			_capture_grayscale = true
		elif argument == "--capture-profile":
			_capture_profile = true
		elif argument == "--capture-static":
			_capture_static = true
		elif argument == "--capture-pause":
			_capture_pause = true
		elif argument == "--capture-story":
			_capture_story = true
		elif argument == "--capture-vent":
			_capture_vent = true
		elif argument == "--capture-attack=sweep":
			_capture_sweep = true
		elif argument.begins_with("--capture-impact="):
			_capture_impact = argument.trim_prefix("--capture-impact=")
	if not _capture_path.is_empty():
		if not _capture_path.is_absolute_path():
			push_error("--capture için mutlak PNG yolu gerekli")
			get_tree().quit(1)
			return
		if _capture_story:
			reduce_motion = false # QA pose only; never save a preference.
			_deniz_story.begin(false)
			_deniz_story.advance(5.2, false)
			set_physics_process(false)
		if _capture_guardian_qa:
			# Preserve the arena comparison camera independently of the arrival spawn.
			# Synthetic capture fixture only, never gameplay or checkpoint placement.
			player_position = Vector3(-5.0, 0.0, 1.0)
			_camera_rig.snap(player_position, Vector3.RIGHT)
			stage = Stage.GUARDIAN
			has_cargo = true
			guard_state = GuardState.EXPOSED if _capture_exposed_qa else GuardState.TELEGRAPH
			_guard_timer = 120.0
			_lock_guard_target()
			if _capture_sweep:
				_guard_attack = GuardAttack.SWEEP
			_refresh_text()
			_sync_visuals(0.0)
		if _capture_vent:
			# Synthetic halfway connection pose; no save or objective completion.
			stage = Stage.VENT
			has_cargo = true
			_dwell = 0.4
			player_position = VENT_POINT + Vector3(-0.35, 0.0, 0.60)
			_camera_rig.snap(player_position, Vector3.RIGHT)
			_refresh_text()
			_sync_visuals(0.0)
		if _capture_grayscale:
			for child: Node in get_children():
				if child is WorldEnvironment:
					(child as WorldEnvironment).environment.adjustment_enabled = true
					(child as WorldEnvironment).environment.adjustment_saturation = 0.0
		if _capture_delivery_qa or _capture_before_delivery_qa:
			# Synthetic QA state, not evidence that a human completed the encounter.
			stage = Stage.COMPLETE if _capture_delivery_qa else Stage.DELIVERY
			has_cargo = _capture_before_delivery_qa
			guard_state = GuardState.CALM
			player_position = SOCKET_POINT + Vector3(-2.0, 0.0, -1.2)
			_camera_rig.snap(player_position, Vector3.RIGHT)
			if _capture_delivery_qa:
				delivery_completed.emit()
				_presentation.advance_delivery(0.0, true)
			_refresh_text()
			_sync_visuals(0.0)
		if _capture_static:
			reduce_motion = true
			_motion_box.set_pressed_no_signal(true)
			_sync_visuals(0.0)
			set_physics_process(false)
		if _capture_pause:
			set_paused(true)
		if _capture_impact in ["parry", "hit", "damage"]:
			if not _capture_static:
				reduce_motion = false # QA-only; never persist this preference.
				_motion_box.set_pressed_no_signal(false)
			var event := COMBAT_FEEDBACK.Kind.PARRY
			if _capture_impact == "hit": event = COMBAT_FEEDBACK.Kind.SEAM_HIT
			if _capture_impact == "damage": event = COMBAT_FEEDBACK.Kind.PLAYER_HIT
			combat_impact.emit(event, Vector3.RIGHT)
			_sync_visuals(0.06)
			set_physics_process(false)
		_capture_after_frames.call_deferred()


func _on_combat_impact(kind: int, direction: Vector3) -> void:
	_combat_feedback.trigger(kind, direction, guard_hits >= 2)
	_refresh_text()


func _build_world() -> void:
	_camera = Camera3D.new()
	_camera_rig = THIRD_PERSON_CAMERA.new()
	add_child(_camera_rig)
	_camera_rig.setup(_camera)

	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("0d252e")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("8babb5")
	settings.ambient_light_energy = 0.23
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	settings.fog_enabled = true
	settings.fog_mode = Environment.FOG_MODE_DEPTH
	settings.fog_depth_begin = 18.0
	settings.fog_depth_end = 55.0
	settings.fog_light_color = Color("234b55")
	settings.fog_light_energy = 0.65
	environment.environment = settings
	add_child(environment)

	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-48.0, -35.0, 0.0)
	sunlight.light_color = Color("f5dfcc")
	sunlight.light_energy = 0.36
	sunlight.shadow_enabled = true
	add_child(sunlight)

	var garden := _load_model(3, "Garden")
	# Replace the +X opaque backdrop with the open cellular destination architecture.
	# Remove it before camera collision creation; never leave an invisible obstacle.
	var replaced_fold := garden.find_child("Side_Fold_R", true, false)
	if replaced_fold:
		replaced_fold.get_parent().remove_child(replaced_fold)
		replaced_fold.free()
	var entry_fold := garden.find_child("Side_Fold_L", true, false)
	if entry_fold:
		entry_fold.get_parent().remove_child(entry_fold)
		entry_fold.free()
	_disable_gold_emission(garden)
	add_child(garden)
	_camera_rig.add_room_collisions(garden)
	var arrival := _load_model(4, "Arrival")
	add_child(arrival)
	_camera_rig.add_room_collisions(arrival)
	_player = _load_model(0, "Ilmek")
	_player.scale = Vector3.ONE * 1.12
	_disable_gold_emission(_player)
	add_child(_player)
	_cargo = _load_model(1, "Nefes")
	_disable_gold_emission(_cargo)
	add_child(_cargo)
	_cargo_marker = Label3D.new()
	_cargo_marker.text = "Nefes"
	_cargo_marker.font_size = 28
	_cargo_marker.pixel_size = 0.01
	_cargo_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_cargo_marker.modulate = Color("e8bd64")
	_cargo_marker.position = PICKUP_POINT + Vector3.UP * 1.8
	add_child(_cargo_marker)
	_guardian = _load_model(2, "Kiskac")
	_disable_gold_emission(_guardian)
	add_child(_guardian)
	_guardian_seam = _guardian.find_child("Guardian_Seam_Runtime", true, false) as Node3D
	if _guardian_seam:
		_guardian_seam_rest = _guardian_seam.position
	else:
		push_error("Kıskaç açık dikiş parçası bulunamadı")
	for suffix: String in ["L", "R"]:
		var shell := _guardian.find_child("Guardian_Shell_%s_Runtime" % suffix, true, false) as Node3D
		if shell:
			_guardian_shells.append(shell)
			_guardian_shell_rest.append(shell.position)
		else:
			push_error("Kıskaç kabuk parçası bulunamadı: " + suffix)
	_presentation = MEMBRANE_PRESENTATION.new()
	add_child(_presentation)
	_presentation.build(garden, _player, _cargo, _guardian, arrival)
	delivery_completed.connect(func() -> void: _presentation.begin_delivery(reduce_motion))
	var gate_ribs := _presentation.find_child("Ivory_Ribs", true, false)
	if gate_ribs:
		# Main ribs stop orbit clipping; the fine decorative lattice stays non-colliding.
		_camera_rig.add_room_collisions(gate_ribs)

	# Interaction signs stay geometric primitives; environment/characters use authored GLBs.
	_vent_ring = _make_ring(VENT_POINT, 0.65, Color(0.57, 0.91, 0.84), false)
	_vent_ring.name = "TemporaryVent"
	_vent_label = Label3D.new()
	_vent_label.name = "VentPrompt"
	_vent_label.position = VENT_POINT + Vector3.UP * 2.8
	_vent_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_vent_label.font_size = 22
	_vent_label.pixel_size = 0.008
	_vent_label.outline_size = 8
	_vent_label.modulate = Color("fff0d9")
	add_child(_vent_label)
	for index: int in ANCHOR_POINTS.size():
		var point: Vector3 = ANCHOR_POINTS[index]
		_anchor_rings.append(_make_ring(point, 0.56, Color(1.0, 0.75, 0.36), false))
		_anchor_markers.append(_make_anchor_marker(point, index))
	_socket_ring = _make_ring(SOCKET_POINT, 0.74, Color(1.0, 0.78, 0.42), true)
	_socket_ring.name = "DeliverySocket"
	_socket_label = Label3D.new()
	_socket_label.name = "DeliveryPrompt"
	_socket_label.position = SOCKET_POINT + Vector3.UP * 2.9
	_socket_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_socket_label.font_size = 32
	_socket_label.pixel_size = 0.01
	_socket_label.outline_size = 8
	_socket_label.modulate = Color("fff0d9")
	add_child(_socket_label)
	_trail_mesh = ImmediateMesh.new()
	_trail_instance = _make_line_instance(_trail_mesh)
	_tether_mesh = ImmediateMesh.new()
	_tether_instance = _make_line_instance(_tether_mesh)
	_telegraph_mesh = ImmediateMesh.new()
	_telegraph_instance = _make_line_instance(_telegraph_mesh)
	var telegraph_material := StandardMaterial3D.new()
	telegraph_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	telegraph_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	telegraph_material.vertex_color_use_as_albedo = true
	_telegraph_instance.material_override = telegraph_material


func _load_model(index: int, node_name: String) -> Node3D:
	var resource: Resource = load(MODEL_PATHS[index])
	if resource is PackedScene:
		var instance: Node = (resource as PackedScene).instantiate()
		if instance is Node3D:
			instance.name = node_name
			return instance as Node3D
		instance.queue_free()
	push_error("Model yüklenemedi: " + MODEL_PATHS[index])
	var empty := Node3D.new()
	empty.name = node_name + "_Eksik"
	return empty


func _disable_gold_emission(node: Node, shared_materials: Dictionary = {}) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			for surface: int in mesh_instance.mesh.get_surface_count():
				var material := mesh_instance.get_active_material(surface) as StandardMaterial3D
				if material != null and material.resource_name.to_lower().contains("gold"):
					var key := material.get_instance_id()
					if not shared_materials.has(key):
						var unlit_gold := material.duplicate() as StandardMaterial3D
						unlit_gold.emission_enabled = false
						unlit_gold.roughness = maxf(unlit_gold.roughness, 0.55)
						shared_materials[key] = unlit_gold
					mesh_instance.set_surface_override_material(surface, shared_materials[key])
	for child: Node in node.get_children():
		_disable_gold_emission(child, shared_materials)


func _make_ring(point: Vector3, radius: float, tint: Color, closed: bool) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var vertices := PackedVector3Array()
	var steps: int = 32 if closed else 28
	var span: float = TAU if closed else TAU * 0.84
	for index: int in steps:
		var a: float = -PI * 0.5 + span * float(index) / float(steps)
		var b: float = -PI * 0.5 + span * float(index + 1) / float(steps)
		var a_outer := Vector3(cos(a) * radius, 0.0, sin(a) * radius)
		var a_inner := Vector3(cos(a) * (radius - 0.12), 0.0, sin(a) * (radius - 0.12))
		var b_outer := Vector3(cos(b) * radius, 0.0, sin(b) * radius)
		var b_inner := Vector3(cos(b) * (radius - 0.12), 0.0, sin(b) * (radius - 0.12))
		vertices.append_array(PackedVector3Array([a_outer, a_inner, b_outer, b_outer, a_inner, b_inner]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var arc := ArrayMesh.new()
	arc.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	ring.mesh = arc
	if closed:
		# A volumetric closed collar reads from a low third-person camera.
		# Keep the open temporary sockets unchanged in this bounded iteration.
		var collar := TorusMesh.new()
		collar.inner_radius = radius - 0.12
		collar.outer_radius = radius
		collar.rings = 32
		collar.ring_segments = 8
		ring.mesh = collar
		var border := MeshInstance3D.new()
		border.name = "ContrastBorder"
		var border_mesh := TorusMesh.new()
		border_mesh.inner_radius = radius - 0.17
		border_mesh.outer_radius = radius + 0.05
		border_mesh.rings = 32
		border_mesh.ring_segments = 8
		border.mesh = border_mesh
		border.position.y = -0.01
		border.scale.y = 0.25
		var border_material := _emissive(Color("342735"))
		border_material.emission_enabled = false
		border.material_override = border_material
		border.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring.add_child(border)
	ring.material_override = _emissive(tint)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position = point + Vector3.UP * 0.10
	add_child(ring)
	return ring


func _make_line_instance(mesh: ImmediateMesh) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _emissive(Color(1.0, 0.73, 0.30))
	add_child(instance)
	return instance


func _make_anchor_marker(point: Vector3, index: int) -> Node3D:
	var marker := Node3D.new()
	marker.position = point
	add_child(marker)
	var vertices := PackedVector3Array()
	if index == 0:
		vertices = PackedVector3Array([Vector3(0.0, 0.12, -0.26), Vector3(-0.25, 0.12, 0.20), Vector3(0.25, 0.12, 0.20)])
	else:
		vertices = PackedVector3Array([Vector3(-0.23, 0.12, -0.23), Vector3(-0.23, 0.12, 0.23), Vector3(0.23, 0.12, -0.23), Vector3(0.23, 0.12, -0.23), Vector3(-0.23, 0.12, 0.23), Vector3(0.23, 0.12, 0.23)])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var geometry := ArrayMesh.new()
	geometry.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var shape := MeshInstance3D.new()
	shape.mesh = geometry
	shape.material_override = _emissive(Color(0.35, 0.75, 0.72))
	marker.add_child(shape)
	var number := Label3D.new()
	number.text = str(index + 1)
	number.font_size = 64
	number.pixel_size = 0.008
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number.position.y = 0.42
	marker.add_child(number)
	return marker


func _emissive(tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 1.5
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	return material


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	_deniz_story = DENIZ_VIGNETTE.new()
	_deniz_story.name = "DenizStory"
	root.add_child(_deniz_story)
	_deniz_story.opened.connect(_on_story_open)
	_deniz_story.dismissed.connect(_on_story_close)

	var top := MarginContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.add_theme_constant_override("margin_left", 24)
	top.add_theme_constant_override("margin_right", 24)
	top.add_theme_constant_override("margin_top", 18)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)
	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(top_row)
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 19)
	_status_label.add_theme_color_override("font_color", Color("e8e1d5"))
	_status_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.04, 0.05, 0.9))
	_status_label.add_theme_constant_override("shadow_offset_y", 2)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(_status_label)
	var pause_button := Button.new()
	pause_button.text = "Duraklat"
	pause_button.custom_minimum_size = Vector2(90.0, 44.0)
	pause_button.add_theme_stylebox_override("normal", _quiet_panel())
	pause_button.focus_mode = Control.FOCUS_ALL
	pause_button.pressed.connect(set_paused.bind(true))
	top_row.add_child(pause_button)

	var bottom := MarginContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.add_theme_constant_override("margin_left", 24)
	bottom.add_theme_constant_override("margin_right", 24)
	bottom.add_theme_constant_override("margin_bottom", 18)
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom.offset_top = -90.0
	bottom.offset_bottom = -8.0
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bottom)
	_hint_label = Label.new()
	_hint_label.add_theme_font_size_override("font_size", 18)
	_hint_label.add_theme_color_override("font_color", Color("e8e1d5"))
	_hint_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.04, 0.05, 0.95))
	_hint_label.add_theme_constant_override("shadow_offset_y", 2)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(_hint_label)

	var pause_center := CenterContainer.new()
	pause_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pause_center)
	_pause_panel = PanelContainer.new()
	_pause_panel.add_theme_stylebox_override("panel", _quiet_panel())
	_pause_panel.custom_minimum_size = Vector2(400.0, 270.0)
	_pause_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_center.add_child(_pause_panel)
	var content := MarginContainer.new()
	content.add_theme_constant_override("margin_left", 24)
	content.add_theme_constant_override("margin_right", 24)
	content.add_theme_constant_override("margin_top", 22)
	content.add_theme_constant_override("margin_bottom", 22)
	_pause_panel.add_child(content)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 15)
	content.add_child(column)
	var title := Label.new()
	title.text = "OYUN DURAKLATILDI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	column.add_child(title)
	_resume_button = Button.new()
	_resume_button.text = "Devam et"
	_resume_button.pressed.connect(set_paused.bind(false))
	column.add_child(_resume_button)
	var restart_button := Button.new()
	restart_button.text = "Baştan başla"
	restart_button.pressed.connect(reset_game)
	column.add_child(restart_button)
	_motion_box = CheckBox.new()
	_motion_box.text = "Hareketi azalt"
	_motion_box.toggled.connect(_set_reduce_motion)
	column.add_child(_motion_box)
	_assist_box = CheckBox.new()
	_assist_box.text = "Yardımcı atılma · savuruş gerekmez"
	_assist_box.toggled.connect(_set_assisted_dash)
	column.add_child(_assist_box)
	_audio_box = CheckBox.new()
	_audio_box.text = "Ses açık"
	_audio_box.button_pressed = true
	_audio_box.toggled.connect(_set_audio_enabled)
	column.add_child(_audio_box)
	_settings_notice = Label.new()
	_settings_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_settings_notice.custom_minimum_size.x = 320.0
	_settings_notice.add_theme_font_size_override("font_size", 15)
	_settings_notice.visible = false
	column.add_child(_settings_notice)
	var instructions := Label.new()
	_control_instructions = instructions
	instructions.text = "Sürükle: hareket • Hızlı savur: atıl\nWindows: WASD / oklar, Boşluk, Esc, R\nKamera: Q / E veya sağ fareyle sürükle"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(instructions)
	_pause_panel.visible = false


func _quiet_panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.095, 0.11, 0.92)
	style.border_color = Color(0.73, 0.66, 0.53, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	return style


func _on_delivery_story() -> void:
	_deniz_story.begin(reduce_motion)


func _on_story_open() -> void:
	_clear_contact()
	_refresh_text()


func _on_story_close() -> void:
	_clear_contact()
	_refresh_text()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		set_paused(not paused)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart_game"):
		reset_game()
		get_viewport().set_input_as_handled()
		return
	if paused or _deniz_story.active:
		return
	if event.is_action_pressed("dash"):
		var keyboard_direction := _keyboard_vector()
		var direction: Vector3 = _camera_rig.screen_to_world(keyboard_direction)
		if direction.length_squared() < 0.01:
			direction = _facing_direction
		start_dash(direction)
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _touch_index < 0 and not _mouse_owned:
			_touch_index = touch.index
			_begin_contact(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_index:
			_update_contact(drag.position)
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.button_index == MOUSE_BUTTON_RIGHT:
			_orbit_owned = click.pressed
		if click.button_index == MOUSE_BUTTON_LEFT and _touch_index < 0:
			if click.pressed and not _mouse_owned:
				_mouse_owned = true
				_begin_contact(click.position)
	elif event is InputEventMouseMotion:
		if _orbit_owned:
			_camera_rig.orbit(-(event as InputEventMouseMotion).screen_relative.x * 0.005)
		elif _mouse_owned:
			_update_contact((event as InputEventMouseMotion).position)


func _input(event: InputEvent) -> void:
	# Releases must reach the owner even when a Control consumes them.
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed and touch.index == _touch_index:
			_touch_index = -1
			_end_contact()
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if not click.pressed and click.button_index == MOUSE_BUTTON_RIGHT:
			_orbit_owned = false
		if not click.pressed and click.button_index == MOUSE_BUTTON_LEFT and _mouse_owned:
			_mouse_owned = false
			_end_contact()


func _begin_contact(position: Vector2) -> void:
	_contact_origin = position
	_contact_time_usec = Time.get_ticks_usec()
	_contact_dash_used = false
	_move_vector = Vector2.ZERO
	if assisted_dash and _assist_released and _assist_ready_left > 0.0:
		var direction := _assist_armed
		_cancel_assisted_dash()
		_contact_dash_used = start_dash(direction)
		return
	_cancel_assisted_dash()


func _update_contact(position: Vector2) -> void:
	var offset := position - _contact_origin
	_move_vector = offset.limit_length(95.0) / 95.0
	if offset.length() < 12.0:
		_move_vector = Vector2.ZERO
	if assisted_dash:
		if _contact_dash_used:
			return
		if offset.length() < ASSIST_PREPARE_PIXELS:
			_cancel_assisted_dash()
			return
		var direction := offset.normalized()
		var starting := _assist_direction.length_squared() < 0.5
		if _assist_direction.dot(direction) < 0.96:
			_cancel_assisted_dash()
			starting = true
		_assist_direction = direction
		if starting:
			_refresh_text()
		return
	if not _contact_dash_used and Time.get_ticks_usec() - _contact_time_usec <= int(SWIPE_SECONDS * 1000000.0) and offset.length() >= SWIPE_PIXELS:
		_contact_dash_used = true
		start_dash(_camera_rig.screen_to_world(offset.normalized()))


func _end_contact() -> void:
	if assisted_dash and _assist_ready_left > 0.0 and not _contact_dash_used:
		_assist_released = true
		_refresh_text()
	else:
		_cancel_assisted_dash()
	_move_vector = Vector2.ZERO
	_contact_dash_used = false
	_assist_hold = 0.0
	_assist_direction = Vector2.ZERO


func _tick_assisted_dash(delta: float) -> void:
	if not assisted_dash or paused:
		return
	if _assist_ready_left > 0.0:
		_assist_ready_left = maxf(0.0, _assist_ready_left - delta)
		if _assist_ready_left == 0.0:
			_cancel_assisted_dash()
		return
	if (_touch_index >= 0 or _mouse_owned) and not _contact_dash_used and _assist_direction.length_squared() > 0.5:
		_assist_hold += maxf(delta, 0.0)
		if _assist_hold >= ASSIST_HOLD_SECONDS and _dash_cooldown <= 0.0 and stage != Stage.COMPLETE:
			_assist_armed = _camera_rig.screen_to_world(_assist_direction)
			_assist_ready_left = ASSIST_READY_SECONDS
			_refresh_text()


func _cancel_assisted_dash() -> void:
	var was_ready := _assist_ready_left > 0.0 or _assist_released or _assist_direction.length_squared() > 0.5
	_assist_ready_left = 0.0
	_assist_armed = Vector3.ZERO
	_assist_released = false
	_assist_hold = 0.0
	_assist_direction = Vector2.ZERO
	if was_ready:
		_refresh_text()


func _keyboard_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")


func _physics_process(delta: float) -> void:
	if paused:
		return
	var movement := _move_vector
	if movement.length_squared() < 0.001:
		movement = _keyboard_vector()
	var orbit_input := Input.get_axis("camera_left", "camera_right")
	if absf(orbit_input) > 0.01 and not _deniz_story.active:
		_camera_rig.orbit(orbit_input * delta * 1.8)
	var world_movement: Vector3 = _camera_rig.screen_to_world(movement)
	simulate_step(delta, Vector2(world_movement.x, world_movement.z))
	_sync_visuals(delta)


func simulate_step(delta: float, movement: Vector2 = Vector2.ZERO) -> void:
	if paused or _deniz_story.active:
		return
	_tick_assisted_dash(delta)
	_elapsed += delta
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	var previous_player := player_position
	if _dash_left > 0.0:
		var dash_dt := minf(delta, _dash_left)
		player_position += _dash_direction * DASH_SPEED * dash_dt
		_dash_left = maxf(0.0, _dash_left - delta)
	else:
		player_position += Vector3(movement.x, 0.0, movement.y).limit_length(1.0) * MOVE_SPEED * delta
		if movement.length_squared() > 0.01:
			_facing_direction = Vector3(movement.x, 0.0, movement.y).normalized()
	player_position = _clamp_playable_position(player_position)
	if stage == Stage.ANCHORS and anchor_count > 0:
		var tether_origin: Vector3 = ANCHOR_POINTS[anchor_count - 1]
		var from_anchor := player_position - tether_origin
		if from_anchor.length() > 5.0:
			player_position = tether_origin + from_anchor.normalized() * 5.0
	_tick_guardian(delta, previous_player)
	_tick_objectives(delta, movement)
	_record_checkpoint()
	_update_trail(delta)


func _clamp_playable_position(point: Vector3) -> Vector3:
	# Union of the original arena and its narrow entrance; not one giant rectangle.
	var arena := Vector3(clampf(point.x, -7.0, 7.0), 0, clampf(point.z, -3.5, 3.5))
	var entry := Vector3(clampf(point.x, -14.0, -6.8), 0, clampf(point.z, 0.0, 2.0))
	return arena if arena.distance_squared_to(point) <= entry.distance_squared_to(point) else entry


func start_dash(direction: Vector3) -> bool:
	if paused or stage == Stage.COMPLETE or _dash_cooldown > 0.0 or direction.length_squared() < 0.01:
		return false
	_dash_direction = Vector3(direction.x, 0.0, direction.z).normalized()
	_facing_direction = _dash_direction
	_dash_left = DASH_TIME
	_dash_cooldown = DASH_COOLDOWN
	_dash_hit_this_dash = false
	return true


func _tick_objectives(delta: float, movement: Vector2) -> void:
	match stage:
		Stage.PICKUP:
			if player_position.distance_to(PICKUP_POINT) < 0.66:
				has_cargo = true
				stage = Stage.VENT
				_dwell = 0.0
				_refresh_text()
		Stage.VENT:
			if player_position.distance_to(VENT_POINT) < 0.80 and movement.length() < 0.08 and _dash_left <= 0.0:
				_dwell += delta
				if _dwell >= 0.8:
					stage = Stage.GUARDIAN
					_dwell = 0.0
					guard_state = GuardState.TELEGRAPH
					_guard_timer = 0.82
					_lock_guard_target()
					_refresh_text()
			else:
				_dwell = 0.0
		Stage.ANCHORS:
			if player_position.distance_to(ANCHOR_POINTS[anchor_count]) < 0.70:
				anchor_count += 1
				_refresh_text()
				if anchor_count == 2:
					stage = Stage.DELIVERY
					_refresh_text()
		Stage.DELIVERY:
			if player_position.distance_to(SOCKET_POINT) < 0.88 and movement.length() < 0.08 and _dash_left <= 0.0:
				_dwell += delta
				_update_socket_prompt()
				if _dwell >= 0.9:
					has_cargo = false
					stage = Stage.COMPLETE
					_dwell = 0.0
					delivery_completed.emit()
					_refresh_text()
			else:
				_dwell = 0.0
				_update_socket_prompt()


func _tick_guardian(delta: float, previous_player: Vector3) -> void:
	if stage != Stage.GUARDIAN:
		return
	if guard_state == GuardState.TELEGRAPH and _guard_attack == GuardAttack.SWEEP and not _sweep_lesson_done:
		_sweep_lesson_elapsed += delta
		# Give the new shape time on screen. Movement remains live, damage does not.
		if _sweep_lesson_elapsed < 1.2 or GUARDIAN_SWEEP.in_warning(player_position, guard_position, guard_direction):
			return
		_sweep_lesson_done = true
		_guard_timer = 0.82 # A full normal wind-up follows the safe exit.
		_refresh_text()
		return
	_guard_timer -= delta
	match guard_state:
		GuardState.TELEGRAPH:
			if _guard_timer <= 0.0:
				guard_state = GuardState.LUNGE
				_guard_timer = 0.40
				_guard_from = guard_position
				_guard_to = guard_position if _guard_attack == GuardAttack.SWEEP else guard_position + guard_direction * 2.1
				_guard_to.x = clampf(_guard_to.x, -6.5, 6.5)
				_guard_to.z = clampf(_guard_to.z, -3.0, 3.0)
				_guard_lunge_hit = false
				_refresh_text()
		GuardState.LUNGE:
			var old_guard := guard_position
			var progress := 1.0 - maxf(_guard_timer, 0.0) / 0.40
			guard_position = _guard_from.lerp(_guard_to, progress)
			var contact := GUARDIAN_SWEEP.hits(previous_player, player_position, guard_position, guard_direction, clampf(progress - delta / 0.40, 0.0, 1.0), progress) if _guard_attack == GuardAttack.SWEEP else _relative_sweep_hit(previous_player, player_position, old_guard, guard_position, 0.72)
			if not _guard_lunge_hit and contact:
				_guard_lunge_hit = true
				var head_on := (previous_player - old_guard).dot(guard_direction) > 0.15
				var parry_window := progress >= 0.25 and progress <= 0.60
				if _guard_attack == GuardAttack.CHARGE and _dash_left > 0.0 and head_on and parry_window and _dash_direction.dot(-guard_direction) > 0.70:
					_enter_exposed()
					_dash_hit_this_dash = true
					combat_impact.emit(COMBAT_FEEDBACK.Kind.PARRY, _dash_direction)
				else:
					player_position = Vector3(-0.7, 0.0, 1.2)
					_clear_contact()
					combat_impact.emit(COMBAT_FEEDBACK.Kind.PLAYER_HIT, guard_direction)
			if _guard_timer <= 0.0 and guard_state == GuardState.LUNGE:
				_enter_exposed()
		GuardState.EXPOSED:
			if _dash_left > 0.0 and not _dash_hit_this_dash and _segment_distance_xz(previous_player, player_position, guard_position) < 0.98 and _dash_direction.dot((guard_position - previous_player).normalized()) > 0.25:
				_dash_hit_this_dash = true
				guard_hits += 1
				combat_impact.emit(COMBAT_FEEDBACK.Kind.SEAM_HIT, _dash_direction)
				_refresh_text()
				if guard_hits >= 2:
					guard_state = GuardState.CALM
					stage = Stage.ANCHORS
					_dash_left = 0.0
					_refresh_text()
				else:
					guard_state = GuardState.RECOVER
					_guard_timer = 0.65
					_refresh_text()
			if _guard_timer <= 0.0 and guard_state == GuardState.EXPOSED:
				guard_state = GuardState.RECOVER
				_guard_timer = 0.38
				_refresh_text()
		GuardState.RECOVER:
			if _guard_timer <= 0.0:
				guard_state = GuardState.TELEGRAPH
				_guard_timer = 0.82
				_lock_guard_target()
				_refresh_text()


func _lock_guard_target() -> void:
	_guard_attack = GuardAttack.SWEEP if guard_hits > 0 else GuardAttack.CHARGE
	var to_player := player_position - guard_position
	guard_direction = to_player.normalized() if to_player.length_squared() > 0.001 else Vector3.LEFT


func _enter_exposed() -> void:
	guard_state = GuardState.EXPOSED
	_guard_timer = 1.25
	_refresh_text()


func _relative_sweep_hit(player_from: Vector3, player_to: Vector3, guard_from: Vector3, guard_to: Vector3, radius: float) -> bool:
	var relative_from := player_from - guard_from
	var relative_to := player_to - guard_to
	return _segment_distance_xz(relative_from, relative_to, Vector3.ZERO) <= radius


func _segment_distance_xz(a: Vector3, b: Vector3, point: Vector3) -> float:
	var segment := Vector2(b.x - a.x, b.z - a.z)
	var from_start := Vector2(point.x - a.x, point.z - a.z)
	var along := clampf(from_start.dot(segment) / maxf(segment.length_squared(), 0.0001), 0.0, 1.0)
	return from_start.distance_to(segment * along)


func _update_trail(delta: float) -> void:
	_trail_clock += delta
	if _trail_clock >= 0.045 and (_trail_points.is_empty() or _trail_points.back().distance_to(player_position) > 0.14):
		_trail_clock = 0.0
		_trail_points.append(player_position + Vector3.UP * 0.16)
		_trail_times.append(_elapsed)
	while _trail_points.size() > TRAIL_LIMIT or (not _trail_times.is_empty() and _elapsed - _trail_times[0] > TRAIL_AGE):
		_trail_points.pop_front()
		_trail_times.pop_front()


func _sync_visuals(delta: float) -> void:
	# Settings can request a redraw while paused; never advance visual easing then.
	delta = 0.0 if paused else maxf(delta, 0.0)
	_deniz_story.advance(delta, reduce_motion)
	if _combat_feedback.advance(delta):
		_refresh_text()
	var camera_input_active := _mouse_owned or _touch_index >= 0 or _orbit_owned or _keyboard_vector().length_squared() > 0.001 or _dash_left > 0.0
	var combat_target := guard_position if stage == Stage.GUARDIAN else Vector3.INF
	_camera_rig.advance(delta, player_position, _facing_direction, camera_input_active, reduce_motion, combat_target)
	_presentation.sync_positions(player_position, guard_position)
	_presentation.advance_delivery(0.0 if paused else delta, reduce_motion)
	_player.position = player_position
	_player.position.y = 0.12 if reduce_motion else 0.12 + 0.06 * sin(_elapsed * 4.0)
	_player.position += _combat_feedback.player_offset(reduce_motion)
	_player.scale = _combat_feedback.player_pose(reduce_motion)
	_guardian.position = guard_position
	_guardian.position.y = 0.05 if reduce_motion else 0.05 + 0.04 * sin(_elapsed * 2.8)
	_guardian.position += _combat_feedback.guardian_offset(reduce_motion)
	var guardian_facing := player_position - guard_position
	if stage == Stage.GUARDIAN and guard_state in [GuardState.TELEGRAPH, GuardState.LUNGE]:
		guardian_facing = guard_direction
		if _guard_attack == GuardAttack.SWEEP and guard_state == GuardState.LUNGE and not reduce_motion:
			guardian_facing = GUARDIAN_SWEEP.direction_at(guard_direction, 1.0 - maxf(_guard_timer, 0.0) / 0.40)
	if guardian_facing.length_squared() > 0.01:
		var target_yaw := atan2(guardian_facing.x, guardian_facing.z)
		if _guard_attack == GuardAttack.SWEEP and guard_state == GuardState.LUNGE:
			_guardian.rotation.y = target_yaw # Attack pose must not lag behind its collision proxy.
		else:
			_guardian.rotation.y = lerp_angle(_guardian.rotation.y, target_yaw, 1.0 - exp(-8.0 * delta))
	var seam_open := stage == Stage.GUARDIAN and guard_state == GuardState.EXPOSED
	var shell_target := 1.0 if seam_open else 0.0
	_guardian_shell_open = shell_target if reduce_motion else lerpf(_guardian_shell_open, shell_target, 1.0 - exp(-18.0 * delta))
	for index: int in _guardian_shells.size():
		var side := -1.0 if index == 0 else 1.0
		_guardian_shells[index].position = _guardian_shell_rest[index] + Vector3(side * 0.22, 0.07, 0.0) * _guardian_shell_open
	if _guardian_seam:
		_guardian_seam.visible = seam_open
		_guardian_seam.position = _guardian_seam_rest + Vector3.UP * (0.12 if seam_open else 0.0)
	var guard_pose := Vector3(1.05, 0.90, 1.05) if seam_open and not reduce_motion else Vector3.ONE
	_guardian.scale = guard_pose if reduce_motion else _guardian.scale.lerp(guard_pose, 1.0 - exp(-14.0 * maxf(delta, 0.0)))
	_player.rotation.y = lerp_angle(_player.rotation.y, atan2(_facing_direction.x, _facing_direction.z), minf(delta * 11.0, 1.0))
	_cargo.visible = true
	var delivery_pulse := 0.0 if reduce_motion else sin(_presentation.delivery_progress * PI)
	_cargo.scale = Vector3.ONE * (1.0 + delivery_pulse * 0.12)
	_socket_ring.scale = Vector3.ONE * (1.0 + _presentation.delivery_progress * 0.12 + delivery_pulse * 0.10)
	_cargo_marker.visible = stage == Stage.PICKUP
	if has_cargo:
		var cargo_side := _facing_direction.cross(Vector3.UP) * -0.85
		_cargo.position = player_position + cargo_side + Vector3.UP * (0.65 if reduce_motion else 0.65 + 0.05 * sin(_elapsed * 5.0))
		if stage == Stage.VENT and _dwell > 0.0:
			var dock := 1.0 if reduce_motion else smoothstep(0.0, 0.18, _dwell)
			var dock_point := VENT_POINT + Vector3.UP * VENT_CARGO_HEIGHT
			_cargo.position = dock_point if dock >= 1.0 else _cargo.position.lerp(dock_point, dock)
	elif stage == Stage.COMPLETE:
		# Above the courier silhouette, including when standing in the socket.
		_cargo.position = SOCKET_POINT + Vector3.UP * DELIVERED_CARGO_HEIGHT
	else:
		_cargo.position = PICKUP_POINT + Vector3(0.0, 0.35 if reduce_motion else 0.35 + 0.05 * sin(_elapsed * 4.0), 0.0)
	var vent_progress := clampf(_dwell / 0.8, 0.0, 1.0) if stage == Stage.VENT else (1.0 if stage > Stage.VENT else 0.0)
	var vent_eased := vent_progress * vent_progress * (3.0 - 2.0 * vent_progress)
	# A persistent open collar is a state cue, not a new passage or collision gate.
	_vent_ring.visible = stage >= Stage.VENT
	_vent_ring.scale = Vector3(1.0 + .4 * vent_eased, 1.0, 1.0 + .4 * vent_eased)
	_vent_label.visible = stage == Stage.VENT or (stage == Stage.GUARDIAN and player_position.distance_to(VENT_POINT) < 2.0)
	# Tiny epsilon keeps exact tenth boundaries stable after fixed-step accumulation.
	var vent_percent := int(floor(vent_progress * 10.0 + 0.00001)) * 10
	_vent_label.text = ("Nefes · %d%%" % vent_percent if _dwell > 0.0 else "Geçici yuva · Nefes") if stage == Stage.VENT else "Akım açık · Nefes sende"
	for index: int in _anchor_rings.size():
		var active := (stage == Stage.ANCHORS and index >= anchor_count) or _capture_guardian_qa
		_anchor_rings[index].visible = active
		_anchor_markers[index].visible = active
	_socket_ring.visible = stage == Stage.DELIVERY or stage == Stage.COMPLETE
	_draw_lines()


func _draw_lines() -> void:
	_trail_mesh.clear_surfaces()
	if _trail_points.size() >= 2:
		_trail_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for index: int in range(1, _trail_points.size()):
			_trail_mesh.surface_add_vertex(_trail_points[index - 1])
			_trail_mesh.surface_add_vertex(_trail_points[index])
		_trail_mesh.surface_end()
	_tether_mesh.clear_surfaces()
	if stage == Stage.VENT and _dwell > 0.0:
		_tether_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		_tether_mesh.surface_add_vertex(player_position + Vector3.UP * 0.35)
		_tether_mesh.surface_add_vertex(_cargo.position)
		_tether_mesh.surface_end()
	elif stage == Stage.ANCHORS and anchor_count > 0:
		_tether_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		_tether_mesh.surface_add_vertex(ANCHOR_POINTS[anchor_count - 1] + Vector3.UP * 0.22)
		_tether_mesh.surface_add_vertex(player_position + Vector3.UP * 0.2)
		_tether_mesh.surface_end()
	_telegraph_mesh.clear_surfaces()
	if _guard_attack == GuardAttack.SWEEP and guard_state in [GuardState.TELEGRAPH, GuardState.LUNGE] and stage == Stage.GUARDIAN:
		_draw_sweep_warning()
		return
	if guard_state == GuardState.TELEGRAPH and stage == Stage.GUARDIAN:
		var side := Vector3(-guard_direction.z, 0.0, guard_direction.x) * 0.8
		var points := [guard_position + Vector3.UP * 0.2 + side,
			guard_position + Vector3.UP * 0.2 + guard_direction * 2.1,
			guard_position + Vector3.UP * 0.2 - side]
		var center: Vector3 = (points[0] + points[1] + points[2]) / 3.0
		_telegraph_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		_telegraph_mesh.surface_set_color(Color("342735"))
		for point: Vector3 in points:
			_telegraph_mesh.surface_add_vertex(point)
		_telegraph_mesh.surface_set_color(Color(1.0, 0.36, 0.27))
		for point: Vector3 in points:
			_telegraph_mesh.surface_add_vertex(center.lerp(point, 0.86) + Vector3.UP * 0.006)
		_telegraph_mesh.surface_end()


func _draw_sweep_warning() -> void:
	var center := guard_position + Vector3.UP * 0.2
	_telegraph_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for inset: int in 2:
		_telegraph_mesh.surface_set_color(Color("342735") if inset == 0 else Color("e49c60"))
		var radius: float = GUARDIAN_SWEEP.WARNING_RADIUS - inset * 0.09
		var origin := center + Vector3.UP * (inset * 0.006)
		for segment: int in 18:
			var a: Vector3 = origin + GUARDIAN_SWEEP.direction_at(guard_direction, segment / 18.0) * radius
			var b: Vector3 = origin + GUARDIAN_SWEEP.direction_at(guard_direction, (segment+1) / 18.0) * radius
			for point: Vector3 in [origin, a, b]:
				_telegraph_mesh.surface_add_vertex(point)
	if guard_state == GuardState.LUNGE:
		var blade: Vector3 = GUARDIAN_SWEEP.direction_at(guard_direction, 1.0 - maxf(_guard_timer, 0.0) / .40)
		var side := Vector3(-blade.z, 0, blade.x)*.07
		var tip: Vector3 = center + blade * GUARDIAN_SWEEP.WARNING_RADIUS
		_telegraph_mesh.surface_set_color(Color("342735"))
		for point: Vector3 in [center+side, tip+side, tip-side, center+side, tip-side, center-side]:
			_telegraph_mesh.surface_add_vertex(point + Vector3.UP*.02)
	_telegraph_mesh.surface_end()


func _refresh_text() -> void:
	_update_socket_prompt()
	if _status_label == null:
		return
	if _deniz_story.active:
		_status_label.text = "Deniz · İlk Nefes"
		_hint_label.text = "Deniz pencereyi açar. Omuzları gevşer; uzun bir nefes verir."
		return
	match stage:
		Stage.PICKUP:
			_status_label.text = "Nefesin Eşiği"
			_hint_label.text = "Nefes seni bekliyor. Yaklaş; sürükleyerek yol al, kısa savuruşla atıl."
			if assisted_dash:
				_hint_label.text = "Sürükle: hareket. Atılmak için daha uzağa sürükle, yönü tut, bırak; yeniden dokun."
		Stage.VENT:
			_status_label.text = "KARGO BAĞLANDI  /  GEÇİCİ YUVA"
			_hint_label.text = "Açık halkada dur: Nefes iplikle yuvaya bağlanır. Hareket edince sana döner; bu son teslimat değil."
		Stage.GUARDIAN:
			_status_label.text = "Kıskaç · çözülen dikiş %d/2" % guard_hits
			if _guard_attack == GuardAttack.SWEEP and guard_state in [GuardState.TELEGRAPH, GuardState.LUNGE]:
				_hint_label.text = "İlk süpürme saptırılamaz. Yelpazeden çık; Kıskaç seni bekliyor." if not _sweep_lesson_done else "Yelpaze süpürülür. Dışına veya arkasına geç; bu saldırı saptırılamaz."
				return
			match guard_state:
				GuardState.EXPOSED:
					_hint_label.text = "Altın dikiş açıldı. Şimdi Kıskaç'a doğru kısa savuruşla atıl."
				GuardState.LUNGE:
					_hint_label.text = "Hamle başladı. Yoldan çekil veya doğru anda karşı atıl."
				GuardState.RECOVER:
					_hint_label.text = "Dikiş kapandı. Bir sonraki hamleyi oku."
				_:
					_hint_label.text = "Üçgen hamleyi gösterir. Kaç veya kısa karşı atıl; açılınca ona doğru atıl."
		Stage.ANCHORS:
			_status_label.text = "BAĞ NOKTALARI  /  %d/2" % anchor_count
			_hint_label.text = "İpliği önce üçgenli 1, sonra kareli 2 numaralı halkadan geçir; ipliği fazla germe."
		Stage.DELIVERY:
			_status_label.text = "SON YUVA  /  TESLİMAT"
			_hint_label.text = "Nefes yazan kapalı halkaya yaklaş; içindeyken parmağını kaldır ve bekle."
		Stage.COMPLETE:
			_status_label.text = "NEFES ULAŞTI"
			_hint_label.text = "Deniz pencereyi açıyor. [Pencere açılır; uzun bir nefes.]\nYeniden oynamak için R veya duraklat menüsünü kullan."
	if not _combat_feedback.message.is_empty():
		_hint_label.text = _combat_feedback.message
	if assisted_dash and _assist_direction.length_squared() > 0.5 and _assist_ready_left <= 0.0:
		_hint_label.text = "Atılma hazırlığı: yönü kısa süre tut. Geri çekerek iptal edebilirsin."
	if _assist_ready_left > 0.0:
		_hint_label.text = "Yön hazır. Bırak, sonra yeniden dokunarak atıl." if not _assist_released else "Yön hazır. Yeniden dokunarak atıl; hazırlık kısa süre geçerli."


func _update_socket_prompt() -> void:
	if _socket_label == null:
		return
	_socket_label.visible = stage == Stage.DELIVERY or stage == Stage.COMPLETE
	if stage == Stage.COMPLETE:
		_socket_label.text = "Nefes ulaştı"
		_socket_prompt_bucket = -1
	elif stage == Stage.DELIVERY:
		var bucket := clampi(int(_dwell / 0.9 * 10.0), 0, 10)
		if bucket != _socket_prompt_bucket:
			_socket_prompt_bucket = bucket
			_socket_label.text = "Son yuva · Nefes" if bucket == 0 else "Yerleşiyor · %d%%" % (bucket * 10)
	else:
		_socket_prompt_bucket = -1


func set_paused(value: bool) -> void:
	paused = value
	_delivery_audio.stream_paused = value
	_clear_contact()
	_pause_panel.visible = value
	_deniz_story.return_button.disabled = value
	if value:
		_resume_button.grab_focus()
	else:
		_resume_button.release_focus()
		if _deniz_story.active:
			_deniz_story.return_button.grab_focus()


func _set_reduce_motion(value: bool) -> void:
	reduce_motion = value
	_motion_box.set_pressed_no_signal(value)
	_sync_visuals(0.0)
	_save_preferences()


func _set_audio_enabled(value: bool) -> void:
	_delivery_audio.set_enabled(value)
	_audio_box.set_pressed_no_signal(value)
	_save_preferences()


func _save_preferences() -> void:
	_preferences.save_preferences(reduce_motion, _delivery_audio.enabled, assisted_dash)
	_update_settings_notice()


func _update_settings_notice() -> void:
	_settings_notice.text = "\n".join([_preferences.notice, _checkpoint_store.notice]).strip_edges()
	_settings_notice.visible = not _settings_notice.text.is_empty()


func _checkpoint_value() -> int:
	match stage:
		Stage.VENT: return 1
		Stage.GUARDIAN: return 2
		Stage.ANCHORS: return 3 + mini(anchor_count, 1)
		Stage.DELIVERY: return 5
		Stage.COMPLETE: return 6
	return 0


func _record_checkpoint() -> void:
	var point := _checkpoint_value()
	if not _checkpoint_ready or point == _checkpoint_attempt:
		return
	_checkpoint_attempt = point # Do not retry a failed disk write every frame.
	_checkpoint_store.save_checkpoint(point)
	_update_settings_notice()


func _restore_checkpoint(point: int) -> void:
	if point == 0:
		return
	has_cargo = point < 6
	stage = Stage.VENT if point == 1 else Stage.GUARDIAN
	player_position = PICKUP_POINT if point == 1 else VENT_POINT + Vector3.BACK * 1.2
	if point == 2:
		guard_state = GuardState.TELEGRAPH
		_guard_timer = 0.82
		_lock_guard_target()
	if point >= 3:
		guard_hits = 2
		guard_state = GuardState.CALM
		stage = Stage.ANCHORS
		anchor_count = 1 if point == 4 else 0
		player_position = ANCHOR_POINTS[0] if point == 4 else GUARD_POINT + Vector3.BACK
	if point >= 5:
		anchor_count = 2
		stage = Stage.DELIVERY if point == 5 else Stage.COMPLETE
		player_position = ANCHOR_POINTS[1] if point == 5 else SOCKET_POINT + Vector3.LEFT * 1.2
	if point == 6:
		_presentation.begin_delivery(true)
		_delivery_audio.triggered = true # Restoring a delivery must not replay its sound.
		_deniz_story.triggered = true
		_deniz_story.seen = true
		_deniz_story.clock = 9.0 # A restored completion does not replay the vignette.
	_camera_rig.snap(player_position, _facing_direction)
	_refresh_text()
	_sync_visuals(0.0)


func _clear_contact() -> void:
	_cancel_assisted_dash()
	_touch_index = -1
	_mouse_owned = false
	_orbit_owned = false
	_move_vector = Vector2.ZERO
	_contact_dash_used = false
	_dash_left = 0.0


func _set_assisted_dash(value: bool) -> void:
	_clear_contact()
	assisted_dash = value
	_assist_box.set_pressed_no_signal(value)
	_update_control_instructions()
	_refresh_text()
	_save_preferences()


func _update_control_instructions() -> void:
	_control_instructions.text = ("Daha uzağa sürükle, 0,35 sn tut, bırak.\nSonraki dokunuş: atıl • Yönü geri çek: iptal" if assisted_dash else "Sürükle: hareket • Hızlı savur: atıl") + "\nWindows: WASD / oklar, Boşluk, Esc, R\nKamera: Q / E veya sağ fareyle sürükle"


func reset_game() -> void:
	_deniz_story.reset_story()
	_combat_feedback.reset()
	_delivery_audio.reset_delivery()
	_presentation.reset_delivery()
	stage = Stage.PICKUP
	guard_state = GuardState.IDLE
	guard_hits = 0
	anchor_count = 0
	has_cargo = false
	player_position = PLAYER_START
	guard_position = GUARD_POINT
	_guardian.scale = Vector3.ONE
	_guardian_shell_open = 0.0
	_guardian.rotation.y = atan2((player_position - guard_position).x, (player_position - guard_position).z)
	guard_direction = Vector3.LEFT
	_facing_direction = Vector3.RIGHT
	_player.rotation.y = atan2(_facing_direction.x, _facing_direction.z)
	_camera_rig.snap(player_position, _facing_direction)
	_guard_from = GUARD_POINT
	_guard_to = GUARD_POINT
	_guard_timer = 0.0
	_guard_lunge_hit = false
	_guard_attack = GuardAttack.CHARGE
	_sweep_lesson_done = false
	_sweep_lesson_elapsed = 0.0
	_dwell = 0.0
	_dash_cooldown = 0.0
	_dash_hit_this_dash = false
	_elapsed = 0.0
	_trail_clock = 0.0
	_trail_points.clear()
	_trail_times.clear()
	set_paused(false)
	_refresh_text()
	_sync_visuals(0.0)
	if _checkpoint_ready:
		_checkpoint_attempt = -1
		_record_checkpoint()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		set_paused(true)


func _capture_after_frames() -> void:
	for frame: int in 8:
		await RenderingServer.frame_post_draw
	if _capture_profile:
		var intervals: Array[float] = []
		var previous: int = Time.get_ticks_usec()
		for frame: int in 120:
			await RenderingServer.frame_post_draw
			var now: int = Time.get_ticks_usec()
			intervals.append(float(now - previous) / 1000.0)
			previous = now
		intervals.sort()
		var report := {
			"samples": intervals.size(), "median_frame_interval_ms": intervals[60],
			"p95_frame_interval_ms": intervals[113],
			"draw_calls_snapshot": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			"rendered_primitives_snapshot": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
			"note": "Windows wall-clock frame intervals include frame pacing; not GPU time or iOS evidence."
		}
		print("CAPTURE_PROFILE=" + JSON.stringify(report))
		var report_file := FileAccess.open(_capture_path + ".profile.json", FileAccess.WRITE)
		if report_file:
			report_file.store_string(JSON.stringify(report, "\t") + "\n")
	var image: Image = get_viewport().get_texture().get_image()
	var result: Error = image.save_png(_capture_path)
	if result != OK:
		push_error("Ekran görüntüsü kaydedilemedi: " + _capture_path)
	get_tree().quit(0 if result == OK else 1)
