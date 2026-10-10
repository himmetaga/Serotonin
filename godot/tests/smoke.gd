extends SceneTree

const GAME_SCENE := "res://main.tscn"
const MODEL_PATHS := ["res://assets/models/ilmek.glb", "res://assets/models/nefes.glb", "res://assets/models/kiskac.glb", "res://assets/models/membrane_room.glb", "res://assets/models/cellular_gate.glb", "res://assets/models/arrival_path.glb"]
var _failures: Array[String] = []
var _checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for path: String in MODEL_PATHS:
		_check(ResourceLoader.exists(path), "GLB mevcut: " + path)
		if ResourceLoader.exists(path):
			var resource: Resource = load(path)
			_check(resource is PackedScene, "GLB sahne: " + path)
			if resource is PackedScene:
				var instance: Node = (resource as PackedScene).instantiate()
				_check(instance is Node3D, "GLB 3D kök: " + path)
				_check(_count_meshes(instance) > 0, "GLB görünür ağ içerir: " + path)
				instance.free()
	var packed: PackedScene = load(GAME_SCENE) as PackedScene
	_check(packed != null, "ana sahne yüklenir")
	if packed == null:
		_finish()
		return
	var game: Node3D = packed.instantiate() as Node3D
	game._preferences_path = "" # Never change the user's preferences during a test.
	root.add_child(game)
	current_scene = game
	game.set_physics_process(false)
	var deliveries: Array[int] = [0]
	game.delivery_completed.connect(func() -> void: deliveries[0] += 1)
	_check(game.stage == game.Stage.PICKUP, "ilk aşama")
	_check(not game._socket_label.visible, "son yuva etiketi erken aşamada gizli")
	_check(_check_guardian_readability(game) == true, "dikiş test grubunun tamamı yürütüldü")
	_check(_check_combat_feedback(game) == true, "savaş geri bildirimi test grubunun tamamı yürütüldü")
	_check(_check_assisted_dash(game) == true, "yardımcı jest test grubu tamamlandı")
	var impacts: Array[int] = [0, 0, 0]
	game.combat_impact.connect(func(kind: int, _direction: Vector3) -> void: impacts[kind - 1] += 1)
	_check(game._socket_ring.mesh is TorusMesh and game._socket_ring.has_node("ContrastBorder"), "son yuva hacimli kapalı halka ve kontrast kenar kullanır")
	if _failures.is_empty():
		_check(game.get_node_or_null("Ilmek") != null, "İlmek model sahnede")
		_check(game.get_node_or_null("Nefes") != null, "Nefes model sahnede")
		_check(game.get_node_or_null("Kiskac") != null, "Kıskaç model sahnede")
		_check(game.get_node_or_null("Garden") != null, "bahçe model sahnede")
		_check(not game.get_node("Garden").has_node("StaticBatch"), "görsel regresyonlu oda birleştirmesi normal oyunda kapalı")
		var fascia: MeshInstance3D = game.get_node("Garden").find_child("Growing_Costal_Roots", true, false) as MeshInstance3D
		_check(fascia != null and fascia.mesh.get_surface_count() == 1, "dallanan kıyı kökleri tek materyal yüzeyiyle sahnede")
		if fascia:
			_check(not fascia.has_node("CameraOnlyCollision"), "dekoratif dış kuşak kamera engeli eklemez")
		var gate: Node = game._presentation.get_node_or_null("CellularGate")
		_check(gate != null and _count_meshes(gate) == 3, "hücresel geçit üç materyal grubuyla sahnede")
		var ribs: Node = game._presentation.find_child("Ivory_Ribs", true, false)
		_check(ribs != null and ribs.has_node("CameraOnlyCollision"), "geçidin ana kaburgalarında kamera engeli var")
		_check(game.get_node("Garden").find_child("Side_Fold_R", true, false) == null, "değiştirilen opak duvar ve görünmez engeli kaldırıldı")
		var depth: Node = game._presentation.get_node_or_null("CellularDepth")
		_check(depth != null and _count_meshes(depth) == 3, "uzak odalar yalnız üç görünür ağ ekler")
		if depth:
			_check(depth.find_child("CameraOnlyCollision", true, false) == null, "dekoratif derinlik hareket ve kamera engeli eklemez")
		var floor_mesh: MeshInstance3D = game.get_node("Garden").find_child("Continuous_Playable_Membrane", true, false) as MeshInstance3D
		var floor_material: ShaderMaterial = floor_mesh.get_surface_override_material(0) as ShaderMaterial if floor_mesh else null
		_check(floor_material != null and floor_material.shader == game._presentation.PATH_SHADER, "zemin özel düşük kontrastlı lif materyalini kullanır")
		_check(_floor_supports_grid(floor_mesh), "435 hareket alanı örneği gerçek zemin üçgenleri üzerinde Y=0 seviyesinde")
		var arrival_floor: MeshInstance3D = game.get_node("Arrival").find_child("Arrival_Causeway", true, false) as MeshInstance3D
		var tissue: MeshInstance3D = game.get_node("Arrival").find_child("Arrival_Tissue", true, false) as MeshInstance3D
		_check(tissue != null and tissue.mesh.get_surface_count() == 1, "doku odası tek materyal yüzeyiyle sahnede")
		_check(tissue != null and tissue.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "büyük dekoratif zar karakteri gölgeyle kapatmaz")
		_check(_floor_supports_grid(arrival_floor, -14.0, 15, 0.0, 5, floor_mesh), "giriş ve arena birleşiminde75 nokta düz desteklenir")
		_check(_floor_supports_grid(arrival_floor, -7.35, 1, 0.0, 5, floor_mesh), "tam ortak kıyı sınırında beş nokta desteksiz kalmaz")
		_check(game.get_node("Garden").find_child("Side_Fold_L", true, false) == null, "girişte opak yan kıvrım ve görünmez kamera engeli yok")
		_check(game._clamp_playable_position(Vector3(-12,0,3.5)) == Vector3(-12,0,2), "girişin yanındaki boşluğa gidilemez")
		_check(game._clamp_playable_position(Vector3(-12,0,1)) == Vector3(-12,0,1), "yeni başlangıç giriş hareket alanında")
		game.stage = game.Stage.GUARDIAN
		game.guard_state = game.GuardState.TELEGRAPH
		game._sync_visuals(0.0)
		var telegraph_arrays: Array = game._telegraph_mesh.surface_get_arrays(0)
		var telegraph_colors: PackedColorArray = telegraph_arrays[Mesh.ARRAY_COLOR]
		_check(telegraph_colors.size() == 6 and telegraph_colors[0].get_luminance() < telegraph_colors[3].get_luminance() * 0.5, "saldırı üçgeninin renk dışı koyu sınırı var")
		game.reset_game()
	game._restore_checkpoint(2)
	_check(game._vent_ring.visible and is_equal_approx(game._vent_ring.scale.x, 1.4) and game.has_cargo, "checkpoint2 açılmış geçici bağ ve geri alınmış kargoyu kurar")
	game.reset_game()
	_check(not game._vent_ring.visible and not game._vent_label.visible and game._vent_ring.scale == Vector3.ONE, "restart geçici bağ görünümünü sıfırlar")
	game.set_paused(true)
	var before_pause: Vector3 = game.player_position
	_advance(game, 0.5, Vector2.RIGHT)
	_check(game.player_position == before_pause, "duraklatma fiziği durdurur")
	game.set_paused(false)
	game.player_position = game.PICKUP_POINT
	game.simulate_step(0.02)
	_check(game.stage == game.Stage.VENT and game.has_cargo, "kargo alınır")
	game.player_position = game.VENT_POINT
	_advance(game, 0.4)
	game._sync_visuals(0.0)
	_check(game.stage == game.Stage.VENT and game.has_cargo, "geçici bağ dolarken kargo sahipliği korunur")
	_check(game._cargo.position.is_equal_approx(game.VENT_POINT + Vector3.UP * game.VENT_CARGO_HEIGHT), "dolumda Nefes yuvaya fiziksel olarak bağlanır")
	_check(game._tether_mesh.get_surface_count() == 1, "geçici bağlantının iplik çizgisi var")
	_check(game._vent_label.visible and game._vent_label.text == "Nefes · 50%", "geçici bağlantının renk dışı ilerlemesi var")
	_check(game._vent_ring.scale.x > 1.15 and game._vent_ring.scale.x < 1.25, "geçici halka dolumla ölçülü genişler")
	var vent_reduced_before: bool = game.reduce_motion
	game.reduce_motion = true
	game._sync_visuals(0.0)
	_check(game._cargo.position.is_equal_approx(game.VENT_POINT + Vector3.UP * game.VENT_CARGO_HEIGHT) and game._vent_label.text == "Nefes · 50%", "azaltılmış harekette bağlanma ve ilerleme bilgisi korunur")
	game.reduce_motion = vent_reduced_before
	game.set_paused(true)
	var dock_position: Vector3 = game._cargo.position
	var dock_dwell: float = game._dwell
	_advance(game, 0.3)
	game._sync_visuals(0.3)
	_check(game._dwell == dock_dwell and game._cargo.position == dock_position, "pause geçici bağın konum ve dolumunu dondurur")
	game.set_paused(false)
	game.simulate_step(0.02, Vector2.LEFT)
	game._sync_visuals(0.02)
	_check(game._dwell == 0.0 and game._tether_mesh.get_surface_count() == 0, "hareket geçici dolumu ve iplik bağını iptal eder")
	_check(game.has_cargo and game._cargo.position.distance_to(game.player_position) < 1.2, "iptalde Nefes kuryeye döner")
	game.player_position = game.VENT_POINT
	_advance(game, 0.81)
	game._sync_visuals(0.0)
	_check(game.stage == game.Stage.GUARDIAN and game.has_cargo, "yuva beklemesi kargoyu korur")
	_check(game._vent_ring.visible and is_equal_approx(game._vent_ring.scale.x, 1.4), "akımın açılması geçici halka üzerinde kalır")
	_check(game._vent_label.text == "Akım açık · Nefes sende" and game._tether_mesh.get_surface_count() == 0, "başarılı bağlantıdan sonra Nefes geri alınır")
	game.player_position = game.SOCKET_POINT
	_advance(game, 0.02)
	_check(game.stage == game.Stage.GUARDIAN, "erken teslimat engellenir")
	# Run the actual telegraph/lunge/exposure loop and cross the guardian during a dash.
	for hit_index: int in 2:
		game.player_position = Vector3(-1.0, 0.0, 0.0)
		if hit_index == 1:
			game.player_position = game.guard_position + Vector3.BACK * 3.0
			_advance(game, 1.25) # Safely leave the first sweep lesson before its normal wind-up.
		_advance(game, 0.83)
		_advance(game, 0.41)
		_check(game.guard_state == game.GuardState.EXPOSED, "hamle sonrası açık dikiş %d" % hit_index)
		game._sync_visuals(0.0)
		_check(game._guardian_seam.visible, "gerçek hamle döngüsü dikişi gösterir %d" % hit_index)
		game.player_position = game.guard_position + Vector3(-1.0, 0.0, 0.0)
		_check(game.start_dash(Vector3.RIGHT), "atılma başlar %d" % hit_index)
		_advance(game, 0.10)
		_check(game.guard_hits == hit_index + 1, "açık dikişe isabet %d" % hit_index)
		_check(impacts[1] == hit_index + 1, "dikiş isabeti yalnız bir geri bildirim olayı üretir %d" % hit_index)
		game._sync_visuals(0.0)
		_check(not game._guardian_seam.visible, "isabet veya sakinleşme dikişi kapatır %d" % hit_index)
		if hit_index == 0:
			_advance(game, 0.70)
	_check(game.stage == game.Stage.ANCHORS, "iki vuruş bağı açar")
	game.player_position = game.ANCHOR_POINTS[0]
	_advance(game, 0.02)
	_check(game.anchor_count == 1, "ilk bağ kurulur")
	game.player_position = Vector3(7.0, 0.0, 3.5)
	_advance(game, 0.02)
	_check(game.player_position.distance_to(game.ANCHOR_POINTS[0]) <= 5.001, "iplik uzunluğu 5 m")
	game.player_position = game.ANCHOR_POINTS[1]
	_advance(game, 0.02)
	_check(game.stage == game.Stage.DELIVERY, "ikinci bağ teslimatı açar")
	_check(game._socket_label.visible and game._socket_label.text == "Son yuva · Nefes", "bağlar tamamlanınca teslimat hedefi adıyla görünür")
	game.player_position = game.SOCKET_POINT
	_advance(game, 0.46)
	_check(game.stage == game.Stage.DELIVERY and game._socket_label.text == "Yerleşiyor · 50%", "teslimat beklemesi renk dışı yüzdeyle gösterilir")
	game.player_position = game.SOCKET_POINT + Vector3.LEFT * 1.5
	game.simulate_step(0.02)
	_check(game._dwell == 0.0 and game._socket_label.text == "Son yuva · Nefes", "yuvadan ayrılmak beklemeyi ve yüzdeyi sıfırlar")
	game.player_position = game.SOCKET_POINT
	_advance(game, 0.91)
	_check(game.stage == game.Stage.COMPLETE and not game.has_cargo, "teslimat kargoyu tüketir")
	_check(game._socket_label.text == "Nefes ulaştı", "teslimat sonunda hedef etiketi sonuç durumuna geçer")
	_check(deliveries[0] == 1 and game._presentation.delivery_started, "teslimat çevre tepkisini bir kez başlatır")
	var rib_transform: Transform3D = game._presentation.find_child("Ivory_Ribs", true, false).transform
	game._sync_visuals(0.45)
	_check(game._presentation.delivery_progress > 0.0 and game._presentation.delivery_progress < 1.0, "teslimat tepkisi zaman içinde ilerler")
	_check(game._cargo.visible and game._cargo.position.is_equal_approx(game.SOCKET_POINT + Vector3.UP * game.DELIVERED_CARGO_HEIGHT), "teslim edilmiş Nefes son yuvada kalır")
	_check(game._cargo.scale.x > 1.0, "Nefes teslimatta kısa bir genleşme verir")
	var delivery_before_pause: float = game._presentation.delivery_progress
	game.set_paused(true)
	game._sync_visuals(0.5)
	_check(is_equal_approx(game._presentation.delivery_progress, delivery_before_pause), "duraklatma teslimat hareketini dondurur")
	game.set_paused(false)
	game._presentation.begin_delivery(false)
	_check(is_equal_approx(game._presentation.delivery_progress, delivery_before_pause), "yinelenen teslimat olayı tepkiyi yeniden başlatmaz")
	game._sync_visuals(2.0)
	_check(is_equal_approx(game._presentation.delivery_progress, 1.0) and game._cargo.scale.is_equal_approx(Vector3.ONE), "genleşme biter ve kargo normal ölçeğine döner")
	_check(game._presentation._valve_light.light_energy > 0.45, "teslimatın kalıcı ışık sonucu var")
	_check(game._presentation.find_child("Ivory_Ribs", true, false).transform == rib_transform, "teslimat kamera engeli taşıyan kaburgaları oynatmaz")
	game.simulate_step(1.0)
	_check(deliveries[0] == 1, "tamamlanmış aşama teslimat olayını tekrar üretmez")
	var settled_cargo_position: Vector3 = game._cargo.position
	var player_after_delivery: Vector3 = game.player_position
	_check(game._deniz_story.active and game._deniz_story.visible, "gerçek teslimat kısa gecikmeden sonra Deniz sahnesini açar")
	game._refresh_text()
	_check(game._status_label.text == "Deniz · İlk Nefes", "anlatı başlığı ayar/HUD yenilemesinde korunur")
	var opening_before: float = game._deniz_story.window_opening()
	game._sync_visuals(0.3)
	_check(game._deniz_story.window_opening() > opening_before, "normal harekette pencere açılışı zamanla ilerler")
	game.simulate_step(0.2, Vector2.LEFT)
	_check(game.player_position == player_after_delivery, "anlatı sahnesi sırasında görünmeyen yürüyüş engellenir")
	var story_clock: float = game._deniz_story.clock
	game.set_paused(true)
	game._sync_visuals(0.5)
	_check(game._deniz_story.clock == story_clock and game._deniz_story.return_button.disabled, "pause anlatı saatini ve dönüş düğmesini durdurur")
	game.set_paused(false)
	_check(game._deniz_story.return_button.has_focus(), "pause sonrası odak anlatı dönüşüne gelir")
	game.reduce_motion = true
	game._sync_visuals(0.0)
	_check(game._deniz_story.window_opening() == 1.0 and game._deniz_story.breath_lift() == 0.0, "azaltılmış hareket açık pencereyi hareketsiz gösterir")
	game._deniz_story.return_button.pressed.emit()
	game._on_delivery_story()
	game._sync_visuals(2.0)
	_check(not game._deniz_story.active and not game._deniz_story.visible, "dönüş düğmesi anlatıyı kapatır ve yinelenen olay yeniden açmaz")
	game.simulate_step(0.2, Vector2.LEFT)
	game._sync_visuals(0.2)
	_check(game.player_position.x < player_after_delivery.x and game._cargo.position == settled_cargo_position and not game.has_cargo, "teslimat sonrası yürünebilir ve kargo yuvada kalır")
	var settled_touch := InputEventScreenTouch.new()
	settled_touch.index = 0
	settled_touch.pressed = true
	settled_touch.position = Vector2(400.0, 300.0)
	game._unhandled_input(settled_touch)
	var settled_drag := InputEventScreenDrag.new()
	settled_drag.index = 0
	settled_drag.position = Vector2(450.0, 300.0)
	game._unhandled_input(settled_drag)
	_check(game._touch_index == 0 and game._move_vector.x > 0.0, "teslimat sonrası tek parmak hareket girdisi açık kalır")
	_check(not game.start_dash(Vector3.RIGHT), "teslimat sonrası savaş atılması kapalı kalır")
	game.reset_game()
	_check(not game._deniz_story.triggered and not game._deniz_story.visible, "restart anlatı durumunu temizler")
	_check(game.stage == game.Stage.PICKUP and game.guard_hits == 0 and game.anchor_count == 0 and not game.has_cargo, "yeniden başlatma tüm aşamaları sıfırlar")
	_check(not game._socket_label.visible and game._socket_prompt_bucket == -1, "yeniden başlatma son yuva etiketini kapatır")
	_check(not game._presentation.delivery_started and is_zero_approx(game._presentation.delivery_progress) and is_equal_approx(game._presentation._valve_light.light_energy, 0.45) and game._socket_ring.scale.is_equal_approx(Vector3.ONE), "yeniden başlatma ışık ve teslimat tepkisini sıfırlar")
	# Focused accessibility case: deliver, then enable reduced motion mid-response.
	game.stage = game.Stage.DELIVERY
	game.has_cargo = true
	game.player_position = game.SOCKET_POINT
	_advance(game, 0.91)
	game._sync_visuals(0.2)
	game._set_reduce_motion(true)
	_check(is_equal_approx(game._presentation.delivery_progress, 1.0) and game._cargo.scale.is_equal_approx(Vector3.ONE), "azaltılmış hareket geçiş ortasında animasyonsuz sonuca ulaşır")
	game.reset_game()
	game.stage = game.Stage.DELIVERY
	game.has_cargo = true
	game.player_position = game.SOCKET_POINT
	_advance(game, 0.91)
	_check(is_equal_approx(game._presentation.delivery_progress, 1.0), "azaltılmış hareket açıkken teslimat sonucu hemen görünür")
	game.reset_game()
	game._set_reduce_motion(false)
	var first_touch := InputEventScreenTouch.new()
	first_touch.index = 3
	first_touch.position = Vector2(400.0, 300.0)
	first_touch.pressed = true
	game._unhandled_input(first_touch)
	var other_touch := InputEventScreenTouch.new()
	other_touch.index = 4
	other_touch.position = Vector2(500.0, 300.0)
	other_touch.pressed = true
	game._unhandled_input(other_touch)
	var wrong_drag := InputEventScreenDrag.new()
	wrong_drag.index = 4
	wrong_drag.position = Vector2(700.0, 300.0)
	game._unhandled_input(wrong_drag)
	_check(game._touch_index == 3 and game._move_vector == Vector2.ZERO, "ilk parmak sahipliği")
	var fast_drag := InputEventScreenDrag.new()
	fast_drag.index = 3
	fast_drag.position = Vector2(520.0, 300.0)
	game._unhandled_input(fast_drag)
	_check(game._dash_left > 0.0 and game._contact_dash_used, "ilk hızlı savuruş bir atılma")
	game._dash_cooldown = 0.0
	game._dash_left = 0.0
	fast_drag.position = Vector2(650.0, 300.0)
	game._unhandled_input(fast_drag)
	_check(game._dash_left == 0.0, "aynı temasta ikinci atılma yok")
	other_touch.pressed = false
	game._input(other_touch)
	_check(game._touch_index == 3, "yabancı parmak kaldırması sahipliği korur")
	first_touch.pressed = false
	game._input(first_touch)
	_check(game._touch_index == -1 and game._move_vector == Vector2.ZERO and game._dash_left == 0.0, "parmak kalkınca yön sıfırlanır")
	game.set_paused(true)
	_check(game._touch_index == -1 and game._move_vector == Vector2.ZERO, "duraklatma girdiyi temizler")
	game.set_paused(false)
	game.simulate_step(1.0 / 60.0, Vector2.UP)
	_check(game._facing_direction.z < -0.9, "klavye yönü modeli döndürür")
	game._set_reduce_motion(true)
	game._sync_visuals(1.0 / 60.0)
	_check(is_equal_approx(game.get_node("Ilmek").position.y, 0.12), "azaltılmış hareket yükselmeyi kapatır")
	game.stage = game.Stage.GUARDIAN
	game.guard_state = game.GuardState.TELEGRAPH
	game.guard_position = Vector3(6.4, 0.0, 2.9)
	game.player_position = Vector3(7.0, 0.0, 3.5)
	game._guard_timer = 0.01
	game._lock_guard_target()
	_advance(game, 0.45)
	_check(game.guard_position.x <= 6.5 and game.guard_position.z <= 3.0, "muhafız arenada kalır")
	game.reset_game()
	game.stage = game.Stage.GUARDIAN
	game.guard_state = game.GuardState.LUNGE
	game.guard_position = Vector3(-0.79, 0.0, 0.0)
	game._guard_from = Vector3.ZERO
	game._guard_to = Vector3(-2.1, 0.0, 0.0)
	game._guard_timer = 0.25
	game._guard_lunge_hit = false
	game.guard_direction = Vector3.LEFT
	game.player_position = Vector3(-1.2, 0.0, 0.0)
	impacts.fill(0)
	game.start_dash(Vector3.RIGHT)
	_advance(game, 1.0 / 60.0)
	_check(game.guard_state == game.GuardState.EXPOSED, "dar karşıdan saptırma penceresi")
	_check(impacts[0] == 1 and impacts[1] == 0 and impacts[2] == 0, "saptırma isabetten ayrı tek olay üretir")
	game.reset_game()
	game.stage = game.Stage.GUARDIAN
	game.guard_state = game.GuardState.LUNGE
	game.guard_position = Vector3(-1.84, 0.0, 0.0)
	game._guard_from = Vector3.ZERO
	game._guard_to = Vector3(-2.1, 0.0, 0.0)
	game._guard_timer = 0.05
	game._guard_lunge_hit = false
	game.guard_direction = Vector3.LEFT
	game.player_position = Vector3(-2.25, 0.0, 0.0)
	game._touch_index = 3
	game.start_dash(Vector3.RIGHT)
	_advance(game, 0.02)
	_check(game._touch_index == -1 and game._dash_left == 0.0, "geç saptırma darbe olur ve girdi temizlenir")
	_check(impacts[2] == 1 and game._combat_feedback.kind == game.COMBAT_FEEDBACK.Kind.PLAYER_HIT, "geç saptırma oyuncu darbesi geri bildirimi üretir")
	await _check_third_person_camera(game)
	game.free()
	# Let the audio mixer retire stopped delivery playbacks before process exit.
	await create_timer(0.10).timeout
	_finish()


