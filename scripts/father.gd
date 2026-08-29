extends Node2D
class_name Father

enum State { IDLE, WALKING, STANDING, SITTING, WATCHING, REACTING }

@export var walk_speed: float = 70.0
@export var target_character_height: float = 58.0

# Temporary crops from the current concept sheet. These remain scaffolding
# until the transparent production sprite sheet is committed.
const WALK_REGION := Rect2(1200, 694, 154, 244)
const STAND_REGION := Rect2(480, 62, 132, 222)
# Seated crop used only behind the console. Kept smaller/lower so the desk
# occludes the lower portion naturally instead of Father floating on screen.
const SIT_REGION := Rect2(580, 600, 300, 360)

var state: State = State.IDLE
var sprite: Sprite2D

func _ready() -> void:
	sprite = get_node_or_null("Sprite2D") as Sprite2D
	_configure_sprite()
	stand()

func _configure_sprite() -> void:
	if sprite == null or sprite.texture == null:
		push_warning("Father has no Sprite2D texture to configure.")
		return
	sprite.hframes = 1
	sprite.vframes = 1
	sprite.region_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true

func _set_region(region: Rect2, height: float = target_character_height) -> void:
	if sprite == null:
		return
	sprite.region_rect = region
	var scale_value := height / region.size.y if region.size.y > 0.0 else 1.0
	sprite.scale = Vector2(scale_value, scale_value)
	sprite.rotation = 0.0

func _set_stand_pose() -> void:
	_set_region(STAND_REGION)
	if sprite:
		sprite.position = Vector2(0, -target_character_height * 0.5)

func _set_walk_pose() -> void:
	_set_region(WALK_REGION)
	if sprite:
		sprite.position = Vector2(0, -target_character_height * 0.5)

func _set_sit_pose() -> void:
	# Smaller visible height because Father is physically behind the console.
	_set_region(SIT_REGION, 50.0)
	if sprite:
		sprite.position = Vector2(0, -22)
		sprite.flip_h = false

func move_to(target_position: Vector2) -> void:
	state = State.WALKING
	_set_walk_pose()
	var start_position := global_position
	var distance := start_position.distance_to(target_position)
	if distance <= 0.5:
		global_position = target_position
		_finish_walk()
		return
	if sprite:
		sprite.flip_h = target_position.x < start_position.x
	var duration := distance / walk_speed
	var elapsed := 0.0
	while elapsed < duration:
		var delta := get_process_delta_time()
		elapsed += delta
		var progress := clampf(elapsed / duration, 0.0, 1.0)
		global_position = start_position.lerp(target_position, progress)
		if sprite:
			var step_phase := sin(elapsed * 18.0)
			sprite.position.y = -target_character_height * 0.5 + round(step_phase * 1.5)
			sprite.rotation = step_phase * 0.015
		await get_tree().process_frame
	global_position = target_position
	_finish_walk()

func _finish_walk() -> void:
	state = State.STANDING
	_set_stand_pose()

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
	_set_stand_pose()

func sit() -> void:
	state = State.SITTING
	_set_sit_pose()

func watch_stage() -> void:
	state = State.WATCHING
	_set_sit_pose()

func react() -> void:
	state = State.REACTING
	_set_stand_pose()

func idle() -> void:
	state = State.IDLE
	_set_stand_pose()
