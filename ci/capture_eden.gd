extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var output_dir := ProjectSettings.globalize_path("res://ci_artifacts")
	var error := DirAccess.make_dir_recursive_absolute(output_dir)
	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("Cannot create capture directory: %s" % error)
		quit(1)
		return

	var packed := load("res://scenes/episodes/eden/eden.tscn") as PackedScene
	if packed == null:
		push_error("Eden scene missing.")
		quit(1)
		return

	var scene := packed.instantiate()
	root.add_child(scene)
	await create_timer(0.4).timeout
	await _capture("08_eden_free_roam.png")

	scene.ci_open_rock_finale()
	await create_timer(0.1).timeout
	await _capture("09_eden_rock.png")
	scene._close_dialogue()

	scene.ci_complete_naming()
	await create_timer(0.1).timeout
	await _capture("10_eden_first_jeff.png")

	if not scene.naming_complete:
		push_error("Naming quest did not complete.")
		quit(1)
		return
	if str(scene.named_animals.get("eagle", "")) != "JEFF":
		push_error("Eagle was not named Jeff. This is unacceptable.")
		quit(1)
		return
	print("Eden vertical slice check passed: free roam, rock gag, First Jeff.")
	quit()

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
