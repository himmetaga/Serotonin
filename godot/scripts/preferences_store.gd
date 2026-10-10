extends RefCounted

const VERSION := 1
const DEFAULTS := {"version": VERSION, "reduce_motion": false, "audio_enabled": true, "assisted_dash": false}
var path: String = "user://preferences_v1.json"
var notice: String = ""
var _read_only := false


func load_preferences() -> Dictionary:
	notice = ""
	_read_only = false
	if path.is_empty():
		return DEFAULTS.duplicate()
	var primary := _read(path)
	var backup := _read(path + ".bak")
	if _future(primary) or _future(backup):
		_read_only = true
		notice = "Ayar kaydı daha yeni bir sürüme ait; değiştirilmeden korunuyor."
		return DEFAULTS.duplicate()
	if _valid(primary):
		primary["assisted_dash"] = primary.get("assisted_dash", false)
		return primary
	if _valid(backup):
		backup["assisted_dash"] = backup.get("assisted_dash", false)
		notice = "Ayarlar son sağlam yedekten yüklendi."
		return backup
	if FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak"):
		notice = "Ayar kaydı okunamadı; varsayılanlar kullanılıyor."
	return DEFAULTS.duplicate()


func save_preferences(reduced_motion: bool, audio_enabled: bool, assisted_dash: bool = false) -> bool:
	if path.is_empty():
		return true # Explicit test isolation; not used by normal gameplay.
	if _read_only or _future(_read(path)) or _future(_read(path + ".bak")):
		notice = "Yeni sürüme ait ayar kaydı korunuyor; değişiklikler yalnız bu oturumda geçerli."
		return false
	var primary := _read(path)
	# Never rotate a corrupt primary over a known-good backup.
	if _valid(primary) and not _write_replace(path + ".bak", primary):
		notice = "Ayarlar yedeklenemedi; değişiklikler yalnız bu oturumda geçerli."
		return false
	var data := {"version": VERSION, "reduce_motion": reduced_motion, "audio_enabled": audio_enabled, "assisted_dash": assisted_dash}
	if not _write_replace(path, data):
		notice = "Ayarlar kaydedilemedi; değişiklikler yalnız bu oturumda geçerli."
		return false
	notice = ""
	return true


func _read(target: String) -> Dictionary:
	if not FileAccess.file_exists(target):
		return {}
	var file := FileAccess.open(target, FileAccess.READ)
	if file == null or file.get_length() > 4096:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		return {}
	return parser.data as Dictionary


func _future(data: Dictionary) -> bool:
	var version: Variant = data.get("version")
	return (version is int or version is float) and version > VERSION


func _valid(data: Dictionary) -> bool:
	var version: Variant = data.get("version")
	return (version is int or version is float) and version == VERSION and data.get("reduce_motion") is bool and data.get("audio_enabled") is bool and (not data.has("assisted_dash") or data["assisted_dash"] is bool)


func _write_replace(target: String, data: Dictionary) -> bool:
	var temporary := target + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data) + "\n")
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target)) == OK
