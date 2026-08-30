extends Node2D
class_name PixelFather

enum State { IDLE, WALKING, STANDING, SITTING, WATCHING, REACTING }

@export var walk_speed: float = 72.0

const STAND_TEXTURE := preload("res://art/characters/father_pixel/father_stand.svg")
const WALK_1_TEXTURE := preload("res://art/characters/father_pixel/father_walk_1.svg")
const WALK_2_TEXTURE := preload("res://art/characters/father_pixel/father_walk_2.svg")
const WALK_3_TEXTURE := preload("res://art/characters/father_pixel/father_walk_3.svg")
const WALK_4_TEXTURE := preload("res://art/characters/father_pixel/father_walk_4.svg")
const SIT_BACK_TEXTURE := preload("res://art/characters/father_pixel/father_sit_back.svg")

var state: State = State.IDLE
var character_sprite: Sprite2D
var facing_left: bool = false
var walk_elapsed: float = 0.0
var walk_frame: int = 0
var idle_elapsed: float = 0.0
var walk_textures: Array[Texture2D] = [WALK_1_TEXTURE, WALK_2_TEXTURE, WALK_3_TEXTURE, WALK_4_TEXTURE]

func _ready() -> void:
	var old_sprite := get_node_or_null("Sprite2D") as Sprite2D
	if old_sprite != null:
		old_sprite.visible = false
	character_sprite = Sprite2D.new()
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.position = Vector2(0, -24)
	add_child(character_sprite)
	stand()

func _process(delta: float) -> void:
	if state == State.WALKING:
		walk_elapsed += delta
		walk_frame = int(floor(walk_elapsed * 8.0)) % walk_textures.size()
		character_sprite.texture = walk_textures[walk_frame]
		character_sprite.position.y = -24.0 + (1.0 if walk_frame % 2 == 1 else 0.0)
	elif state == State.WATCHING:
		idle_elapsed += delta
		character_sprite.position.y = -24.0 + (1.0 if int(idle_elapsed * 1.7) % 4 == 3 else 0.0)

func _show(texture: Texture2D) -> void:
	character_sprite.texture = texture
	character_sprite.flip_h = facing_left
	character_sprite.position = Vector2(0, -24)

func move_to(target_position: Vector2) -> void:
	state = State.WALKING
	var start_position := global_position
	var distance := start_position.distance_to(target_position)
	if distance <= 0.5:
		global_position = target_position
		_finish_walk()
		return
	facing_left = target_position.x < start_position.x
	walk_elapsed = 0.0
	walk_frame = 0
	_show(walk_textures[0])
	var duration := distance / walk_speed
	var elapsed := 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		global_position = start_position.lerp(target_position, clampf(elapsed / duration, 0.0, 1.0))
		await get_tree().process_frame
	global_position = target_position
	_finish_walk()

func _finish_walk() -> void:
	state = State.STANDING
	_show(STAND_TEXTURE)

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
	_show(STAND_TEXTURE)

func sit() -> void:
	state = State.SITTING
	facing_left = false
	_show(SIT_BACK_TEXTURE)

func watch_stage() -> void:
	state = State.WATCHING
	facing_left = false
	idle_elapsed = 0.0
	_show(SIT_BACK_TEXTURE)

func react() -> void:
	state = State.REACTING
	_show(STAND_TEXTURE)

func idle() -> void:
	state = State.IDLE
	_show(STAND_TEXTURE)
