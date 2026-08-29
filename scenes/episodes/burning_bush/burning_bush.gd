extends Node2D
class_name BurningBushEpisode

signal episode_finished

const MOSES_IDLE_TEXTURE := preload("res://art/characters/moses/moses_idle.svg")
const MOSES_SHRUG_TEXTURE := preload("res://art/characters/moses/moses_shrug.svg")

const SCREEN_LEFT := 52.0
const SCREEN_RIGHT := 428.0
const SCREEN_TOP := 36.0
const SCREEN_BOTTOM := 198.0

const OBJECTIONS := ["Who am I supposed to be?","What if they ask Your name?","What if they don't believe me?","I am REALLY not good at public speaking.","Could You maybe send literally anyone else?"]
const FATHER_REPLIES := ["You're Moses. We've covered this.","Tell them I AM sent you.","They won't. That's why we're doing signs.","I know.","Moses."]

var director
var moses: Node2D
var moses_sprite: Sprite2D
var flame_outer: Polygon2D
var flame_mid: Polygon2D
var flame_core: Polygon2D
var embers: Array[Polygon2D] = []
var dialogue_panel: Panel
var speaker_label: Label
var dialogue_label: Label
var prompt_panel: Panel
var prompt_label: Label

func _ready() -> void:
	_build_scene()
	await get_tree().create_timer(0.35).timeout
	await _run_episode()

func _build_scene() -> void:
	_build_desert()
	_build_burning_bush()
	_build_moses()
	_build_dialogue_ui()

func _build_desert() -> void:
	_rect_poly(Color("#3B2748"),Rect2(SCREEN_LEFT,SCREEN_TOP,376,58))
	_rect_poly(Color("#5A3652"),Rect2(SCREEN_LEFT,94,376,33))
	_rect_poly(Color("#8A4C53"),Rect2(SCREEN_LEFT,127,376,28))
	_poly(Color("#2B2440"),PackedVector2Array([Vector2(52,139),Vector2(93,101),Vector2(126,132),Vector2(160,109),Vector2(200,144),Vector2(52,144)]))
	_poly(Color("#342844"),PackedVector2Array([Vector2(190,144),Vector2(245,111),Vector2(281,139),Vector2(331,103),Vector2(382,141),Vector2(428,116),Vector2(428,148),Vector2(190,148)]))
	_rect_poly(Color("#B66A4D"),Rect2(SCREEN_LEFT,145,376,16))
	_rect_poly(Color("#A8754B"),Rect2(SCREEN_LEFT,160,376,38))
	_poly(Color("#C18B58"),PackedVector2Array([Vector2(52,182),Vector2(120,174),Vector2(188,181),Vector2(252,170),Vector2(324,180),Vector2(428,169),Vector2(428,198),Vector2(52,198)]))
	_circle(Vector2(390,62),9.0,Color("#E4C78A"),14)
	_circle(Vector2(388,60),8.0,Color("#3B2748"),14)
	for star in [Vector2(83,66),Vector2(122,82),Vector2(182,61),Vector2(224,76),Vector2(302,61),Vector2(347,88)]:
		_rect_poly(Color("#E6C98B"),Rect2(star,Vector2(2,2)))
	_poly(Color("#6F4A3D"),PackedVector2Array([Vector2(270,191),Vector2(276,183),Vector2(286,181),Vector2(294,190),Vector2(294,194),Vector2(270,194)]))
	_poly(Color("#78503F"),PackedVector2Array([Vector2(373,193),Vector2(378,186),Vector2(386,184),Vector2(393,193),Vector2(373,193)]))

