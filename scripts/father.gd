extends Node2D
class_name Father

# ============================================================
# THE BIBLE... SORT OF
# Father Character Controller
#
# Father owns his visual representation, movement, and local
# state. Theater / episode controllers decide where he goes.
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

# The current Father art is a sprite sheet rather than a single
# character image. Keeping these values exported means we can tune
# the sheet layout in one place when the final animation frames land.
@export var sheet_columns: int = 4
@export var sheet_rows: int = 4
@export var idle_frame: int = 0
@export var target_frame_height: float = 48.0

var state: State = State.IDLE
var sprite: Sprite2D


func _ready() -> void:
	state = State.IDLE
	sprite = get_node_or_null("Sprite2D") as Sprite2D
	_configure_sprite_sheet()


func _configure_sprite_sheet() -> void:
	if sprite == null or sprite.texture == null:
		push_warning("Father has no Sprite2D texture to configure.")
		return

	var columns := maxi(sheet_columns, 1)
	var rows := maxi(sheet_rows, 1)

	sprite.hframes = columns
	sprite.vframes = rows
	sprite.frame = clampi(idle_frame, 0, columns * rows - 1)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# Normalize whatever source resolution the sheet uses to a useful
	# in-game character height while preserving its pixel proportions.
	var frame_height := float(sprite.texture.get_height()) / float(rows)
	if frame_height > 0.0:
		var uniform_scale := target_frame_height / frame_height
		sprite.scale = Vector2(uniform_scale, uniform_scale)


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
	tween.tween_property(self, "global_position", target_position, duration)

	await tween.finished
	global_position = target_position
	state = State.STANDING


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
