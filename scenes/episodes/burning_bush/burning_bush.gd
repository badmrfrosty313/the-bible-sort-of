extends Node2D
class_name BurningBushEpisode

signal episode_finished

var dialogue_label: Label
var prompt_label: Label
var moses: Node2D
var bush_flame: Polygon2D
var objection_index := 0

const OBJECTIONS := [
	"MOSES: Who am I supposed to be?",
	"MOSES: What if they ask Your name?",
	"MOSES: What if they don't believe me?",
	"MOSES: I am REALLY not good at public speaking.",
	"MOSES: Could You maybe send literally anyone else?"
]

func _ready() -> void:
	_build_scene()
	await _run_episode()

func _build_scene() -> void:
	# Desert sky and ground, intentionally chunky for the pixel-art target.
	var sky := Polygon2D.new()
	sky.color = Color("#5B3948")
	sky.polygon = PackedVector2Array([Vector2(52, 48), Vector2(428, 48), Vector2(428, 208), Vector2(52, 208)])
	add_child(sky)

	var ground := Polygon2D.new()
	ground.color = Color("#8A6545")
	ground.polygon = PackedVector2Array([Vector2(52, 160), Vector2(428, 160), Vector2(428, 208), Vector2(52, 208)])
	add_child(ground)

	# Burning bush placeholder. We will swap this for authored pixel art later.
	var bush := Polygon2D.new()
	bush.color = Color("#3E5C35")
	bush.polygon = PackedVector2Array([Vector2(305, 163), Vector2(326, 143), Vector2(348, 163), Vector2(340, 183), Vector2(313, 183)])
	add_child(bush)

	bush_flame = Polygon2D.new()
	bush_flame.color = Color("#E46D32")
	bush_flame.polygon = PackedVector2Array([Vector2(316, 165), Vector2(322, 145), Vector2(328, 154), Vector2(334, 132), Vector2(342, 158), Vector2(338, 174), Vector2(320, 174)])
	add_child(bush_flame)

	# Moses placeholder silhouette until the Moses art is committed.
	moses = Node2D.new()
	moses.name = "Moses"
	moses.position = Vector2(150, 153)
	add_child(moses)

	var body := Polygon2D.new()
	body.color = Color("#D1B28B")
	body.polygon = PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(14, 37), Vector2(-14, 37)])
	moses.add_child(body)

	var head := Polygon2D.new()
	head.color = Color("#B98562")
	head.polygon = PackedVector2Array([Vector2(-7, -13), Vector2(7, -13), Vector2(9, 0), Vector2(-9, 0)])
	moses.add_child(head)

	_build_dialogue_ui()

func _build_dialogue_ui() -> void:
	dialogue_label = Label.new()
	dialogue_label.position = Vector2(70, 58)
	dialogue_label.size = Vector2(340, 45)
	dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.add_theme_font_size_override("font_size", 11)
	add_child(dialogue_label)

	prompt_label = Label.new()
	prompt_label.position = Vector2(140, 187)
	prompt_label.size = Vector2(200, 18)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 11)
	prompt_label.visible = false
	add_child(prompt_label)

func _run_episode() -> void:
	dialogue_label.text = "MOSES: That bush is on fire."
	await _beat(1.5)
	dialogue_label.text = "MOSES: ...and somehow still a bush."
	await _beat(1.6)
	dialogue_label.text = "GOD: Moses."
	await _beat(1.2)
	dialogue_label.text = "MOSES: Yep. Talking bush. Sure."
	await _beat(1.5)
	dialogue_label.text = "GOD: I need you to go to Egypt."
	await _beat(1.5)

	for objection in OBJECTIONS:
		dialogue_label.text = objection
		await _beat(1.35)
		prompt_label.text = "ACCEPT QUEST?   [ NO ]"
		prompt_label.visible = true
		await _beat(0.85)
		prompt_label.visible = false
		dialogue_label.text = "GOD: ..."
		await _beat(0.65)

	dialogue_label.text = "GOD: Aaron can help."
	await _beat(1.0)
	prompt_label.text = "ACCEPT QUEST?   [ YES ]"
	prompt_label.visible = true
	await _beat(1.25)
	prompt_label.visible = false
	dialogue_label.text = "MOSES: Fine."
	await _beat(1.0)
	dialogue_label.text = "QUEST ACCEPTED: EXODUS"
	await _beat(1.5)
	episode_finished.emit()

func _process(_delta: float) -> void:
	if bush_flame != null:
		# Tiny deterministic flicker without needing an animation asset yet.
		bush_flame.scale.y = 0.92 + (sin(Time.get_ticks_msec() * 0.012) * 0.08)

func _beat(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
