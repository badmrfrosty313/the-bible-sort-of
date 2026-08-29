extends Node2D
class_name Father

# ============================================================
# THE BIBLE... SORT OF
# Father Character Controller
#
# Father owns:
# - his visual representation
# - his movement
# - his local animation/state
#
# Father does NOT decide where the story sends him.
# Theater / episode controllers make those decisions.
# ============================================================


enum State {
	IDLE,
	WALKING,
	STANDING,
	SITTING,
	WATCHING,
	REACTING
}


@export var walk_speed: float = 70.0

var state: State = State.IDLE


# ============================================================
# LIFECYCLE
# ============================================================

func _ready() -> void:
	state = State.IDLE


# ============================================================
# MOVEMENT
# ============================================================

func move_to(target_position: Vector2) -> void:
	state = State.WALKING

	var distance := global_position.distance_to(target_position)

	if distance <= 0.5:
		global_position = target_position
		state = State.STANDING
		return

	var duration := distance / walk_speed

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"global_position",
		target_position,
		duration
	)

	await tween.finished

	global_position = target_position
	state = State.STANDING


func enter_from_left(
	entrance_position: Vector2,
	target_position: Vector2
) -> void:

	global_position = entrance_position
	visible = true

	await move_to(target_position)


func enter_from_right(
	entrance_position: Vector2,
	target_position: Vector2
) -> void:

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


# ============================================================
# BASIC STATES
# ============================================================

func stand() -> void:
	state = State.STANDING


func sit() -> void:
	state = State.SITTING


func watch_stage() -> void:
	state = State.WATCHING


func react() -> void:
	state = State.REACTING


func idle() -> void:
	state = State.IDLE
