extends Node2D

const SCREEN_SIZE := Vector2(1200, 900)
const GARDEN_RECT := Rect2(110, 80, 980, 740)
const INTERACT_DISTANCE := 92.0
const MOVE_SPEED := 245.0

var player_position := Vector2(600, 690)
var animals: Array = []
var named_animals := {}
var rock_topics_seen := 0
var rock_topics := ["THE SUN", "TREES", "THE GUY WITH THE MUG", "ADAM", "EXISTENCE"]
var naming_active := false
var naming_complete := false
var naming_index := 0
var naming_order := ["cow", "sheep", "rabbit", "turtle", "eagle"]

var dialogue_open := false
var current_target := {}

var prompt_label: Label
var quest_label: Label
var dialogue_panel: PanelContainer
var dialogue_title: Label
var dialogue_body: Label
var choices_box: VBoxContainer
var achievement_panel: PanelContainer
var achievement_label: Label

func _ready() -> void:
	animals = [
		{"id": "cow", "kind": "COW", "pos": Vector2(285, 285), "noise": "MOO."},
		{"id": "sheep", "kind": "SHEEP", "pos": Vector2(890, 280), "noise": "BAAA."},
		{"id": "rabbit", "kind": "RABBIT", "pos": Vector2(915, 625), "noise": "*sniff sniff*"},
		{"id": "turtle", "kind": "TURTLE", "pos": Vector2(300, 650), "noise": "..."},
		{"id": "eagle", "kind": "EAGLE", "pos": Vector2(680, 245), "noise": "SCREE!"}
	]
	_build_ui()
	_load_checkpoint()
	queue_redraw()

func _process(delta: float) -> void:
	if not dialogue_open:
		var direction := Vector2.ZERO
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			direction.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			direction.x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			direction.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			direction.y += 1.0
		if direction != Vector2.ZERO:
			player_position += direction.normalized() * MOVE_SPEED * delta
			player_position.x = clampf(player_position.x, GARDEN_RECT.position.x + 30.0, GARDEN_RECT.end.x - 30.0)
			player_position.y = clampf(player_position.y, GARDEN_RECT.position.y + 30.0, GARDEN_RECT.end.y - 30.0)
			queue_redraw()
		_update_interaction_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		if dialogue_open:
			_close_dialogue()
		else:
			get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
		get_viewport().set_input_as_handled()
		return
	if not dialogue_open and event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
		if not current_target.is_empty():
			_interact(current_target)
			get_viewport().set_input_as_handled()

func _draw() -> void:
	# Garden boundary and surrounding wilderness.
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#163c31"))
	draw_rect(GARDEN_RECT, Color("#79b85e"))
	draw_rect(Rect2(130, 100, 940, 700), Color("#8bc86a"), true)

	# Water and footpaths.
	draw_circle(Vector2(815, 475), 118, Color("#4ba5b5"))
	draw_circle(Vector2(815, 475), 101, Color("#70c7cb"))
	var path_color := Color("#d6bd79")
	draw_line(Vector2(600, 790), Vector2(600, 135), path_color, 45.0, true)
	draw_line(Vector2(185, 485), Vector2(1015, 485), path_color, 38.0, true)

	# Boundary trees.
	for p in [
		Vector2(145, 135), Vector2(260, 120), Vector2(380, 118), Vector2(820, 120),
		Vector2(945, 130), Vector2(1050, 175), Vector2(150, 750), Vector2(270, 775),
		Vector2(930, 770), Vector2(1040, 735), Vector2(150, 350), Vector2(1050, 365)
	]:
		_draw_tree(p)

	# The suspiciously obvious rock.
	_draw_rock(Vector2(505, 540))

	# God / quest giver.
	_draw_god(Vector2(600, 145))

	for animal in animals:
		_draw_animal(animal)

	_draw_adam(player_position)

func _draw_tree(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-8, 5), Vector2(16, 45)), Color("#6c3e1f"))
	draw_circle(p, 36, Color("#2f713a"))
	draw_circle(p + Vector2(-25, 15), 23, Color("#3c8744"))
	draw_circle(p + Vector2(25, 15), 23, Color("#3c8744"))

