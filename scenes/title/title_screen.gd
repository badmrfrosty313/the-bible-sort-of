extends Node2D

const BEACH_PLATE := preload("res://art/title/beach_title_plate.png")
const TITLE_ART := preload("res://art/title/approved_title.webp")
# Prefer the exact full-size approved concept when present in this project.
# The small WebP remains a portable fallback so CI and cloned projects boot.
const FULL_RES_TITLE_PATH := "res://art/title/approved_title_original.png"
const SLOT_COUNT := 3
const LAYOUT_SIZE := Vector2(480, 360)
const RENDER_SIZE := Vector2i(1200, 900)

# Independent treatments: the title is vector artwork, navigation is live UI.
const MENU_TEXT := Color("#FFF3DC")
const MENU_SELECTED := Color("#FFD477")
const MENU_DISABLED := Color("#C2B5A4")
const MENU_OUTLINE := Color("#21131B")
const MENU_OUTLINE_SIZE := 3

enum Screen { MENU, SLOTS, PROLOGUE, OPTIONS }

var screen := Screen.MENU
var ui: Control
var title_group: Control
var menu_group: Control
var panel_group: Control
var ui_font: FontVariation
var title_background: Sprite2D
var submenu_background: Sprite2D
var title_focus_marker: Label
var continue_button: Button
var last_slot := 0
var active_slot := 0

func _ready() -> void:
	# Render native 1200x900 instead of magnifying an already tiny viewport.
	# Scale existing 480x360 UI geometry uniformly so the hitboxes still line up.
	scale = Vector2(
		float(RENDER_SIZE.x) / LAYOUT_SIZE.x,
		float(RENDER_SIZE.y) / LAYOUT_SIZE.y
	)
	_build_background()
	ui = Control.new()
	ui.name = "Interface"
	ui.size = Vector2(480, 360)
	add_child(ui)
	_load_profile()
	_build_ui_font()
	_build_title()
	_build_panel_group()
	_show_menu()

func _build_background() -> void:
	# This is the actual approved concept image. Keep all of it visible at 4:3.
	title_background = Sprite2D.new()
	title_background.name = "ApprovedIllustratedTitle"
	# One high-quality Lanczos reconstruction. At native resolution, Godot
	# no longer performs fractional bilinear scaling on the entire game.
	var image_source: Texture2D = TITLE_ART
	if ResourceLoader.exists(FULL_RES_TITLE_PATH):
		var full_res := load(FULL_RES_TITLE_PATH) as Texture2D
		if full_res != null:
			image_source = full_res
	var approved_image := image_source.get_image()
	if approved_image != null and not approved_image.is_empty():
		if approved_image.get_size() != RENDER_SIZE:
			approved_image.resize(RENDER_SIZE.x, RENDER_SIZE.y, Image.INTERPOLATE_LANCZOS)
		title_background.texture = ImageTexture.create_from_image(approved_image)
	else:
		title_background.texture = image_source
	title_background.position = Vector2(240, 180)
	title_background.scale = Vector2(
		480.0 / float(title_background.texture.get_width()),
		360.0 / float(title_background.texture.get_height())
	)
	title_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(title_background)

	# The baked title/menu art must NOT remain behind submenu text.
	submenu_background = Sprite2D.new()
	submenu_background.name = "CleanBeachForSubmenus"
	submenu_background.texture = BEACH_PLATE
	submenu_background.position = Vector2(240, 180)
	var cover := maxf(
		480.0 / float(BEACH_PLATE.get_width()),
		360.0 / float(BEACH_PLATE.get_height())
	)
	submenu_background.scale = Vector2.ONE * cover
	submenu_background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	submenu_background.visible = false
	add_child(submenu_background)

func _build_ui_font() -> void:
	# Platform-neutral Godot font, slightly emboldened for the bright sunset.
	# Separate from the serif artwork and still editable in live menu controls.
	ui_font = FontVariation.new()
	ui_font.variation_embolden = 0.55
	ui_font.spacing_glyph = 0


func _build_title() -> void:
	title_group = Control.new()
	title_group.name = "TitleMenu"
	title_group.size = Vector2(480, 360)
	title_group.visible = false
	ui.add_child(title_group)

	# Every word and the logo are already in the approved picture.
	# Native transparent Buttons provide mouse, keyboard, and controller input.
	menu_group = Control.new()
	menu_group.name = "InvisibleLiveMenu"
	menu_group.size = Vector2(480, 360)
	title_group.add_child(menu_group)

	var entries := [
		{"caption": "NEW GAME", "box": Rect2(166, 210, 148, 22)},
		{"caption": "CONTINUE", "box": Rect2(166, 232, 148, 24)},
		{"caption": "LOAD", "box": Rect2(177, 254, 126, 24)},
		{"caption": "CHAPTER SELECTION", "box": Rect2(133, 278, 214, 24)},
		{"caption": "OPTIONS", "box": Rect2(175, 301, 130, 24)}
	]
	for entry in entries:
		var caption: String = entry["caption"]
		var rect: Rect2 = entry["box"]
		var button := Button.new()
		button.text = caption
		button.position = rect.position
		button.size = rect.size
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.flat = true
		# Transparent hit area: do not paint duplicate menu lettering.
		button.modulate.a = 0.0
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		menu_group.add_child(button)
		button.pressed.connect(_on_menu_pressed.bind(caption))
		button.focus_entered.connect(_focus_baked_entry.bind(button))
		button.mouse_entered.connect(_focus_baked_entry.bind(button))
		if caption == "CONTINUE":
			continue_button = button

	# Visible only after moving focus; the untouched image is the initial state.
	title_focus_marker = _label(title_group, "◆", Rect2(143, 209, 16, 19), 11, MENU_SELECTED)
	title_focus_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_focus_marker.visible = false

