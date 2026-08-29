extends Node2D
class_name BurningBushEpisode

signal episode_finished

const BURNING_BUSH_ART := preload("res://art/episodes/burning_bush/burning_bush.png")
const MOSES_IDLE_TEXTURE := preload("res://art/characters/moses/moses_idle.svg")
const MOSES_SHRUG_TEXTURE := preload("res://art/characters/moses/moses_shrug.svg")

const SCREEN_LEFT := 52.0
const SCREEN_RIGHT := 428.0
const SCREEN_TOP := 36.0
const SCREEN_BOTTOM := 198.0
const SCREEN_SIZE := Vector2(376.0,162.0)
const SCREEN_CENTER := Vector2(240.0,117.0)

const OBJECTIONS := ["Who am I supposed to be?","What if they ask Your name?","What if they don't believe me?","I am REALLY not good at public speaking.","Could You maybe send literally anyone else?"]
const FATHER_REPLIES := ["You're Moses. We've covered this.","Tell them I AM sent you.","They won't. That's why we're doing signs.","I know.","Moses."]

var director
var moses: Node2D
var moses_sprite: Sprite2D
var art_sprite: Sprite2D
var fire_glow: Polygon2D
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
	_build_art_stage()
	_build_moses()
	_build_dialogue_ui()

func _build_art_stage() -> void:
	# The generated artwork is now the visual master for the theater screen.
	# We crop it to the episode viewport instead of rebuilding the desert from polygons.
	art_sprite = Sprite2D.new()
	art_sprite.name = "BurningBushArtwork"
	art_sprite.texture = BURNING_BUSH_ART
	art_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	art_sprite.centered = true
	art_sprite.position = SCREEN_CENTER
	art_sprite.z_index = 0
	add_child(art_sprite)

	var texture_size := BURNING_BUSH_ART.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		var scale_factor := max(SCREEN_SIZE.x / texture_size.x,SCREEN_SIZE.y / texture_size.y)
		art_sprite.scale = Vector2.ONE * scale_factor

	# Darken the lower portion slightly so our live Moses sprite reads over the reference art.
	var stage_tint := Polygon2D.new()
	stage_tint.color = Color("#120D1A18")
	stage_tint.polygon = PackedVector2Array([
		Vector2(SCREEN_LEFT,SCREEN_TOP),Vector2(SCREEN_RIGHT,SCREEN_TOP),
		Vector2(SCREEN_RIGHT,SCREEN_BOTTOM),Vector2(SCREEN_LEFT,SCREEN_BOTTOM)
	])
	stage_tint.z_index = 1
	add_child(stage_tint)

	# A live light pulse sits over the painted bush. It gives God's speech a physical response
	# while we prepare separated bush/fire assets in the next art pass.
	fire_glow = _circle(Vector2(335,132),34.0,Color("#FF9B3024"),20)
	fire_glow.z_index = 2
	for i in range(9):
		var ember := Polygon2D.new()
		ember.color = Color("#FFB23E") if i % 2 == 0 else Color("#FFE078")
		ember.polygon = PackedVector2Array([Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)])
		ember.position = Vector2(314+i*5,117-i*3)
		ember.z_index = 3
		add_child(ember)
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
	var shadow := _circle_at(moses,Vector2(0,-1),15.0,Color("#21162666"),14)
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
	if fire_glow != null:
		var glow_scale := 0.96 + sin(t*3.2)*0.04 + speech_boost*0.20
		fire_glow.scale = Vector2(glow_scale,glow_scale)
		fire_glow.modulate.a = 0.50 + speech_boost*0.50
	if art_sprite != null:
		# Tiny cinematic push during divine speech, subtle enough not to feel like a zoom effect.
		var base_scale := art_sprite.scale.x
		art_sprite.modulate = Color(1.0,0.97+speech_boost*0.03,0.94+speech_boost*0.06,1.0)
	for i in range(embers.size()):
		var ember := embers[i]
		var speed := 7.0+float(i)+speech_boost*5.0
		var cycle := fmod(t*speed,24.0)
		ember.position.y = 117.0-cycle-i*2.0
		ember.position.x = 314.0+i*5.0+sin(t*4.0+i)*3.0
		ember.modulate = Color(1,1,1,1.0-(cycle/24.0))

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
