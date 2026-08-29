extends Node2D

const FATHER_SCENE := preload("res://scenes/characters/father.tscn")
const BURNING_BUSH_SCENE := preload("res://scenes/episodes/burning_bush/burning_bush.tscn")

const COLOR_BACKGROUND := Color("#08070B")
const COLOR_WALL := Color("#141018")
const COLOR_STAGE_FRAME := Color("#261A29")
const COLOR_STAGE_EDGE := Color("#5A3448")
const COLOR_STAGE_GOLD := Color("#B98236")
const COLOR_CURTAIN := Color("#6B1624")
const COLOR_CURTAIN_DARK := Color("#3D0C15")
const COLOR_CURTAIN_HIGHLIGHT := Color("#9C2635")
const COLOR_CONSOLE := Color("#302431")
const COLOR_CONSOLE_TOP := Color("#463044")
const COLOR_CONSOLE_EDGE := Color("#785064")
const COLOR_CONSOLE_DARK := Color("#171219")
const COLOR_BUTTON_RED := Color("#C92D39")
const COLOR_BUTTON_RED_DARK := Color("#731A24")
const COLOR_BUTTON_GOLD := Color("#D4A23E")
const COLOR_BUTTON_GREEN := Color("#4D8C69")
const COLOR_BUTTON_BLUE := Color("#3B6F91")
const COLOR_TEXT_GOLD := Color("#E6B84E")

enum FatherLocation { THEATER, EPISODE, TRANSITION }

var stage_content: Node2D
var theater_character_layer: Node2D
var theater_foreground_layer: Node2D
var father_anchor: Marker2D
var left_entrance: Marker2D
var right_entrance: Marker2D
var seat_anchor: Marker2D
var episode_portal: Marker2D
var father: Father
var father_location := FatherLocation.THEATER
var current_episode
var father_dialogue_panel: Panel
var father_speaker_label: Label
var father_dialogue_label: Label

func _ready() -> void:
	build_theater()
	await get_tree().process_frame
	_spawn_father()
	await get_tree().create_timer(0.35).timeout
	await _run_intro()
	await _start_burning_bush()

func build_theater() -> void:
	_build_background()
	_build_stage()
	_build_theater_layers()
	_build_runtime_anchors()
	_build_father_dialogue()

func _build_background() -> void:
	_rect_poly(self, COLOR_BACKGROUND, Rect2(0, 0, 480, 270))
	_rect_poly(self, COLOR_WALL, Rect2(18, 16, 444, 238))
	_rect_poly(self, Color("#241825"), Rect2(18, 206, 444, 3))
	_rect_poly(self, Color("#0D0A10"), Rect2(18, 252, 444, 18))

func _build_stage() -> void:
	var stage := Node2D.new()
	stage.name = "Stage"
	stage.z_index = 0
	add_child(stage)
	_rect_poly(stage, Color("#08070B"), Rect2(42, 26, 396, 182))
	_rect_poly(stage, COLOR_STAGE_FRAME, Rect2(46, 30, 388, 174))
	_rect_poly(stage, COLOR_STAGE_EDGE, Rect2(49, 33, 382, 168))
	_rect_poly(stage, Color("#0C0910"), Rect2(52, 36, 376, 162))
	_rect_poly(stage, COLOR_STAGE_GOLD, Rect2(52, 36, 376, 2))
	stage_content = Node2D.new()
	stage_content.name = "StageContent"
	stage_content.z_index = 1
	stage.add_child(stage_content)

func _build_theater_layers() -> void:
	var curtains := Node2D.new()
	curtains.name = "Curtains"
	curtains.z_index = 5
	add_child(curtains)
	_build_curtains(curtains)
	theater_character_layer = Node2D.new()
	theater_character_layer.name = "TheaterCharacters"
	theater_character_layer.z_index = 8
	add_child(theater_character_layer)
	_build_father_chair(theater_character_layer)
	theater_foreground_layer = Node2D.new()
	theater_foreground_layer.name = "TheaterForeground"
	theater_foreground_layer.z_index = 12
	add_child(theater_foreground_layer)
	_build_control_desk(theater_foreground_layer)