func _check_assisted_dash(game: Node3D) -> bool:
	game.reset_game()
	game._set_assisted_dash(true)
	_check(game._assist_box.button_pressed and game._control_instructions.text.contains("0,35"), "yardımcı jest menüsü tercih ve öğretimi gösterir")
	var touch := InputEventScreenTouch.new()
	touch.index = 7
	touch.position = Vector2(400, 300)
	touch.pressed = true
	game._unhandled_input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 7
	drag.position = Vector2(560, 300)
	game._unhandled_input(drag)
	_check(game._dash_left == 0.0, "yardımcı modda hızlı savuruş atılma üretmez")
	game._tick_assisted_dash(0.20)
	_check(game._assist_ready_left == 0.0, "kısa yön tutma hazırlık üretmez")
	game._tick_assisted_dash(0.16)
	_check(game._assist_ready_left > 0.0 and game._dash_left == 0.0, "yönü tutmak yalnız hazırlar")
	var armed: Vector3 = game._assist_armed
	var stranger := touch.duplicate() as InputEventScreenTouch
	stranger.index = 8
	stranger.pressed = false
	game._input(stranger)
	_check(not game._assist_released and game._touch_index == 7, "yabancı parmak hazırlığı onaylayamaz")
	touch.pressed = false
	game._input(touch)
	_check(game._assist_released and game._dash_left == 0.0 and game._move_vector == Vector2.ZERO, "parmağı bırakmak atılmaz yalnız hazırlığı korur")
	touch.pressed = true
	game._unhandled_input(touch)
	_check(game._dash_left > 0.0 and game._dash_direction.is_equal_approx(armed) and game._contact_dash_used, "sonraki ayrı dokunuş seçilen kamera göreli yöne atılır")
	game._unhandled_input(drag)
	game._tick_assisted_dash(1.0)
	_check(game._assist_ready_left == 0.0, "aynı onay temasında ikinci atılma hazırlanmaz")
	game.reset_game()
	_check(game.assisted_dash and game._assist_ready_left == 0.0, "reset tercihi korur hazırlığı temizler")
	game._unhandled_input(touch)
	game._unhandled_input(drag)
	game._tick_assisted_dash(0.36)
	drag.position = touch.position
	game._unhandled_input(drag)
	_check(game._assist_ready_left == 0.0 and game._dash_left == 0.0, "yönü merkeze geri çekmek hazırlığı iptal eder")
	drag.position = Vector2(560, 300)
	game._unhandled_input(drag)
	game._tick_assisted_dash(0.36)
	touch.pressed = false
	game._input(touch)
	game._tick_assisted_dash(2.01)
	_check(game._assist_ready_left == 0.0 and not game._assist_released, "hazırlık iki saniyede zaman aşımına uğrar")
	touch.pressed = true
	game._unhandled_input(touch)
	_check(game._dash_left == 0.0, "zaman aşımından sonraki dokunuş atılma değildir")
	game._unhandled_input(drag)
	game._tick_assisted_dash(0.36)
	game.set_paused(true)
	_check(game._assist_ready_left == 0.0 and game._touch_index == -1, "menü ve pause hazırlığı iptal eder")
	game.set_paused(false)
	game._unhandled_input(touch)
	game._unhandled_input(drag)
	game._tick_assisted_dash(0.36)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(game.paused and game._assist_ready_left == 0.0, "odak kaybı yardımcı hazırlığı iptal eder")
	game.reset_game()
	game._set_assisted_dash(false)
	_check(not game._assist_box.button_pressed and game._control_instructions.text.contains("Hızlı savur"), "varsayılan savuruş moduna dönülebilir")
	return true


