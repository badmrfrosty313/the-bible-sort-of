extends Node

const BURNING_BUSH_SCENE := preload("res://scenes/episodes/burning_bush/burning_bush.tscn")

func _ready() -> void:
	# Parent Theater builds itself in _ready(), so wait until its generated nodes exist.
	await get_tree().process_frame
	await get_tree().process_frame
	_run_vertical_slice()

func _run_vertical_slice() -> void:
	var theater := get_parent()

	# Let Father's existing entrance finish before the episode starts.
	await get_tree().create_timer(5.0).timeout

	var stage_content := theater.get_node_or_null("Stage/StageContent")
	var father := theater.get_node_or_null("Father")
	var right_exit := theater.get_node_or_null("RightEntrance")
	var seat := theater.get_node_or_null("FatherSeat")

	if stage_content == null:
		push_error("Vertical slice could not find Stage/StageContent.")
		return

	# Father leaves the theater to handle the burning-bush business personally.
	if father != null and right_exit != null:
		await father.leave_to_right(right_exit.global_position)

	await _fade_stage(stage_content, true)

	var episode := BURNING_BUSH_SCENE.instantiate()
	stage_content.add_child(episode)

	await episode.episode_finished
	await _fade_stage(stage_content, false)

	episode.queue_free()
	await get_tree().process_frame

	# Father comes back from the biblical scene and returns to his console.
	if father != null and right_exit != null and seat != null:
		await father.enter_from_right(right_exit.global_position, seat.global_position)
		father.sit()

	await _show_epilogue(stage_content)

func _fade_stage(stage_content: Node2D, fade_in: bool) -> void:
	var overlay := Polygon2D.new()
	overlay.name = "TransitionOverlay"
	overlay.color = Color(0, 0, 0, 0 if fade_in else 1)
	overlay.polygon = PackedVector2Array([
		Vector2(52, 48), Vector2(428, 48), Vector2(428, 208), Vector2(52, 208)
	])
	stage_content.add_child(overlay)

	var tween := create_tween()
	var target_alpha := 1.0 if fade_in else 0.0
	tween.tween_property(overlay, "color:a", target_alpha, 0.45)
	await tween.finished

	if fade_in:
		# Blackout reached. Remove it so the new episode can appear.
		overlay.queue_free()
	else:
		overlay.queue_free()

func _show_epilogue(stage_content: Node2D) -> void:
	var label := Label.new()
	label.text = "FATHER: I am going to smell like smoke all day."
	label.position = Vector2(95, 120)
	label.size = Vector2(290, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	stage_content.add_child(label)
	await get_tree().create_timer(2.5).timeout
	label.queue_free()
