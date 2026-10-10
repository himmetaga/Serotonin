extends RefCounted

enum Kind { NONE, PARRY, SEAM_HIT, PLAYER_HIT }
const MESSAGE_SECONDS := 0.65
const MOTION_SECONDS := 0.18
var kind: Kind = Kind.NONE
var elapsed: float = 0.0
var direction := Vector3.RIGHT
var message: String = ""


func trigger(event: Kind, incoming: Vector3, settled: bool = false) -> void:
	kind = event
	elapsed = 0.0
	direction = Vector3(incoming.x, 0.0, incoming.z).normalized()
	if direction.length_squared() < 0.01:
		direction = Vector3.RIGHT
	match kind:
		Kind.PARRY: message = "Saptırdın. Dikiş açıldı; şimdi karşılık ver."
		Kind.SEAM_HIT: message = "Kıskaç sakinleşti. Bağ noktaları açıldı." if settled else "Dikişi çözdün. Bir açıklık daha."
		Kind.PLAYER_HIT: message = "Darbe aldın. Üçgenin yolundan çık; kargon güvende."
		_: reset()


func advance(delta: float) -> bool:
	if kind == Kind.NONE:
		return false
	elapsed += maxf(delta, 0.0)
	if elapsed >= MESSAGE_SECONDS:
		reset()
		return true
	return false


func envelope() -> float:
	if kind == Kind.NONE:
		return 0.0
	var remaining := maxf(0.0, 1.0 - elapsed / MOTION_SECONDS)
	return remaining * remaining


func guardian_offset(reduced: bool) -> Vector3:
	if reduced or kind not in [Kind.PARRY, Kind.SEAM_HIT]:
		return Vector3.ZERO
	return direction * envelope() * (0.12 if kind == Kind.PARRY else 0.22)


func player_offset(reduced: bool) -> Vector3:
	return direction * envelope() * 0.12 if not reduced and kind == Kind.PLAYER_HIT else Vector3.ZERO


func player_pose(reduced: bool) -> Vector3:
	if reduced:
		return Vector3.ONE
	var strength := envelope()
	match kind:
		Kind.PARRY: return Vector3(1.0 - 0.06 * strength, 1.0 + 0.12 * strength, 1.0 - 0.06 * strength)
		Kind.PLAYER_HIT: return Vector3(1.0 + 0.08 * strength, 1.0 - 0.12 * strength, 1.0 + 0.08 * strength)
	return Vector3.ONE


func reset() -> void:
	kind = Kind.NONE
	elapsed = 0.0
	message = ""
