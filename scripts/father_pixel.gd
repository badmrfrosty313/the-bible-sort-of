extends Node2D
class_name Father

enum State { IDLE, WALKING, STANDING, SITTING, WATCHING, REACTING }

@export var walk_speed: float = 72.0

const MOVEMENT_SHEET := preload("res://art/characters/father_movement_sheet/father_movement_sheet.png")
const SIT_BACK_TEXTURE := preload("res://art/characters/father/father_sit_back.svg")
const FRAME_SIZE := Vector2i(48, 64)
const STAND_OFFSET_Y := -32.0
const WALK_OFFSET_Y := -32.0
const SIT_OFFSET_Y := -31.0

var state: State = State.IDLE
var character_sprite: Sprite2D
var facing_left: bool = false
var walk_elapsed: float = 0.0
var walk_frame: int = 0
var idle_elapsed: float = 0.0
var stand_texture: Texture2D
var walk_textures: Array[Texture2D] = []

func _ready() -> void:
	var old_sprite := get_node_or_null("Sprite2D") as Sprite2D
	if old_sprite != null:
		old_sprite.visible = false
	_build_pixel_frames()
	character_sprite = Sprite2D.new()
	character_sprite.name = "CharacterSprite"
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.centered = true
	add_child(character_sprite)
	stand()

func _build_pixel_frames() -> void:
	stand_texture = _extract_pixel_frame(Rect2i(70, 36, 245, 310))
	walk_textures.clear()
	walk_textures.append(_extract_pixel_frame(Rect2i(65, 382, 245, 305)))
	walk_textures.append(_extract_pixel_frame(Rect2i(300, 382, 245, 305)))
	walk_textures.append(_extract_pixel_frame(Rect2i(540, 382, 245, 305)))
	walk_textures.append(_extract_pixel_frame(Rect2i(780, 382, 245, 305)))
	walk_textures.append(_extract_pixel_frame(Rect2i(1020, 382, 245, 305)))
	walk_textures.append(_extract_pixel_frame(Rect2i(1260, 382, 260, 305)))

func _extract_pixel_frame(region: Rect2i) -> Texture2D:
	var source: Image = MOVEMENT_SHEET.get_image()
	var cropped: Image = source.get_region(region)
	cropped.resize(FRAME_SIZE.x, FRAME_SIZE.y, Image.INTERPOLATE_LANCZOS)
	for y in range(cropped.get_height()):
		for x in range(cropped.get_width()):
			var c: Color = cropped.get_pixel(x, y)
			if c.r > 0.94 and c.g > 0.94 and c.b > 0.94:
				cropped.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				var levels: float = 6.0
				c.r = round(c.r * levels) / levels
				c.g = round(c.g * levels) / levels
				c.b = round(c.b * levels) / levels
				c.a = 1.0
				cropped.set_pixel(x, y, c)
	return ImageTexture.create_from_image(cropped)

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
	elif state == State.WATCHING:
		idle_elapsed += delta
		character_sprite.position.y = SIT_OFFSET_Y + (1.0 if int(idle_elapsed * 1.7) % 4 == 3 else 0.0)

func _show(texture: Texture2D, y_offset: float) -> void:
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
	_show(walk_textures[0], WALK_OFFSET_Y)
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
	_show(stand_texture, STAND_OFFSET_Y)

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
	_show(stand_texture, STAND_OFFSET_Y)

func sit() -> void:
	state = State.SITTING
	facing_left = false
	idle_elapsed = 0.0
	_show(SIT_BACK_TEXTURE, SIT_OFFSET_Y)

func watch_stage() -> void:
	state = State.WATCHING
	facing_left = false
	idle_elapsed = 0.0
	_show(SIT_BACK_TEXTURE, SIT_OFFSET_Y)

func react() -> void:
	state = State.REACTING
	_show(stand_texture, STAND_OFFSET_Y)

func idle() -> void:
	state = State.IDLE
	_show(stand_texture, STAND_OFFSET_Y)
