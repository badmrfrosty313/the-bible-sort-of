extends Node2D
class_name BurningBushEpisode

signal episode_finished

const MOSES_IDLE_TEXTURE := preload("res://art/characters/moses/moses_idle.svg")
const MOSES_SHRUG_TEXTURE := preload("res://art/characters/moses/moses_shrug.svg")

const SCREEN_LEFT := 52.0
const SCREEN_RIGHT := 428.0
const SCREEN_TOP := 36.0
const SCREEN_BOTTOM := 198.0

const OBJECTIONS := [
	"Who am I supposed to be?",
	"What if they ask Your name?",
	"What if they don't believe me?",
	"I am REALLY not good at public speaking.",
	"Could You maybe send literally anyone else?"
]

const FATHER_REPLIES := [
	"You're Moses. We've covered this.",
	"Tell them I AM sent you.",
	"They won't. That's why we're doing signs.",
	"I know.",
	"Moses."
]

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
	# Live pixel-art backdrop. No baked mockup PNG lives in the theater screen anymore.
	_rect_poly(Color("#16152C"), Rect2(SCREEN_LEFT, SCREEN_TOP, 376, 25))
	_rect_poly(Color("#211A3A"), Rect2(SCREEN_LEFT, 61, 376, 24))
	_rect_poly(Color("#342044"), Rect2(SCREEN_LEFT, 85, 376, 23))
	_rect_poly(Color("#52304D"), Rect2(SCREEN_LEFT, 108, 376, 21))
	_rect_poly(Color("#7B4350"), Rect2(SCREEN_LEFT, 129, 376, 18))
	_rect_poly(Color("#A55C4D"), Rect2(SCREEN_LEFT, 147, 376, 14))

	# Stars with deliberately uneven pixel density.
	for star in [
		Vector2(65,48), Vector2(74,59), Vector2(91,44), Vector2(105,70),
		Vector2(123,53), Vector2(139,41), Vector2(158,68), Vector2(178,48),
		Vector2(198,61), Vector2(219,43), Vector2(239,72), Vector2(259,51),
		Vector2(282,62), Vector2(304,45), Vector2(325,71), Vector2(350,51),
		Vector2(371,67), Vector2(408,47)
	]:
		_rect_poly(Color("#F3DC9D"), Rect2(star, Vector2(1,1)))

	for bright_star in [Vector2(112,47), Vector2(246,58), Vector2(365,43)]:
		_rect_poly(Color("#FFF0B7"), Rect2(bright_star + Vector2(-1,0), Vector2(3,1)))
		_rect_poly(Color("#FFF0B7"), Rect2(bright_star + Vector2(0,-1), Vector2(1,3)))

	# Crescent moon.
	_circle(Vector2(394,57), 10.0, Color("#F0D18D"), 16)
	_circle(Vector2(390,53), 9.0, Color("#17162D"), 16)

	# Thin clouds built from chunky pixel bands.
	_rect_poly(Color("#34264A"), Rect2(70,76,35,3))
	_rect_poly(Color("#34264A"), Rect2(81,72,19,3))
	_rect_poly(Color("#4B3152"), Rect2(264,82,42,3))
	_rect_poly(Color("#4B3152"), Rect2(275,78,22,3))
	_rect_poly(Color("#352849"), Rect2(335,91,36,3))

	# Far mountains.
	_poly(Color("#241C39"), PackedVector2Array([
		Vector2(52,146), Vector2(76,122), Vector2(92,135), Vector2(115,103),
		Vector2(136,132), Vector2(160,111), Vector2(184,144), Vector2(205,119),
		Vector2(226,145), Vector2(52,145)
	]))
	_poly(Color("#302342"), PackedVector2Array([
		Vector2(167,149), Vector2(202,116), Vector2(223,138), Vector2(250,104),
		Vector2(278,139), Vector2(308,109), Vector2(337,141), Vector2(365,117),
		Vector2(392,139), Vector2(428,112), Vector2(428,152), Vector2(167,152)
	]))

	# Warm ridge catching sunset/fire tones.
	_poly(Color("#513044"), PackedVector2Array([
		Vector2(52,155), Vector2(89,137), Vector2(120,150), Vector2(157,130),
		Vector2(194,152), Vector2(231,135), Vector2(270,153), Vector2(309,132),
		Vector2(351,151), Vector2(390,132), Vector2(428,145), Vector2(428,162), Vector2(52,162)
	]))

	# Sand base and stepped perspective bands.
	_rect_poly(Color("#765044"), Rect2(SCREEN_LEFT,158,376,40))
	_poly(Color("#956149"), PackedVector2Array([
		Vector2(52,170), Vector2(93,167), Vector2(132,172), Vector2(172,165),
		Vector2(210,173), Vector2(250,164), Vector2(292,172), Vector2(335,163),
		Vector2(377,169), Vector2(428,162), Vector2(428,198), Vector2(52,198)
	]))
	_poly(Color("#B2794E"), PackedVector2Array([
		Vector2(52,184), Vector2(100,179), Vector2(145,186), Vector2(191,178),
		Vector2(238,186), Vector2(285,177), Vector2(332,185), Vector2(379,178),
		Vector2(428,182), Vector2(428,198), Vector2(52,198)
	]))
	_poly(Color("#C89156"), PackedVector2Array([
		Vector2(52,193), Vector2(112,188), Vector2(167,194), Vector2(222,187),
		Vector2(277,194), Vector2(334,187), Vector2(389,193), Vector2(428,189),
		Vector2(428,198), Vector2(52,198)
	]))

	# Ground texture pixels.
	for mark in [
		Vector2(61,181),Vector2(76,190),Vector2(98,174),Vector2(125,187),Vector2(148,177),
		Vector2(174,193),Vector2(203,181),Vector2(222,173),Vector2(254,190),Vector2(279,179),
		Vector2(305,193),Vector2(370,180),Vector2(405,191)
	]:
		_rect_poly(Color("#6C493E"), Rect2(mark, Vector2(5,2)))

	# Rocks and scrub.
	_rock(Vector2(81,187), 11.0)
	_rock(Vector2(113,181), 6.0)
	_rock(Vector2(224,191), 9.0)
	_rock(Vector2(270,183), 6.0)
	_rock(Vector2(393,190), 9.0)
	_rock(Vector2(410,179), 5.0)
	_grass(Vector2(108,193), Color("#4D4930"))
	_grass(Vector2(190,189), Color("#575036"))
	_grass(Vector2(274,194), Color("#66583A"))
	_grass(Vector2(414,188), Color("#514A32"))

	# Firelight painted live beneath the bush.
	_poly(Color("#D9864870"), PackedVector2Array([
		Vector2(286,198), Vector2(303,183), Vector2(332,175), Vector2(365,182), Vector2(391,198)
	]))
	_poly(Color("#F0A13F75"), PackedVector2Array([
		Vector2(306,198), Vector2(318,185), Vector2(338,179), Vector2(356,185), Vector2(372,198)
	]))
	_poly(Color("#FFD05B55"), PackedVector2Array([
		Vector2(320,198), Vector2(328,189), Vector2(339,185), Vector2(350,190), Vector2(358,198)
	]))