func _check_combat_feedback(game: Node3D) -> bool:
	game.reset_game()
	game.reduce_motion = false
	var feedback = game._combat_feedback
	var simulated_guard: Vector3 = game.guard_position
	game.combat_impact.emit(game.COMBAT_FEEDBACK.Kind.SEAM_HIT, Vector3.RIGHT)
	game._sync_visuals(0.0)
	_check(game._guardian.position.x > simulated_guard.x and game.guard_position == simulated_guard, "isabet geri esnemesi yalnız görünür modele uygulanır")
	_check(game._hint_label.text.contains("Dikişi çözdün"), "isabetin renk ve ses dışı yazılı karşılığı var")
	var strength: float = feedback.envelope()
	game.set_paused(true)
	game._sync_visuals(0.5)
	_check(is_equal_approx(feedback.envelope(), strength), "pause darbe tepkisini dondurur")
	game.set_paused(false)
	game._sync_visuals(0.10)
	_check(feedback.envelope() > 0.0 and feedback.envelope() < strength, "geri esneme kısa eğriyle sönümlenir")
	game._sync_visuals(0.10)
	_check(is_equal_approx(game._guardian.position.x, simulated_guard.x) and not feedback.message.is_empty(), "hareket biterken kısa olay mesajı okunabilir kalır")
	game._sync_visuals(0.50)
	_check(feedback.kind == game.COMBAT_FEEDBACK.Kind.NONE and game._hint_label.text.contains("Nefes seni bekliyor"), "tepki bitince normal görev ipucu geri gelir")
	game.combat_impact.emit(game.COMBAT_FEEDBACK.Kind.PARRY, Vector3.LEFT)
	game._sync_visuals(0.0)
	_check(game._player.scale.y > 1.0 and game._hint_label.text.contains("Saptırdın"), "saptırma ayrı dikleşme pozu ve mesaj taşır")
	game.combat_impact.emit(game.COMBAT_FEEDBACK.Kind.PLAYER_HIT, Vector3.LEFT)
	game._sync_visuals(0.0)
	_check(game._player.scale.y < 1.0 and game._player.position.x < game.player_position.x, "oyuncu darbesi ayrı toparlanma pozu taşır")
	_check(game._hint_label.text.contains("kargon güvende"), "oyuncu darbesi sonucunu açıklar")
	game._set_reduce_motion(true)
	_check(game._player.scale == Vector3.ONE and is_equal_approx(game._player.position.x, game.player_position.x) and game._hint_label.text.contains("Darbe aldın"), "azaltılmış harekette pose kapalı bilgi korunur")
	game._set_reduce_motion(false)
	var player_before: Vector3 = game.player_position
	game.simulate_step(0.05, Vector2.RIGHT)
	_check(game.player_position.x > player_before.x, "tepki boyunca oyuncu hareketi kilitlenmez")
	game.reset_game()
	_check(feedback.kind == game.COMBAT_FEEDBACK.Kind.NONE and feedback.message.is_empty() and game._player.scale == Vector3.ONE, "reset tepki ve karakter ölçeğini temizler")
	return true


