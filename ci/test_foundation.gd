extends SceneTree
## Integration checks drive the real shell, UI input, dialogue and disk save.
## Run via tools/check.sh, which isolates user data from real player saves.

var checks: int = 0
var failures: int = 0
var capture: bool = false
var boot: Node
var state: Node

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	state = root.get_node("GameState")
	if capture:
		root.size = Vector2i(480, 270)
		root.position = Vector2i(0, 0)
	boot = load("res://app/boot.tscn").instantiate()
	root.add_child(boot)
	await _settle()
	if "--quit" in OS.get_cmdline_user_args():
		await _key(KEY_UP)
		_check(root.gui_get_focus_owner() == _screen().get_node("%Quit"), "Quit is focused")
		print("Testing actual Quit action")
		await _key(KEY_ENTER)
		_check(false, "Quit must end the process")
		_finish()
		return
	if "--resume" in OS.get_cmdline_user_args():
		await _check_fresh_process_resume()
		_finish()
		return
	_check(not state.has_progress(), "Fresh user data has no progress")
	_check(_screen().name == &"TitleScreen", "Boot mounts the title")
	_check(_screen().get_node("%Continue").disabled, "Continue is disabled without a save")
	_check(root.gui_get_focus_owner() == _screen().get_node("%NewGame"), "New Game has keyboard focus")
	_check_layout(_screen())
	await _snapshot("01_title_native.png")
	await _key(KEY_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Quit"), "Keyboard navigation skips disabled Continue")
	await _key(KEY_UP)
	await _key(KEY_ENTER)
	_check(_screen().name == &"DevelopmentEpisode", "Keyboard New Game loads the catalog episode")
	_check(state.checkpoint == 0 and FileAccess.file_exists(state.SAVE_PATH), "New Game creates a save")
	_check_layout(_screen())
	await _snapshot("02_episode_native.png")
	await _key(KEY_ENTER)
	_check(_screen().get_node("%Dialogue").active, "Read exchange opens shared dialogue")
	_check_layout(_screen())
	await _snapshot("03_dialogue_native.png")
	await _key(KEY_ESCAPE)
	_check(_screen().name == &"DevelopmentEpisode", "Cancel cannot interrupt an active exchange")
	for index in range(3):
		await _key(KEY_ENTER)
	_check(not _screen().get_node("%Dialogue").active, "All three dialogue lines execute and finish")
	_check(state.checkpoint == 1, "Dialogue completion saves checkpoint 1")
	await _key(KEY_ESCAPE)
	_check(_screen().name == &"TitleScreen", "Cancel returns to title")
	_check(not _screen().get_node("%Continue").disabled, "Title enables Continue after saving")
	await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Continue"), "Controller D-pad selects Continue")
	await _joy(JOY_BUTTON_A)
	_check(_screen().name == &"DevelopmentEpisode" and state.checkpoint == 1,
		"Controller accept resumes the saved episode and checkpoint")
	_check(_screen().get_node("%Read").text == "Read again", "Restored progress changes episode behavior")
	await _snapshot("04_continued_native.png")
	if capture:
		root.size = Vector2i(1440, 810)
		await _settle()
		_check_layout(_screen())
		await _snapshot("05_continued_3x.png")
		root.size = Vector2i(480, 270)
	await _key(KEY_ESCAPE)
	await _key(KEY_ENTER)
	var confirmation: ConfirmationDialog = _screen().get_node("ReplaceSave")
	_check(confirmation.visible, "New Game requires confirmation before replacing progress")
	await _snapshot("06_replace_save_native.png")
	await _key(KEY_ESCAPE)
	_check(not confirmation.visible, "Keyboard cancel dismisses save replacement")
	_check(state.checkpoint == 1, "Cancel retains previous progress")
	await _key(KEY_ENTER)
	await _key(KEY_ENTER)
	_check(_screen().name == &"DevelopmentEpisode" and state.checkpoint == 0,
		"Confirmed New Game resets progress")
	await _key(KEY_ESCAPE)
	await _test_invalid_saves()
	_check(state.new_game() == OK, "A fresh save can replace invalid data")
	_check(state.set_checkpoint(1) == OK, "A valid checkpoint can be saved for process restart")
	state.flags["fixture_complete"] = true
	_check(state.save_progress() == OK, "Progress flags persist")
	_check(state.set_checkpoint(2) == ERR_INVALID_PARAMETER and state.checkpoint == 1,
		"Invalid checkpoint cannot replace progress")
	var saved_contents := FileAccess.get_file_as_string(state.SAVE_PATH)
	var blocked_temporary_path: String = state.SAVE_PATH + ".tmp"
	DirAccess.make_dir_absolute(blocked_temporary_path)
	_check(state.new_game() != OK and state.checkpoint == 1 and state.flags.get("fixture_complete") == true,
		"Failed save restores the previous in-memory progress")
	_check(FileAccess.get_file_as_string(state.SAVE_PATH) == saved_contents,
		"Failed save preserves the previous file")
	DirAccess.remove_absolute(blocked_temporary_path)
	_check(state.save_progress() == OK, "Saving recovers when the write blocker is removed")
	_finish()

func _check_fresh_process_resume() -> void:
	_check(state.has_progress() and state.checkpoint == 1, "New process reads the on-disk checkpoint")
	_check(state.flags.get("fixture_complete") == true, "New process reads saved flags")
	await _key(KEY_DOWN)
	await _key(KEY_ENTER)
	_check(_screen().name == &"DevelopmentEpisode", "Continue works after a process restart")
	_check(_screen().get_node("%Read").text == "Read again", "Episode restores checkpoint after restart")
	await _key(KEY_ESCAPE)
	await _key(KEY_UP)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Quit"), "Quit is reachable by keyboard")
	# Exercise the actual Quit signal without ending the test before its report.
	var quit_button: Button = _screen().get_node("%Quit")
	_check(quit_button.pressed.get_connections().size() == 1, "Quit is wired to the shell")

func _test_invalid_saves() -> void:
	var invalid: Array[String] = [
		"{broken", "[]",
		JSON.stringify({"version": 99, "episode_id": "development", "checkpoint": 0, "flags": {}}),
		JSON.stringify({"version": 1, "episode_id": "missing", "checkpoint": 0, "flags": {}}),
		JSON.stringify({"version": 1, "episode_id": "development", "checkpoint": 0.5, "flags": {}}),
		JSON.stringify({"version": 1, "episode_id": "development", "checkpoint": 2, "flags": {}}),
		JSON.stringify({"version": 1, "episode_id": "development", "checkpoint": 0, "flags": []}),
	]
	for contents in invalid:
		var file := FileAccess.open(state.SAVE_PATH, FileAccess.WRITE)
		file.store_string(contents)
		file.close()
		_check(state.load_progress() == ERR_FILE_CORRUPT and not state.has_progress(),
			"Invalid save is rejected without activating progress")
	boot.show_title()
	await _settle()
	_check(_screen().get_node("%Continue").disabled, "Corrupt save disables Continue")
	_check(not _screen().get_node("%Status").text.is_empty(), "Corrupt save shows recovery guidance")
	_check_layout(_screen())

func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	Input.parse_input_event(event)
	await _settle()

func _joy(button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventJoypadButton.new()
	event.button_index = button
	Input.parse_input_event(event)
	await _settle()

func _settle() -> void:
	for frame in range(4):
		await process_frame

func _screen() -> Node:
	return boot.get_node("ScreenHost").get_child(0)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", message)
	else:
		print("PASS: ", message)

func _check_layout(node: Node) -> void:
	if node is Control and node.is_visible_in_tree() and (node is Button or node is Label):
		var rect: Rect2 = node.get_global_rect()
		var viewport_rect := Rect2(Vector2.ZERO, root.get_visible_rect().size)
		_check(viewport_rect.encloses(rect), "Visible UI fits viewport: " + str(node.name))
		_check(rect.size.y >= node.get_combined_minimum_size().y,
			"UI has enough height: " + str(node.name))
	for child in node.get_children():
		_check_layout(child)

func _snapshot(file_name: String) -> void:
	if not capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "Rendered capture is nonempty: " + file_name)
	DirAccess.make_dir_recursive_absolute("res://ci_artifacts")
	_check(image.save_png("res://ci_artifacts/" + file_name) == OK, "Capture saved: " + file_name)

func _finish() -> void:
	print("Foundation checks: %d passed, %d failed, %d total" % [checks - failures, failures, checks])
	quit(0 if failures == 0 else 1)
