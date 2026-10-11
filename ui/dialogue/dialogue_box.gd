extends PanelContainer
class_name DialogueBox
## A reusable, player-paced sequence. Cutscenes can await `finished`.

signal finished

var _lines: Array[DialogueLine] = []
var _index: int = 0
var active: bool = false

@onready var speaker_label: Label = %Speaker
@onready var text_label: Label = %Line
@onready var next_button: Button = %Next

func _ready() -> void:
	next_button.pressed.connect(advance)
	hide()

func start(lines: Array[DialogueLine]) -> void:
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
