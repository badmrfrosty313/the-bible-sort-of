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
var bush_root: Node2D
var bush_glow: Polygon2D
var flame_outer: Polygon2D
var flame_mid: Polygon2D
var flame_core: Polygon2D
var embers: Array[Polygon2D] = []
var dialogue_panel: Panel
var speaker_label: Label
var dialogue_label: Label
var prompt_panel: Panel
var prompt_label: Label
var father_speaking := false
var father_speech_strength := 0.0
var moses_reaction_strength := 0.0

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
	# Mockup-driven dusk sky: broad bands are deliberately stepped like a 16-bit backdrop.
	_rect_poly(Color("#211A38"),Rect2(SCREEN_LEFT,SCREEN_TOP,376,31))
	_rect_poly(Color("#302044"),Rect2(SCREEN_LEFT,67,376,28))
	_rect_poly(Color("#51304D"),Rect2(SCREEN_LEFT,95,376,25))
	_rect_poly(Color("#794451"),Rect2(SCREEN_LEFT,120,376,22))
	_rect_poly(Color("#A45D50"),Rect2(SCREEN_LEFT,142,376,17))

	# Sparse stars and a crescent moon.
	for star in [Vector2(73,53),Vector2(101,72),Vector2(137,49),Vector2(178,78),Vector2(215,58),Vector2(252,84),Vector2(292,54),Vector2(326,74),Vector2(360,48)]:
		_rect_poly(Color("#F1D79B"),Rect2(star,Vector2(2,2)))
	_circle(Vector2(394,58),10.0,Color("#F0D18D"),16)
	_circle(Vector2(390,54),9.0,Color("#211A38"),16)

	# Layered mountains from the mockup: cool silhouettes against the warm horizon.
	_poly(Color("#29213E"),PackedVector2Array([Vector2(52,145),Vector2(82,116),Vector2(105,132),Vector2(132,99),Vector2(165,137),Vector2(194,111),Vector2(225,145)]))
	_poly(Color("#342744"),PackedVector2Array([Vector2(164,146),Vector2(209,112),Vector2(237,137),Vector2(274,103),Vector2(305,137),Vector2(344,109),Vector2(380,139),Vector2(428,112),Vector2(428,151),Vector2(164,151)]))
	_poly(Color("#4C3046"),PackedVector2Array([Vector2(52,153),Vector2(95,136),Vector2(128,149),Vector2(172,129),Vector2(211,151),Vector2(260,133),Vector2(304,151),Vector2(353,130),Vector2(396,149),Vector2(428,137),Vector2(428,160),Vector2(52,160)]))

	# Sand with stepped highlights rather than one flat slab.
	_rect_poly(Color("#8C5A45"),Rect2(SCREEN_LEFT,158,376,40))
	_poly(Color("#A86F4B"),PackedVector2Array([Vector2(52,174),Vector2(91,169),Vector2(129,176),Vector2(168,168),Vector2(207,177),Vector2(249,166),Vector2(290,176),Vector2(334,165),Vector2(377,173),Vector2(428,164),Vector2(428,198),Vector2(52,198)]))
	_poly(Color("#C08A58"),PackedVector2Array([Vector2(52,188),Vector2(107,181),Vector2(154,188),Vector2(205,179),Vector2(259,188),Vector2(310,179),Vector2(365,187),Vector2(428,178),Vector2(428,198),Vector2(52,198)]))

	# Rocks and scrub make the stage read like the detailed mockup instead of empty geometry.
	_rock(Vector2(88,187),12.0)
	_rock(Vector2(230,190),9.0)
	_rock(Vector2(390,190),8.0)
	_grass(Vector2(116,190),Color("#65543A"))
	_grass(Vector2(196,187),Color("#5A4B37"))
	_grass(Vector2(286,191),Color("#67583B"))
	_grass(Vector2(414,187),Color("#554733"))

	# Firelight painted onto the sand under the bush.
	_poly(Color("#D68A4A88"),PackedVector2Array([Vector2(292,197),Vector2(306,183),Vector2(336,176),Vector2(368,183),Vector2(387,197)]))
	_poly(Color("#F0A34B66"),PackedVector2Array([Vector2(310,197),Vector2(321,185),Vector2(337,181),Vector2(354,186),Vector2(368,197)]))

