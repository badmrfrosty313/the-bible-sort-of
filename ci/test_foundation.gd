extends SceneTree
## End-to-end checks for the real title and Adam-and-Eve vertical slice.

var checks := 0
var failures := 0
var capture := false
var boot: Node
var state: Node
var eden: Node

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	state = root.get_node("GameState")
	if capture:
		root.size = Vector2i(480, 270)
	boot = load("res://app/boot.tscn").instantiate()
	root.add_child(boot)
	await _settle()
	if "--quit" in OS.get_cmdline_user_args():
		await _joy(JOY_BUTTON_B)
		_check(_screen().get_node("QuitDialog").visible, "Controller B opens quit confirmation at the title")
		print("PASS: Confirming Quit now")
		await _key(KEY_ENTER)
		_check(false, "Quit should end the process")
		_finish()
		return
	if "--resume" in OS.get_cmdline_user_args():
		await _resume_check()
		_finish()
		return
	_check(_screen().name == &"TitleScreen", "Boot mounts approved title presentation")
	_check(root.content_scale_size == Vector2i(1440, 810), "Title switches to a high-resolution 16:9 logical viewport")
	_check(_screen().get_node("ApprovedArt").texture != null, "Approved title artwork is mounted")
	_check((_screen() as Control).size == Vector2(1440, 810), "Title renders directly in true 16:9 logical space")
	var title_scale := Vector2(1440.0 / 1672.0, 810.0 / 941.0)
	_check(_screen().get_node("%NewGame").position.is_equal_approx(Vector2(955, 414) * title_scale) and _screen().get_node("%Continue").position.is_equal_approx(Vector2(963, 457) * title_scale), "Live title hitboxes share the title-art coordinate transform")
	_check(_screen().get_node("FocusMarker").visible and _screen().get_node("FocusMarker").position.is_equal_approx(Vector2(925, 421.5) * title_scale), "One live selector starts beside New Game")
	_check(_screen().get_node("%Continue").disabled, "Continue disabled without save")
	await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Load"), "Disabled Continue is skipped by controller navigation")
	_check(_screen().get_node("FocusMarker").position.is_equal_approx(Vector2(925, 504) * title_scale), "Selector follows the focused Load row")
	await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%ChapterSelection"), "Chapter Selection is reachable")
	await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Options"), "Options is reachable")
	await _joy(JOY_BUTTON_DPAD_UP)
	_check(root.gui_get_focus_owner() == _screen().get_node("%ChapterSelection"), "Title navigation moves upward")
	_screen().get_node("%Options").emit_signal("mouse_entered")
	await _settle()
	_check(root.gui_get_focus_owner() == _screen().get_node("%Options"), "Mouse hover moves focus and selector")
	await _joy(JOY_BUTTON_DPAD_UP)
	await _joy(JOY_BUTTON_A)
	_check(_screen().get_node("Submenu").visible, "Chapter Selection opens a submenu")
	await _joy(JOY_BUTTON_B)
	_check(not _screen().has_node("Submenu"), "Back returns from Chapter Selection")
	await _joy(JOY_BUTTON_DPAD_DOWN)
	await _joy(JOY_BUTTON_DPAD_DOWN)
	await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Options"), "Options remains reachable after returning")
	await _joy(JOY_BUTTON_A)
	_check(_screen().has_node("Submenu"), "Options opens a settings submenu")
	await _joy(JOY_BUTTON_B)
	await _snapshot("01_approved_title.png")
	await _key(KEY_ENTER)
	eden = _screen()
	_check(eden.name == &"Eden", "New Game enters Adam and Eve episode")
	_check(root.content_scale_size == Vector2i(480, 270), "Entering Eden restores the 480x270 gameplay viewport")
	_check(state.episode_id == &"eden" and state.checkpoint == 0, "New Game uses Eden state")
	_check(eden.dialogue.active, "Adam introduction begins with dialogue")
	await _snapshot("02_adam_intro.png")
	for step in range(20): await _key(KEY_ENTER)
	_check(not eden.dialogue.active and state.checkpoint == 1, "Intro completes and saves Eden checkpoint")
	_check(eden.objective.text.begins_with("EDEN"), "Free roam objective is visible")
	var start: Vector2 = eden.player.global_position
	await _hold_key(KEY_D, 10)
	_check(eden.player.global_position.x > start.x, "Keyboard movement moves Adam")
	start = eden.player.global_position
	await _hold_stick(0, 1.0, 10)
	_check(eden.player.global_position.x > start.x, "Controller stick moves Adam")
	eden.player.global_position = Vector2(35, 120)
	await _hold_key(KEY_A, 30)
	_check(eden.player.global_position.x >= 28.0, "Collision boundary keeps Adam in Eden")
	eden.player.global_position = Vector2(202, 180)
	await _settle()
	_check(eden.current_interactable != null and eden.current_interactable.interaction_id == &"rock", "Interaction detection finds rock")
	await _key(KEY_E)
	_check(eden.dialogue.active, "Rock opens shared dialogue")
	await _snapshot("03_rock_conversation.png")
	eden.ci_complete_rock()
	_check(state.checkpoint == 2 and bool(state.get_flag(&"eden_rock_complete")), "Rock milestone saves")
	eden.ci_complete_naming()
	_check(state.checkpoint == 4 and bool(state.get_flag(&"eden_first_jeff")), "Naming quest reaches First Jeff")
	_check(eden.toast.visible, "First Jeff produces achievement notification")
	await _snapshot("04_first_jeff.png")
	eden.toast.hide()
	eden.ci_activate_eve()
	_check(eden.role == &"eve" and eden.follower != null, "Eve becomes player and Adam follows")
	var follower_start: Vector2 = eden.follower.global_position
	eden.player.global_position += Vector2(25, 0)
	await _settle()
	_check(eden.follower.global_position.distance_to(follower_start) > 0.1, "Follower responds to Eve movement")
	await _snapshot("05_eve_gameplay.png")
	eden.ci_unlock_serpent()
	_check(bool(state.get_flag(&"eden_serpent_unlocked")), "Eve naming unlocks serpent encounter")
	eden.ci_start_fall()
	_check(eden.fall_started and eden.role == &"adam" and state.checkpoint == 6,
		"Fall returns control to Adam and saves checkpoint")
	await _snapshot("06_fall_boxes.png")
	eden._use_leaves()
	_check(eden.adam_clothed and state.checkpoint == 7, "Leaves resolve player gag and save final milestone")
	await _snapshot("07_leaves_used.png")
	eden.return_to_title_requested.emit()
	await _settle()
	_check(_screen().name == &"TitleScreen" and not _screen().get_node("%Continue").disabled and root.content_scale_size == Vector2i(1440, 810), "Return to title restores title mode and enables Continue")
	await _joy(JOY_BUTTON_DPAD_DOWN)
	await _joy(JOY_BUTTON_DPAD_DOWN)
	await _joy(JOY_BUTTON_A)
	_check(_screen().get_node("Submenu").visible, "Load opens a save submenu")
	await _joy(JOY_BUTTON_B)
	await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(root.gui_get_focus_owner() == _screen().get_node("%Continue"), "Controller navigation selects Continue")
	await _joy(JOY_BUTTON_A)
	eden = _screen()
	_check(eden.name == &"Eden" and state.checkpoint == 7 and eden.adam_clothed, "Continue restores Eden's final milestone")
	_finish()

