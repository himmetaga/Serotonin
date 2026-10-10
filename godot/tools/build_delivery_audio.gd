extends SceneTree

# Original procedural sketch, not a recording of a person or a licensed sample.
# Offline bake: no synthesis work is done during gameplay.
const RATE := 22050
const SECONDS := 4.0
const OUTPUT := "res://assets/audio/nefes_delivery.wav"


func _initialize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1701
	var frames := int(RATE * SECONDS)
	var pcm := PackedByteArray()
	pcm.resize(frames * 2)
	var low := 0.0
	var slow := 0.0
	var peak := 0.0
	var energy := 0.0
	var mean := 0.0
	for index: int in frames:
		var t := float(index) / RATE
		var noise := rng.randf_range(-1.0, 1.0)
		low = low * 0.88 + noise * 0.12
		slow = slow * 0.997 + low * 0.003
		var sample := 0.0
		# Soft wooden/mechanical gesture: three damped contacts, not a reward jingle.
		for onset: float in [0.12, 0.30, 0.52]:
			var age := t - onset
			if age >= 0.0 and age < 0.20:
				var attack := minf(age / 0.006, 1.0)
				sample += attack * exp(-age * 35.0) * (0.16 * sin(TAU * 185.0 * age) + noise * 0.08)
		# Filtered air rises slowly, then releases: a poetic exhale/wind proxy.
		var breath := clampf((t - 0.80) / 2.80, 0.0, 1.0)
		var envelope := pow(sin(breath * PI), 1.4)
		sample += (low - slow) * envelope * 0.65
		sample *= minf(t / 0.02, 1.0) * minf((SECONDS - t) / 0.04, 1.0)
		var quantized := int(round(clampf(sample, -0.9, 0.9) * 32767.0))
		pcm.encode_s16(index * 2, quantized)
		var actual := float(quantized) / 32768.0
		peak = maxf(peak, absf(actual))
		energy += actual * actual
		mean += actual
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = pcm
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/audio"))
	var result := stream.save_to_wav(OUTPUT)
	var report := {"rate_hz": RATE, "seconds": SECONDS, "channels": 1, "pcm_bytes": pcm.size(), "peak": peak, "rms": sqrt(energy / frames), "dc_mean": mean / frames, "seed": 1701, "source": "Original deterministic synthesis; temporary window/air sketch, no human recording."}
	var report_file := FileAccess.open("res://assets/audio/nefes_delivery.analysis.json", FileAccess.WRITE)
	if report_file:
		report_file.store_string(JSON.stringify(report, "\t") + "\n")
	print("AUDIO_BAKE=" + JSON.stringify(report))
	quit(0 if result == OK and peak < 0.9 and peak > 0.05 else 1)
