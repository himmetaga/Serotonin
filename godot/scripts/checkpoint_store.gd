extends "res://scripts/preferences_store.gd"

# Reuse only the bounded JSON reader and temp/backup replacement mechanism.
const LEVEL_ID := "nefes_arena_v1"


func load_checkpoint() -> int:
	var result := int(load_preferences().get("checkpoint", 0))
	notice = notice.replace("Ayar", "İlerleme").replace("ayar", "ilerleme")
	return result


func save_checkpoint(checkpoint: int) -> bool:
	if path.is_empty():
		return true
	if checkpoint < 0 or checkpoint > 6:
		return false
	if _read_only or _future(_read(path)) or _future(_read(path + ".bak")):
		notice = "İlerleme kaydı yeni sürüme ait; değiştirilmeden korunuyor."
		return false
	var old := _read(path)
	if _valid(old) and not _write_replace(path + ".bak", old):
		notice = "İlerleme yedeklenemedi; bu oturumdaki ilerleme kaydedilmedi."
		return false
	if not _write_replace(path, {"version": 1, "level": LEVEL_ID, "checkpoint": checkpoint}):
		notice = "İlerleme kaydedilemedi; bu oturumda oynamaya devam edebilirsin."
		return false
	notice = ""
	return true


func _valid(data: Dictionary) -> bool:
	var point: Variant = data.get("checkpoint")
	var version: Variant = data.get("version")
	return (version is int or version is float) and version == 1 and data.get("level") == LEVEL_ID and (point is int or point is float) and point == floorf(float(point)) and point >= 0 and point <= 6
