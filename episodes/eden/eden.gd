extends Node2D
## Eden is a self-contained episode. The shared shell only mounts it and
## GameState owns durable progress; this script owns the story choreography.

signal return_to_title_requested

const GARDEN := Rect2(24, 35, 432, 206)
const ANIMALS := [
	{"id": &"cow", "name": "COW", "at": Vector2(112, 82), "noise": "MOO."},
	{"id": &"lion", "name": "LION", "at": Vector2(346, 74), "noise": "ROAR."},
	{"id": &"elephant", "name": "ELEPHANT", "at": Vector2(370, 179), "noise": "*trumpet*"},
	{"id": &"turtle", "name": "TURTLE", "at": Vector2(108, 188), "noise": "..."},
	{"id": &"eagle", "name": "EAGLE", "at": Vector2(246, 78), "noise": "SCREE!"},
]
const NAMING_ORDER: Array[StringName] = [&"cow", &"turtle", &"lion", &"elephant", &"eagle"]
const CHECKPOINT_EDEN := 1
const CHECKPOINT_ROCK := 2
const CHECKPOINT_NAMING := 3
const CHECKPOINT_JEFF := 4
const CHECKPOINT_EVE := 5
const CHECKPOINT_SERPENT := 6
const CHECKPOINT_LEAVES := 7

@onready var interaction_system: InteractionSystem = $InteractionSystem
@onready var dialogue: DialogueBox = %Dialogue
@onready var prompt: Label = %Prompt
@onready var objective: Label = %Objective
@onready var inventory: PanelContainer = %Inventory
@onready var leaves_button: Button = %UseLeaves
@onready var toast: AchievementToast = %Achievement

var player: TopDownActor
var follower: TopDownActor
var god_actor: TopDownActor
var current_interactable: Interactable
var role: StringName = &"adam"
var intro_playing := false
var dialogue_after: StringName = &""
var naming_index := 0
var named_animals: Dictionary = {}
var eve_named: Dictionary = {}
var rock_complete := false
var rock_discovered := false
var rock_resume := "opening"
var rock_repeats := 0
var naming_authority := false
var rock_node := ""
var animal_visits: Dictionary = {}
var jeff_wait := 0.0
var jeff_hesitated := false
var stage_blackout: ColorRect
var stage_log := false
var cutscene_eve: TopDownActor
var first_jeff := false
var eve_created := false
var serpent_unlocked := false
var fall_started := false
var adam_clothed := false
var god_in_garden := true
var interactables: Dictionary = {}

func _ready() -> void:
	_create_boundaries()
	_create_interactables()
	_spawn_actors()
	dialogue.finished.connect(_on_dialogue_finished)
	dialogue.choice_selected.connect(_on_choice_selected)
	dialogue.canceled.connect(_on_dialogue_canceled)
	dialogue.line_changed.connect(_on_staging_line)
	stage_blackout = ColorRect.new()
	stage_blackout.color = Color.BLACK
	stage_blackout.size = Vector2(480, 270)
	stage_blackout.z_index = 100
	stage_blackout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_blackout.hide()
	add_child(stage_blackout)
	leaves_button.pressed.connect(_use_leaves)
	_restore_or_begin()
	queue_redraw()

