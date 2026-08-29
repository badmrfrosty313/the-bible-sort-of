extends Node2D

const FATHER_SCENE := preload("res://scenes/characters/father.tscn")
const BURNING_BUSH_SCENE := preload("res://scenes/episodes/burning_bush/burning_bush.tscn")

const COLOR_BACKGROUND := Color("#0D0B0C")
const COLOR_STAGE := Color("#21181F")
const COLOR_CURTAIN := Color("#651A24")
const COLOR_CURTAIN_DARK := Color("#451018")
const COLOR_CURTAIN_HIGHLIGHT := Color("#7C2531")
const COLOR_DESK := Color("#30252B")
const COLOR_DESK_FRONT := Color("#1E181C")
const COLOR_DESK_EDGE := Color("#55434C")
const COLOR_SEAT := Color("#24191E")
const COLOR_SEAT_EDGE := Color("#39272F")
const COLOR_BUTTON_RED := Color("#A52A32")
const COLOR_BUTTON_GOLD := Color("#B58A45")
const COLOR_BUTTON_GREEN := Color("#466C55")
const COLOR_PANEL := Color("#171316")

enum FatherLocation { THEATER, EPISODE, TRANSITION }

var stage_content: Node2D
var father_anchor: Marker2D
var left_entrance: Marker2D
var right_entrance: Marker2D
var seat_anchor: Marker2D
var episode_portal: Marker2D
var father: Father
var father_location := FatherLocation.THEATER
var father_dialogue_label: Label
var current_episode: Node2D

func _ready() -> void:
	build_theater()
	await get_tree().process_frame
	_spawn_father()
	await get_tree().create_timer(0.5).timeout
	await _run_intro()
	await _start_burning_bush()

func build_theater() -> void:
	_build_background()
	_build_stage()
	_build_theater_art()
	_build_runtime_anchors()
	_build_father_dialogue()

func _build_background() -> void:
	var p := Polygon2D.new()
	p.color = COLOR_BACKGROUND
	p.polygon = PackedVector2Array([Vector2(0,0), Vector2(480,0), Vector2(480,270), Vector2(0,270)])
	add_child(p)

func _build_stage() -> void:
	var stage := Node2D.new()
	stage.name = "Stage"
	add_child(stage)
	var screen := Polygon2D.new()
	screen.color = COLOR_STAGE
	screen.polygon = PackedVector2Array([Vector2(40,36), Vector2(440,36), Vector2(440,220), Vector2(40,220)])
	stage.add_child(screen)
	var inner := Polygon2D.new()
	inner.color = Color("#160F14")
	inner.polygon = PackedVector2Array([Vector2(52,48), Vector2(428,48), Vector2(428,208), Vector2(52,208)])
	stage.add_child(inner)
	stage_content = Node2D.new()
	stage_content.name = "StageContent"
	stage.add_child(stage_content)

func _build_theater_art() -> void:
	var art := Node2D.new()
	art.name = "TheaterArt"
	add_child(art)
	_build_curtains(art)
	_build_control_desk(art)
	_build_audience(art)

func _build_curtains(parent: Node2D) -> void:
	var left := Polygon2D.new()
	left.color = COLOR_CURTAIN
	left.polygon = PackedVector2Array([Vector2(0,0),Vector2(40,20),Vector2(40,200),Vector2(0,220)])
	parent.add_child(left)
	var right := Polygon2D.new()
	right.color = COLOR_CURTAIN
	right.polygon = left.polygon
	right.position = Vector2(480,0)
	right.scale = Vector2(-1,1)
	parent.add_child(right)
	var top := Polygon2D.new()
	top.color = COLOR_CURTAIN
	top.polygon = PackedVector2Array([Vector2(0,0),Vector2(480,0),Vector2(480,36),Vector2(400,48),Vector2(320,36),Vector2(240,50),Vector2(160,36),Vector2(80,48),Vector2(0,36)])
	parent.add_child(top)
	for x in [10.0, 25.0]:
		var fold := Polygon2D.new()
		fold.color = COLOR_CURTAIN_DARK if x == 10.0 else COLOR_CURTAIN_HIGHLIGHT
		fold.polygon = PackedVector2Array([Vector2(x,5),Vector2(x+7,9),Vector2(x+7,205),Vector2(x,212)])
		parent.add_child(fold)
		var mirror := Polygon2D.new()
		mirror.color = fold.color
		mirror.polygon = fold.polygon
		mirror.position = Vector2(480,0)
		mirror.scale = Vector2(-1,1)
		parent.add_child(mirror)

func _build_control_desk(parent: Node2D) -> void:
	var desk := Node2D.new()
	desk.name = "ControlDesk"
	parent.add_child(desk)
	var surface := Polygon2D.new()
	surface.color = COLOR_DESK
	surface.polygon = PackedVector2Array([Vector2(90,220),Vector2(390,220),Vector2(440,270),Vector2(40,270)])
	desk.add_child(surface)
	var front := Polygon2D.new()
	front.color = COLOR_DESK_FRONT
	front.polygon = PackedVector2Array([Vector2(40,258),Vector2(440,258),Vector2(440,270),Vector2(40,270)])
	desk.add_child(front)
	var edge := Polygon2D.new()
	edge.color = COLOR_DESK_EDGE
	edge.polygon = PackedVector2Array([Vector2(90,220),Vector2(390,220),Vector2(394,224),Vector2(86,224)])
	desk.add_child(edge)
	var panel := Polygon2D.new()
	panel.color = COLOR_PANEL
	panel.polygon = PackedVector2Array([Vector2(155,230),Vector2(325,230),Vector2(350,260),Vector2(130,260)])
	desk.add_child(panel)
	_create_light(desk, Vector2(240,243), 8, COLOR_BUTTON_RED)
	_create_light(desk, Vector2(190,244), 4, COLOR_BUTTON_GOLD)
	_create_light(desk, Vector2(290,244), 4, COLOR_BUTTON_GREEN)
	_create_light(desk, Vector2(166,248), 2, COLOR_BUTTON_GREEN)
	_create_light(desk, Vector2(314,248), 2, COLOR_BUTTON_GOLD)

