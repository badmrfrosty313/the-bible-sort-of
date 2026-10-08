extends Node2D
## Cinematic staging for the authored beach cold open.
##
## The original beach illustration already contains BOTH Father and Adam, as
## well as the vines and the mug. It is a flattened plate, so adding a second
## Adam or redrawing the Father produces visible duplicates. Until separate
## transparent animation cels are approved, frame the existing illustration
## using a moving camera. This preserves the approved art intact.
##
## Positions below are design-space coordinates (480x270).

const CENTER := Vector2(240.0, 135.0)
const FATHER_FOCUS := Vector2(152.0, 151.0)
const ADAM_FOCUS := Vector2(438.0, 85.0)
const FATHER_ANCHOR := Vector2(210.0, 144.0)
const ADAM_ANCHOR := Vector2(420.0, 119.0)
const INITIAL_ZOOM := 1.43
const ADAM_ZOOM := 1.44
const REACTION_ZOOM := 1.53

var backdrop: Sprite2D
var original_position := CENTER
var original_scale := Vector2.ONE
var active_tween: Tween

func configure(sprite: Sprite2D) -> void:
	backdrop = sprite
	original_position = sprite.position
	original_scale = sprite.scale
	# Start on Father's quiet day off. Adam sits outside the first crop.
	_set_frame(FATHER_FOCUS, FATHER_ANCHOR, INITIAL_ZOOM)

func show_adam() -> void:
	# Pan across the scene to reveal the commotion already painted in the plate.
	# This is an animatic reveal, not a fabricated character-fall animation.
	_tween_frame(ADAM_FOCUS, ADAM_ANCHOR, ADAM_ZOOM, 0.8)

func show_father_reaction() -> void:
	# Bring the viewer back to Father's expression before the spoken punchline.
	_tween_frame(FATHER_FOCUS, FATHER_ANCHOR, REACTION_ZOOM, 0.75)

func reveal_full_beach() -> void:
	_kill_active_tween()
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(backdrop, "position", original_position, 0.65)
	active_tween.parallel().tween_property(backdrop, "scale", original_scale, 0.65)

func reset_immediately() -> void:
	_kill_active_tween()
	if backdrop != null:
		backdrop.position = original_position
		backdrop.scale = original_scale

func _set_frame(focus: Vector2, anchor: Vector2, zoom: float) -> void:
	backdrop.position = _frame_position(focus, anchor, zoom)
	backdrop.scale = original_scale * zoom

func _tween_frame(focus: Vector2, anchor: Vector2, zoom: float, duration: float) -> void:
	_kill_active_tween()
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_CUBIC)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(backdrop, "position", _frame_position(focus, anchor, zoom), duration)
	active_tween.parallel().tween_property(backdrop, "scale", original_scale * zoom, duration)

func _frame_position(focus: Vector2, anchor: Vector2, zoom: float) -> Vector2:
	# Move a point in the original 480x270 image to the target screen anchor
	# while zooming about the original texture's center.
	return anchor - (focus - CENTER) * zoom

func _kill_active_tween() -> void:
	if active_tween != null and active_tween.is_running():
		active_tween.kill()
