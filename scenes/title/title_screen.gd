extends Node2D

const BEACH_PLATE := preload("res://art/title/beach_title_plate.png")
const BEACH_INTRO_SCRIPT := preload("res://scenes/title/beach_intro.gd")
const SLOT_COUNT := 3
const GOLD := Color("#FFE2A0")
const CREAM := Color("#FFF2D7")
const DARK := Color("#171026DD")
const BUBBLE_FILL := Color("#FFF5E1")
const BUBBLE_EDGE := Color("#654632")
const BUBBLE_INK := Color("#362719")

# Shared typography for this one screen. Sizing and positions remain unchanged.
const MENU_TEXT := Color("#F6E7C8")
const MENU_SELECTED := Color("#FFD77A")
const MENU_DISABLED := Color("#B9B1A2")
const MENU_OUTLINE := Color("#2E1B16")
const MENU_OUTLINE_SIZE := 2

enum Screen { INTRO, MENU, SLOTS, PROLOGUE, OPTIONS }

var screen := Screen.INTRO
var ui: Control
var title_group: Control
var menu_group: Control
var panel_group: Control
var intro_group: Control
var beach_intro
var beach_plate: Sprite2D
var continue_button: Button
var last_slot := 0
var active_slot := 0

func _ready() -> void:
	_build_background()
	_build_beach_intro()
	ui = Control.new()
	ui.name = "Interface"
	ui.size = Vector2(480, 270)
	add_child(ui)
	_load_profile()
	_build_title()
	_build_intro()
	_build_panel_group()
	_refresh_continue()
	_play_intro()

func _build_background() -> void:
	var beach := Sprite2D.new()
	beach.name = "BeachPlate"
	beach.texture = BEACH_PLATE
	beach.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	beach.position = Vector2(240, 135)
	beach.scale = Vector2(480.0 / float(BEACH_PLATE.get_width()), 270.0 / float(BEACH_PLATE.get_height()))
	beach_plate = beach
	add_child(beach)

func _build_beach_intro() -> void:
	beach_intro = BEACH_INTRO_SCRIPT.new()
	beach_intro.name = "BeachIntro"
	add_child(beach_intro)
	beach_intro.configure(beach_plate)

func _build_title() -> void:
	title_group = Control.new()
	title_group.name = "TitleMenu"
	title_group.size = Vector2(480, 270)
	title_group.visible = false
	ui.add_child(title_group)

	# No tinted card behind the logo or the menu: let the beach illustration show.
	_style_title_label(_label(title_group, "THE", Rect2(252, 37, 120, 15), 11, MENU_TEXT))
	_style_title_label(_label(title_group, "BIBLE:", Rect2(248, 49, 132, 39), 29, MENU_TEXT))
	_style_title_label(_label(title_group, "SORT OF", Rect2(254, 85, 120, 22), 16, MENU_TEXT))

	menu_group = Control.new()
	# Widen to fit CHAPTER SELECTION and center every row on x=312.
	menu_group.position = Vector2(217, 116)
	menu_group.size = Vector2(190, 94)
	title_group.add_child(menu_group)

	var entries := ["NEW GAME", "CONTINUE", "LOAD", "CHAPTER SELECTION", "OPTIONS"]
	for i in range(entries.size()):
		var button := _menu_button(menu_group, entries[i], Rect2(0, i * 18, 190, 17))
		button.pressed.connect(_on_menu_pressed.bind(entries[i]))
		button.focus_entered.connect(_highlight_menu_entry.bind(button))
		if entries[i] == "CONTINUE":
			continue_button = button


func _build_intro() -> void:
	intro_group = Control.new()
	intro_group.name = "GodThoughtBubble"
	intro_group.size = Vector2(480, 270)
	intro_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_group.visible = false
	ui.add_child(intro_group)

	# God's punchline belongs near his head, not in a bottom-of-screen RPG box.
	var bubble := _thought_shape(intro_group, Rect2(154, 34, 177, 59))
	var line := _label(bubble, "I guess my break\nis over.", Rect2(13, 9, 151, 40), 11, BUBBLE_INK)
	line.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	line.add_theme_constant_override("shadow_offset_x", 0)
	line.add_theme_constant_override("shadow_offset_y", 0)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thought_dot(intro_group, Vector2(150, 92), 13)
	_thought_dot(intro_group, Vector2(135, 104), 9)
	_thought_dot(intro_group, Vector2(123, 110), 6)

