extends Node3D

# Presentation only: no objective state, input, or collision changes.
const MEMBRANE_SHADER = preload("res://shaders/membrane.gdshader")
const ABYSS_SHADER = preload("res://shaders/abyss.gdshader")
const CONTACT_SHADER = preload("res://shaders/contact_shadow.gdshader")
const PATH_SHADER = preload("res://shaders/path_membrane.gdshader")
const STATIC_BATCH = preload("res://scripts/static_model_batch.gd")
var _hero_shadow: MeshInstance3D
var _guardian_shadow: MeshInstance3D
var _valve_light: OmniLight3D
var _delivery_materials: Array[ShaderMaterial] = []
var _delivery_colors: Array[Color] = []
var delivery_started: bool = false
var delivery_progress: float = 0.0
const DELIVERY_SECONDS := 1.8


func build(room: Node3D, hero: Node3D, cargo: Node3D, guardian: Node3D, arrival: Node3D = null) -> void:
	_apply_membranes(room)
	if arrival:
		_apply_membranes(arrival)
	_build_distant_chambers(room)
	_build_cellular_gate()
	# Experimental only: batching caused visible threat/detail regressions on Compatibility.
	# Normal gameplay stays unbatched until this passes a real visual comparison.
	if "--capture-batch-experiment" in OS.get_cmdline_user_args():
		STATIC_BATCH.combine(room, [MEMBRANE_SHADER], [], ["Branching_Underside_Rib"])
	for character: Node3D in [hero, cargo, guardian]:
		_soften_character(character)
	var abyss := MeshInstance3D.new()
	abyss.name = "DeepChamber"
	var plane := PlaneMesh.new()
	plane.size = Vector2(160.0, 160.0)
	abyss.mesh = plane
	abyss.position.y = -4.5
	abyss.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var abyss_material := ShaderMaterial.new()
	abyss_material.shader = ABYSS_SHADER
	abyss.material_override = abyss_material
	add_child(abyss)
	_hero_shadow = _make_shadow(Vector2(1.15, 0.8))
	_guardian_shadow = _make_shadow(Vector2(2.6, 1.35))
	# One warm destination light; room geometry supplies the surrounding scale.
	var valve_light := OmniLight3D.new()
	_valve_light = valve_light
	valve_light.position = Vector3(1.0, 3.7, -6.0)
	valve_light.light_color = Color("e8bd8b")
	valve_light.light_energy = 0.45
	valve_light.omni_range = 9.0
	valve_light.omni_attenuation = 1.6
	add_child(valve_light)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30.0, 135.0, 0.0)
	fill.light_color = Color("b1d2d4")
	fill.light_energy = 0.09
	add_child(fill)


func _build_cellular_gate() -> void:
	var packed := load("res://assets/models/cellular_gate.glb") as PackedScene
	if packed == null:
		push_error("Hücresel geçit modeli yüklenemedi")
		return
	var gate := packed.instantiate() as Node3D
	gate.name = "CellularGate"
	add_child(gate)
	_apply_gate_materials(gate)
	_build_gate_depth(gate)
	# Static backdrop beyond x=7; it neither extends the route nor changes objectives.


func _build_gate_depth(gate: Node3D) -> void:
	var depth := Node3D.new()
	depth.name = "CellularDepth"
	add_child(depth)
	var sources: Array[MeshInstance3D] = []
	_collect_gate_meshes(gate, sources)
	for index: int in 2:
		var layer := Node3D.new()
		layer.name = "Chamber%d" % index
		layer.position = Vector3(10.0 + index * 12.0, -0.8 - index * 0.5, 1.0 - index * 2.0)
		layer.scale = Vector3(1.0, 1.12 + index * 0.18, 1.10 + index * 0.12)
		depth.add_child(layer)
		var material := ShaderMaterial.new()
		material.shader = MEMBRANE_SHADER
		material.set_shader_parameter("base_color", Color("728e8c") if index == 0 else Color("476873"))
		material.set_shader_parameter("fiber_strength", 0.0)
		for source: MeshInstance3D in sources:
			# Drop membrane panels in the distance; last chamber uses only large silhouettes.
			if source.name.contains("Thin_Membrane") or (index == 1 and source.name.contains("Peach_Web")):
				continue
			var echo := MeshInstance3D.new()
			echo.name = source.name
			echo.mesh = source.mesh
			echo.transform = source.transform
			echo.material_override = material
			echo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			layer.add_child(echo)


func _collect_gate_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node as MeshInstance3D)
	for child: Node in node.get_children():
		_collect_gate_meshes(child, result)


