extends SceneTree

func _initialize() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var output_dir := ProjectSettings.globalize_path("res://ci_artifacts")
	var dir_error := DirAccess.make_dir_recursive_absolute(output_dir)
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		push_error("Could not create CI artifact directory: %s" % dir_error)
		quit(1)
		return

	var packed := load("res://archive/prototype/theater/theater.tscn") as PackedScene
	if packed == null:
		push_error("Could not load theater scene for visual capture.")
		quit(1)
		return

	var scene := packed.instantiate()
	root.add_child(scene)

	await create_timer(4.2).timeout
	await _capture("01_father_intro.png")
	await create_timer(3.4).timeout
	await _capture("02_burning_bush.png")
	await create_timer(10.0).timeout
	await _capture("03_objections.png")
	await create_timer(15.0).timeout
	await _capture("04_intervention.png")
	quit()

func _capture(file_name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Viewport capture failed for %s" % file_name)
		return
	var path := ProjectSettings.globalize_path("res://ci_artifacts/%s" % file_name)
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s: %s" % [file_name, error])
	else:
		print("Saved visual snapshot: %s" % path)
