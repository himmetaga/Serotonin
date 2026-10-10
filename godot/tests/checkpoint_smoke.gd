extends SceneTree

const STORE = preload("res://scripts/checkpoint_store.gd")
const PATH := "res://../art/previews/checkpoint-qa.json"
var checks := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game := (load("res://main.tscn") as PackedScene).instantiate()
	game._preferences_path = PATH + ".prefs"
	game._checkpoint_path = PATH
	root.add_child(game)
	game.set_physics_process(false)
	if "--checkpoint-write" in OS.get_cmdline_user_args():
		game._restore_checkpoint(6)
		game._record_checkpoint()
		_check(game._checkpoint_store.load_checkpoint() == 6, "tamamlanmış checkpoint yazıldı")
	else:
		_check(game.stage == game.Stage.COMPLETE and not game.has_cargo and game.anchor_count == 2, "ayrı işlemde tamamlanmış görev geri yüklendi")
		_check(game._cargo.visible and game._presentation.delivery_progress == 1.0 and not game._delivery_audio.playing, "yükleme ilk karede teslimat sonucunu sessizce kurar")
		game._sync_visuals(3.0)
		_check(not game._deniz_story.active and not game._deniz_story.visible and game._deniz_story.seen, "tamamlanmış kayıt Deniz sahnesini tekrar oynatmaz")
		var store = STORE.new()
		store.path = PATH + ".cases"
		_fixture(store.path, "{}")
		_fixture(store.path + ".bak", "{}")
		for point: int in 7:
			_check(store.save_checkpoint(point) and store.load_checkpoint() == point, "checkpoint yaz/oku %d" % point)
			game.reset_game()
			game._restore_checkpoint(point)
			_check(game._checkpoint_value() == point, "checkpoint dünya durumuna kurulur %d" % point)
		_check(not store._valid({"version": 1, "level": STORE.LEVEL_ID, "checkpoint": 2.5}), "kesir checkpoint reddedilir")
		_check(not store._valid({"version": 1, "level": "other", "checkpoint": 2}), "başka bölüm kaydı reddedilir")
		_check(not store.save_checkpoint(7), "aralık dışı kayıt reddedilir")
		store.save_checkpoint(3)
		store.save_checkpoint(4)
		_fixture(store.path, "{broken")
		_check(store.load_checkpoint() == 3 and not store.notice.is_empty(), "bozuk kayıtta sağlam önceki checkpoint kurtarılır")
		var future := '{"version":2,"level":"nefes_arena_v1","checkpoint":5}'
		_fixture(store.path, future)
		_check(store.load_checkpoint() == 0 and not store.save_checkpoint(0), "yeni sürüm kaydı korunur")
		_check(FileAccess.get_file_as_string(store.path) == future, "gelecek kayıt değiştirilmez")
		game.reset_game()
		_check(game._checkpoint_store.load_checkpoint() == 0, "baştan başla checkpointi sıfırlar")
	game.free()
	await create_timer(0.10).timeout
	print("CHECKPOINT %s: %d kontrol" % ["PASS" if failures.is_empty() else "FAIL", checks])
	quit(0 if failures.is_empty() else 1)


func _fixture(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(text)
		file.close()
	else:
		_check(false, "QA fixture yazılamadı")


func _check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)
		push_error("CHECKPOINT FAIL: " + label)
