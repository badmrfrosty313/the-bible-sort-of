extends Node2D

# ============================================================
# THE BIBLE... SORT OF
# Theater Scene
#
# Native resolution: 480 x 270
#
# This script builds the complete theater shell:
# - dark theater background
# - biblical stage/screen
# - side curtains
# - scalloped top curtain
# - foreground control desk
# - control panel details
# - audience seating
# - runtime anchors
# - Father entrance
#
# Episodes will eventually load into StageContent.
# ============================================================


# ------------------------------------------------------------
# EXTERNAL SCENES
# ------------------------------------------------------------

const FATHER_SCENE := preload("res://scenes/characters/father.tscn")


# ------------------------------------------------------------
# COLORS
# ------------------------------------------------------------

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


# ------------------------------------------------------------
# RUNTIME REFERENCES
# ------------------------------------------------------------

var stage_content: Node2D

var father_anchor: Marker2D
var left_entrance: Marker2D
var right_entrance: Marker2D
var seat_anchor: Marker2D

var father: Father


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	build_theater()

	# Let Godot finish adding the generated theater nodes
	# before we begin spawning characters.
	await get_tree().process_frame

	_spawn_father()

	# Small theatrical pause before Father enters.
	await get_tree().create_timer(0.75).timeout

	await _run_intro()


# ============================================================
# MASTER BUILD
# ============================================================

func build_theater() -> void:
	_build_background()
	_build_stage()
	_build_theater_art()
	_build_runtime_anchors()


# ============================================================
# BACKGROUND
# ============================================================

func _build_background() -> void:
	var background := Polygon2D.new()
	background.name = "Background"
	background.color = COLOR_BACKGROUND

	background.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(480, 0),
		Vector2(480, 270),
		Vector2(0, 270)
	])

	add_child(background)


# ============================================================
# STAGE
# ============================================================

func _build_stage() -> void:
	var stage := Node2D.new()
	stage.name = "Stage"
	add_child(stage)

	# Main biblical "screen".
	var screen := Polygon2D.new()
	screen.name = "Screen"
	screen.color = COLOR_STAGE

	screen.polygon = PackedVector2Array([
		Vector2(40, 36),
		Vector2(440, 36),
		Vector2(440, 220),
		Vector2(40, 220)
	])

	stage.add_child(screen)

	# Slight inner frame gives the stage more depth.
	var inner_frame := Polygon2D.new()
	inner_frame.name = "InnerFrame"
	inner_frame.color = Color("#160F14")

	inner_frame.polygon = PackedVector2Array([
		Vector2(52, 48),
		Vector2(428, 48),
		Vector2(428, 208),
		Vector2(52, 208)
	])

	stage.add_child(inner_frame)

	# This node will eventually contain Eden, Babel,
	# Burning Bush, Jonah, etc.
	stage_content = Node2D.new()
	stage_content.name = "StageContent"

	stage.add_child(stage_content)


# ============================================================
# THEATER ART
# ============================================================

func _build_theater_art() -> void:
	var theater_art := Node2D.new()
	theater_art.name = "TheaterArt"

	add_child(theater_art)

	_build_left_curtain(theater_art)
	_build_right_curtain(theater_art)
	_build_top_curtain(theater_art)

	_build_curtain_details(theater_art)
	_build_control_desk(theater_art)
	_build_audience(theater_art)


# ============================================================
# CURTAINS
# ============================================================

func _build_left_curtain(parent: Node2D) -> void:
	var curtain := Polygon2D.new()
	curtain.name = "LeftCurtain"
	curtain.color = COLOR_CURTAIN

	curtain.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(40, 20),
		Vector2(40, 200),
		Vector2(0, 220)
	])

	parent.add_child(curtain)


func _build_right_curtain(parent: Node2D) -> void:
	var curtain := Polygon2D.new()
	curtain.name = "RightCurtain"
	curtain.color = COLOR_CURTAIN

	curtain.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(40, 20),
		Vector2(40, 200),
		Vector2(0, 220)
	])

	curtain.position = Vector2(480, 0)
	curtain.scale = Vector2(-1, 1)

	parent.add_child(curtain)


