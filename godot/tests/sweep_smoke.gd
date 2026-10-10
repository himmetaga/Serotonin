extends SceneTree
const SWEEP = preload("res://scripts/guardian_sweep.gd")
var checks := 0
var failures: Array[String] = []
var impacts: Array[int] = [0, 0, 0]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var center := Vector3.ZERO
	var forward := Vector3.FORWARD
	var front := forward * 1.5
	_check(SWEEP.hits(front, front, center, forward, 0.0, 1.0), "duran hedef süpürülen alan içinde isabet alır")
	_check(not SWEEP.hits(-front, -front, center, forward, 0.0, 1.0), "arka taraf güvenlidir")
	_check(not SWEEP.hits(forward*3.0, forward*3.0, center, forward, 0.0, 1.0), "erişim dışında isabet yok")
	_check(not SWEEP.hits(front, front, center, forward, 0.0, 0.10), "henüz öne gelmeyen süpürme erken isabet üretmez")
	var outside_arc := forward.rotated(Vector3.UP, deg_to_rad(71.0))*1.8
	_check(not SWEEP.in_warning(outside_arc, center, forward) and not SWEEP.hits(outside_arc, outside_arc, center, forward, 0.0, 1.0), "uyarı açısı dışındaki duran oyuncuya kapsül taşmasıyla hasar gelmez")
	var flank := SWEEP.direction_at(forward, .15)*1.8
	_check(absf(flank.x) > .72 and SWEEP.hits(flank, flank, center, forward, 0.0, 1.0), "düz hamle koridorunun dışındaki yan konum süpürmede tehlikelidir")
	_check(SWEEP.hits(Vector3(-3,0,-1.5), Vector3(3,0,-1.5), center, forward, .4, .6), "tek karede alanı geçen hareket gözden kaçmaz")
	var game := (load("res://main.tscn") as PackedScene).instantiate()
	game._preferences_path = ""
	root.add_child(game)
	game.set_physics_process(false)
	game._delivery_audio.set_enabled(false)
	game.combat_impact.connect(_impact)
	_check_lesson(game)
	impacts.fill(0)
	# Synthetic FSM fixture; assisted_flow separately covers real progression.
	game.stage = game.Stage.GUARDIAN
	game.guard_hits = 1
	game.guard_state = game.GuardState.TELEGRAPH
	game._guard_timer = .82
	game.player_position = game.guard_position + Vector3.LEFT*1.5
	game._lock_guard_target()
	game._sweep_lesson_done = true # Mechanics fixture; lesson is tested separately below.
	_check(game._guard_attack == game.GuardAttack.SWEEP, "ilk dikişten sonra süpürme seçilir")
	var locked: Vector3 = game.guard_direction
	game.player_position += Vector3.BACK
	game._sync_visuals(0.0)
	_check(game.guard_direction == locked, "hazırlık yönü oyuncuyu sonradan takip etmez")
	var colors: PackedColorArray = game._telegraph_mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
	_check(colors.size() == 108 and colors[0].get_luminance() < colors[54].get_luminance()*.5, "yelpaze koyu sınır ve ayrı dolgu geometrisine sahiptir")
	game.player_position = game.guard_position + locked*1.5
	for frame: int in 50: game.simulate_step(1.0/60.0)
	_check(game.guard_state == game.GuardState.LUNGE, "hazırlık eyleme geçer")
	var timer_before: float = game._guard_timer
	game.set_paused(true)
	game.simulate_step(.3)
	_check(game._guard_timer == timer_before, "pause süpürme saatini dondurur")
	game.set_paused(false)
	game.reduce_motion = false
	game._sync_visuals(0.0)
	var pose_forward: Vector3 = Vector3(sin(game._guardian.rotation.y), 0, cos(game._guardian.rotation.y))
	_check(pose_forward.dot(SWEEP.direction_at(locked, 1.0 - game._guard_timer / .40)) > .999, "normal hareket saldırı pozu proxy açısını gecikmeden izler")
	game.reduce_motion = true
	game._sync_visuals(0.0)
	pose_forward = Vector3(sin(game._guardian.rotation.y), 0, cos(game._guardian.rotation.y))
	_check(pose_forward.dot(locked) > .999 and game._telegraph_mesh.get_surface_count() == 1, "azaltılmış hareket gövde dönüşünü kaldırır, saldırı alanı görünür kalır")
	var before: Vector3 = game.guard_position
	game._dash_direction = -locked
	game._dash_left = 1.0
	# Keep the player in the fan; direct FSM tick isolates damage/parry behavior.
	for frame: int in 25: game._tick_guardian(1.0/60.0, game.player_position)
	_check(game.guard_position == before, "süpürmede muhafız düz hamleye dönüşmez")
	_check(impacts[0] == 0 and impacts[2] == 1, "atılma süpürmeyi saptırmaz ve darbe olayı bir kez üretilir")
	_check(game.guard_state == game.GuardState.EXPOSED, "süpürme sonunda açık dikiş oluşur")
	game.reset_game()
	_check(game._guard_attack == game.GuardAttack.CHARGE, "restart ilk saldırıyı geri kurar")
	game.free()
	await create_timer(.1).timeout
	print("SWEEP %s: %d kontrol" % ["PASS" if failures.is_empty() else "FAIL", checks])
	quit(0 if failures.is_empty() else 1)


func _impact(kind: int, _direction: Vector3) -> void:
	impacts[kind-1] += 1


func _check_lesson(game: Node3D) -> void:
	game.stage = game.Stage.GUARDIAN
	game.guard_hits = 1
	game.guard_state = game.GuardState.TELEGRAPH
	game._guard_timer = .82
	game.player_position = game.guard_position + Vector3.LEFT*3.0
	game._lock_guard_target()
	for frame: int in 30: game.simulate_step(1.0/60.0)
	_check(not game._sweep_lesson_done and game._guard_timer == .82, "erken dışarıda olsa da yeni yelpaze en az1,2sn gösterilir")
	game.player_position = game.guard_position + Vector3.LEFT*1.5
	for frame: int in 180: game.simulate_step(1.0/60.0)
	_check(game.guard_state == game.GuardState.TELEGRAPH and game._guard_timer == .82 and impacts[2] == 0, "ilk gösterimde alan içinde beklemek darbe veya saldırı üretmez")
	var elapsed_before: float = game._sweep_lesson_elapsed
	game.set_paused(true)
	game.simulate_step(.5)
	_check(game._sweep_lesson_elapsed == elapsed_before, "pause öğretim saatini de dondurur")
	game.set_paused(false)
	# Only movement releases the gate; do not set its flags/timer to bypass it.
	for frame: int in 30: game.simulate_step(1.0/60.0, Vector2.DOWN)
	_check(game._sweep_lesson_done and game._guard_timer == .82, "normal yürüyüşle sınırdan çıkınca tam hazırlık penceresi başlar")
	game.player_position = game.guard_position + game.guard_direction*1.5
	for frame: int in 75: game.simulate_step(1.0/60.0)
	_check(game.guard_state == game.GuardState.EXPOSED and impacts[2] == 1, "öğretimden sonra geri girilirse normal saldırı geçerli, tekrar öğretim yok")
	game.reset_game()
	_check(not game._sweep_lesson_done and game._sweep_lesson_elapsed == 0.0, "baştan başla öğretimi yeniden hazırlar")


func _check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures.append(description)
		push_error(description)