func _draw_rock(p: Vector2) -> void:
	var points := PackedVector2Array([
		p + Vector2(-55, 30), p + Vector2(-42, -22), p + Vector2(0, -40),
		p + Vector2(47, -17), p + Vector2(60, 25), p + Vector2(25, 42),
		p + Vector2(-31, 40)
	])
	draw_colored_polygon(points, Color("#6d7375"))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4]]), Color("#a9aeaa"), 5.0)
	draw_string(ThemeDB.fallback_font, p + Vector2(-58, 72), "VERY OBVIOUS ROCK", HORIZONTAL_ALIGNMENT_CENTER, 116, 16, Color("#fff4d2"))

func _draw_god(p: Vector2) -> void:
	draw_circle(p, 31, Color("#f1d18f"))
	draw_circle(p + Vector2(0, 30), 31, Color("#f5f0da"))
	draw_arc(p, 43, 0, TAU, 48, Color("#ffd45f"), 4.0)
	draw_string(ThemeDB.fallback_font, p + Vector2(-60, 78), "GOD", HORIZONTAL_ALIGNMENT_CENTER, 120, 20, Color("#fff4d2"))

func _draw_adam(p: Vector2) -> void:
	draw_circle(p + Vector2(0, -18), 19, Color("#bd7546"))
	draw_circle(p + Vector2(0, 15), 25, Color("#c58251"))
	draw_line(p + Vector2(-13, 30), p + Vector2(-18, 55), Color("#8f5b3e"), 9.0)
	draw_line(p + Vector2(13, 30), p + Vector2(18, 55), Color("#8f5b3e"), 9.0)
	draw_arc(p + Vector2(0, -18), 22, PI, TAU, 18, Color("#4a2b20"), 9.0)
	draw_string(ThemeDB.fallback_font, p + Vector2(-45, 82), "ADAM", HORIZONTAL_ALIGNMENT_CENTER, 90, 18, Color("#fff4d2"))