func _build_curtains(parent: Node2D) -> void:
	var left := Polygon2D.new()
	left.color = COLOR_CURTAIN
	left.polygon = PackedVector2Array([Vector2(0,0),Vector2(54,20),Vector2(54,190),Vector2(42,209),Vector2(0,222)])
	parent.add_child(left)
	var right := Polygon2D.new()
	right.color = COLOR_CURTAIN
	right.polygon = left.polygon
	right.position = Vector2(480,0)
	right.scale = Vector2(-1,1)
	parent.add_child(right)
	var valance := Polygon2D.new()
	valance.color = COLOR_CURTAIN
	valance.polygon = PackedVector2Array([Vector2(0,0),Vector2(480,0),Vector2(480,31),Vector2(420,38),Vector2(360,31),Vector2(300,41),Vector2(240,32),Vector2(180,41),Vector2(120,31),Vector2(60,38),Vector2(0,31)])
	parent.add_child(valance)
	for x in [12.0,31.0]:
		var fold := Polygon2D.new()
		fold.color = COLOR_CURTAIN_DARK if x == 12.0 else COLOR_CURTAIN_HIGHLIGHT
		fold.polygon = PackedVector2Array([Vector2(x,5),Vector2(x+8,9),Vector2(x+8,205),Vector2(x,214)])
		parent.add_child(fold)
		var mirror := Polygon2D.new()
		mirror.color = fold.color
		mirror.polygon = fold.polygon
		mirror.position = Vector2(480,0)
		mirror.scale = Vector2(-1,1)
		parent.add_child(mirror)
	_rect_poly(parent, COLOR_STAGE_GOLD, Rect2(0,31,54,2))
	_rect_poly(parent, COLOR_STAGE_GOLD, Rect2(426,31,54,2))

func _build_father_chair(parent: Node2D) -> void:
	var chair := Node2D.new()
	chair.name = "FatherChair"
	chair.z_index = -1
	parent.add_child(chair)
	_rect_poly(chair, Color("#2A1117"), Rect2(216,171,48,46))
	_rect_poly(chair, Color("#661D27"), Rect2(220,174,40,42))
	_rect_poly(chair, Color("#8D2934"), Rect2(223,177,34,36))
	_rect_poly(chair, Color("#B23A43"), Rect2(226,179,5,31))
	_rect_poly(chair, Color("#3B171D"), Rect2(212,198,9,19))
	_rect_poly(chair, Color("#3B171D"), Rect2(259,198,9,19))

func _build_control_desk(parent: Node2D) -> void:
	var desk := Node2D.new()
	desk.name = "ControlDesk"
	parent.add_child(desk)
	var surface := Polygon2D.new()
	surface.color = COLOR_CONSOLE_TOP
	surface.polygon = PackedVector2Array([Vector2(54,205),Vector2(426,205),Vector2(462,270),Vector2(18,270)])
	desk.add_child(surface)
	_rect_poly(desk, COLOR_CONSOLE_EDGE, Rect2(58,205,364,4))
	_rect_poly(desk, COLOR_CONSOLE_DARK, Rect2(24,260,432,10))
	var left_bank := Polygon2D.new()
	left_bank.color = COLOR_CONSOLE
	left_bank.polygon = PackedVector2Array([Vector2(72,216),Vector2(174,216),Vector2(191,257),Vector2(52,257)])
	desk.add_child(left_bank)
	_rect_poly(desk, COLOR_CONSOLE_DARK, Rect2(79,223,81,27))
	_create_light(desk,Vector2(96,235),6,COLOR_BUTTON_RED)
	_create_light(desk,Vector2(122,235),4,COLOR_BUTTON_GOLD)
	_create_light(desk,Vector2(145,235),4,COLOR_BUTTON_GREEN)
	_add_console_label(desk,"INTERVENE",Vector2(78,248),Vector2(85,9),7,Color("#D9C8B5"))
	var right_bank := Polygon2D.new()
	right_bank.color = COLOR_CONSOLE
	right_bank.polygon = PackedVector2Array([Vector2(306,216),Vector2(408,216),Vector2(428,257),Vector2(289,257)])
	desk.add_child(right_bank)
	_rect_poly(desk, COLOR_CONSOLE_DARK, Rect2(318,223,77,27))
	_create_light(desk,Vector2(334,235),5,COLOR_BUTTON_GREEN)
	_create_light(desk,Vector2(358,235),5,COLOR_BUTTON_BLUE)
	_create_light(desk,Vector2(382,235),5,COLOR_BUTTON_GOLD)
	_add_console_label(desk,"TIMELINE: STABLE(ISH)",Vector2(309,248),Vector2(99,9),6,Color("#BFD6C4"))
	var center_bank := Polygon2D.new()
	center_bank.color = COLOR_CONSOLE
	center_bank.polygon = PackedVector2Array([Vector2(184,216),Vector2(296,216),Vector2(305,260),Vector2(175,260)])
	desk.add_child(center_bank)
	_rect_poly(desk,Color("#17121A"),Rect2(194,220,92,13))
	_rect_poly(desk,COLOR_STAGE_GOLD,Rect2(196,222,88,9))
	_rect_poly(desk,Color("#211923"),Rect2(198,224,84,5))
	_add_console_label(desk,"THEATER 1",Vector2(198,220),Vector2(84,11),6,COLOR_TEXT_GOLD)
	_add_console_label(desk,"EXODUS",Vector2(207,234),Vector2(66,10),7,Color("#E7D6B1"))
	_create_light(desk,Vector2(240,251),7,COLOR_BUTTON_RED_DARK)
	_create_light(desk,Vector2(240,250),5,COLOR_BUTTON_RED)

