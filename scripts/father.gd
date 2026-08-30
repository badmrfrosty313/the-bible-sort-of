extends Node2D
class_name Father

enum State { IDLE, WALKING, STANDING, SITTING, WATCHING, REACTING }

@export var walk_speed: float = 72.0

const STAND_TEXTURE := preload("res://art/characters/father_pixel/father_stand.png")
const WALK_1_TEXTURE := preload("res://art/characters/father_pixel/father_walk_1.png")
const WALK_2_TEXTURE := preload("res://art/characters/father_pixel/father_walk_2.png")
const WALK_3_TEXTURE := preload("res://art/characters/father_pixel/father_walk_3.png")
const WALK_4_TEXTURE := preload("res://art/characters/father_pixel/father_walk_4.png")
const WALK_5_TEXTURE := preload("res://art/characters/father_pixel/father_walk_5.png")
const WALK_6_TEXTURE := preload("res://art/characters/father_pixel/father_walk_6.png")
const SIT_BACK_TEXTURE := preload("res://art/characters/father_pixel/father_sit_back.png")

const DISPLAY_SCALE := Vector2(1.0, 1.0)
const STAND_OFFSET_Y := -34.0
const WALK_OFFSET_Y := -34.0
const SIT_OFFSET_Y := -33.0

var state: State = State.IDLE
var legacy_sprite: Sprite2D
var character_sprite: Sprite2D
var facing_left: bool = false
var walk_elapsed: float = 0.0
var walk_frame: int = 0
var idle_elapsed: float = 0.0
var walk_textures: Array[Texture2D] = [
	WALK_1_TEXTURE,
	WALK_2_TEXTURE,
	WALK_3_TEXTURE,
	WALK_4_TEXTURE,
	WALK_5_TEXTURE,
	WALK_6_TEXTURE,
]

func _ready() -> void:
	legacy_sprite = get_node_or_null("Sprite2D") as Sprite2D
	if legacy_sprite != null:
		legacy_sprite.visible = false

	character_sprite = Sprite2D.new()
	character_sprite.name = "CharacterSprite"
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.centered = true
	character_sprite.scale = DISPLAY_SCALE
	add_child(character_sprite)
	stand()

func _process(delta: float) -> void:
	if character_sprite == null:
		return

	if state == State.WALKING:
		walk_elapsed += delta
		var next_frame: int = int(floor(walk_elapsed * 9.0)) % walk_textures.size()
		if next_frame != walk_frame:
			walk_frame = next_frame
			character_sprite.texture = walk_textures[walk_frame]
		character_sprite.position.y = WALK_OFFSET_Y + (1.0 if walk_frame % 2 == 1 else 0.0)
		return

	if state == State.WATCHING:
		idle_elapsed += delta
		var breath: float = 1.0 if int(idle_elapsed * 1.7) % 4 == 3 else 0.0
		character_sprite.position.y = SIT_OFFSET_Y + breath

func _apply_texture(texture: Texture2D, y_offset: float) -> void:
	if character_sprite == null:
		return
	character_sprite.texture = texture
	character_sprite.flip_h = facing_left
	character_sprite.position = Vector2(0, y_offset)

func move_to(target_position: Vector2) -> void:
	state = State.WALKING
	var start_position: Vector2 = global_position
	var distance: float = start_position.distance_to(target_position)
	if distance <= 0.5:
		global_position = target_position
		_finish_walk()
		return

	facing_left = target_position.x < start_position.x
	walk_elapsed = 0.0
	walk_frame = 0
	_apply_texture(walk_textures[0], WALK_OFFSET_Y)

	var duration: float = distance / walk_speed
	var elapsed: float = 0.0
	while elapsed < duration:
		var frame_delta: float = get_process_delta_time()
		elapsed += frame_delta
		global_position = start_position.lerp(target_position, clampf(elapsed / duration, 0.0, 1.0))
		await get_tree().process_frame

	global_position = target_position
	_finish_walk()

func _finish_walk() -> void:
	state = State.STANDING
	walk_elapsed = 0.0
	walk_frame = 0
	_apply_texture(STAND_TEXTURE, STAND_OFFSET_Y)

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
	idle_elapsed = 0.0
	_apply_texture(STAND_TEXTURE, STAND_OFFSET_Y)

func sit() -> void:
	state = State.SITTING
	facing_left = false
	idle_elapsed = 0.0
	_apply_texture(SIT_BACK_TEXTURE, SIT_OFFSET_Y)

func watch_stage() -> void:
	state = State.WATCHING
	facing_left = false
	idle_elapsed = 0.0
	_apply_texture(SIT_BACK_TEXTURE, SIT_OFFSET_Y)

func react() -> void:
	state = State.REACTING
	idle_elapsed = 0.0
	_apply_texture(STAND_TEXTURE, STAND_OFFSET_Y)

func idle() -> void:
	state = State.IDLE
	idle_elapsed = 0.0
	_apply_texture(STAND_TEXTURE, STAND_OFFSET_Y)
