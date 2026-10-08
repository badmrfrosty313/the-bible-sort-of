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
var eve_created := false
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
	# A deliberately chunky 16-bit-RPG-ish garden. Gameplay geometry stays
	# simple and readable while the presentation gets enough texture to feel alive.
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#0d3428"))
	draw_rect(Rect2(90, 60, 1020, 780), Color("#214c34"))
	draw_rect(GARDEN_RECT, Color("#8acb68"))
	draw_rect(Rect2(125, 95, 950, 710), Color("#78bb5b"))

	# Grass bands and tufts break up the giant green rectangle without adding assets.
	for y in [150.0, 360.0, 585.0, 760.0]:
		draw_line(Vector2(145, y), Vector2(1055, y), Color("#83c56555"), 3.0)
	for p in [
		Vector2(215,205), Vector2(430,170), Vector2(755,185), Vector2(970,215),
		Vector2(195,585), Vector2(405,690), Vector2(760,705), Vector2(1000,610),
		Vector2(370,405), Vector2(925,430), Vector2(235,430), Vector2(735,555)
	]:
		_draw_grass_tuft(p)

	# Dirt roads with a darker outer edge so they read like authored paths.
	var outer_path := Color("#9c7b43")
	var inner_path := Color("#ddc17b")
	draw_line(Vector2(600, 785), Vector2(600, 135), outer_path, 58.0, true)
	draw_line(Vector2(600, 785), Vector2(600, 135), inner_path, 42.0, true)
	draw_line(Vector2(180, 485), Vector2(1020, 485), outer_path, 52.0, true)
	draw_line(Vector2(180, 485), Vector2(1020, 485), inner_path, 38.0, true)
	for p in [Vector2(600,760),Vector2(600,640),Vector2(600,355),Vector2(600,235),Vector2(350,485),Vector2(850,485)]:
		draw_circle(p, 5, Color("#b6985b"))

	# Pond with depth rings, highlight, reeds and lily pads.
	var pond := Vector2(815, 480)
	draw_circle(pond + Vector2(7, 10), 126, Color("#2b674d88"))
	draw_circle(pond, 121, Color("#2c8394"))
	draw_circle(pond, 107, Color("#62bec4"))
	draw_circle(pond + Vector2(-22, -28), 55, Color("#7dd2cf55"))
	for p in [pond + Vector2(-52,-16), pond + Vector2(38,34), pond + Vector2(10,-65)]:
		draw_circle(p, 13, Color("#457d45"))
		draw_line(p, p + Vector2(7,-8), Color("#315e34"), 3.0)
	for x in [700.0, 715.0, 920.0, 936.0]:
		draw_line(Vector2(x, 570), Vector2(x - 4, 535), Color("#416f39"), 5.0)

	# Garden-border trees and hedges.
	for p in [
		Vector2(145, 135), Vector2(260, 120), Vector2(380, 118), Vector2(820, 120),
		Vector2(945, 130), Vector2(1050, 175), Vector2(150, 750), Vector2(270, 775),
		Vector2(930, 770), Vector2(1040, 735), Vector2(150, 350), Vector2(1050, 365)
	]:
		_draw_tree(p)
	for p in [Vector2(475,115),Vector2(720,115),Vector2(155,510),Vector2(1040,530),Vector2(470,780),Vector2(750,780)]:
		_draw_bush(p)

	# Flower clusters are tiny landmarks for navigation.
	for pair in [
		[Vector2(360,320), Color("#f5d250")], [Vector2(975,330), Color("#f2a4c4")],
		[Vector2(410,620), Color("#8e77d9")], [Vector2(875,690), Color("#f5d250")]
	]:
		_draw_flowers(pair[0], pair[1])

	_draw_rock(Vector2(505, 540))
	_draw_god(Vector2(600, 145))
	for animal in animals:
		_draw_animal(animal)
	_draw_adam(player_position)

