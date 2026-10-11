extends Control

const TITLE_ART_PATH := "res://art/title/gods_beach_day_adams_tumble.png"
const BAKED_SELECTOR := Rect2i(925, 418, 35, 37)
const TITLE_RENDER_SIZE := Vector2i(1440, 810)
const TITLE_SOURCE_SIZE := Vector2(1672, 941)
const SETTINGS_PATH := "user://settings.json"
const MENU_ENTRIES := ["NEW GAME", "CONTINUE", "LOAD", "CHAPTER SELECTION", "OPTIONS"]
const MENU_NODE_NAMES := ["NewGame", "Continue", "Load", "ChapterSelection", "Options"]
const SOURCE_MENU_RECTS := [
	Rect2(955, 414, 180, 45), Rect2(963, 457, 165, 42), Rect2(963, 498, 90, 42),
	Rect2(963, 538, 290, 42), Rect2(963, 579, 135, 42)
]
const SOURCE_SELECTOR_X := 925.0

signal new_game_requested
signal continue_requested
signal quit_requested

var menu_buttons: Array[Button] = []
var panel: Control
var panel_title: Label
var panel_body: Label
var panel_list: VBoxContainer
var pending_new_game := false
var main_focus_index := 0
var fallback_active := false
var settings := {"fullscreen": false, "master_volume": 1.0}

@onready var approved_art: TextureRect = $ApprovedArt
@onready var fallback_menu: Control = $FallbackMenu
@onready var focus_marker: Control = $FocusMarker
@onready var status: Label = %Status
@onready var replace_save: ConfirmationDialog = $ReplaceSave
@onready var quit_dialog: ConfirmationDialog = $QuitDialog
@onready var quit_button: Button = $Quit

func _ready() -> void:
	_load_settings()
	_apply_settings()
	_build_menu()
	_load_approved_art()
	replace_save.confirmed.connect(_confirm_new_game)
	replace_save.canceled.connect(_restore_focus)
	quit_dialog.confirmed.connect(func() -> void: quit_requested.emit())
	quit_dialog.canceled.connect(_restore_focus)
	quit_button.pressed.connect(_on_quit_pressed)
	new_game_requested.connect(_restore_focus)
	_refresh_save()
	menu_buttons[0].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if panel != null:
			_show_main_menu()
		else:
			quit_dialog.popup_centered()
		get_viewport().set_input_as_handled()

func _load_approved_art(path := TITLE_ART_PATH) -> void:
	menu_buttons.erase(quit_button)
	approved_art.texture = null
	var source := RuntimeTexture.load_texture(path, Vector2i(TITLE_SOURCE_SIZE))
	if source != null:
		var image := source.get_image()
		if image != null and not image.is_empty():
			image.convert(Image.FORMAT_RGBA8)
			var marker := Image.create(35, 37, false, Image.FORMAT_RGBA8)
			marker.fill(Color.TRANSPARENT)
			for y in range(418, 455):
				var left := image.get_pixel(924, y)
				var right := image.get_pixel(960, y)
				for x in range(925, 960):
					var background := left.lerp(right, float(x - 924) / 36.0)
					var original := image.get_pixel(x, y)
					if Vector3(original.r, original.g, original.b).distance_to(Vector3(background.r, background.g, background.b)) > 0.15:
						marker.set_pixel(x - 925, y - 418, original)
					image.set_pixel(x, y, background)
			focus_marker.texture = ImageTexture.create_from_image(marker)
			focus_marker.size = Vector2(BAKED_SELECTOR.size) * (Vector2(TITLE_RENDER_SIZE) / TITLE_SOURCE_SIZE)
			image.resize(TITLE_RENDER_SIZE.x, TITLE_RENDER_SIZE.y, Image.INTERPOLATE_LANCZOS)
			approved_art.texture = ImageTexture.create_from_image(image)
	fallback_active = approved_art.texture == null
	quit_button.visible = fallback_active
	quit_button.focus_mode = Control.FOCUS_ALL if fallback_active else Control.FOCUS_NONE
	quit_button.modulate.a = 1.0
	if fallback_active:
		fallback_menu.show()
		focus_marker.hide()
		for index in menu_buttons.size():
			menu_buttons[index].text = MENU_ENTRIES[index]
			menu_buttons[index].modulate.a = 1.0
			menu_buttons[index].add_theme_font_size_override("font_size", 24)
		menu_buttons.append(quit_button)
		status.text = "Title artwork unavailable"
		status.show()
	else:
		fallback_menu.hide()
		status.hide()
		focus_marker.show()
		for button in menu_buttons:
			button.text = ""
			button.modulate.a = 0.0
	_refresh_save()