func _build_burning_bush() -> void:
	var bush := Node2D.new()
	bush.name = "BurningBush"
	bush.position = Vector2(336,188)
	add_child(bush)
	_poly_at(bush,Color("#2E3823"),PackedVector2Array([Vector2(-25,-5),Vector2(-31,-18),Vector2(-20,-31),Vector2(-12,-27),Vector2(-5,-42),Vector2(3,-30),Vector2(13,-38),Vector2(20,-25),Vector2(31,-17),Vector2(24,-5)]))
	_poly_at(bush,Color("#486238"),PackedVector2Array([Vector2(-21,-7),Vector2(-25,-18),Vector2(-15,-26),Vector2(-8,-23),Vector2(-3,-35),Vector2(5,-25),Vector2(13,-31),Vector2(24,-16),Vector2(19,-7)]))
	_rect_poly_at(bush,Color("#4A2E1D"),Rect2(-3,-9,7,10))
	_rect_poly_at(bush,Color("#6B4224"),Rect2(-15,-17,29,4))
	flame_outer = Polygon2D.new()
	flame_outer.color = Color("#E64F24")
	flame_outer.polygon = PackedVector2Array([Vector2(-18,-11),Vector2(-22,-28),Vector2(-13,-42),Vector2(-9,-58),Vector2(-1,-47),Vector2(4,-71),Vector2(13,-50),Vector2(20,-39),Vector2(16,-18),Vector2(10,-9),Vector2(-10,-9)])
	bush.add_child(flame_outer)
	flame_mid = Polygon2D.new()
	flame_mid.color = Color("#FF8A28")
	flame_mid.polygon = PackedVector2Array([Vector2(-12,-12),Vector2(-15,-29),Vector2(-7,-42),Vector2(-3,-55),Vector2(3,-42),Vector2(8,-57),Vector2(14,-36),Vector2(11,-17),Vector2(5,-10),Vector2(-7,-10)])
	bush.add_child(flame_mid)
	flame_core = Polygon2D.new()
	flame_core.color = Color("#FFD45A")
	flame_core.polygon = PackedVector2Array([Vector2(-7,-11),Vector2(-9,-25),Vector2(-2,-37),Vector2(2,-48),Vector2(7,-31),Vector2(8,-18),Vector2(4,-10)])
	bush.add_child(flame_core)
	for i in range(4):
		var ember := Polygon2D.new()
		ember.color = Color("#FFB23E")
		ember.polygon = PackedVector2Array([Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)])
		ember.position = Vector2(-10+i*7,-58-i*5)
		bush.add_child(ember)
		embers.append(ember)

func _build_moses() -> void:
	moses = Node2D.new()
	moses.name = "Moses"
	moses.position = Vector2(145,190)
	moses.z_index = 4
	add_child(moses)
	moses_sprite = Sprite2D.new()
	moses_sprite.name = "Sprite"
	moses_sprite.texture = MOSES_IDLE_TEXTURE
	moses_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	moses_sprite.centered = true
	moses_sprite.position = Vector2(0,-31)
	moses.add_child(moses_sprite)

func _build_dialogue_ui() -> void:
	dialogue_panel = Panel.new()
	dialogue_panel.position = Vector2(83,53)
	dialogue_panel.size = Vector2(314,43)
	dialogue_panel.z_index = 20
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dialogue_style := StyleBoxFlat.new()
	dialogue_style.bg_color = Color("#120F19E8")
	dialogue_style.border_color = Color("#A9824A")
	dialogue_style.border_width_left = 1
	dialogue_style.border_width_top = 1
	dialogue_style.border_width_right = 1
	dialogue_style.border_width_bottom = 1
	dialogue_style.corner_radius_top_left = 3
	dialogue_style.corner_radius_top_right = 3
	dialogue_style.corner_radius_bottom_left = 3
	dialogue_style.corner_radius_bottom_right = 3
	dialogue_panel.add_theme_stylebox_override("panel",dialogue_style)
	add_child(dialogue_panel)
	speaker_label = Label.new()
	speaker_label.text = "MOSES"
	speaker_label.position = Vector2(9,4)
	speaker_label.size = Vector2(60,10)
	speaker_label.add_theme_font_size_override("font_size",8)
	speaker_label.add_theme_color_override("font_color",Color("#E0A64C"))
	dialogue_panel.add_child(speaker_label)
	dialogue_label = Label.new()
	dialogue_label.position = Vector2(9,15)
	dialogue_label.size = Vector2(296,23)
	dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.add_theme_font_size_override("font_size",10)
	dialogue_label.add_theme_color_override("font_color",Color("#F6F1E9"))
	dialogue_panel.add_child(dialogue_label)
	prompt_panel = Panel.new()
	prompt_panel.position = Vector2(160,164)
	prompt_panel.size = Vector2(160,27)
	prompt_panel.pivot_offset = Vector2(80,13)
	prompt_panel.visible = false
	prompt_panel.z_index = 22
	prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt_panel)
	prompt_label = Label.new()
	prompt_label.position = Vector2(5,3)
	prompt_label.size = Vector2(150,20)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size",9)
	prompt_panel.add_child(prompt_label)
	_set_prompt_style(false)

func _run_episode() -> void:
	await _say_moses("That bush is on fire.",1.05)
	await _say_moses("...and somehow still a bush.",1.10)
	await _father("Moses.",0.75)
	await _say_moses("Yep. Talking bush. Sure.",1.00)
	await _father("I need you to go to Egypt.",1.00)
	for i in range(OBJECTIONS.size()):
		moses_sprite.texture = MOSES_SHRUG_TEXTURE
		await _say_moses(OBJECTIONS[i],0.95)
		await _show_prompt(false,0.52)
		moses_sprite.texture = MOSES_IDLE_TEXTURE
		await _father(FATHER_REPLIES[i],0.85)
	await _say_moses("So... anyone else?",0.72)
	moses_sprite.texture = MOSES_SHRUG_TEXTURE
	if director != null:
		await director.send_father_into_episode(Vector2(264,190))
	await _father("Fine. Aaron can help.",0.90)
	await _show_prompt(true,0.75)
	moses_sprite.texture = MOSES_IDLE_TEXTURE
	await _say_moses("Fine.",0.58)
	await _father("Excellent. I'm going back to my chair.",0.82)
	if director != null:
		await director.return_father_to_theater()
	await _show_quest_accepted()
	episode_finished.emit()
	if director != null:
		await director._on_episode_finished()