func _build_top_curtain(parent: Node2D) -> void:
	var curtain := Polygon2D.new()
	curtain.name = "TopCurtain"
	curtain.color = COLOR_CURTAIN

	curtain.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(480, 0),
		Vector2(480, 36),
		Vector2(400, 48),
		Vector2(320, 36),
		Vector2(240, 50),
		Vector2(160, 36),
		Vector2(80, 48),
		Vector2(0, 36)
	])

	parent.add_child(curtain)


# ============================================================
# CURTAIN DETAIL
# ============================================================

func _build_curtain_details(parent: Node2D) -> void:
	# Vertical folds. These are deliberately chunky because
	# we're working at a 480x270 pixel-art resolution.

	var left_fold := Polygon2D.new()
	left_fold.name = "LeftCurtainFold"
	left_fold.color = COLOR_CURTAIN_DARK

	left_fold.polygon = PackedVector2Array([
		Vector2(10, 5),
		Vector2(18, 9),
		Vector2(18, 210),
		Vector2(10, 215)
	])

	parent.add_child(left_fold)

	var right_fold := Polygon2D.new()
	right_fold.name = "RightCurtainFold"
	right_fold.color = COLOR_CURTAIN_DARK

	right_fold.polygon = PackedVector2Array([
		Vector2(10, 5),
		Vector2(18, 9),
		Vector2(18, 210),
		Vector2(10, 215)
	])

	right_fold.position = Vector2(480, 0)
	right_fold.scale = Vector2(-1, 1)

	parent.add_child(right_fold)

	# Chunky highlights.
	var left_highlight := Polygon2D.new()
	left_highlight.name = "LeftCurtainHighlight"
	left_highlight.color = COLOR_CURTAIN_HIGHLIGHT

	left_highlight.polygon = PackedVector2Array([
		Vector2(25, 14),
		Vector2(31, 17),
		Vector2(31, 203),
		Vector2(25, 207)
	])

	parent.add_child(left_highlight)

	var right_highlight := Polygon2D.new()
	right_highlight.name = "RightCurtainHighlight"
	right_highlight.color = COLOR_CURTAIN_HIGHLIGHT

	right_highlight.polygon = PackedVector2Array([
		Vector2(25, 14),
		Vector2(31, 17),
		Vector2(31, 203),
		Vector2(25, 207)
	])

	right_highlight.position = Vector2(480, 0)
	right_highlight.scale = Vector2(-1, 1)

	parent.add_child(right_highlight)


# ============================================================
# CONTROL DESK
# ============================================================

func _build_control_desk(parent: Node2D) -> void:
	var desk := Node2D.new()
	desk.name = "ControlDesk"

	parent.add_child(desk)

	# Sloped upper control surface.
	var surface := Polygon2D.new()
	surface.name = "Surface"
	surface.color = COLOR_DESK

	surface.polygon = PackedVector2Array([
		Vector2(90, 220),
		Vector2(390, 220),
		Vector2(440, 270),
		Vector2(40, 270)
	])

	desk.add_child(surface)

	# Front edge.
	var front := Polygon2D.new()
	front.name = "Front"
	front.color = COLOR_DESK_FRONT

	front.polygon = PackedVector2Array([
		Vector2(40, 258),
		Vector2(440, 258),
		Vector2(440, 270),
		Vector2(40, 270)
	])

	desk.add_child(front)

	# Highlight on the desk's upper edge.
	var edge := Polygon2D.new()
	edge.name = "UpperEdge"
	edge.color = COLOR_DESK_EDGE

	edge.polygon = PackedVector2Array([
		Vector2(90, 220),
		Vector2(390, 220),
		Vector2(394, 224),
		Vector2(86, 224)
	])

	desk.add_child(edge)

	_build_control_panel(desk)


# ============================================================
# CONTROL PANEL
# ============================================================