func _build_burning_bush() -> void:
	bush_root = Node2D.new()
	bush_root.name = "BurningBush"
	bush_root.position = Vector2(337,190)
	bush_root.z_index = 3
	add_child(bush_root)

	bush_glow = _circle_at(bush_root, Vector2(0,-31), 45.0, Color("#FFB33A24"), 20)
	bush_glow.z_index = -3

	# Trunk and branching silhouette.
	_rect_poly_at(bush_root, Color("#3D2419"), Rect2(-4,-21,8,22))
	_poly_at(bush_root, Color("#5A3320"), PackedVector2Array([
		Vector2(-4,-18), Vector2(-18,-32), Vector2(-15,-35), Vector2(0,-23),
		Vector2(13,-38), Vector2(16,-35), Vector2(4,-18)
	]))
	_poly_at(bush_root, Color("#7A4827"), PackedVector2Array([
		Vector2(-2,-19), Vector2(-12,-30), Vector2(-10,-32), Vector2(1,-24),
		Vector2(10,-34), Vector2(12,-32), Vector2(3,-18)
	]))

	# Dense live foliage with shadow/highlight clusters.
	_leaf(Vector2(-24,-16), 10, Color("#1F3426"))
	_leaf(Vector2(-18,-28), 12, Color("#27432B"))
	_leaf(Vector2(-8,-39), 12, Color("#315431"))
	_leaf(Vector2(4,-42), 13, Color("#386039"))
	_leaf(Vector2(17,-34), 12, Color("#2C4D2E"))
	_leaf(Vector2(25,-21), 11, Color("#233D29"))
	_leaf(Vector2(-4,-24), 14, Color("#3D663A"))
	_leaf(Vector2(10,-21), 13, Color("#456F3F"))
	_leaf(Vector2(-27,-6), 8, Color("#29452C"))
	_leaf(Vector2(28,-8), 8, Color("#315034"))

	# Fire silhouette: three independently animated layers.
	flame_outer = Polygon2D.new()
	flame_outer.color = Color("#C9361C")
	flame_outer.polygon = PackedVector2Array([
		Vector2(-28,-10),Vector2(-31,-26),Vector2(-25,-38),Vector2(-21,-55),
		Vector2(-14,-46),Vector2(-11,-67),Vector2(-5,-57),Vector2(0,-82),
		Vector2(6,-63),Vector2(12,-88),Vector2(18,-63),Vector2(25,-49),
		Vector2(29,-31),Vector2(24,-12),Vector2(15,-6),Vector2(-15,-6)
	])
	bush_root.add_child(flame_outer)

	flame_mid = Polygon2D.new()
	flame_mid.color = Color("#F06A1F")
	flame_mid.polygon = PackedVector2Array([
		Vector2(-20,-10),Vector2(-22,-28),Vector2(-15,-41),Vector2(-12,-58),
		Vector2(-5,-47),Vector2(0,-69),Vector2(5,-52),Vector2(10,-75),
		Vector2(16,-51),Vector2(22,-36),Vector2(18,-17),Vector2(10,-8),Vector2(-9,-7)
	])
	bush_root.add_child(flame_mid)

	flame_core = Polygon2D.new()
	flame_core.color = Color("#FFD458")
	flame_core.polygon = PackedVector2Array([
		Vector2(-11,-9),Vector2(-13,-25),Vector2(-7,-36),Vector2(-3,-53),
		Vector2(2,-41),Vector2(6,-60),Vector2(11,-40),Vector2(13,-26),
		Vector2(9,-13),Vector2(4,-7)
	])
	bush_root.add_child(flame_core)

	for i in range(10):
		var ember: Polygon2D = Polygon2D.new()
		ember.color = Color("#FF9B31") if i % 2 == 0 else Color("#FFE17D")
		ember.polygon = PackedVector2Array([Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)])
		ember.position = Vector2(-22+i*5,-52-i*3)
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

	var shadow: Polygon2D = _circle_at(moses, Vector2(0,-1), 15.0, Color("#21162666"), 14)
	shadow.scale.y = 0.24
	shadow.z_index = -1

