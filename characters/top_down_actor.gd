extends CharacterBody2D
class_name TopDownActor
## Keyboard and controller-ready old-school movement. Episode code supplies
## intent only; collision resolution remains the CharacterBody2D's job.

@export var speed: float = 70.0
@export var display_name: String = "ADAM"
@export var role: StringName = &"adam"

var movement_enabled := true
var facing := Vector2.DOWN
var _intent := Vector2.ZERO

func set_move_intent(intent: Vector2) -> void:
	_intent = intent.limit_length(1.0)
	if not _intent.is_zero_approx():
		facing = _intent.normalized()

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		return
	velocity = _intent * speed
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	var hair := Color("#42281d") if role == &"adam" else Color("#5b3323")
	var robe := Color("#9d603e") if role == &"adam" else Color("#b66b4d")
	draw_circle(Vector2(0, -9), 6.0, Color("#d28c61"))
	draw_arc(Vector2(0, -10), 7.0, PI, TAU, 10, hair, 3.5)
	if role == &"eve":
		draw_line(Vector2(-6, -8), Vector2(-8, 4), hair, 2.0)
		draw_line(Vector2(6, -8), Vector2(8, 4), hair, 2.0)
	draw_rect(Rect2(-6, -3, 12, 13), robe)
	draw_line(Vector2(-3, 10), Vector2(-4, 15), Color("#865239"), 3.0)
	draw_line(Vector2(3, 10), Vector2(4, 15), Color("#865239"), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(-17, 26), display_name, HORIZONTAL_ALIGNMENT_CENTER, 34, 7, Color("#fff4d5"))