func _draw_grass_tuft(p: Vector2) -> void:
	var c := Color("#4f963f")
	draw_line(p, p + Vector2(-6, -12), c, 3.0)
	draw_line(p, p + Vector2(0, -15), c, 3.0)
	draw_line(p, p + Vector2(7, -10), c, 3.0)

func _draw_bush(p: Vector2) -> void:
	draw_circle(p + Vector2(3,7), 29, Color("#225a32"))
	draw_circle(p + Vector2(-19,2), 20, Color("#347a3d"))
	draw_circle(p + Vector2(20,2), 20, Color("#3f8b46"))
	draw_circle(p + Vector2(0,-14), 22, Color("#3b8442"))

func _draw_flowers(p: Vector2, petal: Color) -> void:
	for off in [Vector2(-10,0), Vector2(10,0), Vector2(0,-10), Vector2(0,10)]:
		draw_circle(p + off * 0.55, 5, petal)
	draw_circle(p, 4, Color("#ffe68b"))

func _draw_tree(p: Vector2) -> void:
	# Heavy outlines match the title art better than the old flat circles.
	draw_circle(p + Vector2(8, 18), 42, Color("#153d27aa"))
	draw_rect(Rect2(p + Vector2(-11, 3), Vector2(22, 55)), Color("#4b2b1a"))
	draw_rect(Rect2(p + Vector2(-6, 3), Vector2(12, 55)), Color("#835027"))
	for crown in [
		[p + Vector2(-28,4), 27.0, Color("#245f33")],
		[p + Vector2(28,6), 27.0, Color("#2f7839")],
		[p + Vector2(0,-20), 34.0, Color("#2c6e37")],
		[p + Vector2(0,10), 30.0, Color("#3d8640")]
	]:
		draw_circle(crown[0], crown[1] + 4.0, Color("#173f29"))
		draw_circle(crown[0], crown[1], crown[2])

func _draw_rock(p: Vector2) -> void:
	var shadow := PackedVector2Array([
		p + Vector2(-59, 38), p + Vector2(-47, -16), p + Vector2(-3, -37),
		p + Vector2(53, -12), p + Vector2(65, 32), p + Vector2(28, 49),
		p + Vector2(-34, 47)
	])
	draw_colored_polygon(shadow, Color("#273a35aa"))
	var points := PackedVector2Array([
		p + Vector2(-55, 30), p + Vector2(-42, -22), p + Vector2(0, -40),
		p + Vector2(47, -17), p + Vector2(60, 25), p + Vector2(25, 42),
		p + Vector2(-31, 40)
	])
	draw_colored_polygon(points, Color("#717a7c"))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4]]), Color("#b8bdb5"), 5.0)
	draw_line(p + Vector2(-10,-18), p + Vector2(8,0), Color("#51595b"), 4.0)
	draw_line(p + Vector2(8,0), p + Vector2(-3,15), Color("#51595b"), 4.0)
	draw_string(ThemeDB.fallback_font, p + Vector2(-75, 73), "VERY OBVIOUS ROCK", HORIZONTAL_ALIGNMENT_CENTER, 150, 15, Color("#fff4d2"))

func _draw_god(p: Vector2) -> void:
	# Quest-giver God: halo, hair/beard, simple robe silhouette.
	draw_circle(p + Vector2(5,10), 48, Color("#203c2d66"))
	var robe := PackedVector2Array([
		p + Vector2(-30,25), p + Vector2(30,25), p + Vector2(44,78), p + Vector2(-44,78)
	])
	draw_colored_polygon(robe, Color("#f0ead6"))
	draw_polyline(PackedVector2Array([robe[0],robe[1],robe[2]]), Color("#c8ad67"), 4.0)
	draw_circle(p, 29, Color("#d99a62"))
	draw_arc(p, 44, 0, TAU, 48, Color("#ffd35a"), 6.0)
	draw_arc(p, 49, 0, TAU, 48, Color("#fff0a0"), 2.0)
	draw_arc(p + Vector2(0,-3), 29, PI, TAU, 20, Color("#f1eee1"), 13.0)
	draw_circle(p + Vector2(-13,25), 18, Color("#f1eee1"))
	draw_circle(p + Vector2(13,25), 18, Color("#f1eee1"))
	draw_circle(p + Vector2(-8,-3), 3, Color("#31231d"))
	draw_circle(p + Vector2(8,-3), 3, Color("#31231d"))
	draw_string(ThemeDB.fallback_font, p + Vector2(-60, 105), "GOD", HORIZONTAL_ALIGNMENT_CENTER, 120, 19, Color("#fff4d2"))