func _draw_animal(animal: Dictionary) -> void:
	var p: Vector2 = animal["pos"]
	var id: String = animal["id"]
	var body := Color("#e9e1c8")
	match id:
		"cow":
			body = Color("#f2eee3")
			draw_circle(p, 29, body)
			draw_circle(p + Vector2(29, -10), 18, body)
			draw_circle(p + Vector2(-10, -5), 8, Color("#4d352b"))
			draw_circle(p + Vector2(10, 8), 7, Color("#4d352b"))
		"sheep":
			for off in [Vector2(-18,0), Vector2(0,-12), Vector2(19,0), Vector2(0,12)]:
				draw_circle(p + off, 20, Color("#fff6dd"))
			draw_circle(p + Vector2(28, 3), 13, Color("#4b413a"))
		"rabbit":
			draw_circle(p, 22, Color("#d8c5b7"))
			draw_circle(p + Vector2(17, -18), 14, Color("#d8c5b7"))
			draw_line(p + Vector2(12, -27), p + Vector2(8, -52), Color("#d8c5b7"), 9.0)
			draw_line(p + Vector2(23, -27), p + Vector2(27, -52), Color("#d8c5b7"), 9.0)
		"turtle":
			draw_circle(p, 27, Color("#4d8449"))
			draw_circle(p + Vector2(31, 0), 11, Color("#75a85d"))
			draw_arc(p, 18, 0, TAU, 24, Color("#2f5f37"), 4.0)
		"eagle":
			draw_circle(p, 19, Color("#704326"))
			draw_circle(p + Vector2(0, -22), 13, Color("#eee5d0"))
			draw_line(p + Vector2(-6, 4), p + Vector2(-38, 19), Color("#704326"), 14.0)
			draw_line(p + Vector2(6, 4), p + Vector2(38, 19), Color("#704326"), 14.0)
	var display_name: String = str(named_animals.get(id, animal["kind"]))
	draw_string(ThemeDB.fallback_font, p + Vector2(-70, 63), display_name, HORIZONTAL_ALIGNMENT_CENTER, 140, 18, Color("#fff4d2"))

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var quest_panel := PanelContainer.new()
	quest_panel.position = Vector2(24, 20)
	quest_panel.size = Vector2(500, 70)
	quest_panel.add_theme_stylebox_override("panel", _panel_style(Color("#152419e8"), Color("#e7c56c")))
	layer.add_child(quest_panel)
	quest_label = Label.new()
	quest_label.text = "DAY ONE IN EDEN  •  EXPLORE BEFORE THE NAMING QUEST"
	quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	quest_label.add_theme_font_size_override("font_size", 20)
	quest_label.add_theme_color_override("font_color", Color("#fff2cf"))
	quest_panel.add_child(quest_label)

	var help := Label.new()
	help.position = Vector2(790, 26)
	help.size = Vector2(380, 55)
	help.text = "MOVE: WASD / ARROWS     INTERACT: E / ENTER\nESC: TITLE SCREEN"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	help.add_theme_font_size_override("font_size", 16)
	help.add_theme_color_override("font_color", Color("#f8eccb"))
	layer.add_child(help)

	var prompt_panel := PanelContainer.new()
	prompt_panel.position = Vector2(330, 824)
	prompt_panel.size = Vector2(540, 52)
	prompt_panel.add_theme_stylebox_override("panel", _panel_style(Color("#1b1823e8"), Color("#f0c66d")))
	layer.add_child(prompt_panel)
	prompt_label = Label.new()
	prompt_label.text = "WANDER AROUND EDEN"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 20)
	prompt_label.add_theme_color_override("font_color", Color("#fff3d8"))
	prompt_panel.add_child(prompt_label)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.position = Vector2(205, 565)
	dialogue_panel.size = Vector2(790, 260)
	dialogue_panel.visible = false
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style(Color("#211724f4"), Color("#e8b94f")))
	layer.add_child(dialogue_panel)

	var dialogue_stack := VBoxContainer.new()
	dialogue_stack.add_theme_constant_override("separation", 9)
	dialogue_panel.add_child(dialogue_stack)

	dialogue_title = Label.new()
	dialogue_title.add_theme_font_size_override("font_size", 26)
	dialogue_title.add_theme_color_override("font_color", Color("#ffd672"))
	dialogue_stack.add_child(dialogue_title)

	dialogue_body = Label.new()
	dialogue_body.custom_minimum_size = Vector2(730, 70)
	dialogue_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_body.add_theme_font_size_override("font_size", 20)
	dialogue_body.add_theme_color_override("font_color", Color("#fff4df"))
	dialogue_stack.add_child(dialogue_body)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 5)
	dialogue_stack.add_child(choices_box)

	achievement_panel = PanelContainer.new()
	achievement_panel.position = Vector2(360, 105)
	achievement_panel.size = Vector2(480, 70)
	achievement_panel.visible = false
	achievement_panel.add_theme_stylebox_override("panel", _panel_style(Color("#4b2a10f2"), Color("#ffd65a")))
	layer.add_child(achievement_panel)
	achievement_label = Label.new()
	achievement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	achievement_label.add_theme_font_size_override("font_size", 23)
	achievement_label.add_theme_color_override("font_color", Color("#fff2b2"))
	achievement_panel.add_child(achievement_label)

func _panel_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func _button_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style

