extends Control
## Engine-native narrative animatic. Not final character art or a Blender model.
signal opened
signal dismissed

const REVEAL_DELAY := 1.8
var triggered := false
var clock := 0.0
var active := false
var reduced := false
var seen := false
var return_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	return_button = Button.new()
	return_button.text = "İç dünyaya dön"
	return_button.custom_minimum_size = Vector2(180, 48)
	return_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	return_button.offset_left = -220
	return_button.offset_right = -24
	return_button.offset_top = -148
	return_button.offset_bottom = -96
	return_button.pressed.connect(close_story)
	add_child(return_button)
	resized.connect(queue_redraw)


func begin(reduce_motion: bool) -> void:
	if triggered:
		return
	triggered = true
	reduced = reduce_motion
	clock = 0.0


func advance(delta: float, reduce_motion: bool) -> void:
	reduced = reduce_motion
	if not triggered:
		return
	clock = minf(clock + maxf(delta, 0.0), 9.0)
	if not active and not seen and clock >= REVEAL_DELAY:
		active = true
		show()
		opened.emit()
		return_button.grab_focus()
	if active:
		queue_redraw()


func close_story() -> void:
	active = false
	seen = true
	clock = 9.0 # Prevent a dismissed scene reopening on the next frame.
	hide()
	return_button.release_focus()
	dismissed.emit()


func reset_story() -> void:
	triggered = false
	seen = false
	active = false
	clock = 0.0
	hide()
	if return_button:
		return_button.release_focus()


func window_opening() -> float:
	return 1.0 if reduced else smoothstep(0.0, 1.0, clampf((clock - REVEAL_DELAY) / 2.0, 0.0, 1.0))


func breath_lift() -> float:
	return 0.0 if reduced else sin(clampf((clock - 3.8) / 4.0, 0.0, 1.0) * PI) * 8.0


func _poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)


func _stroke(points: Array, color: Color, width: float) -> void:
	draw_polyline(PackedVector2Array(points), color, width, true)


func _draw() -> void:
	# One authored composition fitted without cropping; controls remain anchored.
	draw_rect(Rect2(Vector2.ZERO, size), Color("13282e"))
	var scale_factor := minf(size.x / 1100.0, (size.y - 170.0) / 500.0)
	var origin := Vector2((size.x - 1000.0 * scale_factor) * .5, 70.0)
	draw_set_transform(origin, 0.0, Vector2.ONE * scale_factor)
	var ink := Color("263c43")
	var peach := Color("efd3b8")
	var light := Color("fff1cf")
	var opening := window_opening()
	var lift := breath_lift()
	draw_rect(Rect2(0, 0, 1000, 500), peach)
	# Quiet apartment, window light, and floor; no HUD text baked into the art.
	_poly([Vector2(0,350),Vector2(1000,325),Vector2(1000,500),Vector2(0,500)], Color("c39f88"))
	_poly([Vector2(675,285),Vector2(910,285),Vector2(1000,460),Vector2(415,475)], Color("eddcb5"))
	draw_rect(Rect2(658,40,260,290), ink)
	draw_rect(Rect2(670,52,236,266), Color("9fc7c3"))
	for index: int in 5:
		var x := 702.0 + index*41.0
		_stroke([Vector2(x,305), Vector2(x+5,182), Vector2(x-10,111+index*13)], Color("7ba6a3"), 3)
		_stroke([Vector2(x+3,220),Vector2(x+24,186),Vector2(x+28,147)], Color("7ba6a3"), 2)
	# Hinged sash contracts in perspective as the hand opens it.
	var sash_right := lerpf(897.0, 772.0, opening)
	_poly([Vector2(681,62),Vector2(sash_right,62-16*opening),Vector2(sash_right,307+16*opening),Vector2(681,307)], Color(.93,.91,.80,.38))
	_stroke([Vector2(681,62),Vector2(sash_right,62-16*opening),Vector2(sash_right,307+16*opening),Vector2(681,307),Vector2(681,62)], light, 8)
	_stroke([Vector2(681,181),Vector2(sash_right,181)], light, 5)
	_stroke([Vector2(651,334),Vector2(931,334)], ink, 9)
	# Unfinished instrument on the desk: a small narrative anchor, not a reward score.
	draw_rect(Rect2(120,300,290,17), ink)
	_stroke([Vector2(148,316),Vector2(134,438)], ink, 12)
	_stroke([Vector2(380,316),Vector2(392,438)], ink, 12)
	draw_circle(Vector2(278,281), 31, Color("ae785d"))
	draw_circle(Vector2(278,281), 12, ink)
	_stroke([Vector2(278,275),Vector2(286,187)], Color("ae785d"), 16)
	_stroke([Vector2(279,299),Vector2(287,187)], light, 1)
	# Seated adult profile. Neck/head settle upward; shoulders expand for one breath.
	_stroke([Vector2(475,282),Vector2(455,395),Vector2(577,395)], ink, 15)
	_stroke([Vector2(469,397),Vector2(452,468)], ink, 10)
	_stroke([Vector2(564,397),Vector2(581,465)], ink, 10)
	var head_y := 176.0 - 7.0*opening - lift*.3
	_poly([Vector2(504,259-lift),Vector2(546,249-lift),Vector2(576,282-lift),Vector2(566,364),Vector2(488,367),Vector2(482,301)], ink)
	_poly([Vector2(512,213-lift),Vector2(539,209-lift),Vector2(545,260-lift),Vector2(515,269-lift)], Color("b7846e"))
	_poly([Vector2(499,head_y),Vector2(517,head_y-24),Vector2(548,head_y-16),Vector2(558,head_y+8),Vector2(570,head_y+20),Vector2(556,head_y+24),Vector2(552,head_y+44),Vector2(534,head_y+52),Vector2(509,head_y+36)], Color("bc8c75"))
	_poly([Vector2(498,head_y+18),Vector2(491,head_y-4),Vector2(505,head_y-29),Vector2(536,head_y-30),Vector2(552,head_y-13),Vector2(538,head_y-9),Vector2(518,head_y-12),Vector2(511,head_y+23)], ink)
	_stroke([Vector2(548,head_y+10),Vector2(554,head_y+12)], ink, 2)
	_stroke([Vector2(548,head_y+35),Vector2(555,head_y+33)], ink, 2)
	# Hand remains attached to the moving window handle; no abstract "happy" flash.
	var hand := Vector2(sash_right-12,215)
	_stroke([Vector2(549,277-lift),Vector2(607,278-lift),hand], Color("b7846e"), 15)
	draw_circle(hand, 9, Color("b7846e"))
	_stroke([Vector2(492,355),Vector2(537,391),Vector2(559,446),Vector2(605,448)], ink, 26)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
