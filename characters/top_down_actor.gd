extends CharacterBody2D
class_name TopDownActor
## Reusable four-direction actor using the repository's 64px 4x4 sheets.

const FRAME_SIZE := Vector2i(64, 64)
const SHEETS := {
	&"adam": "res://art/characters/adam/adam_leaves_walk.png",
	&"eve": "res://art/characters/eve/eve_leaves_walk.png",
	&"god": "res://art/characters/god/god_walk.png",
}
const DIRECTIONS := [&"down", &"left", &"right", &"up"]
enum Presentation { PRE_FALL_MODESTY, POST_FALL_CENSOR, LEAVES }
# All conceptual states use approved covered leaf sheets until dedicated art exists.
var presentation: Presentation = Presentation.PRE_FALL_MODESTY
var rendered_presentation: Presentation = Presentation.LEAVES
var fallback_active := false

@export var speed: float = 70.0
@export var display_name: String = "ADAM"
@export var role: StringName = &"adam":
	set(value):
		role = value
		if is_inside_tree():
			_ensure_sprite_sheet()
			_update_animation()
			queue_redraw()

var movement_enabled := true
var facing := Vector2.DOWN
var _intent := Vector2.ZERO
var _configured_role: StringName = &""
var _sprite: AnimatedSprite2D

func _ready() -> void:
	z_index = 1
	_ensure_sprite_sheet()
	_update_animation()

func set_move_intent(intent: Vector2) -> void:
	_intent = intent.limit_length(1.0)
	if not _intent.is_zero_approx():
		facing = _intent.normalized()
	_update_animation()

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
	var path: String = SHEETS.get(role, "")
	var texture := RuntimeTexture.load_texture(path, Vector2i(256, 256)) if not path.is_empty() else null
	fallback_active = texture == null
	queue_redraw()
	if texture == null:
		push_warning("ACTOR ART FAILURE: " + display_name + " (" + String(role) + ") — covered placeholder retained")
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
	frame.filter_clip = true
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
	if fallback_active:
		draw_circle(Vector2(0, -22), 7, Color("#e1ae77"))
		draw_rect(Rect2(-9, -15, 18, 18), Color("#eee5d1") if role == &"god" else Color("#315f2d"))
		draw_rect(Rect2(-10, -30, 20, 35), Color("#ffb94a"), false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(-20, 16), display_name, HORIZONTAL_ALIGNMENT_CENTER, 40, 7, Color("#fff4d5"))

func visible_frame_bounds() -> Rect2:
	return Rect2(global_position + Vector2(-32, -54), Vector2(64, 64))