func _add_console_label(parent: Node,text: String,pos: Vector2,label_size: Vector2,font_size: int,color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)

func _create_light(parent: Node2D, center: Vector2, radius: float, color: Color) -> void:
	var rim := Polygon2D.new()
	var rim_color := color
	rim_color.a = 0.28
	rim.color = rim_color
	rim.polygon = _circle_points(center,radius+2.0,10)
	parent.add_child(rim)
	var light := Polygon2D.new()
	light.color = color
	light.polygon = _circle_points(center,radius,10)
	parent.add_child(light)

func _circle_points(center: Vector2,radius: float,count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(center + Vector2(cos(angle),sin(angle)) * radius)
	return points

func _ellipse_points(rx: float,ry: float,count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(Vector2(cos(angle)*rx,sin(angle)*ry))
	return points

func _rect_poly(parent: Node,color: Color,rect: Rect2) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.position+rect.size,rect.position+Vector2(0,rect.size.y)])
	parent.add_child(poly)
	return poly

func _build_runtime_anchors() -> void:
	left_entrance = _marker("LeftEntrance",Vector2(-24,218))
	right_entrance = _marker("RightEntrance",Vector2(504,218))
	father_anchor = _marker("FatherStanding",Vector2(188,218))
	seat_anchor = _marker("FatherSeat",Vector2(240,216))
	episode_portal = _marker("EpisodePortal",Vector2(420,218))

func _marker(node_name: String,pos: Vector2) -> Marker2D:
	var marker := Marker2D.new()
	marker.name = node_name
	marker.position = pos
	add_child(marker)
	return marker

func _build_father_dialogue() -> void:
	father_dialogue_panel = Panel.new()
	father_dialogue_panel.name = "FatherDialogue"
	father_dialogue_panel.size = Vector2(156,55)
	father_dialogue_panel.visible = false
	father_dialogue_panel.z_index = 30
	father_dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#090B13EE")
	style.border_color = COLOR_TEXT_GOLD
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	father_dialogue_panel.add_theme_stylebox_override("panel",style)
	add_child(father_dialogue_panel)
	father_speaker_label = Label.new()
	father_speaker_label.text = "THE FATHER"
	father_speaker_label.position = Vector2(8,3)
	father_speaker_label.size = Vector2(140,11)
	father_speaker_label.add_theme_font_size_override("font_size",8)
	father_speaker_label.add_theme_color_override("font_color",COLOR_TEXT_GOLD)
	father_dialogue_panel.add_child(father_speaker_label)
	father_dialogue_label = Label.new()
	father_dialogue_label.position = Vector2(8,15)
	father_dialogue_label.size = Vector2(140,35)
	father_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	father_dialogue_label.add_theme_font_size_override("font_size",8)
	father_dialogue_label.add_theme_color_override("font_color",Color("#F4EFE8"))
	father_dialogue_panel.add_child(father_dialogue_label)

func _spawn_father() -> void:
	father = FATHER_SCENE.instantiate() as Father
	if father == null:
		push_error("Father scene could not be instantiated.")
		return
	father.name = "Father"
	father.visible = false
	theater_character_layer.add_child(father)