func _resume_check() -> void:
	_check(state.episode_id == &"eden" and state.checkpoint == 7, "New process reads Eden progress")
	await _key(KEY_DOWN)
	await _key(KEY_ENTER)
	eden = _screen()
	_check(eden.name == &"Eden" and eden.adam_clothed, "Continue restores Eden after process restart")

func _screen() -> Node:
	return boot.get_node("ScreenHost").get_child(0)

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

func _hold_key(code: Key, frames: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	for frame in range(frames): await physics_frame
	event = InputEventKey.new()
	event.keycode = code
	Input.parse_input_event(event)
	await _settle()

func _hold_stick(axis: int, amount: float, frames: int) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = amount
	Input.parse_input_event(event)
	for frame in range(frames): await physics_frame
	event = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = 0.0
	Input.parse_input_event(event)
	await _settle()

func _settle() -> void:
	for frame in range(4): await process_frame

func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition: print("PASS: ", message)
	else:
		failures += 1
		printerr("FAIL: ", message)

func _snapshot(file_name: String) -> void:
	if not capture: return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "Rendered capture: " + file_name)
	DirAccess.make_dir_recursive_absolute("res://ci_artifacts")
	_check(image.save_png("res://ci_artifacts/" + file_name) == OK, "Saved capture: " + file_name)

func _finish() -> void:
	print("Eden checks: %d passed, %d failed, %d total" % [checks - failures, failures, checks])
	quit(0 if failures == 0 else 1)