func _build_panel_group() -> void:
	panel_group = Control.new()
	panel_group.name = "Subscreen"
	panel_group.size = Vector2(480, 270)
	panel_group.visible = false
	ui.add_child(panel_group)

func _play_intro() -> void:
	# The existing art is a full composite, so this first animatic uses
	# cinematic framing until Father/Adam/vines are supplied as layered art.
	await get_tree().create_timer(1.55).timeout
	if screen != Screen.INTRO:
		return
	beach_intro.show_adam()
	await get_tree().create_timer(0.8).timeout
	if screen != Screen.INTRO:
		return
	await get_tree().create_timer(0.65).timeout
	if screen != Screen.INTRO:
		return
	beach_intro.show_father_reaction()
	await get_tree().create_timer(0.75).timeout
	if screen != Screen.INTRO:
		return
	intro_group.visible = true
	await get_tree().create_timer(1.65).timeout
	if screen != Screen.INTRO:
		return
	intro_group.visible = false
	beach_intro.reveal_full_beach()
	await get_tree().create_timer(0.65).timeout
	if screen == Screen.INTRO:
		_show_menu()

func _show_menu() -> void:
	screen = Screen.MENU
	intro_group.visible = false
	if beach_intro != null:
		beach_intro.reset_immediately()
	panel_group.visible = false
	title_group.visible = true
	title_group.modulate.a = 0.0
	create_tween().tween_property(title_group, "modulate:a", 1.0, 0.35)
	_refresh_continue()
	_focus_first(menu_group)

func _on_menu_pressed(entry: String) -> void:
	match entry:
		"NEW GAME":
			_show_slots(true)
		"CONTINUE":
			if last_slot > 0 and _slot_exists(last_slot):
				_open_prologue(last_slot)
		"LOAD":
			_show_slots(false)
		"CHAPTER SELECTION":
			_show_chapters()
		"OPTIONS":
			_show_options()

func _show_slots(new_game: bool) -> void:
	screen = Screen.SLOTS
	_clear_panel()
	_panel(panel_group, Rect2(224, 52, 214, 173), DARK)
	_label(panel_group, "CHOOSE A SAVE SLOT" if new_game else "LOAD GAME", Rect2(234, 61, 194, 23), 13, GOLD)
	for i in range(1, SLOT_COUNT + 1):
		var occupied := _slot_exists(i)
		var caption := "SLOT %d  -  PROLOGUE" % i if occupied else "SLOT %d  -  EMPTY" % i
		var button := _button(panel_group, caption, Rect2(236, 91 + (i - 1) * 29, 190, 24), 10)
		button.disabled = not new_game and not occupied
		if new_game:
			button.pressed.connect(_start_new_game.bind(i))
		else:
			button.pressed.connect(_open_prologue.bind(i))
	_add_back_button()
	_focus_first(panel_group)

func _start_new_game(slot: int) -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "chapter", "prologue")
	var error := save.save(_slot_path(slot))
	if error != OK:
		push_error("Unable to write save slot %d: %s" % [slot, error])
		return
	last_slot = slot
	_save_profile()
	_open_prologue(slot)

func _open_prologue(slot: int) -> void:
	active_slot = slot
	last_slot = slot
	_save_profile()
	screen = Screen.PROLOGUE
	_clear_panel()
	_panel(panel_group, Rect2(184, 188, 254, 63), DARK)
	_label(panel_group, "PROLOGUE  /  SLOT %d" % slot, Rect2(194, 194, 234, 15), 10, GOLD, false)
	_label(panel_group, "I guess my break is over.", Rect2(194, 211, 234, 18), 12, CREAM, false)
	var button := _button(panel_group, "RETURN TO TITLE", Rect2(291, 232, 135, 15), 8)
	button.pressed.connect(_show_menu)
	_focus_first(panel_group)

func _show_chapters() -> void:
	screen = Screen.SLOTS
	_clear_panel()
	_panel(panel_group, Rect2(224, 66, 214, 144), DARK)
	_label(panel_group, "CHAPTER SELECTION", Rect2(234, 76, 194, 24), 13, GOLD)
	var button := _button(panel_group, "PROLOGUE", Rect2(236, 111, 190, 25), 11)
	button.pressed.connect(_open_prologue.bind(last_slot if last_slot > 0 else 1))
	_add_back_button()
	_focus_first(panel_group)

func _show_options() -> void:
	screen = Screen.OPTIONS
	_clear_panel()
	_panel(panel_group, Rect2(224, 66, 214, 144), DARK)
	_label(panel_group, "OPTIONS", Rect2(234, 76, 194, 24), 14, GOLD)
	var button := _button(panel_group, "TOGGLE FULLSCREEN", Rect2(236, 113, 190, 25), 10)
	button.pressed.connect(_toggle_fullscreen)
	_add_back_button()
	_focus_first(panel_group)

