extends SceneTree

var failures: Array[String] = []
var checks := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game := (load("res://main.tscn") as PackedScene).instantiate()
	game._preferences_path = ""
	root.add_child(game)
	game.set_physics_process(false)
	var player: AudioStreamPlayer = game._delivery_audio
	_check(player.stream is AudioStreamWAV and player.stream.get_length() >= 3.5, "WAV içe aktarıldı ve süre korundu")
	_check(not player.playing and not player.triggered, "oyun başlangıcı sessiz")
	game.stage = game.Stage.DELIVERY
	game.has_cargo = true
	game.player_position = game.SOCKET_POINT
	game.simulate_step(0.91)
	await process_frame
	_check(player.triggered and player.playing, "gerçek teslimat geçişi sesi başlatır")
	await create_timer(0.08).timeout
	game.set_paused(true)
	var paused_position := player.get_playback_position()
	await create_timer(0.08).timeout
	_check(player.stream_paused and absf(player.get_playback_position() - paused_position) < 0.03, "pause ses konumunu dondurur")
	game.set_paused(false)
	_check(not player.stream_paused, "resume ses akışını sürdürür")
	game._set_audio_enabled(false)
	_check(not player.playing and not game._audio_box.button_pressed, "ses kapatılınca çalma durur ve menü eşleşir")
	game._set_audio_enabled(true)
	_check(not player.playing, "ses açmak eski teslimatı yeniden çalmaz")
	game.reset_game()
	_check(not player.triggered and not player.playing, "reset sesi ve olay kilidini temizler")
	game._set_audio_enabled(false)
	game.stage = game.Stage.DELIVERY
	game.has_cargo = true
	game.player_position = game.SOCKET_POINT
	game.simulate_step(0.91)
	_check(game.stage == game.Stage.COMPLETE and player.triggered and not player.playing, "sessiz modda görev tamamlanır")
	_check(game._hint_label.text.contains("uzun bir nefes"), "sessiz modda anlatı sesinin yazılı karşılığı var")
	game.reset_game()
	_check(not player.enabled and not game._audio_box.button_pressed, "reset oturumun ses tercihini korur")
	game._set_audio_enabled(true)
	game.stage = game.Stage.DELIVERY
	game.has_cargo = true
	game.player_position = game.SOCKET_POINT
	game.simulate_step(0.91)
	await create_timer(0.30).timeout
	var before_repeat := player.get_playback_position()
	game.delivery_completed.emit()
	await process_frame
	_check(player.get_playback_position() >= before_repeat - 0.03, "yinelenen olay ses başına dönmez")
	await create_timer(4.1).timeout
	_check(not player.playing and player.triggered, "ses kendiliğinden biter ve döngüye girmez")
	print("AUDIO %s: %d kontrol" % ["PASS" if failures.is_empty() else "FAIL", checks])
	quit(0 if failures.is_empty() else 1)


func _check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)
		push_error("AUDIO FAIL: " + label)
