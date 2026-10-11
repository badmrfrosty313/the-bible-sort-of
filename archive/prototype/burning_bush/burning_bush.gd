extends Node2D
class_name PrototypeBurningBushEpisode

signal episode_finished

const DESERT_BACKGROUND_TEXTURE := preload("res://art/episodes/burning_bush/desert_background.svg")
const BUSH_BASE_TEXTURE := preload("res://art/episodes/burning_bush/bush_base.svg")
const FLAME_01_TEXTURE := preload("res://art/episodes/burning_bush/flame_01.svg")
const FLAME_02_TEXTURE := preload("res://art/episodes/burning_bush/flame_02.svg")
const FLAME_03_TEXTURE := preload("res://art/episodes/burning_bush/flame_03.svg")
const MOSES_IDLE_TEXTURE := preload("res://art/characters/moses/moses_idle.svg")
const MOSES_SHRUG_TEXTURE := preload("res://art/characters/moses/moses_shrug.svg")

const SCREEN_LEFT := 52.0
const SCREEN_RIGHT := 428.0
const SCREEN_TOP := 36.0
const SCREEN_BOTTOM := 198.0
const SCREEN_CENTER := Vector2(240.0,117.0)

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
var background_sprite: Sprite2D
var moses: Node2D
var moses_sprite: Sprite2D
var bush_root: Node2D
var bush_sprite: Sprite2D
var flame_sprite: AnimatedSprite2D
var bush_glow: Polygon2D
var ground_glow: Polygon2D
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
	background_sprite = Sprite2D.new()
	background_sprite.name = "IllustratedDesertBackground"
	background_sprite.texture = DESERT_BACKGROUND_TEXTURE
	background_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	background_sprite.centered = true
	background_sprite.position = SCREEN_CENTER
	background_sprite.scale = Vector2(0.5,0.5)
	background_sprite.z_index = 0
	add_child(background_sprite)

	ground_glow = Polygon2D.new()
	ground_glow.color = Color("#FF9F3C45")
	ground_glow.polygon = PackedVector2Array([
		Vector2(283,198),Vector2(299,185),Vector2(324,178),Vector2(349,177),
		Vector2(377,185),Vector2(394,198)
	])
	ground_glow.z_index = 1
	add_child(ground_glow)

func _build_burning_bush() -> void:
	bush_root = Node2D.new()
	bush_root.name = "BurningBush"
	bush_root.position = Vector2(337,190)
	bush_root.z_index = 4
	add_child(bush_root)

	bush_glow = _circle_at(bush_root,Vector2(0,-42),48.0,Color("#FF9C322C"),24)
	bush_glow.z_index = -2
	bush_glow.scale.y = 0.86

	bush_sprite = Sprite2D.new()
	bush_sprite.name = "BushBase"
	bush_sprite.texture = BUSH_BASE_TEXTURE
	bush_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bush_sprite.centered = true
	bush_sprite.position = Vector2(0,-40)
	bush_sprite.scale = Vector2(0.62,0.62)
	bush_sprite.z_index = 1
	bush_root.add_child(bush_sprite)

	var fire_frames: SpriteFrames = SpriteFrames.new()
	fire_frames.add_animation("burn")
	fire_frames.set_animation_loop("burn",true)
	fire_frames.set_animation_speed("burn",8.0)
	fire_frames.add_frame("burn",FLAME_01_TEXTURE)
	fire_frames.add_frame("burn",FLAME_02_TEXTURE)
	fire_frames.add_frame("burn",FLAME_03_TEXTURE)
	fire_frames.add_frame("burn",FLAME_02_TEXTURE)

	flame_sprite = AnimatedSprite2D.new()
	flame_sprite.name = "AnimatedFire"
	flame_sprite.sprite_frames = fire_frames
	flame_sprite.animation = "burn"
	flame_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	flame_sprite.centered = true
	flame_sprite.position = Vector2(0,-40)
	flame_sprite.scale = Vector2(0.68,0.68)
	flame_sprite.z_index = 2
	bush_root.add_child(flame_sprite)
	flame_sprite.play("burn")

	for i in range(12):
		var ember: Polygon2D = Polygon2D.new()
		ember.color = Color("#FFB43F") if i % 2 == 0 else Color("#FFE58B")
		ember.polygon = PackedVector2Array([
			Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)
		])
		ember.position = Vector2(-25+i*4,-62-i*2)
		ember.z_index = 3
		bush_root.add_child(ember)
		embers.append(ember)

func _build_moses() -> void:
	moses = Node2D.new()
	moses.name = "Moses"
	moses.position = Vector2(142,191)
	moses.z_index = 6
	add_child(moses)

	moses_sprite = Sprite2D.new()
	moses_sprite.name = "Sprite"
	moses_sprite.texture = MOSES_IDLE_TEXTURE
	moses_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	moses_sprite.centered = true
	moses_sprite.position = Vector2(0,-31)
	moses_sprite.scale = Vector2(1.08,1.08)
	moses.add_child(moses_sprite)

	var shadow: Polygon2D = _circle_at(moses,Vector2(0,-1),16.0,Color("#1B132066"),18)
	shadow.scale.y = 0.22
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
	var fade: Tween = create_tween()
	fade.tween_property(dialogue_panel,"modulate:a",1.0,0.08)
	await fade.finished
	await get_tree().create_timer(hold).timeout

func _father(text: String,hold: float) -> void:
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
	settle.tween_property(self,"father_speech_strength",0.0,0.20)
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

func _show_prompt(accepted: bool,hold: float) -> void:
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

	if background_sprite != null:
		background_sprite.position.x = SCREEN_CENTER.x + sin(t*0.35)*0.35

	if bush_glow != null:
		var glow_scale: float = 0.96 + sin(t*3.0)*0.04 + speech_boost*0.18
		bush_glow.scale = Vector2(glow_scale,glow_scale*0.86)
		bush_glow.modulate.a = 0.58 + speech_boost*0.42

	if ground_glow != null:
		ground_glow.modulate.a = 0.62 + sin(t*4.3)*0.08 + speech_boost*0.30

	if flame_sprite != null:
		var flame_scale: float = 0.68 + sin(t*7.0)*0.012 + speech_boost*0.075
		flame_sprite.scale = Vector2(flame_scale,flame_scale + sin(t*5.0)*0.015)
		flame_sprite.speed_scale = 1.0 + speech_boost*0.65

	if bush_sprite != null:
		bush_sprite.rotation = sin(t*1.8)*0.0025

	if moses_sprite != null:
		moses_sprite.position.y = -31.0 + sin(t*2.1)*0.45
		moses_sprite.modulate = Color(1.0,0.96 + speech_boost*0.04,0.90 + speech_boost*0.10,1.0)

	for i in range(embers.size()):
		var ember: Polygon2D = embers[i]
		var speed: float = 7.0 + float(i)*0.6 + speech_boost*5.0
		var cycle: float = fmod(t*speed + float(i)*2.7,30.0)
		ember.position.y = -54.0-cycle
		ember.position.x = -24.0+float(i)*4.0+sin(t*3.5+float(i))*4.0
		ember.modulate.a = 1.0-(cycle/30.0)

func _circle_at(parent: Node2D,center: Vector2,radius: float,color: Color,count: int) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = color
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(count):
		var angle: float = TAU * float(i) / float(count)
		points.append(center+Vector2(cos(angle),sin(angle))*radius)
	poly.polygon = points
	parent.add_child(poly)
	return poly
