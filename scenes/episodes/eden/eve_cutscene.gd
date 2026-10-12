extends Node2D

const SCREEN_SIZE := Vector2(1200, 900)

var phase := 0
var caption_panel: PanelContainer
var speaker_label: Label
var body_label: Label
var advance_button: Button
var blackout := false

func _ready() -> void:
	_build_ui()
	_set_phase(0)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#0e3025"))
	draw_rect(Rect2(70, 70, 1060, 760), Color("#7ab85b"))
	draw_line(Vector2(130, 720), Vector2(1070, 720), Color("#d3ba79"), 55.0, true)
	for p in [Vector2(130,130),Vector2(240,120),Vector2(975,125),Vector2(1080,145),Vector2(170,690),Vector2(1030,690)]:
		_draw_tree(p)

	if phase <= 2:
		_draw_god(Vector2(400, 420))
		_draw_adam(Vector2(700, 455), phase >= 2)
		if phase == 0:
			_draw_log(Vector2(520, 535))
	elif phase >= 3:
		_draw_god(Vector2(335, 430))
		_draw_adam(Vector2(870, 515), true)
		_draw_eve(Vector2(615, 455))
		_draw_cow(Vector2(610, 645))

	if blackout:
		draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color.BLACK)

func _draw_tree(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-10, 0), Vector2(20, 65)), Color("#75431f"))
	for q in [p + Vector2(-28,0),p + Vector2(28,0),p + Vector2(0,-28),p + Vector2(0,12)]:
		draw_circle(q, 34, Color("#2f773b"))
		draw_arc(q, 34, 0, TAU, 24, Color("#1e4e2e"), 4.0)

func _draw_god(p: Vector2) -> void:
	var robe := PackedVector2Array([p+Vector2(-42,25),p+Vector2(42,25),p+Vector2(65,135),p+Vector2(-65,135)])
	draw_colored_polygon(robe, Color("#f2ecdb"))
	draw_circle(p, 38, Color("#d99a62"))
	draw_arc(p, 55, 0, TAU, 48, Color("#ffd35a"), 6.0)
	draw_arc(p+Vector2(0,-4), 38, PI, TAU, 24, Color("#f3efe3"), 15.0)
	draw_circle(p+Vector2(-16,32), 23, Color("#f3efe3"))
	draw_circle(p+Vector2(16,32), 23, Color("#f3efe3"))
	draw_circle(p+Vector2(-10,-4), 3.5, Color("#32221c"))
	draw_circle(p+Vector2(10,-4), 3.5, Color("#32221c"))

func _draw_adam(p: Vector2, unconscious: bool) -> void:
	if unconscious:
		draw_circle(p + Vector2(75, 15), 27, Color("#c88759"))
		draw_line(p+Vector2(10,18),p+Vector2(62,18),Color("#bb7548"),42.0)
		draw_line(p+Vector2(5,20),p+Vector2(-35,35),Color("#9b613f"),12.0)
		draw_line(p+Vector2(18,20),p+Vector2(55,48),Color("#9b613f"),12.0)
		draw_arc(p+Vector2(75,15),29,PI*0.5,PI*1.5,18,Color("#43281e"),11.0)
		draw_string(ThemeDB.fallback_font,p+Vector2(8,85),"ADAM (VERY ASLEEP)",HORIZONTAL_ALIGNMENT_CENTER,180,18,Color("#fff1cf"))
	else:
		draw_circle(p + Vector2(0,-30), 27, Color("#c88759"))
		draw_circle(p + Vector2(0,18), 34, Color("#bb7548"))
		draw_line(p+Vector2(-17,38),p+Vector2(-22,82),Color("#9b613f"),12.0)
		draw_line(p+Vector2(17,38),p+Vector2(22,82),Color("#9b613f"),12.0)
		draw_arc(p+Vector2(0,-30),30,PI,TAU,18,Color("#43281e"),11.0)
		draw_string(ThemeDB.fallback_font,p+Vector2(-60,115),"ADAM",HORIZONTAL_ALIGNMENT_CENTER,120,18,Color("#fff1cf"))

func _draw_eve(p: Vector2) -> void:
	draw_circle(p + Vector2(0,-30), 27, Color("#c88759"))
	draw_circle(p + Vector2(0,18), 34, Color("#c88358"))
	draw_line(p+Vector2(-17,38),p+Vector2(-22,82),Color("#9b613f"),12.0)
	draw_line(p+Vector2(17,38),p+Vector2(22,82),Color("#9b613f"),12.0)
	draw_arc(p+Vector2(0,-31),31,PI,TAU,20,Color("#5a3324"),14.0)
	draw_line(p+Vector2(-23,-27),p+Vector2(-37,18),Color("#5a3324"),9.0)
	draw_line(p+Vector2(23,-27),p+Vector2(37,18),Color("#5a3324"),9.0)
	draw_string(ThemeDB.fallback_font,p+Vector2(-60,115),"EVE",HORIZONTAL_ALIGNMENT_CENTER,120,18,Color("#fff1cf"))

