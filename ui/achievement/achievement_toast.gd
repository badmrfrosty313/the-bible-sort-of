extends PanelContainer
class_name AchievementToast

@onready var label: Label = %Label
var _timer: SceneTreeTimer

func show_event(event_name: String) -> void:
	label.text = "ACHIEVEMENT UNLOCKED\n" + event_name
	show()
	_timer = get_tree().create_timer(3.2)
	_timer.timeout.connect(hide)