func _check_guardian_readability(game: Node3D) -> bool:
	_check(game._guardian_seam != null, "altın dikiş GLB'de ayrı semantik parça")
	if game._guardian_seam == null:
		return false
	_check(not game._guardian_seam.visible, "açık dikiş görev öncesinde gizli")
	_check(game._guardian_shells.size() == 2, "GLB iki bağımsız kapalı kabuk parçası içerir")
	game.stage = game.Stage.GUARDIAN
	game.guard_position = Vector3.ZERO
	game.guard_direction = Vector3.LEFT
	game.player_position = Vector3(3.0, 0.0, 2.0)
	for state: int in [game.GuardState.TELEGRAPH, game.GuardState.LUNGE]:
		game.guard_state = state
		game._sync_visuals(1.0)
		_check(not game._guardian_seam.visible, "kapalı savaş evresinde dikiş gizli %d" % state)
		var facing := Vector3(sin(game._guardian.rotation.y), 0.0, cos(game._guardian.rotation.y))
		_check(facing.dot(game.guard_direction) > 0.99, "muhafız bakışı oyuncuyu değil kilitli hamleyi izler %d" % state)
	game._enter_exposed()
	game._sync_visuals(0.08)
	_check(game._guardian_seam.visible and game._guardian_seam.position.y > game._guardian_seam_rest.y, "karşılık penceresinde dikiş belirir ve yükselir")
	_check(game._guardian.scale.y < 1.0 and game._guardian.scale.x > 1.0, "açıklık pozu yalnız görünür modele uygulanır")
	_check(game._guardian_shell_open > 0.0 and game._guardian_shell_open < 1.0, "kabuk açılması kısa geçişle ilerler")
	if game._guardian_shells.size() == 2:
		_check(game._guardian_shells[0].position.x < game._guardian_shell_rest[0].x and game._guardian_shells[1].position.x > game._guardian_shell_rest[1].x, "kabuklar zıt yönde ayrılıp gerçek boşluk oluşturur")
	_check(is_equal_approx(game._guard_timer, 1.25) and game.guard_position == Vector3.ZERO, "görsel tepki açıklık süresi ve muhafız konumunu değiştirmez")
	_check(game._hint_label.text.contains("Altın dikiş"), "açıklık evresinin yazılı karşılığı var")
	var pose: Vector3 = game._guardian.scale
	var shell_open: float = game._guardian_shell_open
	game.set_paused(true)
	game._sync_visuals(0.5)
	_check(game._guardian.scale == pose, "pause görsel açıklık geçişini dondurur")
	_check(is_equal_approx(game._guardian_shell_open, shell_open), "pause kabuk açılmasını dondurur")
	game._set_reduce_motion(true)
	_check(game._guardian_seam.visible and game._guardian.scale.is_equal_approx(Vector3.ONE), "azaltılmış harekette dikiş bilgisi korunur ve genleşme kapanır")
	_check(is_equal_approx(game._guardian_shell_open, 1.0), "azaltılmış harekette kabuk animasyonsuz açık duruşa geçer")
	game.set_paused(false)
	game.player_position = Vector3(5.0, 0.0, 3.0)
	_advance(game, 1.26)
	game._sync_visuals(0.0)
	_check(game.guard_state == game.GuardState.RECOVER and not game._guardian_seam.visible, "pencere bitince dikiş kapanır")
	_check(is_zero_approx(game._guardian_shell_open), "azaltılmış harekette toparlanma kabuğu doğrudan kapatır")
	game._enter_exposed()
	game._sync_visuals(0.0)
	game.reset_game()
	_check(not game._guardian_seam.visible and game._guardian.scale.is_equal_approx(Vector3.ONE) and game._guardian_seam.position == game._guardian_seam_rest, "reset dikişi ve pozu sıfırlar")
	_check(is_zero_approx(game._guardian_shell_open), "reset kabuk açıklığını sıfırlar")
	for index: int in game._guardian_shells.size():
		_check(game._guardian_shells[index].position == game._guardian_shell_rest[index], "reset kabuk parçasını kaynağın kapalı konumuna getirir %d" % index)
	game._set_reduce_motion(false)
	game.stage = game.Stage.GUARDIAN
	game._enter_exposed()
	game._sync_visuals(0.25)
	_check(game._guardian_shell_open > 0.98, "normal harekette kabuk açık duruşa ulaşır")
	game.guard_state = game.GuardState.RECOVER
	game._sync_visuals(0.30)
	_check(game._guardian_shell_open < 0.01, "normal harekette kabuk tekrar kapalı duruşa yaklaşır")
	game.reset_game()
	return true