func _process(_delta: float) -> void:
	if dialogue.active and dialogue.choices.get_child_count() == 4 and naming_authority and not first_jeff and NAMING_ORDER[naming_index] == &"eagle" and rock_node.is_empty():
		jeff_wait += _delta
		if jeff_wait > 8.0 and not jeff_hesitated:
			jeff_hesitated = true
			dialogue_after = &"name_choice"
			dialogue.start(_lines(EdenDialogue.JEFF_HESITATION))
	if not dialogue.active and not intro_playing:
		player.set_move_intent(_movement_intent())
		current_interactable = interaction_system.nearest(player.global_position, self)
		prompt.text = current_interactable.prompt if current_interactable != null else "Explore Eden  •  WASD / arrows / D-pad"
	else:
		player.set_move_intent(Vector2.ZERO)
	if follower != null:
		var offset := player.global_position - follower.global_position
		follower.set_move_intent(offset.normalized() * minf((offset.length() - 28.0) / 12.0, 1.0) if offset.length() > 30.0 and not dialogue.active else Vector2.ZERO)
		follower.z_index = 2 if follower.position.y > player.position.y else 1
		player.z_index = 1 if follower.position.y > player.position.y else 2
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and dialogue.active:
		if dialogue.cancelable:
			dialogue.close()
			_on_dialogue_canceled()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"ui_cancel") and not dialogue.active:
		get_viewport().set_input_as_handled()
		return_to_title_requested.emit()
		return
	if dialogue.active or intro_playing:
		return
	if event.is_action_pressed(&"ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		get_viewport().set_input_as_handled()
		if current_interactable != null:
			_interact(current_interactable.interaction_id)
	if event is InputEventKey and event.pressed and event.keycode == KEY_I and fall_started:
		inventory.visible = not inventory.visible

func _movement_intent() -> Vector2:
	var intent := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	if Input.is_key_pressed(KEY_A): intent.x -= 1.0
	if Input.is_key_pressed(KEY_D): intent.x += 1.0
	if Input.is_key_pressed(KEY_W): intent.y -= 1.0
	if Input.is_key_pressed(KEY_S): intent.y += 1.0
	return intent.limit_length(1.0)

func _create_boundaries() -> void:
	_add_wall(Vector2(240, 29), Vector2(432, 8))
	_add_wall(Vector2(240, 247), Vector2(432, 8))
	_add_wall(Vector2(20, 138), Vector2(8, 214))
	_add_wall(Vector2(460, 138), Vector2(8, 214))
	_add_wall(Vector2(240, 132), Vector2(28, 26)) # tree / map obstacle

func _add_wall(center: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = center
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)
	add_child(wall)

func _create_interactables() -> void:
	_add_interactable(&"rock", Vector2(202, 159), "E / Enter  •  Talk to the very obvious rock")
	_add_interactable(&"god", Vector2(240, 55), "E / Enter  •  Talk to God")
	for animal in ANIMALS:
		_add_interactable(animal["id"], animal["at"], "E / Enter  •  Talk to " + animal["name"])
	_add_interactable(&"serpent", Vector2(415, 134), "E / Enter  •  Approach the serpent")
	interactables["serpent"].visible = false

func _add_interactable(id: StringName, position: Vector2, text: String) -> void:
	var interactable := Interactable.new()
	interactable.interaction_id = id
	interactable.position = position
	interactable.prompt = text
	interactable.radius = 22.0
	interactable.add_to_group(&"interactable")
	add_child(interactable)
	interactables[String(id)] = interactable

func _spawn_actors() -> void:
	player = _make_actor(&"adam", "ADAM", Vector2(240, 205))
	add_child(player)
	god_actor = _make_actor(&"god", "GOD", Vector2(240, 55))
	god_actor.movement_enabled = false
	add_child(god_actor)

func _make_actor(actor_role: StringName, display: String, position: Vector2) -> TopDownActor:
	var actor := TopDownActor.new()
	actor.role = actor_role
	actor.display_name = display
	actor.position = position
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	collider.shape = shape
	actor.add_child(collider)
	return actor

func _restore_or_begin() -> void:
	rock_complete = bool(GameState.get_flag(&"eden_rock_complete", false))
	rock_discovered = bool(GameState.get_flag(&"eden_rock_discovered", rock_complete))
	rock_resume = str(GameState.get_flag(&"eden_rock_resume", "opening"))
	if not RockDialogue.NODES.has(rock_resume): rock_resume = "opening"
	rock_repeats = int(GameState.get_flag(&"eden_rock_repeats", 0))
	naming_authority = bool(GameState.get_flag(&"eden_naming_authority", not GameState.get_flag(&"eden_named_animals", {}).is_empty()))
	first_jeff = bool(GameState.get_flag(&"eden_first_jeff", false))
	named_animals = GameState.get_flag(&"eden_named_animals", {}).duplicate(true)
	animal_visits = GameState.get_flag(&"eden_animal_visits", {}).duplicate(true)
	eve_named = GameState.get_flag(&"eden_eve_named", {}).duplicate(true)
	eve_created = bool(GameState.get_flag(&"eden_eve_created", false))
	serpent_unlocked = bool(GameState.get_flag(&"eden_serpent_unlocked", false))
	fall_started = bool(GameState.get_flag(&"eden_fall_started", false))
	adam_clothed = bool(GameState.get_flag(&"eden_adam_clothed", false))
	if GameState.checkpoint == 0:
		_begin_intro()
	else:
		if eve_created:
			_activate_eve()
		if fall_started:
			_activate_adam_after_fall()
		_update_objective()

func _begin_intro() -> void:
	intro_playing = true
	player.position = Vector2(195, 94)
	god_actor.position = Vector2(285, 94)
	dialogue_after = &"intro_complete"
	dialogue.cancelable = false
	dialogue.start(_lines(EdenDialogue.INTRO))

func _on_dialogue_finished() -> void:
	if dialogue_after == &"naming_start":
		naming_authority = true
		_commit(GameState.checkpoint, {"eden_naming_authority": true})
		_resume_naming()
		return
	if dialogue_after in [&"name_choice", &"name_next"]:
		var show_choice := dialogue_after == &"name_choice"
		dialogue_after = &""
		if show_choice: _show_naming_choice()
		else: _resume_naming()
		return
	if String(dialogue_after).begins_with("rock:"):
		var next := String(dialogue_after).trim_prefix("rock:")
		dialogue_after = &""
		_rock_step(next)
		return
	if dialogue_after == &"intro_complete":
		intro_playing = false
		player.position = Vector2(240, 205)
		god_actor.position = Vector2(240, 55)
		dialogue_after = &""
		_commit(CHECKPOINT_EDEN, {})
		_update_objective()
	elif dialogue_after == &"rock_complete":
		dialogue_after = &""
		rock_complete = true
		_commit(maxi(GameState.checkpoint, CHECKPOINT_ROCK), {"eden_rock_complete": true})
		_update_objective()
	elif dialogue_after == &"eve_created":
		dialogue_after = &""
		stage_blackout.hide()
		stage_log = false
		player.rotation = 0.0
		if cutscene_eve != null:
			cutscene_eve.queue_free()
			cutscene_eve = null
		player.position = Vector2(240, 205)
		god_actor.position = Vector2(240, 55)
		eve_created = true
		_activate_eve()
		_commit(CHECKPOINT_EVE, {"eden_eve_created": true})
		_update_objective()
	elif dialogue_after == &"fall_started":
		dialogue_after = &""
		fall_started = true
		_activate_adam_after_fall()
		inventory.visible = true
		_commit(CHECKPOINT_SERPENT, {"eden_fall_started": true})
		_update_objective()

func _on_choice_selected(id: StringName) -> void:
	if String(id).begins_with("rock:"):
		var target := String(id).trim_prefix("rock:")
		if target != "leave": _rock_step(target)
		else: _on_dialogue_canceled()
		return
	if String(id).begins_with("name_"):
		var parts := String(id).split("_", false, 2)
		_select_name(StringName(parts[1]), parts[2])
		return
	match id:
		&"start_naming":
			naming_authority = true
			_commit(GameState.checkpoint, {"eden_naming_authority": true})
			naming_index = 0
			_show_naming_choice()
		&"eve_cutscene":
			_start_eve_cutscene()
		&"fruit":
			_start_fall()
		&"later":
			_update_objective()

func _interact(id: StringName) -> void:
	if id == &"rock":
		_open_rock()
	elif id == &"god" and god_in_garden:
		_open_god()
	elif id == &"serpent" and serpent_unlocked:
		_open_serpent()
	elif id in NAMING_ORDER:
		_open_animal(id)

func _open_animal(id: StringName) -> void:
	dialogue.cancelable = true
	var animal := _animal(id)
	if role == &"eve":
		if not eve_named.has(String(id)):
			eve_named[String(id)] = true
			var count := eve_named.size()
			if count >= 2:
				god_in_garden = false
				interactables["god"].visible = false
				god_actor.hide()
			if count == ANIMALS.size():
				serpent_unlocked = true
				interactables["serpent"].visible = true
			_commit(maxi(GameState.checkpoint, CHECKPOINT_EVE if not serpent_unlocked else CHECKPOINT_SERPENT), {
				"eden_eve_named": eve_named, "eden_serpent_unlocked": serpent_unlocked,
			})
		dialogue.start(_lines([["EVE", "That's a " + String(animal["name"]).to_lower() + "."]]))
		_update_objective()
		return
	var key := String(id)
	var visits := int(animal_visits.get(key, 0))
	animal_visits[key] = visits + 1
	_commit(GameState.checkpoint, {"eden_animal_visits": animal_visits})
	if id == &"cow" and visits > 0: key = "cow_repeat"
	if id == &"lion" and visits == 1: key = "lion_second"
	elif id == &"lion" and visits > 1: key = "lion_repeat"
	if id == &"turtle" and rock_discovered:
		key = "turtle_repeat" if rock_complete and visits > 0 else "turtle_rock"
	if id == &"eagle" and first_jeff: key = "eagle_jeff"
	dialogue.start(_lines(EdenDialogue.FREE_ROAM[key]))

func _open_rock() -> void:
	if role != &"adam":
		dialogue.start(_lines([["EVE", "Rock."]]))
		return
	rock_discovered = true
	_commit(GameState.checkpoint, {"eden_rock_discovered": true})
	if naming_authority and not bool(GameState.get_flag(&"eden_rock_authority_seen", false)):
		_commit(GameState.checkpoint, {"eden_rock_authority_seen": true})
		_rock_step("authority")
	elif rock_complete:
		_rock_step("repeat_first" if rock_repeats == 0 else "repeat_later")
		rock_repeats += 1
		_commit(GameState.checkpoint, {"eden_rock_repeats": rock_repeats})
	else:
		_rock_step(rock_resume)

func _rock_step(id: String) -> void:
	if id == "complete":
		rock_complete = true
		_commit(maxi(GameState.checkpoint, CHECKPOINT_ROCK), {"eden_rock_complete": true})
		_update_objective()
		_on_dialogue_canceled()
		return
	if id == "end":
		_on_dialogue_canceled()
		return
	var node: Dictionary = RockDialogue.NODES[id]
	rock_node = id
	if not rock_complete and id != "authority":
		rock_resume = id
		_commit(GameState.checkpoint, {"eden_rock_resume": id})
	dialogue.cancelable = true
	if node.has("choices"):
		var choices: Array[Dictionary] = []
		for choice in node.choices:
			choices.append({"id": StringName("rock:" + choice.target), "label": choice.label})
		dialogue.ask("ADAM & THE ROCK", "", choices)
	else:
		dialogue_after = StringName("rock:" + node.next)
		if id == "payoff" and god_in_garden:
			god_actor.position = Vector2(265, 94)
		dialogue.start(_lines(node.lines))

func _on_dialogue_canceled() -> void:
	dialogue_after = &""
	dialogue.cancelable = false
	rock_node = ""
	if god_in_garden: god_actor.position = Vector2(240, 55)
	_update_objective()

func _open_god() -> void:
	dialogue.cancelable = false
	if not naming_authority:
		dialogue_after = &"naming_start"
		dialogue.start(_lines(EdenDialogue.QUEST_START))
	elif not first_jeff:
		_resume_naming()
	elif not eve_created:
		_start_eve_cutscene()
	else:
		dialogue.start(_lines([["STORY", "God sees that Eve is doing well and Adam is occupied, so He returns to the theater."]]))

func _show_naming_choice() -> void:
	if naming_index >= NAMING_ORDER.size(): return
	var id := NAMING_ORDER[naming_index]
	var options := _name_options(id)
	var choices: Array[Dictionary] = []
	for index in options.size():
		choices.append({"id": StringName("name_%s_%s" % [id, options[index]]), "label": options[index]})
	dialogue_after = &""
	dialogue.cancelable = true
	jeff_wait = 0.0
	dialogue.ask("NAME THE " + _animal(id)["name"], "", choices)

func _resume_naming() -> void:
	naming_index = 0
	while naming_index < NAMING_ORDER.size() and named_animals.has(String(NAMING_ORDER[naming_index])):
		naming_index += 1
	if naming_index >= NAMING_ORDER.size(): return
	var id := NAMING_ORDER[naming_index]
	var rows: Array = EdenDialogue.NAMING_INTRO[String(id)]
	dialogue.cancelable = true
	dialogue_after = &"name_choice"
	if rows.is_empty(): _show_naming_choice()
	else: dialogue.start(_lines(rows))

func _select_name(id: StringName, value: String) -> void:
	named_animals[String(id)] = value
	var key := String(id) + "_" + value.replace(" ", "_")
	var rows: Array = [["ADAM", value + "."]]
	if EdenDialogue.REACTIONS.has(key):
		rows = EdenDialogue.REACTIONS[key]
	elif id == &"turtle" and rock_discovered:
		rows += EdenDialogue.REACTIONS.turtle_other
	dialogue.cancelable = false
	if id == &"eagle":
		first_jeff = true
		_commit(CHECKPOINT_JEFF, {"eden_named_animals": named_animals, "eden_first_jeff": true})
		toast.show_event("FIRST JEFF")
		dialogue_after = &""
	else:
		_commit(maxi(GameState.checkpoint, CHECKPOINT_NAMING), {"eden_named_animals": named_animals})
		dialogue_after = &"name_next"
	dialogue.start(_lines(rows))
	_update_objective()
	queue_redraw()

func _start_eve_cutscene() -> void:
	dialogue_after = &"eve_created"
	dialogue.cancelable = false
	player.position = Vector2(190, 94)
	god_actor.position = Vector2(285, 94)
	dialogue.start(_lines(EdenDialogue.EVE_CREATION))

func _activate_eve() -> void:
	role = &"eve"
	player.role = &"eve"
	player.display_name = "EVE"
	if follower == null:
		follower = _make_actor(&"adam", "ADAM", player.position + Vector2(-16, 12))
		follower.speed = player.speed + 8.0
		add_child(follower)
	if eve_named.size() >= 2:
		god_in_garden = false
		interactables["god"].visible = false
		god_actor.visible = false
	interactables["serpent"].visible = serpent_unlocked
	queue_redraw()

func _activate_adam_after_fall() -> void:
	if follower == null:
		return
	# The player returns to Adam for the leaves gag. Reuse the two actor nodes
	# instead of creating a second character-switching mechanism.
	var eve_position := player.global_position
	player.role = &"adam"
	player.display_name = "ADAM"
	player.global_position = follower.global_position
	follower.role = &"eve"
	follower.display_name = "EVE"
	follower.global_position = eve_position
	role = &"adam"
	player.presentation = TopDownActor.Presentation.POST_FALL_CENSOR
	follower.presentation = TopDownActor.Presentation.LEAVES
	queue_redraw()

func _open_serpent() -> void:
	if fall_started:
		dialogue.start(_lines([["GOD — FROM THE THEATER", "The leaves are in your inventory. I am not repeating myself."]]))
		return
	dialogue.cancelable = true
	dialogue.ask("STORY", "Eve encounters the serpent, who tempts her to eat the fruit.", [
		{"id": &"fruit", "label": "Eat the fruit"}, {"id": &"later", "label": "Not yet"},
	])

func _start_fall() -> void:
	dialogue_after = &"fall_started"
	dialogue.start(_lines([
		["STORY", "Eve eats the fruit and offers it to Adam."],
		["ADAM", "The pretty lady told me to."],
		["STORY", "The modesty blur becomes two extremely obvious black boxes."],
		["EVE", "I am going to get leaves."],
	]))

func _use_leaves() -> void:
	if not fall_started or adam_clothed:
		return
	adam_clothed = true
	player.presentation = TopDownActor.Presentation.LEAVES
	inventory.visible = false
	_commit(CHECKPOINT_LEAVES, {"eden_adam_clothed": true})
	dialogue.start(_lines([
		["GOD — FROM THE THEATER", "Finally."],
		["STORY", "Prototype continues later."],
	]))
	_update_objective()

func _update_objective() -> void:
	if GameState.checkpoint == 0:
		objective.text = "CREATION DAY"
	elif adam_clothed:
		objective.text = "PROTOTYPE CONTINUES LATER"
	elif fall_started:
		objective.text = "USE LEAVES  •  PRESS I"
	elif serpent_unlocked:
		objective.text = "SOMETHING IS MOVING NEAR THE EASTERN TREES"
	elif eve_created:
		objective.text = "EVE'S NAMING ROUND  •  %d / 5" % eve_named.size()
	elif first_jeff:
		objective.text = "FIRST JEFF COMPLETE  •  TALK TO GOD"
	elif naming_authority:
		objective.text = "NAME THE ANIMALS  •  TALK TO GOD TO RESUME"
	elif animal_visits.size() >= 3:
		objective.text = "GOD IS CALLING  •  TALK TO GOD"
	else:
		objective.text = "EDEN  •  Explore, talk, or find God"

func _commit(checkpoint: int, changes: Dictionary) -> void:
	var error := GameState.commit_progress(checkpoint, changes)
	if error != OK:
		prompt.text = GameState.last_error

func _animal(id: StringName) -> Dictionary:
	for animal in ANIMALS:
		if animal["id"] == id: return animal
	return {}

func _name_options(id: StringName) -> Array[String]:
	match id:
		&"cow": return ["Moo", "Grass Dog", "Big", "Wednesday"]
		&"turtle":
			if rock_discovered: return ["Moving Rock", "Small Ground", "Round", "Other Rock"]
			return ["Slow", "Shell", "Round", "Small"]
		&"lion": return ["No", "Loud", "Hair Mouth", "Do Not"]
		&"elephant": return ["Very Big", "Five Legs", "Long Face", "Kevin"]
		&"eagle": return ["Jeff", "Jeff", "Jeff", "Jeff"]
	return ["Thing"]

func _lines(rows: Array) -> Array[DialogueLine]:
	var result: Array[DialogueLine] = []
	for row in rows:
		var line := DialogueLine.new()
		line.speaker = row[0]
		line.text = row[1]
		result.append(line)
	return result

# Tiny public hooks keep the integration test on real episode code.
func ci_complete_intro() -> void:
	intro_playing = false
	_commit(CHECKPOINT_EDEN, {})
	_update_objective()

func ci_complete_rock() -> void:
	dialogue.close()
	rock_complete = true
	_commit(CHECKPOINT_ROCK, {"eden_rock_complete": true})

func ci_complete_naming() -> void:
	dialogue.close()
	for id in NAMING_ORDER: named_animals[String(id)] = "Jeff" if id == &"eagle" else "Thing"
	first_jeff = true
	_commit(CHECKPOINT_JEFF, {"eden_named_animals": named_animals, "eden_first_jeff": true})
	toast.show_event("FIRST JEFF")

func ci_activate_eve() -> void:
	dialogue.close()
	eve_created = true
	_activate_eve()
	_commit(CHECKPOINT_EVE, {"eden_eve_created": true})

func ci_unlock_serpent() -> void:
	dialogue.close()
	ci_activate_eve()
	for animal in ANIMALS: eve_named[String(animal["id"])] = true
	serpent_unlocked = true
	interactables["serpent"].visible = true
	_commit(CHECKPOINT_SERPENT, {"eden_eve_named": eve_named, "eden_serpent_unlocked": true})

func ci_start_fall() -> void:
	dialogue.close()
	fall_started = true
	_activate_adam_after_fall()
	player.global_position = Vector2(285, 177)
	if follower != null:
		follower.global_position = Vector2(325, 177)
	_commit(CHECKPOINT_SERPENT, {"eden_fall_started": true})
	_update_objective()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(480, 270)), Color("#102a2a"))
	draw_rect(GARDEN, Color("#82b85b"))
	draw_rect(GARDEN, Color("#d7be78"), false, 3.0)
	for position in [Vector2(45,52),Vector2(82,49),Vector2(402,53),Vector2(437,55),Vector2(46,220),Vector2(425,216),Vector2(240,132)]:
		_draw_tree(position)
	_draw_rock(Vector2(202, 159))
	for animal in ANIMALS: _draw_animal(animal)
	if serpent_unlocked or fall_started: _draw_serpent(Vector2(415, 134))
	if stage_log: draw_rect(Rect2(270, 57, 30, 9), Color("#70431f"))

