extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var state := root.get_node("GameState")
	var bad_flags := {"version": 1, "episode_id": "eden", "checkpoint": 2, "flags": {"eden_named_animals": "bad"}}
	var cases := ["{", "[]", JSON.stringify(bad_flags), '{"version":99,"episode_id":"eden","checkpoint":0,"flags":{}}']
	for original in cases:
		var file := FileAccess.open(state.SAVE_PATH, FileAccess.WRITE)
		file.store_string(original)
		file.close()
		_check(state.load_progress() != OK and not state.has_progress(), "Malformed save disables Continue safely")
		_check(FileAccess.get_file_as_string(state.SAVE_PATH) == original, "Failed load preserves the existing save bytes")
		var boot: Node = load("res://app/boot.tscn").instantiate()
		root.add_child(boot)
		await _settle()
		var title: Control = boot.screen_host.get_child(0)
		_check(not title.menu_buttons[0].disabled and title.menu_buttons[1].disabled, "Malformed save leaves New Game usable")
		title.menu_buttons[0].pressed.emit()
		_check(title.replace_save.visible, "New Game confirms replacing incompatible progress")
		title.replace_save.confirmed.emit()
		await _settle()
		_check(boot.screen_host.get_child(0).name == &"Eden" and state.checkpoint == 0, "New Game recovers from an incompatible save")
		_check(FileAccess.get_file_as_string(state.SAVE_PATH + ".bak") == original, "Recovery keeps the previous save in progress.json.bak")
		boot.queue_free()
		await _settle()
	DirAccess.remove_absolute(state.SAVE_PATH)
	DirAccess.remove_absolute(state.SAVE_PATH + ".bak")
	state.load_progress()
	var boot: Node = load("res://app/boot.tscn").instantiate()
	root.add_child(boot)
	await _settle()
	var title: Control = boot.screen_host.get_child(0)
	title._load_approved_art("res://art/title/intentionally_missing_test.png")
	_check(title.fallback_active and title.quit_button.visible and title.menu_buttons.size() == 6, "Missing title art produces one complete fallback menu")
	for index in 5:
		_check(title.menu_buttons[index].modulate.a == 1.0 and title.menu_buttons[index].text == title.MENU_ENTRIES[index], "Fallback text is attached to the live button " + str(index))
	title._load_approved_art()
	_check(not title.fallback_active and not title.quit_button.visible and title.menu_buttons.size() == 5, "Recovering art restores the approved five invisible hitboxes")
	var actor := TopDownActor.new()
	actor.role = &"intentionally_missing_test"
	root.add_child(actor)
	_check(actor.fallback_active and actor.visible and not actor.display_name.is_empty(), "Missing actor art retains a visible covered placeholder and label")
	actor.queue_free()
	var settings := FileAccess.open(title.SETTINGS_PATH, FileAccess.WRITE)
	settings.store_string('{"fullscreen": {}, "master_volume": {}}')
	settings.close()
	title._load_settings()
	_check(title.settings.master_volume == 1.0, "Malformed settings retain safe defaults")
	DirAccess.remove_absolute(title.SETTINGS_PATH)
	print("Save/fallback checks: ", checks, "; failures: ", failures)
	quit(0 if failures == 0 else 1)

func _settle() -> void:
	for frame in 4: await process_frame

func _check(condition: bool, description: String) -> void:
	checks += 1
	if condition: print("PASS: ", description)
	else:
		failures += 1
		printerr("FAIL: ", description)
