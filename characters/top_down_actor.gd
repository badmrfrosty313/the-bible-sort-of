extends CharacterBody2D
class_name TopDownActor
## Reusable four-direction actor using the repository's 64px 4x4 sheets.

const FRAME_SIZE := Vector2i(64, 64)
const SHEETS := {
	&"adam": preload("res://art/characters/adam/adam_leaves_walk.png"),
	&"eve": preload("res://art/characters/eve/eve_leaves_walk.png"),
	&"god": preload("res://art/characters/god/god_walk.png"),
}
const DIRECTIONS := [&"down", &"left", &"right", &"up"]

@export var speed: float = 70.0
@export var display_name: String = "ADAM"
@export var role: StringName = &"adam"

var movement_enabled := true
var facing := Vector2.DOWN
var _intent := Vector2.ZERO
var _configured_role: StringName = &""
var _sprite: AnimatedSprite2D

func _ready() -> void:
	_ensure_sprite_sheet()
	_update_animation()

func set_move_intent(intent: Vector2) -> void:
	_intent = intent.limit_length(1.0)
	if not _intent.is_zero_approx():
		facing = _intent.normalized()

func _physics_process(_delta: float) -> void:
	_ensure_sprite_sheet()
	if not movement_enabled:
		velocity = Vector2.ZERO
		_update_animation()
		return
	velocity = _intent * speed
	move_and_slide()
	_update_animation()

func _ensure_sprite_sheet() -> void:
	if _configured_role == role and _sprite != null:
		return
	_configured_role = role
	if _sprite == null:
		_sprite = AnimatedSprite2D.new()
		_sprite.name = "Sprite"
		_sprite.position = Vector2(0, -22)
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(_sprite)
	var texture := SHEETS.get(role) as Texture2D
	if texture == null:
		_sprite.hide()
		return
	var frames := SpriteFrames.new()
	for row in DIRECTIONS.size():
		var direction: StringName = DIRECTIONS[row]
		var idle := "idle_" + String(direction)
		frames.add_animation(idle)
		frames.set_animation_loop(idle, false)
		frames.add_frame(idle, _frame(texture, row, 0))
		var walk := "walk_" + String(direction)
		frames.add_animation(walk)
		frames.set_animation_speed(walk, 8.0)
		frames.set_animation_loop(walk, true)
		for column in [0, 1, 2, 3]:
			frames.add_frame(walk, _frame(texture, row, column))
	_sprite.sprite_frames = frames
	_sprite.show()

func _frame(texture: Texture2D, row: int, column: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = texture
	frame.region = Rect2(column * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return frame

func _update_animation() -> void:
	if _sprite == null or not _sprite.visible:
		return
	var direction := _direction_name()
	var animation := ("walk_" if not _intent.is_zero_approx() and movement_enabled else "idle_") + direction
	if _sprite.animation != animation:
		_sprite.play(animation)
	elif not _sprite.is_playing():
		_sprite.play()

func _direction_name() -> String:
	if absf(facing.x) > absf(facing.y):
		return "right" if facing.x > 0.0 else "left"
	return "down" if facing.y >= 0.0 else "up"

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(-17, 26), display_name, HORIZONTAL_ALIGNMENT_CENTER, 34, 7, Color("#fff4d5"))
