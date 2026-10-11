extends Control

signal new_game_requested
signal continue_requested
signal quit_requested

## Optional final title artwork. Keep its aspect ratio inside the existing slot.
@export var title_art: Texture2D

@onready var new_game_button: Button = %NewGame
@onready var continue_button: Button = %Continue
@onready var status: Label = %Status
@onready var replace_save: ConfirmationDialog = $ReplaceSave

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	%Quit.pressed.connect(func() -> void: quit_requested.emit())
	replace_save.confirmed.connect(func() -> void: new_game_requested.emit())
	replace_save.canceled.connect(func() -> void: new_game_button.grab_focus())
	if title_art != null:
		%TitleArt.texture = title_art
		%TitleArt.show()
		%TextTitle.hide()
	_refresh_save()
	new_game_button.grab_focus()

func _refresh_save() -> void:
	continue_button.disabled = not GameState.has_progress()
	status.text = GameState.last_error
	new_game_button.focus_neighbor_bottom = new_game_button.get_path_to(
		%Quit if continue_button.disabled else continue_button)
	%Quit.focus_neighbor_top = %Quit.get_path_to(
		new_game_button if continue_button.disabled else continue_button)

func _on_new_game_pressed() -> void:
	if FileAccess.file_exists(GameState.SAVE_PATH):
		replace_save.popup_centered(Vector2i(320, 120))
	else:
		new_game_requested.emit()

func show_error(message: String) -> void:
	_refresh_save()
	status.text = message
	new_game_button.grab_focus()