func _build_burning_bush() -> void:
	bush_root = Node2D.new()
	bush_root.name = "BurningBush"
	bush_root.position = Vector2(337,190)
	bush_root.z_index = 3
	add_child(bush_root)

	bush_glow = _circle_at(bush_root,Vector2(0,-31),45.0,Color("#FFB33A24"),20)
	bush_glow.z_index = -2

	# Dense layered foliage, closer to the leafy mockup than the original single polygon.
	_rect_poly_at(bush_root,Color("#4A2E1D"),Rect2(-3,-14,7,15))
	_rect_poly_at(bush_root,Color("#714424"),Rect2(-16,-18,32,5))
	_leaf(Vector2(-21,-17),10,Color("#263825"))
	_leaf(Vector2(-12,-27),12,Color("#31482C"))
	_leaf(Vector2(0,-23),13,Color("#3F5B34"))
	_leaf(Vector2(13,-28),11,Color("#35502E"))
	_leaf(Vector2(22,-17),10,Color("#2B4028"))
	_leaf(Vector2(-2,-37),11,Color("#45633A"))
	_leaf(Vector2(-24,-8),8,Color("#334A2C"))
	_leaf(Vector2(25,-8),8,Color("#3C5732"))

	flame_outer = Polygon2D.new()
	flame_outer.color = Color("#D84420")
	flame_outer.polygon = PackedVector2Array([Vector2(-23,-12),Vector2(-27,-29),Vector2(-19,-40),Vector2(-16,-58),Vector2(-8,-48),Vector2(-3,-73),Vector2(4,-59),Vector2(10,-82),Vector2(16,-58),Vector2(25,-44),Vector2(21,-25),Vector2(15,-12)])
	bush_root.add_child(flame_outer)
	flame_mid = Polygon2D.new()
	flame_mid.color = Color("#F47B24")
	flame_mid.polygon = PackedVector2Array([Vector2(-16,-13),Vector2(-19,-31),Vector2(-10,-43),Vector2(-7,-61),Vector2(0,-49),Vector2(5,-69),Vector2(11,-48),Vector2(18,-35),Vector2(13,-16),Vector2(5,-10),Vector2(-8,-11)])
	bush_root.add_child(flame_mid)
	flame_core = Polygon2D.new()
	flame_core.color = Color("#FFD45A")
	flame_core.polygon = PackedVector2Array([Vector2(-8,-12),Vector2(-10,-28),Vector2(-3,-39),Vector2(1,-55),Vector2(6,-40),Vector2(10,-30),Vector2(7,-16),Vector2(3,-10)])
	bush_root.add_child(flame_core)
	for i in range(8):
		var ember := Polygon2D.new()
		ember.color = Color("#FFB23E") if i % 2 == 0 else Color("#FFE078")
		ember.polygon = PackedVector2Array([Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)])
		ember.position = Vector2(-17+i*5,-55-i*3)
		bush_root.add_child(ember)
		embers.append(ember)

func _build_moses() -> void:
	moses = Node2D.new()
	moses.name = "Moses"
	moses.position = Vector2(142,191)
	moses.z_index = 4
	add_child(moses)
	moses_sprite = Sprite2D.new()
	moses_sprite.name = "Sprite"
	moses_sprite.texture = MOSES_IDLE_TEXTURE
	moses_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	moses_sprite.centered = true
	moses_sprite.position = Vector2(0,-31)
	moses.add_child(moses_sprite)
	# Ground contact shadow helps the sprite belong to the painted stage.
	var shadow := _circle_at(moses,Vector2(0,-1),15.0,Color("#3A283F66"),14)
	shadow.scale.y = 0.24
	shadow.z_index = -1

func _build_dialogue_ui() -> void:
	dialogue_panel = Panel.new()
	dialogue_panel.position = Vector2(72,48)
	dialogue_panel.size = Vector2(264,45)
	dialogue_panel.z_index = 20
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dialogue_style := StyleBoxFlat.new()
	dialogue_style.bg_color = Color("#100D18F2")
	dialogue_style.border_color = Color("#D6A449")
	dialogue_style.border_width_left = 2
	dialogue_style.border_width_top = 2
	dialogue_style.border_width_right = 2
	dialogue_style.border_width_bottom = 2
	dialogue_style.corner_radius_top_left = 2
	dialogue_style.corner_radius_top_right = 2
	dialogue_style.corner_radius_bottom_left = 2
	dialogue_style.corner_radius_bottom_right = 2
	dialogue_panel.add_theme_stylebox_override("panel",dialogue_style)
	add_child(dialogue_panel)
	speaker_label = Label.new()
	speaker_label.text = "MOSES"
	speaker_label.position = Vector2(9,4)
	speaker_label.size = Vector2(70,11)
	speaker_label.add_theme_font_size_override("font_size",8)
	speaker_label.add_theme_color_override("font_color",Color("#F0BE55"))
	dialogue_panel.add_child(speaker_label)
	dialogue_label = Label.new()
	dialogue_label.position = Vector2(9,16)
	dialogue_label.size = Vector2(246,23)
	dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.add_theme_font_size_override("font_size",10)
	dialogue_label.add_theme_color_override("font_color",Color("#FFF7E8"))
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
	await _moses_double_take()
	await _say_moses("That bush is on fire.",1.05)
	await _say_moses("...and somehow still a bush.",1.10)
	await _father("Moses.",0.75)
	await _moses_recoil()
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
	await get_tree().create_timer(0.34).timeout
	await _father("Fine. Aaron can help.",0.90)
	await _show_prompt(true,0.75)
	moses_sprite.texture = MOSES_IDLE_TEXTURE
	await _say_moses("Fine.",0.58)
	await _father("Excellent. Let's get moving.",0.82)
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
	if dialogue_panel != null:
		dialogue_panel.visible = false
	father_speaking = true
	var surge := create_tween()
	surge.tween_property(self,"father_speech_strength",1.0,0.10)
	if director == null:
		await get_tree().create_timer(hold).timeout
	else:
		await director.father_speak(text,hold)
	father_speaking = false
	var settle := create_tween()
	settle.tween_property(self,"father_speech_strength",0.0,0.18)
	await settle.finished

