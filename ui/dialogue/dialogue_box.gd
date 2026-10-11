extends PanelContainer
class_name DialogueBox
## A reusable, player-paced sequence. Cutscenes can await `finished`.

signal finished
signal choice_selected(id: StringName)
signal canceled
signal line_changed(speaker: String, text: String)

var _lines: Array[DialogueLine] = []
var _index: int = 0
var active: bool = false
var cancelable := false

@onready var speaker_label: Label = %Speaker
@onready var text_label: Label = %Line
@onready var next_button: Button = %Next
@onready var choices: VBoxContainer = %Choices

func _ready() -> void:
	next_button.pressed.connect(advance)
	hide()

func start(lines: Array[DialogueLine]) -> void:
	_clear_choices()
	next_button.show()
	_lines = lines
	_index = 0
	active = not _lines.is_empty()
	if not active:
		finished.emit()
		return
	show()
	_show_line()
	next_button.grab_focus()

func advance() -> void:
	if not active:
		return
	_index += 1
	if _index >= _lines.size():
		active = false
		hide()
		finished.emit()
	else:
		_show_line()

func _show_line() -> void:
	speaker_label.text = _lines[_index].speaker
	text_label.text = _lines[_index].text
	next_button.text = "Finish" if _index == _lines.size() - 1 else "Next"
	line_changed.emit(speaker_label.text, text_label.text)

func _unhandled_input(event: InputEvent) -> void:
	if active and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if cancelable:
			close()
			canceled.emit()

func ask(speaker: String, text: String, options: Array[Dictionary]) -> void:
	_lines = []
	active = true
	speaker_label.text = speaker
	text_label.text = text
	next_button.hide()
	_clear_choices()
	for option in options:
		var button := Button.new()
		button.text = str(option.get("label", "Continue"))
		button.custom_minimum_size = Vector2(0, 22)
		button.pressed.connect(_select_choice.bind(StringName(option.get("id", "continue"))))
		choices.add_child(button)
	show()
	if choices.get_child_count() > 0:
		choices.get_child(0).grab_focus()

func close() -> void:
	active = false
	_clear_choices()
	hide()

func _select_choice(id: StringName) -> void:
	close()
	choice_selected.emit(id)

func _clear_choices() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
