extends Node2D

const SCREEN_SIZE := Vector2(1200, 900)

var phase := 0
var fallen := false
var adam_clothed := false
var god_comment_index := 0
var god_comments := [
	"Adam. Buddy.",
	"You have leaves.",
	"The inventory is not decorative.",
	"I'm going to keep talking until you fix this."
]

var story_panel: PanelContainer
var title_label: Label
var body_label: Label
var choices_box: VBoxContainer
var inventory_panel: PanelContainer
var inventory_label: Label
var use_leaves_button: Button
var theater_panel: PanelContainer
var theater_label: Label
var comment_timer: Timer

func _ready() -> void:
	_build_ui()
	_show_temptation()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#0d3428"))
	draw_rect(Rect2(70, 70, 1060, 760), Color("#75b75a"))

	# Tree of knowledge and clearing.
	draw_circle(Vector2(600, 330), 135, Color("#173e29"))
	draw_circle(Vector2(600, 315), 125, Color("#347c3d"))
	draw_rect(Rect2(575, 320, 50, 205), Color("#6f421f"))
	for p in [Vector2(545,275),Vector2(590,235),Vector2(650,275),Vector2(560,350),Vector2(655,350)]:
		draw_circle(p, 46, Color("#3f8d46"))
	for p in [Vector2(540,300),Vector2(605,260),Vector2(650,315),Vector2(575,365),Vector2(630,380)]:
		draw_circle(p, 11, Color("#c84839"))
		draw_circle(p + Vector2(-3,-3), 4, Color("#ef7562"))

	_draw_eve(Vector2(390, 580), fallen)
	_draw_adam(Vector2(800, 585), fallen, adam_clothed)
	_draw_serpent(Vector2(850, 330))

	draw_string(ThemeDB.fallback_font, Vector2(505, 545), "FRUIT", HORIZONTAL_ALIGNMENT_CENTER, 190, 18, Color("#fff2d1"))

func _draw_eve(p: Vector2, after_fall: bool) -> void:
	draw_circle(p + Vector2(0,-35), 27, Color("#c98758"))
	draw_circle(p + Vector2(0,15), 34, Color("#c88358"))
	draw_line(p+Vector2(-16,36),p+Vector2(-20,82),Color("#955d3d"),12.0)
	draw_line(p+Vector2(16,36),p+Vector2(20,82),Color("#955d3d"),12.0)
	draw_arc(p+Vector2(0,-36),31,PI,TAU,20,Color("#5a3324"),14.0)
	draw_line(p+Vector2(-23,-30),p+Vector2(-38,20),Color("#5a3324"),9.0)
	draw_line(p+Vector2(23,-30),p+Vector2(38,20),Color("#5a3324"),9.0)
	if after_fall:
		_draw_leaf_cover(p + Vector2(0,32))
	else:
		_draw_soft_blur(p + Vector2(0,33))
	draw_string(ThemeDB.fallback_font,p+Vector2(-55,120),"EVE",HORIZONTAL_ALIGNMENT_CENTER,110,18,Color("#fff2d1"))

func _draw_adam(p: Vector2, after_fall: bool, clothed: bool) -> void:
	draw_circle(p + Vector2(0,-35), 27, Color("#c98758"))
	draw_circle(p + Vector2(0,15), 34, Color("#bd7546"))
	draw_line(p+Vector2(-16,36),p+Vector2(-20,82),Color("#955d3d"),12.0)
	draw_line(p+Vector2(16,36),p+Vector2(20,82),Color("#955d3d"),12.0)
	draw_arc(p+Vector2(0,-36),30,PI,TAU,18,Color("#43281e"),11.0)
	if after_fall:
		if clothed:
			_draw_leaf_cover(p + Vector2(0,32))
		else:
			_draw_black_box(p + Vector2(0,32))
	else:
		_draw_soft_blur(p + Vector2(0,33))
	draw_string(ThemeDB.fallback_font,p+Vector2(-55,120),"ADAM",HORIZONTAL_ALIGNMENT_CENTER,110,18,Color("#fff2d1"))

func _draw_soft_blur(p: Vector2) -> void:
	for item in [
		[Vector2(-12,-7),Color("#b78b68aa")],[Vector2(0,-10),Color("#d2a17aaa")],
		[Vector2(12,-5),Color("#a9785baa")],[Vector2(-6,7),Color("#ca9874aa")],
		[Vector2(8,8),Color("#bb8865aa")]
	]:
		draw_rect(Rect2(p + item[0] - Vector2(8,7), Vector2(16,14)), item[1])

func _draw_black_box(p: Vector2) -> void:
	draw_rect(Rect2(p - Vector2(30,18), Vector2(60,36)), Color("#111111"))
	draw_rect(Rect2(p - Vector2(30,18), Vector2(60,36)), Color("#3a3a3a"), false, 3.0)

func _draw_leaf_cover(p: Vector2) -> void:
	for off in [Vector2(-18,0),Vector2(0,-8),Vector2(18,1),Vector2(-7,12),Vector2(10,12)]:
		draw_circle(p + off, 13, Color("#397b3f"))
		draw_line(p + off, p + off + Vector2(7,-7), Color("#20572f"), 2.0)

