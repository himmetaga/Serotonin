extends SceneTree

const STORE = preload("res://scripts/preferences_store.gd")
const TEST_PATH := "res://../art/previews/preferences-relaunch-test.json"
var failures: Array[String] = []
var checks := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var writing := "--prefs-phase=write" in OS.get_cmdline_user_args()
	var game := (load("res://main.tscn") as PackedScene).instantiate()
	game._preferences_path = TEST_PATH
	game._checkpoint_path = ""
	root.add_child(game)
	game.set_physics_process(false)
	if writing:
		game._set_reduce_motion(true)
		game._set_audio_enabled(false)
		game._set_assisted_dash(true)
		_check(game.assisted_dash and game._assist_box.button_pressed, "yardımcı jest tercihi yazıldı")
		_check(game._motion_box.button_pressed and not game._audio_box.button_pressed, "menü gerçek tercihlerle eşleşir")
		_check(FileAccess.file_exists(TEST_PATH) and FileAccess.file_exists(TEST_PATH + ".bak"), "kayıt ve önceki sağlam yedek yazıldı")
		_check(not game._settings_notice.visible, "başarılı kayıtta hata mesajı yok")
	else:
		_check(game.assisted_dash and game._assist_box.button_pressed, "yardımcı jest ayrı işlemde geri yüklendi")
		_check(game.reduce_motion and not game._delivery_audio.enabled, "ayrı işlem açılışında tercihler geri yüklendi")
		_check(game._motion_box.button_pressed and not game._audio_box.button_pressed, "yeniden açılış menüsü yüklenen tercihlere uyar")
		_check(is_equal_approx(game._player.position.y, 0.12), "azaltılmış hareket ilk oyun karesinden uygulanır")
		game.reset_game()
		_check(game.assisted_dash, "reset yardımcı jest tercihini korur")
		_check(game.reduce_motion and not game._delivery_audio.enabled, "oyunu baştan başlatmak erişilebilirlik tercihini silmez")
		await _cases()
	print("PREFERENCES %s (%s): %d kontrol" % ["PASS" if failures.is_empty() else "FAIL", "write" if writing else "read", checks])
	quit(0 if failures.is_empty() else 1)


func _cases() -> void:
	var store = STORE.new()
	store.path = TEST_PATH + ".cases"
	_fixture(store.path, "{}")
	_fixture(store.path + ".bak", "{}")
	_fixture(store.path, '{"version":1,"reduce_motion":false,"audio_enabled":true}')
	_check(not store.load_preferences()["assisted_dash"], "eski v1 kayıt yardımcı jesti varsayılan kapalı yükler")
	_fixture(store.path, '{"version":1,"reduce_motion":false,"audio_enabled":true,"assisted_dash":"true"}')
	_check(store.load_preferences() == STORE.DEFAULTS and not store.notice.is_empty(), "yardımcı jest yanlış bool türü reddedilir")
	_fixture(store.path, "{}")
	_check(store.load_preferences() == STORE.DEFAULTS, "eksik alanlarda varsayılanlar kullanılır")
	_check(not store.notice.is_empty(), "bozuk kayıt sessizce gizlenmez")
	_check(store.save_preferences(true, false), "geçerli kayıt oluşturulur")
	_check(store.save_preferences(false, true), "ikinci yazma ilk sağlam kaydı yedekler")
	_fixture(store.path + ".tmp", "{interrupted")
	_check(store.load_preferences()["audio_enabled"], "yarım geçici dosya sağlam ana kaydı etkilemez")
	_fixture(store.path, "{broken")
	var recovered: Dictionary = store.load_preferences()
	_check(recovered["reduce_motion"] and not recovered["audio_enabled"], "bozuk ana kayıtta sağlam önceki yedeğe dönülür")
	_check(store.save_preferences(false, false), "yedekten kurtarma sonrası yeniden kaydedilebilir")
	var backup: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(store.path + ".bak"))
	_check(backup["reduce_motion"] and not backup["audio_enabled"], "bozuk ana kayıt sağlam yedeğin üstüne taşınmaz")
	_fixture(store.path, '{"version":1,"reduce_motion":"false","audio_enabled":0}')
	_fixture(store.path + ".bak", "[]")
	_check(store.load_preferences() == STORE.DEFAULTS, "yanlış alan türleri bool'a çevrilmez")
	var future := '{"version":2,"reduce_motion":true,"audio_enabled":false,"future_option":42}'
	_fixture(store.path, future)
	store.load_preferences()
	_check(not store.save_preferences(false, true), "daha yeni sürüm kaydı yazmaya kapalıdır")
	_check(FileAccess.get_file_as_string(store.path) == future, "gelecek sürümün bilinmeyen alanları korunur")
	var future_game := (load("res://main.tscn") as PackedScene).instantiate()
	future_game._preferences_path = store.path
	future_game._checkpoint_path = ""
	root.add_child(future_game)
	future_game.set_physics_process(false)
	_check(future_game._settings_notice.visible, "uyumsuz kayıt mesajı menüye yansır")
	future_game._set_audio_enabled(false)
	_check(not future_game._delivery_audio.enabled and future_game._settings_notice.visible, "kayıt engelliyken tercih oturumda çalışır")
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--prefs-capture="):
			future_game.set_paused(true)
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			var capture := argument.trim_prefix("--prefs-capture=")
			_check(capture.is_absolute_path() and get_root().get_texture().get_image().save_png(capture) == OK, "hata menüsü gerçek viewport'tan kaydedildi")
	future_game.free()
	store.path = TEST_PATH + ".missing-directory/preferences.json"
	_check(not store.save_preferences(true, false) and not store.notice.is_empty(), "yazma hatası bildirilir")


func _fixture(path: String, value: String) -> void:
	# Only explicitly named workspace QA files; never the user's settings.
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(value)
		file.close()
	else:
		_check(false, "test girdisi oluşturulamadı")


func _check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)
		push_error("PREFERENCES FAIL: " + label)
