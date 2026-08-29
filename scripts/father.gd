extends Node2D
class_name Father

enum State { IDLE, WALKING, STANDING, SITTING, WATCHING, REACTING }

@export var walk_speed: float = 70.0

const IDLE_TEXTURE := preload("res://art/characters/father/father_idle.svg")
const WALK_A_TEXTURE := preload("res://art/characters/father/father_walk_a.svg")
const WALK_B_TEXTURE := preload("res://art/characters/father/father_walk_b.svg")
const SIT_TEXTURE := preload("res://art/characters/father/father_sit.svg")

var state: State = State.IDLE
var legacy_sprite: Sprite2D
var character_sprite: Sprite2D
var facing_left := false
var walk_elapsed := 0.0
var walk_frame := 0

func _ready() -> void:
	legacy_sprite = get_node_or_null("Sprite2D") as Sprite2D
	if legacy_sprite:
		legacy_sprite.visible = false
	character_sprite = Sprite2D.new()
	character_sprite.name = "CharacterSprite"
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.centered = true
	character_sprite.position = Vector2(0, -31)
	add_child(character_sprite)
	stand()

func _process(delta: float) -> void:
	if state != State.WALKING:
		return
	walk_elapsed += delta
	var next_frame := int(floor(walk_elapsed * 7.0)) % 2
	if next_frame != walk_frame:
		walk_frame = next_frame
		character_sprite.texture = WALK_A_TEXTURE if walk_frame == 0 else WALK_B_TEXTURE
	character_sprite.position.y = -31 + (1 if walk_frame == 1 else 0)

func _apply_texture(texture: Texture2D, y_offset: float = -31.0) -> void:
	if character_sprite == null:
		return
	character_sprite.texture = texture
	character_sprite.flip_h = facing_left
	character_sprite.position = Vector2(0, y_offset)

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
	_apply_texture(WALK_A_TEXTURE)
	var duration := distance / walk_speed
	var elapsed := 0.0
	while elapsed < duration:
		var delta := get_process_delta_time()
		elapsed += delta
		global_position = start_position.lerp(target_position, clampf(elapsed / duration, 0.0, 1.0))
		await get_tree().process_frame
	global_position = target_position
	_finish_walk()

func _finish_walk() -> void:
	state = State.STANDING
	walk_elapsed = 0.0
	_apply_texture(IDLE_TEXTURE)

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
	_apply_texture(IDLE_TEXTURE)

func sit() -> void:
	state = State.SITTING
	facing_left = false
	_apply_texture(SIT_TEXTURE, -31)

func watch_stage() -> void:
	state = State.WATCHING
	facing_left = false
	_apply_texture(SIT_TEXTURE, -31)

func react() -> void:
	state = State.REACTING
	_apply_texture(IDLE_TEXTURE)

func idle() -> void:
	state = State.IDLE
	_apply_texture(IDLE_TEXTURE)
