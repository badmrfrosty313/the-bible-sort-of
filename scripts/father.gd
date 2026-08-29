extends Node2D
class_name Father

enum State { IDLE, WALKING, STANDING, SITTING, WATCHING, REACTING }

@export var walk_speed: float = 70.0

var state: State = State.IDLE
var legacy_sprite: Sprite2D
var facing := 1.0
var walk_phase := 0.0

const OUTLINE := Color("#2A1A16")
const SKIN := Color("#C99368")
const SKIN_SHADOW := Color("#9C6748")
const HAIR := Color("#E8DDC7")
const HAIR_SHADOW := Color("#B8AA95")
const ROBE := Color("#D8C7A2")
const ROBE_SHADOW := Color("#A99572")
const SANDAL := Color("#5B3825")
const GOLD := Color("#C59643")

func _ready() -> void:
	legacy_sprite = get_node_or_null("Sprite2D") as Sprite2D
	if legacy_sprite:
		# The concept sheet remains in the repo as reference art, but it is never
		# rendered in-game. No more laminated God JPEG.
		legacy_sprite.visible = false
	stand()

func _process(delta: float) -> void:
	if state == State.WALKING:
		walk_phase += delta * 12.0
		queue_redraw()

func _draw() -> void:
	if state == State.SITTING or state == State.WATCHING:
		_draw_sitting_father()
	else:
		_draw_standing_father(state == State.WALKING)

func _px(rect: Rect2, color: Color) -> void:
	var r := rect
	if facing < 0.0:
		r.position.x = -rect.position.x - rect.size.x
	draw_rect(r, color)

func _draw_standing_father(walking: bool) -> void:
	var bob := 0.0
	var leg_shift := 0.0
	var arm_shift := 0.0
	if walking:
		bob = round(sin(walk_phase * 2.0))
		leg_shift = round(sin(walk_phase) * 3.0)
		arm_shift = round(sin(walk_phase) * 2.0)

	# Hair silhouette and head.
	_px(Rect2(-9,-52+bob,18,5),OUTLINE)
	_px(Rect2(-12,-47+bob,24,15),HAIR)
	_px(Rect2(-14,-40+bob,5,17),HAIR_SHADOW)
	_px(Rect2(9,-40+bob,5,17),HAIR_SHADOW)
	_px(Rect2(-8,-43+bob,16,15),SKIN)
	_px(Rect2(-5,-38+bob,3,3),OUTLINE)
	_px(Rect2(3,-38+bob,3,3),OUTLINE)
	# Beard.
	_px(Rect2(-9,-31+bob,18,14),HAIR)
	_px(Rect2(-6,-18+bob,12,5),HAIR_SHADOW)

	# Robe/body.
	_px(Rect2(-13,-18+bob,26,5),OUTLINE)
	_px(Rect2(-12,-16+bob,24,31),ROBE)
	_px(Rect2(-12,-3+bob,5,18),ROBE_SHADOW)
	_px(Rect2(7,-3+bob,5,18),ROBE_SHADOW)
	_px(Rect2(-14,13+bob,28,5),OUTLINE)
	_px(Rect2(-11,16+bob,22,17),ROBE)
	_px(Rect2(-11,28+bob,22,5),ROBE_SHADOW)
	# Belt.
	_px(Rect2(-12,3+bob,24,4),SANDAL)
	_px(Rect2(-2,2+bob,4,6),GOLD)

	# Arms swing opposite the legs.
	_px(Rect2(-18,-13+bob+arm_shift,6,23),ROBE_SHADOW)
	_px(Rect2(12,-13+bob-arm_shift,6,23),ROBE_SHADOW)
	_px(Rect2(-19,7+bob+arm_shift,7,7),SKIN)
	_px(Rect2(12,7+bob-arm_shift,7,7),SKIN)

	# Legs and sandals. Alternating offsets create an actual readable walk cycle.
	_px(Rect2(-10,31+bob+leg_shift,8,13),ROBE_SHADOW)
	_px(Rect2(2,31+bob-leg_shift,8,13),ROBE_SHADOW)
	_px(Rect2(-12,42+bob+leg_shift,11,5),SANDAL)
	_px(Rect2(1,42+bob-leg_shift,11,5),SANDAL)

func _draw_sitting_father() -> void:
	# Chair is deliberately part of the temporary procedural character so it
	# has a transparent background and can be cleanly masked by the desk.
	_px(Rect2(-18,-18,36,34),Color("#54251F"))
	_px(Rect2(-15,-15,30,29),Color("#713127"))
	_px(Rect2(-20,10,5,18),SANDAL)
	_px(Rect2(15,10,5,18),SANDAL)
	# Father torso/head above chair.
	_px(Rect2(-10,-48,20,5),OUTLINE)
	_px(Rect2(-13,-44,26,14),HAIR)
	_px(Rect2(-8,-41,16,14),SKIN)
	_px(Rect2(-5,-36,3,3),OUTLINE)
	_px(Rect2(3,-36,3,3),OUTLINE)
	_px(Rect2(-9,-29,18,13),HAIR)
	_px(Rect2(-12,-17,24,22),ROBE)
	_px(Rect2(-12,-3,24,5),SANDAL)
	# Arms resting on the console/chair arms.
	_px(Rect2(-18,-12,7,18),ROBE_SHADOW)
	_px(Rect2(11,-12,7,18),ROBE_SHADOW)
	_px(Rect2(-18,2,7,6),SKIN)
	_px(Rect2(11,2,7,6),SKIN)

func move_to(target_position: Vector2) -> void:
	state = State.WALKING
	var start_position := global_position
	var distance := start_position.distance_to(target_position)
	if distance <= 0.5:
		global_position = target_position
		_finish_walk()
		return
	facing = -1.0 if target_position.x < start_position.x else 1.0
	var duration := distance / walk_speed
	var elapsed := 0.0
	while elapsed < duration:
		var delta := get_process_delta_time()
		elapsed += delta
		var progress := clampf(elapsed / duration,0.0,1.0)
		global_position = start_position.lerp(target_position,progress)
		await get_tree().process_frame
	global_position = target_position
	_finish_walk()

func _finish_walk() -> void:
	state = State.STANDING
	walk_phase = 0.0
	queue_redraw()

func enter_from_left(entrance_position: Vector2, target_position: Vector2) -> void:
	global_position = entrance_position
	visible = true
	await move_to(target_position)

func enter_from_right(entrance_position: Vector2, target_position: Vector2) -> void:
	global_position = entrance_position
	visible = true
	await move_to(target_position)

func leave_to_left(exit_position: Vector2) -> void:
	await move_to(exit_position)
	visible = false
	state = State.IDLE

func leave_to_right(exit_position: Vector2) -> void:
	await move_to(exit_position)
	visible = false
	state = State.IDLE

func stand() -> void:
	state = State.STANDING
	queue_redraw()

func sit() -> void:
	state = State.SITTING
	queue_redraw()

func watch_stage() -> void:
	state = State.WATCHING
	queue_redraw()

func react() -> void:
	state = State.REACTING
	queue_redraw()

func idle() -> void:
	state = State.IDLE
	queue_redraw()
