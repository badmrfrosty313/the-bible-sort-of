extends Control

# The title is mounted only while Boot has the Window in this native 4:3 mode.
const FULL_RES_TITLE_PATH := "res://art/title/approved_title_original.png"
const TITLE_RENDER_SIZE := Vector2i(1200, 900)

signal new_game_requested
signal continue_requested
signal quit_requested

@onready var approved_art: TextureRect = $ApprovedArt
@onready var fallback_menu: Control = $FallbackMenu
@onready var new_game_button: Button = %NewGame
@onready var continue_button: Button = %Continue
@onready var status: Label = %Status
@onready var replace_save: ConfirmationDialog = $ReplaceSave
@onready var focus_marker: Label = $FocusMarker

func _ready() -> void:
	_load_approved_art()
	new_game_button.pressed.connect(_on_new_game_pressed)
	new_game_button.focus_entered.connect(_move_marker.bind(new_game_button))
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	continue_button.focus_entered.connect(_move_marker.bind(continue_button))
	%Quit.pressed.connect(func() -> void: quit_requested.emit())
	%Quit.focus_entered.connect(_move_marker.bind(%Quit))
	replace_save.confirmed.connect(func() -> void: new_game_requested.emit())
	replace_save.canceled.connect(func() -> void: new_game_button.grab_focus())
	_refresh_save()
	new_game_button.grab_focus()
	# The unmodified approved image is the first frame, just as it was before.
	focus_marker.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		quit_requested.emit()
		get_viewport().set_input_as_handled()

func _load_approved_art() -> void:
	var image_source: Texture2D = null
	if ResourceLoader.exists(FULL_RES_TITLE_PATH):
		image_source = load(FULL_RES_TITLE_PATH) as Texture2D
	if image_source != null:
		var image := image_source.get_image()
		if image != null and not image.is_empty():
			if image.get_size() != TITLE_RENDER_SIZE:
				image.resize(TITLE_RENDER_SIZE.x, TITLE_RENDER_SIZE.y, Image.INTERPOLATE_LANCZOS)
			approved_art.texture = ImageTexture.create_from_image(image)
	if approved_art.texture == null:
		fallback_menu.show()
		status.show()
	else:
		fallback_menu.hide()
		status.hide()

func _move_marker(button: Button) -> void:
	if button == %Quit:
		focus_marker.hide()
		return
	focus_marker.position.y = button.position.y + 2.5
	focus_marker.show()

func _refresh_save() -> void:
	continue_button.disabled = not GameState.has_progress()
	new_game_button.focus_neighbor_bottom = new_game_button.get_path_to(
		%Quit if continue_button.disabled else continue_button)
	continue_button.focus_neighbor_bottom = continue_button.get_path_to(%Quit)
	%Quit.focus_neighbor_top = %Quit.get_path_to(
		new_game_button if continue_button.disabled else continue_button)

func _on_new_game_pressed() -> void:
	if FileAccess.file_exists(GameState.SAVE_PATH):
		replace_save.popup_centered(Vector2i(640, 240))
	else:
		new_game_requested.emit()

func show_error(message: String) -> void:
	status.text = message
	status.show()
	new_game_button.grab_focus()
