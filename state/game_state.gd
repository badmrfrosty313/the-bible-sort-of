extends Node
## One local save slot. Only stable content IDs and JSON-compatible state are saved.

signal save_changed

const SAVE_PATH := "user://progress.json"
const SAVE_VERSION := 1
const MAX_SAVE_BYTES := 1024 * 1024

var episode_id: StringName = &""
var checkpoint: int = 0
var flags: Dictionary = {}
var last_error: String = ""

func _ready() -> void:
	load_progress()

func has_progress() -> bool:
	return not episode_id.is_empty()

func new_game() -> Error:
	var previous := [episode_id, checkpoint, flags.duplicate(true)]
	episode_id = EpisodeCatalog.FIRST_EPISODE
	checkpoint = 0
	flags = {}
	var error := save_progress()
	if error != OK:
		episode_id = previous[0]
		checkpoint = previous[1]
		flags = previous[2]
	return error

func set_checkpoint(value: int) -> Error:
	var definition := EpisodeCatalog.find_episode(episode_id)
	if definition == null or value < 0 or value > definition.last_checkpoint:
		last_error = "This checkpoint does not belong to the current episode."
		return ERR_INVALID_PARAMETER
	var previous := checkpoint
	checkpoint = value
	var error := save_progress()
	if error != OK:
		checkpoint = previous
	return error

func get_flag(id: StringName, fallback: Variant = null) -> Variant:
	return flags.get(String(id), fallback)

func commit_progress(value: int, changes: Dictionary = {}) -> Error:
	## Saves a coherent milestone: callers never need to save a checkpoint and
	## its episode flags separately.
	var definition := EpisodeCatalog.find_episode(episode_id)
	if definition == null or value < 0 or value > definition.last_checkpoint:
		last_error = "This checkpoint does not belong to the current episode."
		return ERR_INVALID_PARAMETER
	var previous_checkpoint := checkpoint
	var previous_flags := flags.duplicate(true)
	checkpoint = value
	for key in changes:
		flags[str(key)] = changes[key]
	var error := save_progress()
	if error != OK:
		checkpoint = previous_checkpoint
		flags = previous_flags
	return error

func save_progress() -> Error:
	last_error = ""
	if not has_progress():
		return ERR_UNCONFIGURED
	var temporary := SAVE_PATH + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Could not write progress. Check the user data folder permissions."
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({
		"version": SAVE_VERSION, "episode_id": String(episode_id),
		"checkpoint": checkpoint, "flags": flags,
	}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(temporary, SAVE_PATH)
	if error != OK:
		last_error = "Progress could not be saved. The previous save has been retained."
		return error
	save_changed.emit()
	return OK

func load_progress() -> Error:
	episode_id = &""
	checkpoint = 0
	flags = {}
	last_error = ""
	if not FileAccess.file_exists(SAVE_PATH):
		return ERR_FILE_NOT_FOUND
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		last_error = "Your save could not be read."
		return FileAccess.get_open_error()
	if file.get_length() > MAX_SAVE_BYTES:
		last_error = "Your save is too large to load."
		return ERR_FILE_CORRUPT
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		last_error = "Your save is incompatible or damaged. New Game can replace it."
		return ERR_FILE_CORRUPT
	var data: Variant = parser.data
	if not _valid_save(data):
		last_error = "Your save is incompatible or damaged. New Game can replace it."
		return ERR_FILE_CORRUPT
	episode_id = StringName(data["episode_id"])
	checkpoint = int(data["checkpoint"])
	flags = data["flags"].duplicate(true)
	save_changed.emit()
	return OK

func _valid_save(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if data.get("version") != SAVE_VERSION or not data.get("episode_id") is String:
		return false
	var definition := EpisodeCatalog.find_episode(StringName(data["episode_id"]))
	var saved_checkpoint: Variant = data.get("checkpoint")
	if definition == null or not (saved_checkpoint is float or saved_checkpoint is int):
		return false
	if not is_finite(float(saved_checkpoint)) or saved_checkpoint != int(saved_checkpoint):
		return false
	if saved_checkpoint < 0 or saved_checkpoint > definition.last_checkpoint:
		return false
	return data.get("flags") is Dictionary