func _apply_gate_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh := node as MeshInstance3D
		var material := ShaderMaterial.new()
		material.shader = MEMBRANE_SHADER
		var color := Color("d8b9a0")
		if node.name.contains("Peach_Web"):
			color = Color("ae796e")
		elif node.name.contains("Thin_Membrane"):
			color = Color("e1a486")
		material.set_shader_parameter("base_color", color)
		material.set_shader_parameter("fiber_strength", 0.006)
		mesh.material_override = material
		_delivery_materials.append(material)
		_delivery_colors.append(color)
	for child: Node in node.get_children():
		_apply_gate_materials(child)


func sync_positions(hero_position: Vector3, guardian_position: Vector3) -> void:
	_hero_shadow.position = Vector3(hero_position.x, 0.025, hero_position.z)
	_guardian_shadow.position = Vector3(guardian_position.x, 0.027, guardian_position.z)


func begin_delivery(reduced_motion: bool) -> void:
	if delivery_started:
		return
	delivery_started = true
	advance_delivery(0.0, reduced_motion)


func reset_delivery() -> void:
	delivery_started = false
	delivery_progress = 0.0
	_apply_delivery(0.0)


func advance_delivery(delta: float, reduced_motion: bool) -> void:
	if not delivery_started or delivery_progress >= 1.0:
		return
	delivery_progress = 1.0 if reduced_motion else minf(1.0, delivery_progress + maxf(delta, 0.0) / DELIVERY_SECONDS)
	# A bounded eased exhale, driven by the game's visual clock so pause freezes it.
	var eased := delivery_progress * delivery_progress * (3.0 - 2.0 * delivery_progress)
	_apply_delivery(eased)


func _apply_delivery(amount: float) -> void:
	for index: int in _delivery_materials.size():
		var original: Color = _delivery_colors[index]
		_delivery_materials[index].set_shader_parameter("base_color", original.lerp(Color("f1cfaa"), amount * 0.32))
	if _valve_light:
		_valve_light.light_energy = lerpf(0.45, 0.65, amount)
		_valve_light.light_color = Color("e8bd8b").lerp(Color("f4d9b5"), amount)


func _build_distant_chambers(node: Node) -> void:
	if node is MeshInstance3D and node.name.contains("Rear_Folded_Vault"):
		for row: int in 2:
			var echo := MeshInstance3D.new()
			echo.mesh = (node as MeshInstance3D).mesh
			echo.scale = Vector3(1.25, 1.0, 1.4)
			echo.position = Vector3(-3.0 if row == 0 else 4.0, -0.6, -6.0 - row * 6.0)
			echo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var material := ShaderMaterial.new()
			material.shader = MEMBRANE_SHADER
			material.set_shader_parameter("base_color", Color("42636b") if row == 0 else Color("324c57"))
			material.set_shader_parameter("fiber_strength", 0.0)
			echo.material_override = material
			add_child(echo)
	for child: Node in node.get_children():
		_build_distant_chambers(child)


func _apply_membranes(node: Node) -> void:
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		if instance.name == "Arrival_Tissue":
			# Huge background sheets must not bury the courier/telegraphs in a
			# flat directional shadow. Opaque surfaces still receive lighting.
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface: int in instance.mesh.get_surface_count():
			var imported := instance.get_active_material(surface) as StandardMaterial3D
			var membrane := ShaderMaterial.new()
			membrane.shader = MEMBRANE_SHADER
			var color := Color("c5a89b")
			if imported and imported.resource_name.contains("Coral"):
				color = Color("a87674")
			elif imported and imported.resource_name.contains("Teal"):
				color = Color("31555f")
			if instance.name.contains("Side_Fold"):
				color = Color("795865")
			if instance.name == "Arrival_Tissue":
				color = Color("d4a095")
			if instance.name.contains("Continuous_Playable_Membrane") or instance.name.contains("Causeway"):
				membrane.shader = PATH_SHADER
				color = Color("bf9990")
			membrane.set_shader_parameter("base_color", color)
			if membrane.shader == MEMBRANE_SHADER:
				membrane.set_shader_parameter("fiber_strength", 0.018 if instance.name == "Arrival_Tissue" else 0.003)
			instance.set_surface_override_material(surface, membrane)
	for child: Node in node.get_children():
		_apply_membranes(child)


func _soften_character(node: Node) -> void:
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		for surface: int in instance.mesh.get_surface_count():
			var original := instance.get_active_material(surface) as StandardMaterial3D
			if original:
				var satin := original.duplicate() as StandardMaterial3D
				satin.metallic = 0.0
				satin.roughness = maxf(satin.roughness, 0.68)
				satin.metallic_specular = 0.25
				satin.emission_enabled = false
				instance.set_surface_override_material(surface, satin)
	for child: Node in node.get_children():
		_soften_character(child)


func _make_shadow(size: Vector2) -> MeshInstance3D:
	var shadow := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	shadow.mesh = plane
	var material := ShaderMaterial.new()
	material.shader = CONTACT_SHADER
	shadow.material_override = material
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shadow)
	return shadow
