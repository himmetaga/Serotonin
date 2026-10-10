extends RefCounted
## Deterministic curved attack proxy; presentation and simulation share its arc.
const HALF_ANGLE := deg_to_rad(70.0)
const REACH := 2.05
const HIT_RADIUS := 0.42
const WARNING_RADIUS := REACH + HIT_RADIUS


static func direction_at(forward: Vector3, progress: float) -> Vector3:
	return forward.rotated(Vector3.UP, lerpf(-HALF_ANGLE, HALF_ANGLE, clampf(progress, 0.0, 1.0)))


static func in_warning(point: Vector3, center: Vector3, forward: Vector3) -> bool:
	var offset := point - center
	offset.y = 0.0
	if offset.length_squared() > WARNING_RADIUS * WARNING_RADIUS:
		return false
	return offset.length_squared() < 0.000001 or offset.normalized().dot(forward) >= cos(HALF_ANGLE)


static func hits(from: Vector3, to: Vector3, center: Vector3, forward: Vector3, previous_progress: float, progress: float) -> bool:
	# Sample the swept blade, not only the player's final point. Fixed subdivisions
	# cover the entire 140-degree arc even on a frame spanning the full action.
	var travel := to - from
	travel.y = 0.0
	for sample: int in 13:
		var direction := direction_at(forward, lerpf(previous_progress, progress, sample / 12.0))
		for radial: float in [0.4, 0.95, 1.5, REACH]:
			var point := center + direction * radial
			var t := clampf((point - from).dot(travel) / maxf(travel.length_squared(), 0.000001), 0.0, 1.0)
			var closest := from + travel*t
			var offset := point - closest
			offset.y = 0.0
			if offset.length_squared() <= HIT_RADIUS*HIT_RADIUS and in_warning(closest, center, forward):
				return true
	return false
