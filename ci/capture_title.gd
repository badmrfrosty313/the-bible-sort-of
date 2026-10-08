extends SceneTree

func _initialize() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var output_dir := ProjectSettings.globalize_path("res://ci_artifacts")
	var error := DirAccess.make_dir_recursive_absolute(output_dir)
	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("Could not create CI artifact directory: %s" % error)
		quit(1)
		return

	var packed := load("res://scenes/title/title_screen.tscn") as PackedScene
	if packed == null:
		push_error("Could not load title screen.")
		quit(1)
		return

	var scene := packed.instantiate()
	root.add_child(scene)
	await create_timer(0.8).timeout
	await _capture("01_rest_on_the_beach.png")
	await create_timer(1.3).timeout
	await _capture("02_adam_falls.png")
	await create_timer(0.9).timeout
	await _capture("03_vines_catch_adam.png")
	await create_timer(1.3).timeout
	await _capture("04_gods_punchline.png")
	await create_timer(2.0).timeout
	await _capture("05_title_menu.png")
	scene._start_new_game(1)
	await create_timer(0.3).timeout
	await _capture("06_prologue.png")
	quit()

func _capture(file_name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Viewport capture failed for %s" % file_name)
		quit(1)
		return
	var path := ProjectSettings.globalize_path("res://ci_artifacts/%s" % file_name)
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s: %s" % [file_name, error])
		quit(1)