func _create_light(parent: Node2D, center: Vector2, radius: float, color: Color) -> void:
	var light := Polygon2D.new()
	light.color = color
	var points := PackedVector2Array()
	for i in range(8):
		var a := TAU * float(i) / 8.0
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	light.polygon = points
	parent.add_child(light)

func _build_audience(parent: Node2D) -> void:
	_create_seat(parent, Vector2(12,234),28,30)
	_create_seat(parent, Vector2(450,234),28,30)
	_create_seat(parent, Vector2(2,202),24,27)
	_create_seat(parent, Vector2(454,202),24,27)

func _create_seat(parent: Node2D, pos: Vector2, width: float, height: float) -> void:
	var seat := Polygon2D.new()
	seat.position = pos
	seat.color = COLOR_SEAT
	seat.polygon = PackedVector2Array([Vector2(0,0),Vector2(width,0),Vector2(width-2,height),Vector2(2,height)])
	parent.add_child(seat)

func _build_runtime_anchors() -> void:
	left_entrance = _marker("LeftEntrance", Vector2(-30,205))
	right_entrance = _marker("RightEntrance", Vector2(510,205))
	father_anchor = _marker("FatherStanding", Vector2(240,205))
	seat_anchor = _marker("FatherSeat", Vector2(240,211))
	episode_portal = _marker("EpisodePortal", Vector2(415,190))

func _marker(node_name: String, pos: Vector2) -> Marker2D:
	var m := Marker2D.new()
	m.name = node_name
	m.position = pos
	add_child(m)
	return m

func _build_father_dialogue() -> void:
	father_dialogue_label = Label.new()
	father_dialogue_label.position = Vector2(110,174)
	father_dialogue_label.size = Vector2(260,40)
	father_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	father_dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	father_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	father_dialogue_label.add_theme_font_size_override("font_size", 10)
	father_dialogue_label.add_theme_color_override("font_color", Color("#E7B94F"))
	father_dialogue_label.visible = false
	father_dialogue_label.z_index = 20
	add_child(father_dialogue_label)

func _spawn_father() -> void:
	father = FATHER_SCENE.instantiate() as Father
	if father == null:
		push_error("Father scene could not be instantiated.")
		return
	father.name = "Father"
	father.visible = false
	father.z_index = 10
	add_child(father)

func _run_intro() -> void:
	father_location = FatherLocation.TRANSITION
	await father.enter_from_left(left_entrance.global_position, father_anchor.global_position)
	father.stand()
	await _father_speak("Alright. Let's see what my humans get up to this time.", 1.6)
	await father.move_to(seat_anchor.global_position)
	father.sit()
	father_location = FatherLocation.THEATER

func _start_burning_bush() -> void:
	current_episode = BURNING_BUSH_SCENE.instantiate()
	stage_content.add_child(current_episode)
	current_episode.father_line_requested.connect(_on_father_line_requested)
	current_episode.father_enter_requested.connect(_on_father_enter_requested)
	current_episode.father_exit_requested.connect(_on_father_exit_requested)
	current_episode.episode_finished.connect(_on_episode_finished)

func _on_father_line_requested(text: String) -> void:
	await _father_speak(text, 1.0)

func _on_father_enter_requested(entry_position: Vector2) -> void:
	await _send_father_into_episode(entry_position)

func _on_father_exit_requested() -> void:
	await _return_father_to_theater()

func _father_speak(text: String, duration: float = 1.0) -> void:
	if father_dialogue_label == null:
		return
	var prefix := "FATHER: "
	father_dialogue_label.text = prefix + text
	# Theater lines sit above the desk. Episode lines move into the screen.
	father_dialogue_label.position = Vector2(110,174) if father_location == FatherLocation.THEATER else Vector2(95,58)
	father_dialogue_label.visible = true
	await get_tree().create_timer(duration).timeout
	father_dialogue_label.visible = false

func _send_father_into_episode(entry_position: Vector2) -> void:
	if father == null or father_location != FatherLocation.THEATER:
		return
	father_location = FatherLocation.TRANSITION
	father.stand()
	await father.move_to(episode_portal.global_position)
	# Store the theater representation offstage while Father is in the story.
	father.visible = false
	father_location = FatherLocation.EPISODE
	# Reuse the same authoritative Father node. Reparenting keeps identity/state.
	father.reparent(stage_content, true)
	father.global_position = entry_position
	father.visible = true
	father.stand()

func _return_father_to_theater() -> void:
	if father == null or father_location != FatherLocation.EPISODE:
		return
	father_location = FatherLocation.TRANSITION
	father.visible = false
	father.reparent(self, true)
	father.global_position = episode_portal.global_position
	father.visible = true
	father.stand()
	await father.move_to(seat_anchor.global_position)
	father.sit()
	father_location = FatherLocation.THEATER

func _on_episode_finished() -> void:
	if father_location == FatherLocation.EPISODE:
		await _return_father_to_theater()
	await _father_speak("Well. That went about as expected.", 1.4)
