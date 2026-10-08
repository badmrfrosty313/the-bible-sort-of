extends Node2D
## Lightweight atmospheric effects for the authored beach plate.
##
## IMPORTANT: The source painting already includes Adam caught in the upper-
## right vines. Do NOT paint a second Adam (or a reaction emoji) over it.
## The camera begins tight on the Father, then reveals the existing Adam.
## A true fall/eye-roll animation awaits separate transparent character art.

const FOAM := Color(1.0, 0.97, 0.88, 0.20)
const LEAF := Color("#48763E")
const LEAF_LIGHT := Color("#83A65B")

enum Beat { REST, FALLING, CAUGHT, REACTION }
var beat := Beat.REST
var elapsed := 0.0
var fall_progress := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func start_fall() -> void:
	beat = Beat.FALLING
	fall_progress = 0.0

func set_fall_progress(value: float) -> void:
	fall_progress = clampf(value, 0.0, 1.0)

func catch_adam() -> void:
	beat = Beat.CAUGHT
	fall_progress = 1.0

func begin_eye_roll() -> void:
	beat = Beat.REACTION

func _draw() -> void:
	# Subtle foam motion over the static water, without obscuring source art.
	for i in range(4):
		var phase := elapsed * 0.65 + float(i) * 1.7
		var x := 50.0 + float(i) * 107.0 + sin(phase) * 8.0
		var y := 212.0 + float(i % 2) * 10.0
		draw_line(Vector2(x, y), Vector2(x + 12.0, y), FOAM, 1.1)

	# Leaves accent the offscreen commotion as the camera pulls out to reveal
	# Adam already hanging in the painted vines. No duplicate character.
	if beat == Beat.FALLING or beat == Beat.CAUGHT:
		var fade := 1.0 - fall_progress * 0.7
		for i in range(6):
			var t := float(i)
			var drift := sin(elapsed * 2.3 + t) * 3.0
			var x := 390.0 + t * 13.0 + drift
			var y := 47.0 + t * 7.0 + fall_progress * (19.0 + t * 2.0)
			var color := LEAF if i % 2 == 0 else LEAF_LIGHT
			color.a = fade
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, y), Vector2(x + 6.0, y - 3.0),
				Vector2(x + 2.0, y + 6.0)
			]), color)