func _draw_log(p: Vector2) -> void:
	draw_line(p+Vector2(-70,0),p+Vector2(70,0),Color("#3d2115"),34.0)
	draw_line(p+Vector2(-65,-2),p+Vector2(65,-2),Color("#875126"),24.0)
	draw_circle(p+Vector2(70,0),17,Color("#5a331d"))
	draw_circle(p+Vector2(70,0),10,Color("#aa6a32"))
	draw_string(ThemeDB.fallback_font,p+Vector2(-80,52),"A PERFECTLY NORMAL LOG",HORIZONTAL_ALIGNMENT_CENTER,160,15,Color("#fff1cf"))

func _draw_cow(p: Vector2) -> void:
	draw_circle(p, 48, Color("#2e2926"))
	draw_circle(p, 41, Color("#eee9da"))
	draw_circle(p+Vector2(48,-13),27,Color("#2e2926"))
	draw_circle(p+Vector2(46,-13),22,Color("#eee9da"))
	draw_circle(p+Vector2(-15,-8),13,Color("#4b342b"))
	draw_circle(p+Vector2(12,14),11,Color("#4b342b"))
	draw_string(ThemeDB.fallback_font,p+Vector2(-70,80),"COW",HORIZONTAL_ALIGNMENT_CENTER,140,18,Color("#fff1cf"))

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	caption_panel = PanelContainer.new()
	caption_panel.position = Vector2(180, 85)
	caption_panel.size = Vector2(840, 220)
	caption_panel.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(caption_panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	caption_panel.add_child(stack)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 28)
	speaker_label.add_theme_color_override("font_color", Color("#ffd66d"))
	stack.add_child(speaker_label)

	body_label = Label.new()
	body_label.custom_minimum_size = Vector2(770, 75)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 22)
	body_label.add_theme_color_override("font_color", Color("#fff3db"))
	stack.add_child(body_label)

	advance_button = Button.new()
	advance_button.custom_minimum_size = Vector2(0, 42)
	advance_button.add_theme_font_size_override("font_size", 19)
	advance_button.add_theme_color_override("font_color", Color("#fff3db"))
	advance_button.add_theme_color_override("font_hover_color", Color("#ffd66d"))
	advance_button.add_theme_stylebox_override("normal", _button_style(Color("#35263d"),Color("#805f85")))
	advance_button.add_theme_stylebox_override("hover", _button_style(Color("#493352"),Color("#e0ad51")))
	advance_button.pressed.connect(_advance)
	stack.add_child(advance_button)

	var skip := Button.new()
	skip.text = "RETURN TO EDEN"
	skip.position = Vector2(1010, 835)
	skip.size = Vector2(170, 42)
	skip.add_theme_font_size_override("font_size", 15)
	skip.add_theme_stylebox_override("normal", _button_style(Color("#18231ee8"),Color("#d8b963")))
	skip.pressed.connect(_finish_scene)
	layer.add_child(skip)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#211724f2")
	style.border_color = Color("#e8b94f")
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

func _button_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style

func _set_phase(value: int) -> void:
	phase = value
	blackout = false
	match phase:
		0:
			speaker_label.text = "STORY"
			body_label.text = "God realizes Adam needs help. A completely ordinary log is nearby."
			advance_button.text = "THIS SEEMS FINE"
		1:
			blackout = true
			caption_panel.visible = false
			queue_redraw()
			var timer := get_tree().create_timer(0.75)
			timer.timeout.connect(func():
				caption_panel.visible = true
				_set_phase(2)
			)
			return
		2:
			speaker_label.text = "GOD"
			body_label.text = "\"And I PUT HIM TO SLEEP.\""
			advance_button.text = "ABSOLUTELY. THAT IS WHAT HAPPENED."
		3:
			speaker_label.text = "STORY"
			body_label.text = "One rib later, Eve is here. God immediately decides to test the difference."
			advance_button.text = "PROCEED TO COW"
		4:
			speaker_label.text = "GOD"
			body_label.text = "What is this animal called?"
			advance_button.text = "LET EVE ANSWER"
		5:
			speaker_label.text = "EVE"
			body_label.text = "\"That's a cow.\""
			advance_button.text = "GOD PROCESSES THIS"
		6:
			speaker_label.text = "GOD"
			body_label.text = "\"I like this one.\"\n\nGod turns toward Adam. God slowly shakes His head."
			advance_button.text = "END SCENE"
	queue_redraw()

func _advance() -> void:
	if phase == 6:
		_finish_scene()
		return
	_set_phase(phase + 1)

func _finish_scene() -> void:
	_save_eve_created()
	get_tree().change_scene_to_file("res://scenes/episodes/eden/eden.tscn")

func _save_eve_created() -> void:
	var profile := ConfigFile.new()
	if profile.load("user://profile.cfg") != OK:
		return
	var slot := int(profile.get_value("save", "last_slot", 0))
	if slot < 1:
		return
	var save := ConfigFile.new()
	save.load("user://slot_%d.cfg" % slot)
	save.set_value("progress", "chapter", "eden")
	save.set_value("progress", "eve_created", true)
	save.save("user://slot_%d.cfg" % slot)

func ci_jump_to_sleep_line() -> void:
	_set_phase(2)

func ci_jump_to_cow_payoff() -> void:
	_set_phase(6)