func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func _add_back_button() -> void:
	var button := _button(panel_group, "BACK", Rect2(340, 193, 86, 20), 9)
	button.pressed.connect(_show_menu)

func _clear_panel() -> void:
	for child in panel_group.get_children():
		panel_group.remove_child(child)
		child.queue_free()
	panel_group.visible = true
	title_group.visible = false

func _refresh_continue() -> void:
	if continue_button != null:
		continue_button.disabled = last_slot == 0 or not _slot_exists(last_slot)

func _slot_path(slot: int) -> String:
	return "user://slot_%d.cfg" % slot

func _slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))

func _load_profile() -> void:
	var profile := ConfigFile.new()
	if profile.load("user://profile.cfg") == OK:
		last_slot = int(profile.get_value("save", "last_slot", 0))
	if last_slot < 1 or last_slot > SLOT_COUNT:
		last_slot = 0

func _save_profile() -> void:
	var profile := ConfigFile.new()
	profile.set_value("save", "last_slot", last_slot)
	var error := profile.save("user://profile.cfg")
	if error != OK:
		push_error("Unable to remember last save slot: %s" % error)

func _thought_shape(parent: Control, rect: Rect2) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = BUBBLE_FILL
	style.border_color = BUBBLE_EDGE
	style.set_border_width_all(2)
	style.set_corner_radius_all(29)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _thought_dot(parent: Control, center: Vector2, diameter: int) -> void:
	var dot := Panel.new()
	dot.position = center - Vector2.ONE * float(diameter) * 0.5
	dot.size = Vector2.ONE * float(diameter)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = BUBBLE_FILL
	style.border_color = BUBBLE_EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(diameter)
	dot.add_theme_stylebox_override("panel", style)
	parent.add_child(dot)

func _style_title_label(label: Label, fill: Color = MENU_TEXT) -> void:
	# A single clean edge without an offset double shadow.
	label.add_theme_color_override("font_color", fill)
	label.add_theme_color_override("font_outline_color", MENU_OUTLINE)
	label.add_theme_constant_override("outline_size", MENU_OUTLINE_SIZE)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)

func _menu_button(parent: Control, caption: String, rect: Rect2) -> Button:
	var button := _button(parent, caption, rect, 10)
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_color_override("font_pressed_color", MENU_SELECTED)
	button.add_theme_color_override("font_hover_color", MENU_SELECTED)
	button.add_theme_color_override("font_focus_color", MENU_SELECTED)
	button.add_theme_color_override("font_color", MENU_TEXT)
	button.add_theme_color_override("font_disabled_color", MENU_DISABLED)
	# Same exact stroke as title labels, and no offset shadow.
	button.add_theme_color_override("font_outline_color", MENU_OUTLINE)
	button.add_theme_constant_override("outline_size", MENU_OUTLINE_SIZE)
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button.add_theme_constant_override("shadow_offset_x", 0)
	button.add_theme_constant_override("shadow_offset_y", 0)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxEmpty.new()
		button.add_theme_stylebox_override(state, style)
	return button

func _highlight_menu_entry(button: Button) -> void:
	# All items stay aligned; selection is gold text, never a floating marker.
	for child in menu_group.get_children():
		if child is Button and not child.disabled:
			child.add_theme_color_override("font_color", MENU_SELECTED if child == button else MENU_TEXT)

func _panel(parent: Control, rect: Rect2, color: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#DAA65E")
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _label(parent: Control, value: String, rect: Rect2, font_size: int, color: Color, centered: bool = true) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("#281425"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label

func _button(parent: Control, value: String, rect: Rect2, font_size: int) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", GOLD)
	button.add_theme_color_override("font_focus_color", GOLD)
	button.add_theme_color_override("font_disabled_color", Color("#B6A5A4"))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#2B152000") if state == "normal" else Color("#2B1520B8")
		if state == "focus" or state == "hover":
			style.border_color = GOLD
			style.set_border_width_all(1)
		button.add_theme_stylebox_override(state, style)
	parent.add_child(button)
	return button

func _focus_first(parent: Control) -> void:
	for child in parent.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if screen == Screen.INTRO:
			_show_menu()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and screen != Screen.MENU:
			_show_menu()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and screen == Screen.INTRO:
		_show_menu()
		get_viewport().set_input_as_handled()
