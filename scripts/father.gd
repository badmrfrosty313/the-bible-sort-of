extends Node2D
class_name Father

# ============================================================
# THE BIBLE... SORT OF
# Father Character Controller
#
# NOTE:
# father.png is currently a CHARACTER CONCEPT SHEET, not a true
# production sprite sheet. For the prototype we crop useful poses
# directly from that sheet. Once final transparent animation frames
# exist, this controller can swap to AnimatedSprite2D without changing
# the Theater API.
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
@export var target_character_height: float = 58.0

# Pixel rectangles measured from the current 1536x1024 concept sheet.
# ENTER GAME is the closest full-body walking pose available.
const WALK_REGION := Rect2(1200, 694, 154, 244)
const IDLE_REGION := Rect2(480, 62, 132, 222)

var state: State = State.IDLE
var sprite: Sprite2D
var walk_tween: Tween


func _ready() -> void:
	state = State.IDLE
	sprite = get_node_or_null("Sprite2D") as Sprite2D
	_configure_sprite()
	_set_idle_pose()


func _configure_sprite() -> void:
	if sprite == null or sprite.texture == null:
		push_warning("Father has no Sprite2D texture to configure.")
		return

	sprite.hframes = 1
	sprite.vframes = 1
	sprite.region_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true


func _set_region(region: Rect2) -> void:
	if sprite == null:
		return

	sprite.region_rect = region

	var region_height := region.size.y
	if region_height > 0.0:
		var uniform_scale := target_character_height / region_height
		sprite.scale = Vector2(uniform_scale, uniform_scale)


func _set_idle_pose() -> void:
	_set_region(IDLE_REGION)
	if sprite != null:
		sprite.position = Vector2(0, -target_character_height * 0.5)
		sprite.rotation = 0.0


func _set_walk_pose() -> void:
	_set_region(WALK_REGION)
	if sprite != null:
		sprite.position = Vector2(0, -target_character_height * 0.5)
		sprite.rotation = 0.0


# ============================================================
# MOVEMENT
# ============================================================

func move_to(target_position: Vector2) -> void:
	state = State.WALKING
	_set_walk_pose()

	var start_position := global_position
	var distance := start_position.distance_to(target_position)

	if distance <= 0.5:
		global_position = target_position
		_finish_walk()
		return

	# Face the direction of travel. The concept art faces right.
	if sprite != null:
		sprite.flip_h = target_position.x < start_position.x

	var duration := distance / walk_speed
	var elapsed := 0.0

	# We move manually here instead of a single tween so we can add a
	# tiny pixel-art step bounce. It makes the one available walk pose
	# read as walking until proper multi-frame animation art lands.
	while elapsed < duration:
		var delta := get_process_delta_time()
		elapsed += delta
		var progress := clampf(elapsed / duration, 0.0, 1.0)
		global_position = start_position.lerp(target_position, progress)

		if sprite != null:
			var step_phase := sin(elapsed * 18.0)
			sprite.position.y = -target_character_height * 0.5 + round(step_phase * 1.5)
			sprite.rotation = step_phase * 0.015

		await get_tree().process_frame

	global_position = target_position
	_finish_walk()


func _finish_walk() -> void:
	state = State.STANDING
	_set_idle_pose()


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
	_set_idle_pose()


func sit() -> void:
	state = State.SITTING
	_set_idle_pose()


func watch_stage() -> void:
	state = State.WATCHING
	_set_idle_pose()


func react() -> void:
	state = State.REACTING


func idle() -> void:
	state = State.IDLE
	_set_idle_pose()
