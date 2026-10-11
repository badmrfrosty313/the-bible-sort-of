extends Control
## A development fixture, not the opening story or a playable biblical episode.

signal return_to_title_requested

@export var introduction: Array[DialogueLine]

@onready var dialogue: DialogueBox = %Dialogue
@onready var read_button: Button = %Read
@onready var status: Label = %Status

func _ready() -> void:
	%Return.pressed.connect(_return_to_title)
	read_button.pressed.connect(_start_dialogue)
	dialogue.finished.connect(_on_dialogue_finished)
	_refresh_checkpoint()
	read_button.grab_focus()

func _start_dialogue() -> void:
	read_button.disabled = true
	%Return.disabled = true
	status.hide()
	$Margin/Column/Actions.hide()
	dialogue.start(introduction)

func _on_dialogue_finished() -> void:
	read_button.disabled = false
	%Return.disabled = false
	status.show()
	$Margin/Column/Actions.show()
	if GameState.set_checkpoint(1) != OK:
		status.text = GameState.last_error
	else:
		_refresh_checkpoint()
	read_button.grab_focus()

func _refresh_checkpoint() -> void:
	status.text = "Checkpoint saved. Continue resumes here." if GameState.checkpoint == 1 \
		else "New game started. Read the exchange to save a checkpoint."
	read_button.text = "Read again" if GameState.checkpoint == 1 else "Read exchange"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if dialogue.active:
			# Prevent switching scenes while a narrative sequence is in progress.
			return
		_return_to_title()

func _return_to_title() -> void:
	return_to_title_requested.emit()
