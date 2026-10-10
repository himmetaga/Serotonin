extends AudioStreamPlayer

const DELIVERY_STREAM = preload("res://assets/audio/nefes_delivery.wav")
var enabled: bool = true
var triggered: bool = false


func _ready() -> void:
	stream = DELIVERY_STREAM
	volume_db = -6.0
	max_polyphony = 1
	autoplay = false


func on_delivery() -> void:
	if triggered:
		return
	triggered = true
	if enabled:
		play()


func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		stop()
	# Unmuting never unexpectedly restarts an old narrative cue.


func reset_delivery() -> void:
	stop()
	stream_paused = false
	triggered = false