func _moses_double_take() -> void:
	var tween := create_tween()
	tween.tween_property(moses,"position:x",146.0,0.10)
	tween.tween_property(moses,"position:x",142.0,0.12)
	await tween.finished

func _moses_recoil() -> void:
	moses_reaction_strength = 1.0
	var tween := create_tween()
	tween.tween_property(moses,"position:x",134.0,0.09)
	tween.tween_property(moses,"position:x",142.0,0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	moses_reaction_strength = 0.0

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
	var pop := create_tween()
	pop.tween_property(prompt_panel,"scale",Vector2(1.06,1.06),0.10)
	pop.tween_property(prompt_panel,"scale",Vector2.ONE,0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await pop.finished
	await get_tree().create_timer(0.86).timeout

func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	var speech_boost := father_speech_strength
	if bush_glow != null:
		var glow_breath := 0.96 + sin(t*3.2)*0.04
		var glow_scale := glow_breath + speech_boost*0.16 + sin(t*10.0)*0.015*speech_boost
		bush_glow.scale = Vector2(glow_scale,glow_scale)
		bush_glow.modulate.a = 0.62 + speech_boost*0.38
	if flame_outer != null:
		flame_outer.scale.y = 0.96 + sin(t*9.0)*0.05 + speech_boost*0.09
		flame_outer.scale.x = 1.0 + speech_boost*0.05
		flame_outer.position.x = round(sin(t*6.0)*(1.0+speech_boost))
	if flame_mid != null:
		flame_mid.scale.y = 0.94 + sin(t*11.0+1.2)*0.07 + speech_boost*0.11
		flame_mid.position.x = round(sin(t*8.0+0.8)*(1.0+speech_boost))
	if flame_core != null:
		flame_core.scale.y = 0.93 + sin(t*13.0+2.0)*0.08 + speech_boost*0.13
		flame_core.modulate = Color(1.0,1.0,1.0,1.0)
	for i in range(embers.size()):
		var ember := embers[i]
		var speed := 8.0+float(i)+speech_boost*5.0
		var cycle := fmod(t*speed,22.0)
		ember.position.y = -53.0-cycle-i*2.0
		ember.position.x = -17.0+i*5.0+sin(t*4.0+i)*3.0
		ember.modulate = Color(1,1,1,1.0-(cycle/22.0))

func _rock(center: Vector2,size: float) -> void:
	_poly(Color("#4A3540"),PackedVector2Array([center+Vector2(-size,3),center+Vector2(-size*0.65,-size*0.35),center+Vector2(0,-size*0.62),center+Vector2(size*0.72,-size*0.25),center+Vector2(size,3)]))
	_poly(Color("#6A4745"),PackedVector2Array([center+Vector2(-size*0.55,-size*0.28),center+Vector2(0,-size*0.62),center+Vector2(size*0.45,-size*0.28),center+Vector2(size*0.18,0),center+Vector2(-size*0.35,0)]))

func _grass(center: Vector2,color: Color) -> void:
	_poly(color,PackedVector2Array([center+Vector2(-7,2),center+Vector2(-5,-7),center+Vector2(-2,0),center+Vector2(0,-10),center+Vector2(2,0),center+Vector2(6,-6),center+Vector2(5,2)]))

func _leaf(center: Vector2,radius: float,color: Color) -> void:
	var leaf := _circle_at(bush_root,center,radius,color,10)
	leaf.scale.y = 0.72

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

func _circle_at(parent: Node2D,center: Vector2,radius: float,color: Color,count: int) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(center+Vector2(cos(angle),sin(angle))*radius)
	poly.polygon = points
	parent.add_child(poly)
	return poly