func _build_dialogue_ui() -> void:
	dialogue_panel = Panel.new()
	dialogue_panel.position = Vector2(72,48)
	dialogue_panel.size = Vector2(264,45)
	dialogue_panel.z_index = 20
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var dialogue_style: StyleBoxFlat = StyleBoxFlat.new()
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
	dialogue_panel.add_theme_stylebox_override("panel", dialogue_style)
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

func _say_moses(text: String, hold: float) -> void:
	speaker_label.text = "MOSES"
	dialogue_label.text = text
	dialogue_panel.modulate = Color(1,1,1,0)
	dialogue_panel.visible = true
	var fade: Tween = create_tween()
	fade.tween_property(dialogue_panel,"modulate:a",1.0,0.08)
	await fade.finished
	await get_tree().create_timer(hold).timeout

func _father(text: String, hold: float) -> void:
	if dialogue_panel != null:
		dialogue_panel.visible = false
	father_speaking = true
	var surge: Tween = create_tween()
	surge.tween_property(self,"father_speech_strength",1.0,0.10)
	if director == null:
		await get_tree().create_timer(hold).timeout
	else:
		await director.father_speak(text,hold)
	father_speaking = false
	var settle: Tween = create_tween()
	settle.tween_property(self,"father_speech_strength",0.0,0.18)
	await settle.finished

func _moses_double_take() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(moses,"position:x",146.0,0.10)
	tween.tween_property(moses,"position:x",142.0,0.12)
	await tween.finished