func _check_third_person_camera(game: Node3D) -> void:
	game.reset_game()
	var rig: Node3D = game._camera_rig
	_check(game._camera.projection == Camera3D.PROJECTION_PERSPECTIVE, "üçüncü şahıs perspektif")
	_check(game._camera.get_parent() is SpringArm3D, "kamera çarpışma kolunda")
	rig.snap(Vector3.ZERO, Vector3.RIGHT)
	_check(rig.screen_to_world(Vector2.UP).dot(Vector3.RIGHT) > 0.99, "ileri hareket kamera yönüne göre")
	_check(rig.screen_to_world(Vector2.RIGHT).dot(Vector3.BACK) > 0.99, "sağ hareket kamera yönüne göre")
	_check(is_equal_approx(rig.screen_to_world(Vector2(1.0, -1.0)).length(), 1.0), "kamera göreli çapraz hareket hızlanmaz")
	rig.orbit(-PI * 0.5)
	_check(rig.screen_to_world(Vector2.UP).dot(Vector3.BACK) > 0.99, "kamera dönünce hareket ekseni döner")
	game._begin_contact(Vector2.ZERO)
	game._update_contact(Vector2(0.0, -120.0))
	_check(game._dash_direction.dot(Vector3.BACK) > 0.99, "dokunmatik atılma kamera yönüne göre")
	game._clear_contact()
	rig.snap(Vector3.ZERO, Vector3.FORWARD)
	var stable_yaw: float = rig.yaw
	rig.advance(0.5, Vector3.ZERO, Vector3.RIGHT, true, false)
	_check(is_equal_approx(rig.yaw, stable_yaw), "hareket boyunca kamera yönü kararlı")
	rig.advance(1.0, Vector3.ZERO, Vector3.RIGHT, false, false)
	_check(rig.forward_direction().dot(Vector3.RIGHT) > 0.9, "durunca kamera karakterin arkasına döner")
	stable_yaw = rig.yaw
	rig.advance(1.0, Vector3.ZERO, Vector3.LEFT, false, true)
	_check(is_equal_approx(rig.yaw, stable_yaw), "azaltılmış hareket otomatik dönüşü kapatır")
	rig.snap(Vector3.ZERO, Vector3.FORWARD)
	await physics_frame
	await physics_frame
	await process_frame
	_check(rig._arm.get_hit_length() > 6.5, "açık alanda kamera mesafesi korunur")
	var blocker := StaticBody3D.new()
	blocker.collision_layer = rig.CAMERA_LAYER
	blocker.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 2.0, 1.0)
	shape.shape = box
	blocker.add_child(shape)
	root.add_child(blocker)
	blocker.global_position = rig._arm.global_position + rig._arm.global_basis.z * 3.0
	await physics_frame
	await physics_frame
	await process_frame
	_check(rig._arm.get_hit_length() > 0.0 and rig._arm.get_hit_length() < 3.5, "duvar arkasına geçmek yerine kamera içeri çekilir")
	blocker.free()
	await physics_frame
	await physics_frame
	await process_frame
	_check(rig._arm.get_hit_length() > 6.5, "engel kalkınca kamera mesafesi geri açılır")
	game.reset_game()


