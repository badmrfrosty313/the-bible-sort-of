extends Node
## Owns screen changes. Episode content requests transitions through signals.

const TITLE := preload("res://ui/title/title_screen.tscn")

var _transition_pending: bool = false

@onready var screen_host: Node = $ScreenHost

func _ready() -> void:
	show_title()

func show_title() -> void:
	if _transition_pending:
		return
	var title := TITLE.instantiate()
	title.new_game_requested.connect(_on_new_game)
	title.continue_requested.connect(_on_continue)
	title.quit_requested.connect(func() -> void: get_tree().quit())
	_replace_screen(title)

func _on_new_game() -> void:
	if _transition_pending:
		return
	var episode := _prepare_episode(EpisodeCatalog.FIRST_EPISODE)
	if episode == null:
		return
	if GameState.new_game() != OK:
		episode.free()
		_show_error(GameState.last_error)
		return
	_replace_screen(episode)

func _on_continue() -> void:
	if _transition_pending:
		return
	if GameState.load_progress() != OK:
		_show_error(GameState.last_error)
		return
	var episode := _prepare_episode(GameState.episode_id)
	if episode != null:
		_replace_screen(episode)

func _prepare_episode(id: StringName) -> Node:
	var definition := EpisodeCatalog.find_episode(id)
	if definition == null or not ResourceLoader.exists(definition.scene_path):
		_show_error("This episode is unavailable.")
		return null
	var packed := load(definition.scene_path) as PackedScene
	if packed == null:
		_show_error("This episode could not be loaded.")
		return null
	var episode := packed.instantiate()
	if not episode.has_signal("return_to_title_requested"):
		episode.free()
		_show_error("This episode is missing its return-to-title signal.")
		return null
	episode.connect("return_to_title_requested", show_title)
	return episode

func _replace_screen(screen: Node) -> void:
	# Deferred swaps are safe even when requested from a UI input callback.
	_transition_pending = true
	call_deferred("_mount_screen", screen)

func _mount_screen(screen: Node) -> void:
	for old in screen_host.get_children():
		screen_host.remove_child(old)
		old.queue_free()
	screen_host.add_child(screen)
	_transition_pending = false

func _show_error(message: String) -> void:
	var title := screen_host.get_child(0)
	if title.has_method("show_error"):
		title.show_error(message)
