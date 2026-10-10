extends SceneTree

const DT := 1.0 / 60.0
const ORIGIN := Vector2(420, 320)
var game: Node3D
var failures: Array[String] = []
var checks := 0
var simulated_seconds := 0.0
var damage_count := 0
var dash_count := 0
var save_flow := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	game = (load("res://main.tscn") as PackedScene).instantiate()
	game._preferences_path = ""
	root.add_child(game)
	game.set_physics_process(false)
	save_flow = "--flow-save" in OS.get_cmdline_user_args()
	if save_flow:
		game._checkpoint_store.path = "res://../art/previews/checkpoint-flow-qa.json"
		game.reset_game()
	game._set_assisted_dash(true)
	game._set_reduce_motion(not "--flow-motion" in OS.get_cmdline_user_args())
	game._set_audio_enabled(false)
	game.combat_impact.connect(_on_impact)
	if not _walk_to(game.PICKUP_POINT):
		await _finish()
		return
	_check(game.stage == game.Stage.VENT and game.has_cargo, "dokunma hareketiyle kargo alınır")
	_check_saved(1)
	if not _walk_to(game.VENT_POINT):
		await _finish()
		return
	_wait(0.82)
	_check(game.stage == game.Stage.GUARDIAN, "bırakıp bekleme geçidi açar")
	_check_saved(2)
	for hit: int in 2:
		if not _walk_to(Vector3(-1.5, 0.0, 2.5)):
			break
		var timeout := 0.0
		while game.guard_state != game.GuardState.EXPOSED and timeout < 3.0:
			_step()
			timeout += DT
		_check(game.guard_state == game.GuardState.EXPOSED, "hamle kaçırılınca gerçek açıklık %d" % hit)
		_check(game._guard_attack == (game.GuardAttack.CHARGE if hit == 0 else game.GuardAttack.SWEEP), "gerçek akışta beklenen saldırı türü %d" % hit)
		var direction: Vector3 = (game.guard_position - game.player_position).normalized()
		_press()
		_drag_world(direction, 165.0)
		_wait(0.37)
		_check(game._assist_ready_left > 0.0 and game._dash_left == 0.0, "açıklık sırasında yalnız yardımcı hazırlık %d" % hit)
		_release()
		_check(game._dash_left == 0.0, "bırakmak savaşta da saldırı değildir %d" % hit)
		_press()
		_check(game._dash_left > 0.0, "ayrı onay dokunuşu atılır %d" % hit)
		if game._dash_left > 0.0:
			dash_count += 1
		_wait(0.22)
		_release()
		_check(game.guard_hits == hit + 1, "yardımcı atılma açık dikişe isabet eder %d" % hit)
	_check(game.stage == game.Stage.ANCHORS, "iki gerçek isabet bağ aşamasını açar")
	_check_saved(3)
	if game.stage == game.Stage.ANCHORS:
		_walk_to(game.ANCHOR_POINTS[0])
		_check(game.anchor_count == 1, "ilk bağ yürüyerek kurulur")
		_check_saved(4)
		_walk_to(game.ANCHOR_POINTS[1])
		_check(game.stage == game.Stage.DELIVERY, "ikinci bağ yürüyerek açılır")
		_check_saved(5)
		_walk_to(game.SOCKET_POINT)
		_wait(0.92)
		_check(game.stage == game.Stage.COMPLETE and not game.has_cargo, "dokunma akışıyla gerçek teslimat tamamlanır")
		_check_saved(6)
	_check(damage_count == 0, "rota muhafız hamlelerinden darbe almadan kaçınır")
	_check(dash_count == 2, "akışta yalnız iki bilinçli atılma var")
	await _finish()


func _check_saved(point: int) -> void:
	if save_flow:
		_check(game._checkpoint_store.load_checkpoint() == point, "gerçek aşama geçişi checkpoint yazdı %d" % point)


func _walk_to(target: Vector3) -> bool:
	_press()
	var timeout := 0.0
	while game.player_position.distance_to(target) > 0.22 and timeout < 6.0:
		_drag_world((target - game.player_position).normalized(), 75.0)
		_step()
		timeout += DT
	_release()
	var reached: bool = game.player_position.distance_to(target) <= 0.22
	_check(reached, "dokunmayla rota noktasına ulaşılır %s" % target)
	_check(game._assist_ready_left == 0.0 and game._dash_left == 0.0, "normal yürüyüş atılma hazırlamaz")
	return reached and game._assist_ready_left == 0.0 and game._dash_left == 0.0


func _press() -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = ORIGIN
	event.pressed = true
	game._unhandled_input(event)


func _release() -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = ORIGIN
	event.pressed = false
	game._input(event)


func _drag_world(direction: Vector3, pixels: float) -> void:
	var right: Vector3 = game._camera_rig.screen_to_world(Vector2.RIGHT)
	var down: Vector3 = game._camera_rig.screen_to_world(Vector2.DOWN)
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = ORIGIN + Vector2(direction.dot(right), direction.dot(down)) * pixels
	game._unhandled_input(event)


func _step(delta: float = DT) -> void:
	var movement: Vector3 = game._camera_rig.screen_to_world(game._move_vector)
	game.simulate_step(delta, Vector2(movement.x, movement.z))
	game._sync_visuals(delta)
	simulated_seconds += delta


func _wait(seconds: float) -> void:
	var left := seconds
	while left > 0.00001:
		var dt := minf(left, DT)
		_step(dt)
		left -= dt


func _on_impact(kind: int, _direction: Vector3) -> void:
	if kind == game.COMBAT_FEEDBACK.Kind.PLAYER_HIT:
		damage_count += 1


func _check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures.append(description)
		push_error("ASSISTED FLOW FAIL: " + description)


func _finish() -> void:
	game.free()
	await create_timer(0.10).timeout
	print("ASSISTED FLOW %s: %d kontrol, %.2f sim saniye, %d onaylı atılma, %d darbe" % ["PASS" if failures.is_empty() else "FAIL", checks, simulated_seconds, dash_count, damage_count])
	quit(0 if failures.is_empty() else 1)
