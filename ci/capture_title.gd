extends SceneTree

# Verify every title-menu destination on the STATIC beach illustration.
func _initialize() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var output_dir := ProjectSettings.globalize_path("res://ci_artifacts")
	var error := DirAccess.make_dir_recursive_absolute(output_dir)
	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("Cannot create capture directory: %s" % error)
		quit(1)
		return

	var packed := load("res://scenes/title/title_screen.tscn") as PackedScene
	if packed == null:
		push_error("Title scene missing.")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	await create_timer(0.5).timeout
	if not scene.menu_group.visible or scene.panel_group.visible:
		push_error("Title must be visible immediately, with no animated intro.")
		quit(1)
		return
	await _capture("01_title_menu.png")

	if not _press(scene.menu_group, "NEW GAME"):
		quit(1)
		return
	await _capture("02_new_game_slots.png")
	if not _press(scene.panel_group, "SLOT 1  -  EMPTY") and not _press(scene.panel_group, "SLOT 1  -  PROLOGUE"):
		quit(1)
		return
	await _capture("03_prologue.png")

	if not _press(scene.panel_group, "RETURN TO TITLE"):
		quit(1)
		return
	if not _press(scene.menu_group, "CONTINUE"):
		quit(1)
		return
	if not _press(scene.panel_group, "RETURN TO TITLE"):
		quit(1)
		return
	if not _press(scene.menu_group, "LOAD"):
		quit(1)
		return
	await _capture("04_load_slots.png")
	if not _press(scene.panel_group, "SLOT 1  -  PROLOGUE"):
		quit(1)
		return
	if not _press(scene.panel_group, "RETURN TO TITLE"):
		quit(1)
		return

	if not _press(scene.menu_group, "CHAPTER SELECTION"):
		quit(1)
		return
	await _capture("05_chapter_select.png")
	if not _press(scene.panel_group, "PROLOGUE"):
		quit(1)
		return
	if not _press(scene.panel_group, "RETURN TO TITLE"):
		quit(1)
		return

	if not _press(scene.menu_group, "OPTIONS"):
		quit(1)
		return
	await _capture("06_options.png")
	if not _press(scene.panel_group, "BACK"):
		quit(1)
		return
	await _capture("07_return_to_title.png")
	print("UI navigation check passed: new game, continue, load, chapters, options, back.")
	quit()

func _press(parent: Control, caption: String) -> bool:
	for child in parent.get_children():
		if child is Button and child.text == caption and not child.disabled:
			child.pressed.emit()
			return true
	push_error("No enabled button: " + caption)
	return false

func _capture(file_name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Viewport screenshot failed.")
		quit(1)
		return
	var path := ProjectSettings.globalize_path("res://ci_artifacts/%s" % file_name)
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s: %s" % [file_name, error])
		quit(1)