func _build_menu() -> void:
	for index in MENU_ENTRIES.size():
		var button := get_node(MENU_NODE_NAMES[index]) as Button
		button.set_meta("entry", MENU_ENTRIES[index])
		var rect := _source_rect_to_title(SOURCE_MENU_RECTS[index])
		button.position = rect.position
		button.size = rect.size
		button.flat = true
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.modulate.a = 0.0
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		button.focus_entered.connect(_move_marker.bind(button))
		button.mouse_entered.connect(func() -> void:
			if not button.disabled: button.grab_focus())
		button.pressed.connect(_menu_pressed.bind(MENU_ENTRIES[index]))
		menu_buttons.append(button)
	_refresh_neighbors()

func _refresh_neighbors() -> void:
	for index in menu_buttons.size():
		var button := menu_buttons[index]
		var next := _next_enabled(index, 1)
		var previous := _next_enabled(index, -1)
		button.focus_neighbor_bottom = button.get_path_to(menu_buttons[next])
		button.focus_neighbor_top = button.get_path_to(menu_buttons[previous])

func _next_enabled(index: int, direction: int) -> int:
	var candidate := index
	for _step in menu_buttons.size():
		candidate = posmod(candidate + direction, menu_buttons.size())
		if not menu_buttons[candidate].disabled:
			return candidate
	return index

func _move_marker(button: Button) -> void:
	var index := menu_buttons.find(button)
	main_focus_index = index
	if fallback_active: return
	var row: Rect2 = SOURCE_MENU_RECTS[index]
	focus_marker.position = _source_to_title(Vector2(SOURCE_SELECTOR_X, row.get_center().y - 18.5))
	focus_marker.show()

func _source_to_title(point: Vector2) -> Vector2:
	return point * (Vector2(TITLE_RENDER_SIZE) / TITLE_SOURCE_SIZE)

func _source_rect_to_title(rect: Rect2) -> Rect2:
	var scale := Vector2(TITLE_RENDER_SIZE) / TITLE_SOURCE_SIZE
	return Rect2(rect.position * scale, rect.size * scale)

func _refresh_save() -> void:
	menu_buttons[1].disabled = not GameState.has_progress()
	_refresh_neighbors()

func _menu_pressed(entry: String) -> void:
	switch_entry(entry)

func switch_entry(entry: String) -> void:
	match entry:
		"NEW GAME": _request_new_game()
		"CONTINUE": continue_requested.emit()
		"LOAD": _show_load()
		"CHAPTER SELECTION": _show_chapters()
		"OPTIONS": _show_options()

func _request_new_game() -> void:
	pending_new_game = true
	if GameState.has_progress() or FileAccess.file_exists(GameState.SAVE_PATH):
		replace_save.dialog_text = "Start Adam & Eve from the beginning? Current progress will be replaced."
		replace_save.popup_centered()
	else:
		_confirm_new_game()

func _confirm_new_game() -> void:
	pending_new_game = false
	new_game_requested.emit()

func _restore_focus() -> void:
	if menu_buttons.size() > 0:
		menu_buttons[main_focus_index].grab_focus()

func _on_quit_pressed() -> void:
	quit_dialog.popup_centered()

func _show_main_menu() -> void:
	if panel != null:
		panel.queue_free()
		panel = null
	for button in menu_buttons:
		button.show()
	if not fallback_active: focus_marker.show()
	_restore_focus()