func _on_staging_line(_speaker: String, text: String) -> void:
	stage_blackout.visible = text.contains("Cut to black.")
	if dialogue_after == &"eve_created":
		if text.contains("picks up a log"): stage_log = true
		if text.contains("unconscious"):
			stage_log = false
			player.rotation = PI / 2.0
		if text.contains("creates the woman") and cutscene_eve == null:
			cutscene_eve = _make_actor(&"eve", "EVE", Vector2(235, 94))
			cutscene_eve.movement_enabled = false
			add_child(cutscene_eve)

func _draw_tree(position: Vector2) -> void:
	draw_rect(Rect2(position - Vector2(3, 0), Vector2(6, 17)), Color("#70431f"))
	for offset in [Vector2(-7,-4),Vector2(7,-4),Vector2(0,-10)]: draw_circle(position + offset, 10, Color("#35733c"))

func _draw_rock(position: Vector2) -> void:
	draw_circle(position, 12, Color("#515963"))
	draw_circle(position - Vector2(3,3), 7, Color("#77808a"))
	draw_string(ThemeDB.fallback_font, position + Vector2(-20,21), "ROCK", HORIZONTAL_ALIGNMENT_CENTER, 40, 7, Color("#fff4d5"))

func _draw_animal(animal: Dictionary) -> void:
	var position: Vector2 = animal["at"]
	var color := Color("#eee5d1")
	match animal["id"]:
		&"cow": color = Color("#eee5d1")
		&"lion": color = Color("#c89338")
		&"elephant": color = Color("#a3a6ae")
		&"turtle": color = Color("#5f914e")
		&"eagle": color = Color("#835234")
	draw_circle(position, 9, Color("#283126"))
	draw_circle(position, 7, color)
	var label := str(named_animals.get(String(animal["id"]), animal["name"]))
	draw_string(ThemeDB.fallback_font, position + Vector2(-22,17), label, HORIZONTAL_ALIGNMENT_CENTER, 44, 6, Color("#fff4d5"))

func _draw_serpent(position: Vector2) -> void:
	draw_arc(position, 12, 0.2, TAU * 0.85, 16, Color("#245a31"), 5.0)
	draw_circle(position + Vector2(10,-10), 5, Color("#5ca34d"))
	draw_string(ThemeDB.fallback_font, position + Vector2(-21,20), "SERPENT", HORIZONTAL_ALIGNMENT_CENTER, 42, 6, Color("#fff4d5"))

# Adam, Eve, and God render through TopDownActor sprite sheets.