func _moses_recoil() -> void:
	moses_reaction_strength = 1.0
	var tween: Tween = create_tween()
	tween.tween_property(moses,"position:x",134.0,0.09)
	tween.tween_property(moses,"position:x",142.0,0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	moses_reaction_strength = 0.0

func _show_prompt(accepted: bool, hold: float) -> void:
	_set_prompt_style(accepted)
	prompt_label.text = "ACCEPT QUEST?   [ YES ]" if accepted else "ACCEPT QUEST?   [ NO ]"
	prompt_panel.modulate = Color(1,1,1,0)
	prompt_panel.visible = true
	var fade_in: Tween = create_tween()
	fade_in.tween_property(prompt_panel,"modulate:a",1.0,0.08)
	await fade_in.finished
	var pulse: Tween = create_tween()
	pulse.tween_property(prompt_panel,"scale",Vector2(1.03,1.03),0.08)
	pulse.tween_property(prompt_panel,"scale",Vector2.ONE,0.08)
	await pulse.finished
	await get_tree().create_timer(hold).timeout
	var fade_out: Tween = create_tween()
	fade_out.tween_property(prompt_panel,"modulate:a",0.0,0.08)
	await fade_out.finished
	prompt_panel.visible = false

func _set_prompt_style(accepted: bool) -> void:
	if prompt_panel == null:
		return
	var style: StyleBoxFlat = StyleBoxFlat.new()
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
	var fade: Tween = create_tween()
	fade.tween_property(prompt_panel,"modulate:a",1.0,0.12)
	await fade.finished
	var pop: Tween = create_tween()
	pop.tween_property(prompt_panel,"scale",Vector2(1.06,1.06),0.10)
	pop.tween_property(prompt_panel,"scale",Vector2.ONE,0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await pop.finished
	await get_tree().create_timer(0.86).timeout

func _process(_delta: float) -> void:
	var t: float = Time.get_ticks_msec() * 0.001
	var speech_boost: float = father_speech_strength

	if bush_glow != null:
		var glow_breath: float = 0.96 + sin(t*3.2)*0.04
		var glow_scale: float = glow_breath + speech_boost*0.16 + sin(t*10.0)*0.015*speech_boost
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

	for i in range(embers.size()):
		var ember: Polygon2D = embers[i]
		var speed: float = 8.0 + float(i) + speech_boost*5.0
		var cycle: float = fmod(t*speed,24.0)
		ember.position.y = -53.0-cycle-i*2.0
		ember.position.x = -22.0+i*5.0+sin(t*4.0+i)*3.0
		ember.modulate = Color(1,1,1,1.0-(cycle/24.0))

func _rock(center: Vector2, size: float) -> void:
	_poly(Color("#43313C"), PackedVector2Array([
		center+Vector2(-size,3), center+Vector2(-size*0.65,-size*0.35),
		center+Vector2(0,-size*0.62), center+Vector2(size*0.72,-size*0.25), center+Vector2(size,3)
	]))
	_poly(Color("#684544"), PackedVector2Array([
		center+Vector2(-size*0.55,-size*0.28), center+Vector2(0,-size*0.62),
		center+Vector2(size*0.45,-size*0.28), center+Vector2(size*0.18,0), center+Vector2(-size*0.35,0)
	]))
	_rect_poly(Color("#8A5D4C"), Rect2(center+Vector2(-size*0.25,-size*0.47), Vector2(size*0.45,2)))

func _grass(center: Vector2, color: Color) -> void:
	_poly(color, PackedVector2Array([
		center+Vector2(-7,2), center+Vector2(-5,-7), center+Vector2(-2,0),
		center+Vector2(0,-10), center+Vector2(2,0), center+Vector2(6,-6), center+Vector2(5,2)
	]))

func _leaf(center: Vector2, radius: float, color: Color) -> void:
	var leaf: Polygon2D = _circle_at(bush_root,center,radius,color,10)
	leaf.scale.y = 0.72

func _rect_poly(color: Color, rect: Rect2) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.position+rect.size,rect.position+Vector2(0,rect.size.y)])
	add_child(poly)
	return poly

func _rect_poly_at(parent: Node2D, color: Color, rect: Rect2) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.position+rect.size,rect.position+Vector2(0,rect.size.y)])
	parent.add_child(poly)
	return poly

func _poly(color: Color, points: PackedVector2Array) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	poly.polygon = points
	add_child(poly)
	return poly

func _poly_at(parent: Node2D, color: Color, points: PackedVector2Array) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	poly.polygon = points
	parent.add_child(poly)
	return poly

func _circle(center: Vector2, radius: float, color: Color, count: int) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(count):
		var angle: float = TAU * float(i) / float(count)
		points.append(center+Vector2(cos(angle),sin(angle))*radius)
	poly.polygon = points
	add_child(poly)
	return poly

func _circle_at(parent: Node2D, center: Vector2, radius: float, color: Color, count: int) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(count):
		var angle: float = TAU * float(i) / float(count)
		points.append(center+Vector2(cos(angle),sin(angle))*radius)
	poly.polygon = points
	parent.add_child(poly)
	return poly