func _focus_baked_entry(button: Button) -> void:
	if screen != Screen.MENU or title_focus_marker == null:
		return
	title_focus_marker.position.y = button.position.y + 1.0
	title_focus_marker.visible = true

func _build_panel_group() -> void:
	panel_group = Control.new()
	panel_group.name = "Subscreen"
	panel_group.size = Vector2(480, 360)
	panel_group.visible = false
	ui.add_child(panel_group)

func _show_menu() -> void:
	screen = Screen.MENU
	panel_group.visible = false
	title_group.visible = true
	menu_group.visible = true
	title_background.visible = true
	submenu_background.visible = false
	_refresh_continue()
	_focus_first(menu_group)
	title_focus_marker.visible = false

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
	_subtitle("CHOOSE SAVE SLOT" if new_game else "LOAD GAME")
	for i in range(1, SLOT_COUNT + 1):
		var occupied := _slot_exists(i)
		var caption := "SLOT %d  -  PROLOGUE" % i if occupied else "SLOT %d  -  EMPTY" % i
		var button := _submenu_button(caption, 184 + (i - 1) * 27)
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
	_subtitle("PROLOGUE  /  SLOT %d" % slot)
	# Scene content has not been authored yet. Keep this honest and unboxed.
	_subtitle("STORY IN DEVELOPMENT", 198, 10, MENU_TEXT)
	_submenu_button("RETURN TO TITLE", 268).pressed.connect(_show_menu)
	_focus_first(panel_group)

func _show_chapters() -> void:
	screen = Screen.SLOTS
	_clear_panel()
	_subtitle("CHAPTER SELECTION")
	_submenu_button("PROLOGUE", 204).pressed.connect(_open_prologue.bind(last_slot if last_slot > 0 else 1))
	_add_back_button()
	_focus_first(panel_group)

func _show_options() -> void:
	screen = Screen.OPTIONS
	_clear_panel()
	_subtitle("OPTIONS")
	_submenu_button("TOGGLE FULLSCREEN", 204).pressed.connect(_toggle_fullscreen)
	_add_back_button()
	_focus_first(panel_group)

func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func _add_back_button() -> void:
	_submenu_button("BACK", 286).pressed.connect(_show_menu)

func _clear_panel() -> void:
	for child in panel_group.get_children():
		panel_group.remove_child(child)
		child.queue_free()
	panel_group.visible = true
	title_group.visible = false
	menu_group.visible = false
	title_background.visible = false
	submenu_background.visible = true

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

func _subtitle(caption: String, y: float = 160.0, size: int = 13, fill: Color = MENU_SELECTED) -> void:
	var heading := _label(panel_group, caption, Rect2(141, y, 198, 25), size, fill)
	_style_section_heading(heading, fill)

func _submenu_button(caption: String, y: float) -> Button:
	var button := _menu_button(panel_group, caption, Rect2(145, y, 190, 20))
	button.focus_entered.connect(_highlight_menu_entry.bind(button))
	return button

func _style_section_heading(label: Label, fill: Color) -> void:
	label.add_theme_font_override("font", ui_font)
	label.add_theme_color_override("font_color", fill)
	label.add_theme_color_override("font_outline_color", MENU_OUTLINE)
	label.add_theme_constant_override("outline_size", MENU_OUTLINE_SIZE)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)

func _menu_button(parent: Control, caption: String, rect: Rect2) -> Button:
	var button := _button(parent, caption, rect, 11)
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_override("font", ui_font)
	button.add_theme_color_override("font_pressed_color", MENU_SELECTED)
	button.add_theme_color_override("font_hover_color", MENU_SELECTED)
	button.add_theme_color_override("font_focus_color", MENU_SELECTED)
	button.add_theme_color_override("font_color", MENU_TEXT)
	button.add_theme_color_override("font_disabled_color", MENU_DISABLED)
	button.add_theme_color_override("font_outline_color", MENU_OUTLINE)
	button.add_theme_constant_override("outline_size", MENU_OUTLINE_SIZE)
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button.add_theme_constant_override("shadow_offset_x", 0)
	button.add_theme_constant_override("shadow_offset_y", 0)
	# Both mouse and keyboard focus stay fully unboxed.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	return button

func _highlight_menu_entry(button: Button) -> void:
	# Update the focused option in either menu without boxes.
	for child in button.get_parent().get_children():
		if child is Button and not child.disabled:
			child.add_theme_color_override("font_color", MENU_SELECTED if child == button else MENU_TEXT)



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
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.flat = true
	button.add_theme_font_size_override("font_size", font_size)
	parent.add_child(button)
	return button

func _focus_first(parent: Control) -> void:
	for child in parent.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and screen != Screen.MENU:
			_show_menu()
			get_viewport().set_input_as_handled()