func _draw_serpent(p: Vector2) -> void:
	draw_arc(p, 48, 0.2, TAU*0.85, 32, Color("#183c25"), 20.0)
	draw_arc(p, 48, 0.2, TAU*0.85, 32, Color("#51a148"), 12.0)
	draw_circle(p + Vector2(42,-38), 18, Color("#193b25"))
	draw_circle(p + Vector2(42,-38), 13, Color("#5dad4d"))
	draw_circle(p + Vector2(48,-42), 3, Color("#f2d956"))
	draw_line(p + Vector2(55,-35),p+Vector2(69,-31),Color("#c84848"),3.0)
	draw_string(ThemeDB.fallback_font,p+Vector2(-55,105),"SERPENT",HORIZONTAL_ALIGNMENT_CENTER,110,18,Color("#fff2d1"))

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	story_panel = PanelContainer.new()
	story_panel.position = Vector2(150, 80)
	story_panel.size = Vector2(900, 245)
	story_panel.add_theme_stylebox_override("panel", _panel_style(Color("#211724f4"), Color("#e8b94f")))
	layer.add_child(story_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	story_panel.add_child(stack)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 27)
	title_label.add_theme_color_override("font_color", Color("#ffd66d"))
	stack.add_child(title_label)
	body_label = Label.new()
	body_label.custom_minimum_size = Vector2(840, 70)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 21)
	body_label.add_theme_color_override("font_color", Color("#fff3db"))
	stack.add_child(body_label)
	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 6)
	stack.add_child(choices_box)

	inventory_panel = PanelContainer.new()
	inventory_panel.position = Vector2(870, 690)
	inventory_panel.size = Vector2(290, 150)
	inventory_panel.visible = false
	inventory_panel.add_theme_stylebox_override("panel", _panel_style(Color("#18251fed"),Color("#d6b85e")))
	layer.add_child(inventory_panel)
	var inv_stack := VBoxContainer.new()
	inventory_panel.add_child(inv_stack)
	inventory_label = Label.new()
	inventory_label.text = "INVENTORY\nLEAVES  x1"
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_label.add_theme_font_size_override("font_size", 19)
	inventory_label.add_theme_color_override("font_color", Color("#fff3db"))
	inv_stack.add_child(inventory_label)
	use_leaves_button = Button.new()
	use_leaves_button.text = "USE LEAVES"
	use_leaves_button.add_theme_font_size_override("font_size", 18)
	use_leaves_button.add_theme_stylebox_override("normal", _button_style(Color("#31452d"),Color("#8cbf5e")))
	use_leaves_button.pressed.connect(_use_leaves)
	inv_stack.add_child(use_leaves_button)

	theater_panel = PanelContainer.new()
	theater_panel.position = Vector2(80, 690)
	theater_panel.size = Vector2(720, 120)
	theater_panel.visible = false
	theater_panel.add_theme_stylebox_override("panel", _panel_style(Color("#17121ce8"),Color("#8f7698")))
	layer.add_child(theater_panel)
	theater_label = Label.new()
	theater_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	theater_label.add_theme_font_size_override("font_size", 19)
	theater_label.add_theme_color_override("font_color", Color("#efe3f2"))
	theater_panel.add_child(theater_label)

	comment_timer = Timer.new()
	comment_timer.wait_time = 4.0
	comment_timer.one_shot = false
	comment_timer.timeout.connect(_god_comment)
	add_child(comment_timer)

func _panel_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(3)
	style.set_corner_radius_all(11)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

func _button_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style

func _clear_choices() -> void:
	for child in choices_box.get_children():
		choices_box.remove_child(child)
		child.queue_free()

func _choice(text_value: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 38)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("#fff3db"))
	button.add_theme_color_override("font_hover_color", Color("#ffd66d"))
	button.add_theme_stylebox_override("normal", _button_style(Color("#35263d"),Color("#805f85")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#493352"),Color("#e0ad51")))
	button.pressed.connect(action)
	choices_box.add_child(button)

func _show_temptation() -> void:
	title_label.text = "SERPENT ENCOUNTER"
	body_label.text = "The serpent tempts Eve. Finished serpent dialogue is intentionally left for the script."
	_clear_choices()
	_choice("EAT THE FRUIT", _eve_eats)
	_choice("NOT YET", _show_temptation)
	story_panel.visible = true

func _eve_eats() -> void:
	phase = 1
	title_label.text = "STORY"
	body_label.text = "Eve eats the fruit and offers it to Adam."
	_clear_choices()
	_choice("THE PRETTY LADY TOLD HIM TO", _adam_eats)
	queue_redraw()

func _adam_eats() -> void:
	phase = 2
	fallen = true
	story_panel.visible = false
	inventory_panel.visible = true
	theater_panel.visible = true
	god_comment_index = 0
	_god_comment()
	comment_timer.start()
	queue_redraw()

func _god_comment() -> void:
	if adam_clothed:
		return
	var line: String = str(god_comments[god_comment_index % god_comments.size()])
	god_comment_index += 1
	theater_label.text = "GOD — FROM THE THEATER\n" + line

func _use_leaves() -> void:
	if adam_clothed:
		return
	adam_clothed = true
	comment_timer.stop()
	use_leaves_button.disabled = true
	inventory_label.text = "INVENTORY\nLEAVES  x0"
	theater_label.text = "GOD — FROM THE THEATER\nFinally."
	story_panel.visible = true
	title_label.text = "FALL VERTICAL SLICE COMPLETE"
	body_label.text = "Adam is clothed. The next exile / consequence beat remains to be scripted and built."
	_clear_choices()
	_choice("RETURN TO TITLE", _finish)
	_save_progress()
	queue_redraw()

func _finish() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func _save_progress() -> void:
	var profile := ConfigFile.new()
	if profile.load("user://profile.cfg") != OK:
		return
	var slot := int(profile.get_value("save", "last_slot", 0))
	if slot < 1:
		return
	var save := ConfigFile.new()
	save.load("user://slot_%d.cfg" % slot)
	save.set_value("progress", "chapter", "eden")
	save.set_value("progress", "fall_clothed", true)
	save.save("user://slot_%d.cfg" % slot)

func ci_after_fruit() -> void:
	_adam_eats()

func ci_clothe_adam() -> void:
	if not fallen:
		_adam_eats()
	_use_leaves()