func _choice(text_value: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 32)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("#fff3d8"))
	button.add_theme_color_override("font_hover_color", Color("#ffd76c"))
	button.add_theme_stylebox_override("normal", _button_style(Color("#34243d"), Color("#765a79")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#473252"), Color("#e0ae52")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#24192c"), Color("#ffd76c")))
	button.pressed.connect(action)
	choices_box.add_child(button)

func _clear_choices() -> void:
	for child in choices_box.get_children():
		choices_box.remove_child(child)
		child.queue_free()

func _show_dialogue(title_text: String, body_text: String) -> void:
	dialogue_open = true
	dialogue_panel.visible = true
	dialogue_title.text = title_text
	dialogue_body.text = body_text
	_clear_choices()

func _close_dialogue() -> void:
	dialogue_open = false
	dialogue_panel.visible = false
	_clear_choices()
	_update_interaction_prompt()

func _update_interaction_prompt() -> void:
	current_target = _nearest_target()
	if current_target.is_empty():
		prompt_label.text = "WANDER AROUND EDEN"
		return
	match current_target["type"]:
		"rock":
			prompt_label.text = "E / ENTER  •  TALK TO THE VERY OBVIOUS ROCK"
		"god":
			prompt_label.text = "E / ENTER  •  ANIMAL NAMING QUEST"
		"animal":
			var animal: Dictionary = current_target["animal"]
			prompt_label.text = "E / ENTER  •  TALK TO " + str(named_animals.get(animal["id"], animal["kind"]))

func _nearest_target() -> Dictionary:
	var best := {}
	var best_distance := INTERACT_DISTANCE
	var targets := [
		{"type": "rock", "pos": Vector2(505, 540)},
		{"type": "god", "pos": Vector2(600, 145)}
	]
	for animal in animals:
		targets.append({"type": "animal", "pos": animal["pos"], "animal": animal})
	for target in targets:
		var distance := player_position.distance_to(target["pos"])
		if distance < best_distance:
			best_distance = distance
			best = target
	return best

func _interact(target: Dictionary) -> void:
	match target["type"]:
		"rock":
			_open_rock()
		"god":
			_open_naming_intro()
		"animal":
			_open_animal(target["animal"])

func _open_animal(animal: Dictionary) -> void:
	var display_name := str(named_animals.get(animal["id"], animal["kind"]))
	_show_dialogue(display_name, animal["noise"])
	_choice("NOD LIKE THAT HELPED", _close_dialogue)

func _open_rock() -> void:
	if rock_topics_seen >= rock_topics.size():
		_show_dialogue("GOD", "\"That's a rock, Adam.\"")
		_choice("SMILE AND NOD", _close_dialogue)
		return
	_show_dialogue("VERY OBVIOUS ROCK", "Adam has decided this is an excellent listener.")
	for i in range(rock_topics.size()):
		if i < rock_topics_seen:
			continue
		var topic := rock_topics[i]
		_choice("EXPLAIN " + topic, _rock_topic.bind(i))
		if i >= rock_topics_seen + 2:
			break

func _rock_topic(index: int) -> void:
	rock_topics_seen = maxi(rock_topics_seen, index + 1)
	if rock_topics_seen >= rock_topics.size():
		_show_dialogue("GOD", "\"That's a rock, Adam.\"")
		_choice("SMILE AND NOD", _close_dialogue)
		return
	var topic := rock_topics[index].to_lower()
	_show_dialogue("ADAM → ROCK", "Adam explains " + topic + " with the absolute confidence of a man who has existed for less than a day.")
	_choice("KEEP TALKING TO THE ROCK", _open_rock)
	_choice("MAYBE LATER", _close_dialogue)

func _open_naming_intro() -> void:
	if naming_complete:
		_show_dialogue("ANIMAL NAMING", "Five animals have names. One of those names is Jeff. History has been made.")
		_choice("RETURN TO EDEN", _close_dialogue)
		return
	if naming_active:
		_show_naming_choice()
		return
	_show_dialogue("ANIMAL NAMING QUEST", "God has decided Adam is ready to name the animals. This confidence may be premature.")
	_choice("START NAMING", _begin_naming)
	_choice("WANDER AROUND FIRST", _close_dialogue)

func _begin_naming() -> void:
	naming_active = true
	naming_index = 0
	quest_label.text = "ANIMAL NAMING QUEST  •  0 / 5"
	_show_naming_choice()

func _animal_by_id(id_value: String) -> Dictionary:
	for animal in animals:
		if animal["id"] == id_value:
			return animal
	return {}

func _show_naming_choice() -> void:
	if naming_index >= naming_order.size():
		_finish_naming()
		return
	var id_value := naming_order[naming_index]
	var animal := _animal_by_id(id_value)
	var options := _name_options(id_value)
	_show_dialogue("NAME THE " + animal["kind"], "Pick the name Adam believes is obviously correct.")
	for option in options:
		_choice(option, _select_name.bind(id_value, option))

func _name_options(id_value: String) -> Array:
	match id_value:
		"cow":
			return ["MOO RECTANGLE", "BEEF PILLOW", "GRUMBLES", "MILK HORSE"]
		"sheep":
			return ["CLOUD DOG", "BAA BALL", "FLOOF UNIT", "WOOL THING"]
		"rabbit":
			return ["FAST POTATO", "EAR BEAST", "HOP CHUNK", "GROUND BIRD"]
		"turtle":
			return ["ROCK WITH LEGS", "SLOW PLATE", "SHELL BLOB", "POND ROCK"]
		"eagle":
			return ["JEFF", "JEFF", "JEFF", "JEFF"]
	return ["THING"]

func _select_name(id_value: String, chosen_name: String) -> void:
	named_animals[id_value] = chosen_name
	naming_index += 1
	quest_label.text = "ANIMAL NAMING QUEST  •  %d / 5" % naming_index
	queue_redraw()
	if id_value == "eagle":
		naming_complete = true
		naming_active = false
		_save_checkpoint()
		_unlock_first_jeff()
		_show_dialogue("GOD", "\"You know what? That's Jeff.\"")
		_choice("ACCEPT JEFF", _close_dialogue)
		return
	_show_naming_choice()

func _finish_naming() -> void:
	naming_complete = true
	naming_active = false
	_save_checkpoint()
	_close_dialogue()

func _unlock_first_jeff() -> void:
	achievement_label.text = "ACHIEVEMENT UNLOCKED  •  FIRST JEFF"
	achievement_panel.visible = true
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func(): achievement_panel.visible = false)

func _load_checkpoint() -> void:
	var profile := ConfigFile.new()
	if profile.load("user://profile.cfg") != OK:
		return
	var slot := int(profile.get_value("save", "last_slot", 0))
	if slot < 1:
		return
	var save := ConfigFile.new()
	if save.load("user://slot_%d.cfg" % slot) != OK:
		return
	if str(save.get_value("progress", "chapter", "prologue")) != "eden":
		return
	naming_complete = bool(save.get_value("progress", "naming_complete", false))
	rock_topics_seen = int(save.get_value("progress", "rock_topics_seen", 0))
	for id_value in naming_order:
		if save.has_section_key("names", id_value):
			named_animals[id_value] = str(save.get_value("names", id_value, ""))
	if naming_complete:
		quest_label.text = "ANIMAL NAMING QUEST COMPLETE  •  FIRST JEFF"

func _save_checkpoint() -> void:
	var profile := ConfigFile.new()
	if profile.load("user://profile.cfg") != OK:
		return
	var slot := int(profile.get_value("save", "last_slot", 0))
	if slot < 1:
		return
	var save := ConfigFile.new()
	save.load("user://slot_%d.cfg" % slot)
	save.set_value("progress", "chapter", "eden")
	save.set_value("progress", "naming_complete", naming_complete)
	save.set_value("progress", "first_jeff", naming_complete)
	save.set_value("progress", "rock_topics_seen", rock_topics_seen)
	for id_value in named_animals.keys():
		save.set_value("names", str(id_value), str(named_animals[id_value]))
	save.save("user://slot_%d.cfg" % slot)

# CI hooks: intentionally tiny public helpers so the automated build can
# verify the authored interactions without synthesizing keyboard input.
func ci_open_rock_finale() -> void:
	rock_topics_seen = rock_topics.size()
	_open_rock()

func ci_complete_naming() -> void:
	naming_active = true
	naming_index = naming_order.size() - 1
	_show_naming_choice()
	_select_name("eagle", "JEFF")
