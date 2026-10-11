extends Control

const OUTLINE := Color("#3a1809")
const GOLD := Color("#ffd477")

func _ready() -> void:
	custom_minimum_size = Vector2(24, 30)
	queue_redraw()

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(1, 1), Vector2(23, 15), Vector2(1, 29), Vector2(5, 15)
	]), OUTLINE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(5, 6), Vector2(17, 15), Vector2(5, 24), Vector2(8, 15)
	]), GOLD)