func _draw_adam(p: Vector2) -> void:
	# Chunky top-down Adam with a soft shadow and deliberately simple anatomy.
	draw_circle(p + Vector2(7,44), 29, Color("#29433277"))
	draw_circle(p + Vector2(0,-18), 21, Color("#c98758"))
	draw_circle(p + Vector2(0,16), 27, Color("#bd7546"))
	draw_line(p + Vector2(-18,5), p + Vector2(-36,24), Color("#a86443"), 10.0)
	draw_line(p + Vector2(18,5), p + Vector2(36,24), Color("#a86443"), 10.0)
	draw_line(p + Vector2(-12,34), p + Vector2(-17,60), Color("#8f5b3e"), 10.0)
	draw_line(p + Vector2(12,34), p + Vector2(17,60), Color("#8f5b3e"), 10.0)
	draw_arc(p + Vector2(0,-18), 24, PI, TAU, 18, Color("#43281e"), 10.0)
	draw_circle(p + Vector2(-7,-18), 2.5, Color("#2e211b"))
	draw_circle(p + Vector2(7,-18), 2.5, Color("#2e211b"))
	# The pre-Fall modesty gag remains abstract rather than explicit.
	for off in [Vector2(-7,26),Vector2(0,23),Vector2(7,27),Vector2(0,31)]:
		draw_rect(Rect2(p + off - Vector2(5,5), Vector2(10,10)), Color("#b88a63"))
	draw_string(ThemeDB.fallback_font, p + Vector2(-45, 87), "ADAM", HORIZONTAL_ALIGNMENT_CENTER, 90, 17, Color("#fff4d2"))

func _draw_animal(animal: Dictionary) -> void:
	var p: Vector2 = animal["pos"]
	var id: String = animal["id"]
	var outline := Color("#2b3128")
	match id:
		"cow":
			draw_circle(p, 33, outline)
			draw_circle(p + Vector2(31,-10), 21, outline)
			draw_circle(p, 28, Color("#eee8d9"))
			draw_circle(p + Vector2(29,-10), 17, Color("#eee8d9"))
			draw_circle(p + Vector2(-10,-5), 8, Color("#4d352b"))
			draw_circle(p + Vector2(10,8), 7, Color("#4d352b"))
			draw_circle(p + Vector2(34,-12), 3, Color("#241b18"))
		"sheep":
			for off in [Vector2(-18,0),Vector2(0,-12),Vector2(19,0),Vector2(0,12)]:
				draw_circle(p + off, 23, outline)
				draw_circle(p + off, 19, Color("#fff3d4"))
			draw_circle(p + Vector2(29,3), 16, outline)
			draw_circle(p + Vector2(29,3), 12, Color("#4b413a"))
		"rabbit":
			draw_circle(p, 26, outline)
			draw_circle(p + Vector2(17,-18), 17, outline)
			draw_circle(p, 22, Color("#d9c2b0"))
			draw_circle(p + Vector2(17,-18), 13, Color("#d9c2b0"))
			draw_line(p + Vector2(12,-27), p + Vector2(8,-52), outline, 12.0)
			draw_line(p + Vector2(23,-27), p + Vector2(27,-52), outline, 12.0)
			draw_line(p + Vector2(12,-27), p + Vector2(8,-52), Color("#d9c2b0"), 7.0)
			draw_line(p + Vector2(23,-27), p + Vector2(27,-52), Color("#d9c2b0"), 7.0)
		"turtle":
			draw_circle(p, 31, outline)
			draw_circle(p + Vector2(31,0), 14, outline)
			draw_circle(p, 27, Color("#4d8449"))
			draw_circle(p + Vector2(31,0), 10, Color("#75a85d"))
			draw_arc(p, 18, 0, TAU, 24, Color("#2f5f37"), 4.0)
			draw_line(p + Vector2(-12,-12), p + Vector2(12,12), Color("#315e34"), 3.0)
		"eagle":
			draw_circle(p + Vector2(0,2), 23, outline)
			draw_circle(p + Vector2(0,-23), 16, outline)
			draw_circle(p + Vector2(0,2), 19, Color("#704326"))
			draw_circle(p + Vector2(0,-23), 12, Color("#eee5d0"))
			draw_line(p + Vector2(-5,5), p + Vector2(-42,20), outline, 18.0)
			draw_line(p + Vector2(5,5), p + Vector2(42,20), outline, 18.0)
			draw_line(p + Vector2(-5,5), p + Vector2(-40,19), Color("#704326"), 12.0)
			draw_line(p + Vector2(5,5), p + Vector2(40,19), Color("#704326"), 12.0)
			var beak := PackedVector2Array([p + Vector2(10,-24),p + Vector2(27,-18),p + Vector2(11,-13)])
			draw_colored_polygon(beak, Color("#e0b447"))
	var display_name: String = str(named_animals.get(id, animal["kind"]))
	draw_string(ThemeDB.fallback_font, p + Vector2(-70, 67), display_name, HORIZONTAL_ALIGNMENT_CENTER, 140, 17, Color("#fff4d2"))

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
		var topic: String = str(rock_topics[i])
		_choice("EXPLAIN " + topic, _rock_topic.bind(i))
		if i >= rock_topics_seen + 2:
			break

