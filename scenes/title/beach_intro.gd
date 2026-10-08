extends Node2D
## Temporary, independently animated foreground for the authored beach cold open.
## All coordinates are in the project's 480x270 design space.
## The background plate remains untouched; replace these drawn actors with
## dedicated transparent sprite sheets when the final character art is ready.

const SKIN := Color("#E6AF83")
const SKIN_SHADE := Color("#BC7958")
const HAIR := Color("#533528")
const LEAF := Color("#44864A")
const LEAF_LIGHT := Color("#76A45B")
const VINE := Color("#496435")
const VINE_HIGHLIGHT := Color("#96B968")
const INK := Color("#31281F")

enum Beat { REST, FALLING, CAUGHT, EYE_ROLL }
var beat := Beat.REST
var elapsed := 0.0
var fall_progress := 0.0
var eye_roll_elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if beat == Beat.EYE_ROLL:
		eye_roll_elapsed += delta
	queue_redraw()

func start_fall() -> void:
	beat = Beat.FALLING
	fall_progress = 0.0
	queue_redraw()

func set_fall_progress(value: float) -> void:
	fall_progress = clampf(value, 0.0, 1.0)
	queue_redraw()

func catch_adam() -> void:
	fall_progress = 1.0
	beat = Beat.CAUGHT
	queue_redraw()

func begin_eye_roll() -> void:
	beat = Beat.EYE_ROLL
	eye_roll_elapsed = 0.0
	queue_redraw()

func _draw() -> void:
	# Small shifting foam highlights lend movement to the existing still plate.
	for i in range(4):
		var phase := elapsed * 0.65 + float(i) * 1.7
		var x := 48.0 + float(i) * 111.0 + sin(phase) * 10.0
		var y := 210.0 + float(i % 2) * 9.0
		draw_line(Vector2(x, y), Vector2(x + 13.0, y), Color(1.0, 0.97, 0.88, 0.21), 1.5)

	if beat == Beat.REST:
		return

	# Adam enters from above the shot. He stops far short of the ground.
	var final_x := 157.0
	var final_y := 142.0
	var x := lerpf(125.0, final_x, fall_progress)
	var y := lerpf(-42.0, final_y, fall_progress)
	if beat == Beat.CAUGHT or beat == Beat.EYE_ROLL:
		var swing := sin(elapsed * 4.0) * 3.0
		x += swing
		y += absf(swing) * 0.35
		_draw_vines(Vector2(x, y))
	_draw_adam(Vector2(x, y))

	if beat == Beat.EYE_ROLL:
		_draw_eye_roll()

func _draw_vines(adam_position: Vector2) -> void:
	var root := Vector2(108, 33)
	var shoulder := adam_position + Vector2(-10, -7)
	var waist := adam_position + Vector2(8, 18)
	draw_line(root, Vector2(124, 73), VINE, 3.0, true)
	draw_line(Vector2(124, 73), shoulder, VINE, 3.0, true)
	draw_line(Vector2(124, 73), waist, VINE_HIGHLIGHT, 2.0, true)
	for point in [Vector2(119, 62), Vector2(138, 95), Vector2(142, 118)]:
		draw_colored_polygon(PackedVector2Array([
			point, point + Vector2(12, -5), point + Vector2(4, 5)
		]), LEAF)

func _draw_adam(center: Vector2) -> void:
	# Character is deliberately an animation stand-in, not final pixel artwork.
	var bob := sin(elapsed * 5.0) * 1.1 if beat != Beat.FALLING else 0.0
	var p := center + Vector2(0, bob)
	# Hair, face, torso, limbs, and an appropriately placed fig leaf.
	draw_line(p + Vector2(-5, 7), p + Vector2(-12, 23), SKIN_SHADE, 5.0, true)
	draw_line(p + Vector2(5, 7), p + Vector2(14, 18), SKIN, 5.0, true)
	draw_line(p + Vector2(-5, 25), p + Vector2(-12, 38), SKIN_SHADE, 5.0, true)
	draw_line(p + Vector2(5, 25), p + Vector2(12, 38), SKIN, 5.0, true)
	draw_rect(Rect2(p + Vector2(-7, 4), Vector2(14, 23)), SKIN)
	draw_circle(p + Vector2(0, -7), 10.0, SKIN)
	draw_arc(p + Vector2(-1, -9), 10.0, PI, TAU, 12, HAIR, 4.0)
	draw_circle(p + Vector2(-3.5, -8), 1.2, INK)
	draw_circle(p + Vector2(3.5, -8), 1.2, INK)
	draw_line(p + Vector2(-2, -2), p + Vector2(3, -2), INK, 1.2)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(-9, 23), p + Vector2(8, 20),
		p + Vector2(7, 30), p + Vector2(-2, 33)
	]), LEAF)
	draw_line(p + Vector2(-3, 25), p + Vector2(3, 29), LEAF_LIGHT, 1.0)

func _draw_eye_roll() -> void:
	# Reaction animatic marker. A future transparent Father face sheet replaces it.
	var c := Vector2(317, 82)
	var outline := Color("#594A44")
	draw_circle(c, 18.0, outline)
	draw_circle(c, 16.5, Color("#FFF2DC"))
	var roll := clampf(eye_roll_elapsed / 0.55, 0.0, 1.0)
	var pupil_y := lerpf(2.0, -3.0, roll)
	for dx in [-6.0, 6.0]:
		draw_circle(c + Vector2(dx, -1), 5.0, Color("#FDFDF8"))
		draw_circle(c + Vector2(dx, pupil_y), 2.0, INK)
	draw_arc(c + Vector2(0, 10), 6.0, PI, TAU, 10, outline, 1.5)