func _build_control_panel(parent: Node2D) -> void:
	var panel := Polygon2D.new()
	panel.name = "Panel"
	panel.color = COLOR_PANEL

	panel.polygon = PackedVector2Array([
		Vector2(155, 230),
		Vector2(325, 230),
		Vector2(350, 260),
		Vector2(130, 260)
	])

	parent.add_child(panel)

	# Big red INTERVENE button.
	_create_control_light(
		parent,
		"InterveneButton",
		Vector2(240, 243),
		8.0,
		COLOR_BUTTON_RED
	)

	# Secondary controls.
	_create_control_light(
		parent,
		"GoldControl",
		Vector2(190, 244),
		4.0,
		COLOR_BUTTON_GOLD
	)

	_create_control_light(
		parent,
		"GreenControl",
		Vector2(290, 244),
		4.0,
		COLOR_BUTTON_GREEN
	)

	# Tiny status indicators.
	_create_control_light(
		parent,
		"StatusLeft",
		Vector2(166, 248),
		2.0,
		COLOR_BUTTON_GREEN
	)

	_create_control_light(
		parent,
		"StatusRight",
		Vector2(314, 248),
		2.0,
		COLOR_BUTTON_GOLD
	)


func _create_control_light(
	parent: Node2D,
	node_name: String,
	center: Vector2,
	radius: float,
	color: Color
) -> void:

	var light := Polygon2D.new()
	light.name = node_name
	light.color = color

	var points := PackedVector2Array()
	var segments := 8

	for i in range(segments):
		var angle := TAU * float(i) / float(segments)

		points.append(
			center + Vector2(
				cos(angle),
				sin(angle)
			) * radius
		)

	light.polygon = points

	parent.add_child(light)


# ============================================================
# AUDIENCE
# ============================================================

func _build_audience(parent: Node2D) -> void:
	var audience := Node2D.new()
	audience.name = "Audience"

	parent.add_child(audience)

	# Only the closest rows are visible.
	# The theater should feel mostly empty and enormous.

	_create_seat(
		audience,
		Vector2(12, 234),
		28,
		30
	)

	_create_seat(
		audience,
		Vector2(450, 234),
		28,
		30
	)

	_create_seat(
		audience,
		Vector2(2, 202),
		24,
		27
	)

	_create_seat(
		audience,
		Vector2(454, 202),
		24,
		27
	)


func _create_seat(
	parent: Node2D,
	position_value: Vector2,
	width: float,
	height: float
) -> void:

	var seat := Node2D.new()
	seat.position = position_value

	parent.add_child(seat)

	var back := Polygon2D.new()
	back.color = COLOR_SEAT

	back.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(width, 0),
		Vector2(width - 2, height),
		Vector2(2, height)
	])

	seat.add_child(back)

	var edge := Polygon2D.new()
	edge.color = COLOR_SEAT_EDGE

	edge.polygon = PackedVector2Array([
		Vector2(2, 3),
		Vector2(width - 2, 3),
		Vector2(width - 3, 6),
		Vector2(3, 6)
	])

	seat.add_child(edge)


# ============================================================
# RUNTIME ANCHORS
# ============================================================

func _build_runtime_anchors() -> void:
	# Father can enter from either side of the theater.

	left_entrance = Marker2D.new()
	left_entrance.name = "LeftEntrance"
	left_entrance.position = Vector2(-30, 205)

	add_child(left_entrance)

	right_entrance = Marker2D.new()
	right_entrance.name = "RightEntrance"
	right_entrance.position = Vector2(510, 205)

	add_child(right_entrance)

	# Where Father eventually sits behind the controls.
	seat_anchor = Marker2D.new()
	seat_anchor.name = "FatherSeat"
	seat_anchor.position = Vector2(240, 211)

	add_child(seat_anchor)

	# Useful general anchor for Father when standing.
	father_anchor = Marker2D.new()
	father_anchor.name = "FatherStanding"
	father_anchor.position = Vector2(240, 205)

	add_child(father_anchor)


# ============================================================
# FATHER
# ============================================================

func _spawn_father() -> void:
	father = FATHER_SCENE.instantiate() as Father

	if father == null:
		push_error("Father scene could not be instantiated.")
		return

	father.name = "Father"
	father.visible = false

	add_child(father)


# ============================================================
# INTRO SEQUENCE
# ============================================================

func _run_intro() -> void:
	if father == null:
		push_error("Father does not exist.")
		return

	if left_entrance == null:
		push_error("LeftEntrance marker does not exist.")
		return

	if father_anchor == null:
		push_error("FatherStanding marker does not exist.")
		return

	await father.enter_from_left(
		left_entrance.global_position,
		father_anchor.global_position
	)

	father.stand()
