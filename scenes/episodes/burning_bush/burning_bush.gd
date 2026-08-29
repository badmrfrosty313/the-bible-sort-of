extends Node2D
class_name BurningBushEpisode

signal episode_finished
signal father_line_requested(text: String)
signal father_enter_requested(entry_position: Vector2)
signal father_exit_requested

var dialogue_label: Label
var prompt_label: Label
var moses: Node2D
var bush_flame: Polygon2D

const OBJECTIONS := [
	"MOSES: Who am I supposed to be?",
	"MOSES: What if they ask Your name?",
	"MOSES: What if they don't believe me?",
	"MOSES: I am REALLY not good at public speaking.",
	"MOSES: Could You maybe send literally anyone else?"
]

const FATHER_REPLIES := [
	"You're Moses. We've covered this.",
	"Tell them I AM sent you.",
	"They won't. That's why we're doing signs.",
	"I know.",
	"Moses."
]

func _ready() -> void:
	_build_scene()
	await _run_episode()

func _build_scene() -> void:
	var sky := Polygon2D.new()
	sky.color = Color("#5B3948")
	sky.polygon = PackedVector2Array([Vector2(52, 48), Vector2(428, 48), Vector2(428, 208), Vector2(52, 208)])
	add_child(sky)

	var ground := Polygon2D.new()
	ground.color = Color("#8A6545")
	ground.polygon = PackedVector2Array([Vector2(52, 160), Vector2(428, 160), Vector2(428, 208), Vector2(52, 208)])
	add_child(ground)

	var bush := Polygon2D.new()
	bush.color = Color("#3E5C35")
	bush.polygon = PackedVector2Array([Vector2(305, 163), Vector2(326, 143), Vector2(348, 163), Vector2(340, 183), Vector2(313, 183)])
	add_child(bush)

	bush_flame = Polygon2D.new()
	bush_flame.color = Color("#E46D32")
	bush_flame.polygon = PackedVector2Array([Vector2(316, 165), Vector2(322, 145), Vector2(328, 154), Vector2(334, 132), Vector2(342, 158), Vector2(338, 174), Vector2(320, 174)])
	add_child(bush_flame)

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
	father_line_requested.emit("Moses.")
	await _beat(1.2)
	dialogue_label.text = "MOSES: Yep. Talking bush. Sure."
	await _beat(1.5)
	father_line_requested.emit("I need you to go to Egypt.")
	await _beat(1.5)

	for i in range(OBJECTIONS.size()):
		dialogue_label.text = OBJECTIONS[i]
		await _beat(1.35)
		prompt_label.text = "ACCEPT QUEST?   [ NO ]"
		prompt_label.visible = true
		await _beat(0.75)
		prompt_label.visible = false
		father_line_requested.emit(FATHER_REPLIES[i])
		await _beat(1.0)

	# Talking has failed. Father physically enters the episode.
	dialogue_label.text = "MOSES: So... anyone else?"
	await _beat(0.8)
	father_enter_requested.emit(Vector2(255, 150))
	await _beat(1.0)
	father_line_requested.emit("Fine. Aaron can help.")
	await _beat(1.1)
	prompt_label.text = "ACCEPT QUEST?   [ YES ]"
	prompt_label.visible = true
	await _beat(1.0)
	prompt_label.visible = false
	dialogue_label.text = "MOSES: Fine."
	await _beat(0.9)
	father_line_requested.emit("Excellent. I'm going back to my chair.")
	await _beat(0.9)
	father_exit_requested.emit()
	await _beat(1.2)
	dialogue_label.text = "QUEST ACCEPTED: EXODUS"
	await _beat(1.4)
	episode_finished.emit()

func _process(_delta: float) -> void:
	if bush_flame != null:
		bush_flame.scale.y = 0.92 + (sin(Time.get_ticks_msec() * 0.012) * 0.08)

func _beat(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