func _rock_topic(index: int) -> void:
	rock_topics_seen = maxi(rock_topics_seen, index + 1)
	if rock_topics_seen >= rock_topics.size():
		_show_dialogue("GOD", "\"That's a rock, Adam.\"")
		_choice("SMILE AND NOD", _close_dialogue)
		return
	var topic: String = str(rock_topics[index]).to_lower()
	_show_dialogue("ADAM → ROCK", "Adam explains " + topic + " with the absolute confidence of a man who has existed for less than a day.")
	_choice("KEEP TALKING TO THE ROCK", _open_rock)
	_choice("MAYBE LATER", _close_dialogue)

func _open_naming_intro() -> void:
	if naming_complete:
		if eve_created:
			_show_dialogue("ANIMAL NAMING", "Five animals have names. One of those names is Jeff. Eve has also proven dramatically more competent.")
			_choice("RETURN TO EDEN", _close_dialogue)
		else:
			_show_dialogue("ANIMAL NAMING", "Five animals have names. One of those names is Jeff. God has concluded that Adam may require additional assistance.")
			_choice("CONTINUE STORY", _start_eve_cutscene)
			_choice("WANDER EDEN", _close_dialogue)
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
	var id_value: String = str(naming_order[naming_index])
	var animal: Dictionary = _animal_by_id(id_value)
	var options: Array = _name_options(id_value)
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
		_choice("CONTINUE STORY", _start_eve_cutscene)
		_choice("WANDER EDEN", _close_dialogue)
		return
	_show_naming_choice()

func _start_eve_cutscene() -> void:
	_close_dialogue()
	get_tree().change_scene_to_file("res://scenes/episodes/eden/eve_cutscene.tscn")

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
	eve_created = bool(save.get_value("progress", "eve_created", false))
	rock_topics_seen = int(save.get_value("progress", "rock_topics_seen", 0))
	for id_value in naming_order:
		if save.has_section_key("names", id_value):
			named_animals[id_value] = str(save.get_value("names", id_value, ""))
	if eve_created:
		quest_label.text = "EVE CREATED  •  NEXT DAY STORY BEAT NOT YET BUILT"
	elif naming_complete:
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
	save.set_value("progress", "eve_created", eve_created)
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