func _run_intro() -> void:
	father_location = FatherLocation.TRANSITION
	await father.enter_from_left(left_entrance.global_position,father_anchor.global_position)
	father.stand()
	await father_speak("Alright. Let's see what my humans get up to this time.",1.55)
	await father.move_to(seat_anchor.global_position)
	father.sit()
	father_location = FatherLocation.THEATER

func _start_burning_bush() -> void:
	current_episode = BURNING_BUSH_SCENE.instantiate()
	current_episode.director = self
	current_episode.modulate = Color(1,1,1,0)
	stage_content.add_child(current_episode)
	var fade := create_tween()
	fade.tween_property(current_episode,"modulate:a",1.0,0.35)
	await fade.finished

func father_speak(text: String,duration: float=1.0) -> void:
	if father_dialogue_panel == null:
		return
	father_dialogue_label.text = text
	if father_location == FatherLocation.EPISODE:
		father_dialogue_panel.position = Vector2(270,68)
		if father != null and father.state != Father.State.WALKING:
			father.react()
	else:
		father_dialogue_panel.position = Vector2(274,141)
	father_dialogue_panel.modulate = Color(1,1,1,0)
	father_dialogue_panel.visible = true
	var fade_in := create_tween()
	fade_in.tween_property(father_dialogue_panel,"modulate:a",1.0,0.10)
	await fade_in.finished
	await get_tree().create_timer(duration).timeout
	var fade_out := create_tween()
	fade_out.tween_property(father_dialogue_panel,"modulate:a",0.0,0.10)
	await fade_out.finished
	father_dialogue_panel.visible = false
	if father_location == FatherLocation.EPISODE and father != null:
		father.stand()

func send_father_into_episode(entry_position: Vector2) -> void:
	if father == null or father_location != FatherLocation.THEATER:
		return
	father_location = FatherLocation.TRANSITION
	father.stand()
	await father.move_to(episode_portal.global_position)
	var portal := await _open_portal(stage_content,Vector2(412,167))
	father.visible = false
	father.reparent(stage_content,false)
	father.position = Vector2(410,190)
	father.z_index = 7
	father_location = FatherLocation.EPISODE
	father.visible = true
	father.stand()
	await get_tree().create_timer(0.08).timeout
	await _close_portal(portal)
	await father.move_to(entry_position)
	father.stand()

func return_father_to_theater() -> void:
	if father == null or father_location != FatherLocation.EPISODE:
		return
	father_location = FatherLocation.TRANSITION
	var portal := await _open_portal(stage_content,Vector2(412,167))
	await father.move_to(Vector2(410,190))
	father.visible = false
	await _close_portal(portal)
	father.reparent(theater_character_layer,false)
	father.global_position = episode_portal.global_position
	father.z_index = 0
	father.visible = true
	father.stand()
	await father.move_to(seat_anchor.global_position)
	father.sit()
	father_location = FatherLocation.THEATER

func _open_portal(parent: Node2D,portal_position: Vector2) -> Node2D:
	var portal := Node2D.new()
	portal.name = "RealityPortal"
	portal.position = portal_position
	portal.z_index = 6
	parent.add_child(portal)
	var outer := Polygon2D.new()
	outer.color = Color("#2358C9CC")
	outer.polygon = _ellipse_points(11.0,28.0,18)
	portal.add_child(outer)
	var middle := Polygon2D.new()
	middle.color = Color("#36B5FFE6")
	middle.polygon = _ellipse_points(7.0,24.0,18)
	portal.add_child(middle)
	var core := Polygon2D.new()
	core.color = Color("#E9FAFFFF")
	core.polygon = _ellipse_points(3.0,20.0,18)
	portal.add_child(core)
	portal.scale = Vector2(0.08,0.85)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(portal,"scale",Vector2(1.0,1.0),0.22)
	await tween.finished
	return portal

func _close_portal(portal: Node2D) -> void:
	if portal == null or not is_instance_valid(portal):
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(portal,"scale",Vector2(0.05,0.9),0.16)
	tween.parallel().tween_property(portal,"modulate:a",0.0,0.16)
	await tween.finished
	portal.queue_free()

func _on_episode_finished() -> void:
	if father_location == FatherLocation.EPISODE:
		await return_father_to_theater()
	father.watch_stage()
	await father_speak("Well. That went about as expected.",1.35)