func _make_panel(title: String) -> void:
	_show_main_menu()
	panel = Control.new()
	panel.name = "Submenu"
	panel.position = Vector2(360, 160)
	panel.size = Vector2(720, 540)
	add_child(panel)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.06, 0.035, 0.03, 0.94)
	backdrop.size = panel.size
	panel.add_child(backdrop)
	panel_title = Label.new()
	panel_title.position = Vector2(35, 25)
	panel_title.size = Vector2(650, 55)
	panel_title.add_theme_font_size_override("font_size", 32)
	panel_title.text = title
	panel.add_child(panel_title)
	panel_body = Label.new()
	panel_body.position = Vector2(35, 100)
	panel_body.size = Vector2(650, 230)
	panel_body.add_theme_font_size_override("font_size", 22)
	panel_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(panel_body)
	panel_list = VBoxContainer.new()
	panel_list.position = Vector2(35, 240)
	panel_list.size = Vector2(650, 170)
	panel_list.add_theme_constant_override("separation", 8)
	panel.add_child(panel_list)
	for button in menu_buttons:
		button.hide()
	focus_marker.hide()

func _panel_button(text: String, action: Callable, disabled := false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.disabled = disabled
	if action.is_valid():
		button.pressed.connect(action)
	panel_list.add_child(button)
	button.add_theme_font_size_override("font_size", 22)
	if not disabled and panel_list.get_child_count() == 1: button.grab_focus()
	return button

func _back_button() -> void:
	_panel_button("BACK", _show_main_menu)
	var enabled: Array[Control] = []
	for child in panel_list.get_children():
		if child is Button and child.disabled: continue
		if child.focus_mode != Control.FOCUS_NONE: enabled.append(child)
	for index in enabled.size():
		enabled[index].focus_neighbor_bottom = enabled[index].get_path_to(enabled[(index + 1) % enabled.size()])
		enabled[index].focus_neighbor_top = enabled[index].get_path_to(enabled[posmod(index - 1, enabled.size())])

func _show_load() -> void:
	_make_panel("LOAD")
	if GameState.has_progress():
		panel_body.text = "ADAM & EVE\n" + GameState.progress_summary()
		_panel_button("LOAD SAVE", func() -> void: continue_requested.emit())
	else:
		panel_body.text = "No save data" if GameState.last_error.is_empty() else GameState.last_error
	_back_button()

func _show_chapters() -> void:
	_make_panel("CHAPTER SELECTION")
	panel_body.text = "Choose an available chapter. Unfinished chapters remain locked."
	_panel_button("ADAM & EVE   AVAILABLE", _request_new_game)
	_panel_button("NOAH   LOCKED", Callable(), true)
	_panel_button("TOWER OF BABEL   LOCKED", Callable(), true)
	_panel_button("JONAH   LOCKED", Callable(), true)
	_back_button()

func _show_options() -> void:
	_make_panel("OPTIONS")
	panel_body.text = "Settings are saved automatically."
	var fullscreen := _panel_button("FULLSCREEN: " + ("ON" if settings.fullscreen else "OFF"), func() -> void:
		settings.fullscreen = not settings.fullscreen
		_apply_settings()
		_save_settings()
		_show_options())
	var volume := HSlider.new()
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.1
	volume.value = settings.master_volume
	volume.custom_minimum_size = Vector2(0, 42)
	volume.tooltip_text = "MASTER VOLUME"
	volume.value_changed.connect(func(value: float) -> void:
		settings.master_volume = value
		_apply_settings()
		_save_settings())
	panel_list.add_child(volume)
	var volume_label := Label.new()
	volume_label.text = "MASTER VOLUME"
	volume_label.add_theme_font_size_override("font_size", 18)
	panel_list.add_child(volume_label)
	_back_button()

func _apply_settings() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(settings.master_volume, 0.001)))
	AudioServer.set_bus_mute(0, settings.master_volume == 0.0)

func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file != null:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			if parsed.get("fullscreen") is bool: settings.fullscreen = parsed.fullscreen
			var volume: Variant = parsed.get("master_volume", 1.0)
			if (volume is int or volume is float) and is_finite(float(volume)):
				settings.master_volume = clampf(float(volume), 0.0, 1.0)

func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(settings))

func show_error(message: String) -> void:
	status.text = message
	status.show()
	_restore_focus()