func _advance(game: Node3D, duration: float, movement: Vector2 = Vector2.ZERO) -> void:
	var remaining := duration
	while remaining > 0.000001:
		var step := minf(remaining, 1.0 / 60.0)
		game.simulate_step(step, movement)
		remaining -= step


func _floor_supports_grid(floor_mesh: MeshInstance3D, x_start: float = -7.0, x_count: int = 29, z_start: float = -3.5, z_count: int = 15, other_floor: MeshInstance3D = null) -> bool:
	if not floor_mesh or not floor_mesh.mesh:
		return false
	var faces := PackedVector3Array()
	for support: MeshInstance3D in [floor_mesh, other_floor]:
		if support and support.mesh:
			for point: Vector3 in support.mesh.get_faces():
				faces.append(support.to_global(point))
	if faces.is_empty():
		return false
	for x_index: int in x_count:
		for z_index: int in z_count:
			var origin := Vector3(x_start + x_index * 0.5, 2.0, z_start + z_index * 0.5)
			var supported := false
			for vertex: int in range(0, faces.size(), 3):
				var hit: Variant = Geometry3D.ray_intersects_triangle(origin, Vector3.DOWN, faces[vertex], faces[vertex + 1], faces[vertex + 2])
				if hit is Vector3 and absf(hit.y) < 0.001:
					supported = true
					break
			if not supported:
				push_error("Zemin desteği eksik: " + str(origin))
				return false
	return true


func _count_meshes(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child: Node in node.get_children():
		count += _count_meshes(child)
	return count


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
		push_error("SMOKE FAIL: " + description)


func _finish() -> void:
	if _failures.is_empty():
		print("SMOKE PASS: %d kontrol" % _checks)
		quit(0)
	else:
		print("SMOKE FAIL: %d/%d kontrol başarısız" % [_failures.size(), _checks])
		quit(1)