func _say_moses(text: String,hold: float) -> void:
	speaker_label.text = "MOSES"
	dialogue_label.text = text
	dialogue_panel.modulate = Color(1,1,1,0)
	dialogue_panel.visible = true
	var fade := create_tween()
	fade.tween_property(dialogue_panel,"modulate:a",1.0,0.08)
	await fade.finished
	await get_tree().create_timer(hold).timeout

func _father(text: String,hold: float) -> void:
	if director == null:
		await get_tree().create_timer(hold).timeout
		return
	await director.father_speak(text,hold)

func _show_prompt(accepted: bool,hold: float) -> void:
	_set_prompt_style(accepted)
	prompt_label.text = "ACCEPT QUEST?   [ YES ]" if accepted else "ACCEPT QUEST?   [ NO ]"
	prompt_panel.modulate = Color(1,1,1,0)
	prompt_panel.visible = true
	var fade_in := create_tween()
	fade_in.tween_property(prompt_panel,"modulate:a",1.0,0.08)
	await fade_in.finished
	var pulse := create_tween()
	pulse.tween_property(prompt_panel,"scale",Vector2(1.03,1.03),0.08)
	pulse.tween_property(prompt_panel,"scale",Vector2.ONE,0.08)
	await pulse.finished
	await get_tree().create_timer(hold).timeout
	var fade_out := create_tween()
	fade_out.tween_property(prompt_panel,"modulate:a",0.0,0.08)
	await fade_out.finished
	prompt_panel.visible = false

func _set_prompt_style(accepted: bool) -> void:
	if prompt_panel == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#111018F2")
	style.border_color = Color("#61A66F") if accepted else Color("#B94A52")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	prompt_panel.add_theme_stylebox_override("panel",style)
	prompt_label.add_theme_color_override("font_color",Color("#A9E4B2") if accepted else Color("#F0A0A4"))

func _show_quest_accepted() -> void:
	_set_prompt_style(true)
	prompt_panel.position = Vector2(146,162)
	prompt_panel.size = Vector2(188,29)
	prompt_panel.pivot_offset = Vector2(94,14)
	prompt_label.size = Vector2(178,22)
	prompt_label.text = "QUEST ACCEPTED: EXODUS"
	prompt_panel.visible = true
	prompt_panel.modulate = Color(1,1,1,0)
	var fade := create_tween()
	fade.tween_property(prompt_panel,"modulate:a",1.0,0.12)
	await fade.finished
	await get_tree().create_timer(1.10).timeout

func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	if flame_outer != null:
		flame_outer.scale.y = 0.96 + sin(t*9.0)*0.05
		flame_outer.position.x = round(sin(t*6.0))
	if flame_mid != null:
		flame_mid.scale.y = 0.94 + sin(t*11.0+1.2)*0.07
		flame_mid.position.x = round(sin(t*8.0+0.8))
	if flame_core != null:
		flame_core.scale.y = 0.93 + sin(t*13.0+2.0)*0.08
	for i in range(embers.size()):
		var ember := embers[i]
		var cycle := fmod(t*(8.0+i),22.0)
		ember.position.y = -53.0-cycle-i*3.0
		ember.position.x = -9.0+i*6.0+sin(t*4.0+i)*3.0
		ember.modulate = Color(1,1,1,1.0-(cycle/22.0))

func _rect_poly(color: Color,rect: Rect2) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.position+rect.size,rect.position+Vector2(0,rect.size.y)])
	add_child(poly)
	return poly

func _rect_poly_at(parent: Node2D,color: Color,rect: Rect2) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.position+rect.size,rect.position+Vector2(0,rect.size.y)])
	parent.add_child(poly)
	return poly

func _poly(color: Color,points: PackedVector2Array) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = points
	add_child(poly)
	return poly

func _poly_at(parent: Node2D,color: Color,points: PackedVector2Array) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = points
	parent.add_child(poly)
	return poly

func _circle(center: Vector2,radius: float,color: Color,count: int) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(center+Vector2(cos(angle),sin(angle))*radius)
	poly.polygon = points
	add_child(poly)
	return poly
