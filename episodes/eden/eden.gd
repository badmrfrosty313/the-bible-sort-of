extends Node2D
## Eden is a self-contained episode. The shared shell only mounts it and
## GameState owns durable progress; this script owns the story choreography.

signal return_to_title_requested

const GARDEN := Rect2(24, 35, 432, 206)
const ANIMALS := [
	{"id": &"cow", "name": "COW", "at": Vector2(112, 82), "noise": "MOO."},
	{"id": &"sheep", "name": "SHEEP", "at": Vector2(346, 74), "noise": "BAAA."},
	{"id": &"rabbit", "name": "RABBIT", "at": Vector2(370, 179), "noise": "*sniff sniff*"},
	{"id": &"turtle", "name": "TURTLE", "at": Vector2(108, 188), "noise": "..."},
	{"id": &"eagle", "name": "EAGLE", "at": Vector2(246, 78), "noise": "SCREE!"},
]
const NAMING_ORDER: Array[StringName] = [&"cow", &"sheep", &"rabbit", &"turtle", &"eagle"]
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
var current_interactable: Interactable
var role: StringName = &"adam"
var intro_playing := false
var dialogue_after: StringName = &""
var naming_index := 0
var named_animals: Dictionary = {}
var eve_named: Dictionary = {}
var rock_complete := false
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
	leaves_button.pressed.connect(_use_leaves)
	_restore_or_begin()
	queue_redraw()

func _process(_delta: float) -> void:
	if not dialogue.active and not intro_playing:
		player.set_move_intent(_movement_intent())
		current_interactable = interaction_system.nearest(player.global_position, self)
		prompt.text = current_interactable.prompt if current_interactable != null else "Explore Eden  •  WASD / arrows / D-pad"
	else:
		player.set_move_intent(Vector2.ZERO)
	if follower != null:
		var target := player.global_position - player.facing * 18.0
		follower.global_position = follower.global_position.lerp(target, 0.12)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
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
	first_jeff = bool(GameState.get_flag(&"eden_first_jeff", false))
	named_animals = GameState.get_flag(&"eden_named_animals", {}).duplicate(true)
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
		_update_objective()

func _begin_intro() -> void:
	intro_playing = true
	dialogue_after = &"intro_complete"
	dialogue.start(_lines([
		["STORY", "Adam stares intensely at his own hand, opens and closes his fingers, and thinks very hard."],
		["GOD", "Adam."],
		["ADAM", "Adam."],
		["GOD", "Yes. You're Adam."],
		["ADAM", "Adam."],
		["GOD", "Right."],
		["GOD", "God."],
		["ADAM", "Adam."],
		["GOD", "No, you're Adam. I'm God."],
		["ADAM", "Adam?"],
		["GOD", "We have time."],
		["STORY", "Five hours later."],
		["GOD", "Tell me something you've learned."],
		["ADAM", "Adam!"],
		["GOD", "Fantastic. Five hours."],
		["GOD", "I made that."],
		["STORY", "God shows Adam a rock, an apple, a tree, and eventually Himself. Adam gets nearly every one wrong."],
		["GOD", "You know what? Go explore."],
		["ADAM", "Adam."],
		["GOD", "Sure."],
	]))

func _on_dialogue_finished() -> void:
	if dialogue_after == &"intro_complete":
		intro_playing = false
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
		eve_created = true
		_activate_eve()
		_commit(CHECKPOINT_EVE, {"eden_eve_created": true})
		_update_objective()
	elif dialogue_after == &"fall_started":
		dialogue_after = &""
		fall_started = true
		inventory.visible = true
		_commit(CHECKPOINT_SERPENT, {"eden_fall_started": true})
		_update_objective()

func _on_choice_selected(id: StringName) -> void:
	if String(id).begins_with("name_"):
		var parts := String(id).split("_", false, 2)
		_select_name(StringName(parts[1]), parts[2])
		return
	match id:
		&"start_naming":
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
	var animal := _animal(id)
	if role == &"eve" and not eve_named.has(String(id)):
		eve_named[String(id)] = true
		var count := eve_named.size()
		if count >= 2:
			god_in_garden = false
			interactables["god"].visible = false
		if count == ANIMALS.size():
			serpent_unlocked = true
			interactables["serpent"].visible = true
		_commit(CHECKPOINT_EVE if not serpent_unlocked else CHECKPOINT_SERPENT, {
			"eden_eve_named": eve_named, "eden_serpent_unlocked": serpent_unlocked,
		})
		dialogue.start(_lines([["EVE", "That's a " + String(animal["name"]).to_lower() + "."]]))
		_update_objective()
		return
	dialogue.start(_lines([[String(animal["name"]), String(animal["noise"])]]))

func _open_rock() -> void:
	if rock_complete:
		dialogue.start(_lines([["GOD", "That's a rock, Adam."], ["ADAM", "I know. We're friends."]]))
		return
	dialogue_after = &"rock_complete"
	dialogue.start(_lines([
		["ADAM → ROCK", "Hi. I am Adam. I learned that is my name."],
		["ADAM → ROCK", "There is a sun. It is very bright. I have decided it is doing a good job."],
		["ADAM → ROCK", "God said you are a rock. That means you are excellent at listening."],
		["ADAM → ROCK", "I met a cow. It had thoughts. I think. It said moo."],
		["ADAM → ROCK", "Anyway, I have existed for one day. It has been a lot."],
		["GOD", "That's a rock, Adam."],
		["ADAM", "I know."],
	]))

func _open_god() -> void:
	if not first_jeff:
		dialogue.ask("GOD", "Adam, it is time to name the animals. Please take this seriously.", [
			{"id": &"start_naming", "label": "I will do my best."},
			{"id": &"later", "label": "I need to talk to a rock first."},
		])
	elif not eve_created:
		dialogue.ask("GOD", "Five animals have names. One is Jeff. I may need to intervene.", [
			{"id": &"eve_cutscene", "label": "Continue story"}, {"id": &"later", "label": "Wander Eden"},
		])
	else:
		dialogue.start(_lines([["GOD", "Eve is doing very well. I am going to let you two handle this."]]))

func _show_naming_choice() -> void:
	if naming_index >= NAMING_ORDER.size():
		return
	var id := NAMING_ORDER[naming_index]
	var options := _name_options(id)
	var choices: Array[Dictionary] = []
	for index in options.size():
		choices.append({"id": StringName("name_%s_%s" % [id, options[index]]), "label": options[index]})
	dialogue.ask("NAME THE " + _animal(id)["name"], "Pick the name Adam believes is obviously correct.", choices)

func _select_name(id: StringName, value: String) -> void:
	named_animals[String(id)] = value
	naming_index += 1
	if id == &"eagle":
		first_jeff = true
		_commit(CHECKPOINT_JEFF, {"eden_named_animals": named_animals, "eden_first_jeff": true})
		toast.show_event("FIRST JEFF")
		dialogue_after = &""
		dialogue.start(_lines([["GOD", "You know what? That's Jeff."], ["STORY", "Achievement unlocked: First Jeff."]]))
		_update_objective()
		return
	_commit(CHECKPOINT_NAMING, {"eden_named_animals": named_animals})
	_show_naming_choice()

func _start_eve_cutscene() -> void:
	dialogue_after = &"eve_created"
	dialogue.start(_lines([
		["STORY", "God picks up a log. The screen cuts to black."],
		["STORY", "When the image returns, Adam is very clearly unconscious."],
		["GOD", "And I PUT HIM TO SLEEP."],
		["GOD", "What is this animal called?"],
		["EVE", "That's a cow."],
		["GOD", "I like this one."],
	]))

func _activate_eve() -> void:
	role = &"eve"
	player.role = &"eve"
	player.display_name = "EVE"
	if follower == null:
		follower = _make_actor(&"adam", "ADAM", player.position + Vector2(-16, 12))
		follower.movement_enabled = false
		add_child(follower)
	if eve_named.size() >= 2:
		god_in_garden = false
		interactables["god"].visible = false
	interactables["serpent"].visible = serpent_unlocked
	queue_redraw()

func _open_serpent() -> void:
	if fall_started:
		dialogue.start(_lines([["GOD — FROM THE THEATER", "The leaves are in your inventory. I am not repeating myself."]]))
		return
	dialogue.ask("SERPENT", "The temptation beat is ready. Finished serpent dialogue remains intentionally unwritten.", [
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
		&"cow": return ["Moo Rectangle", "Beef Pillow", "Grumbles", "Milk Horse"]
		&"sheep": return ["Cloud Dog", "Baa Ball", "Floof Unit", "Wool Thing"]
		&"rabbit": return ["Fast Potato", "Ear Beast", "Hop Chunk", "Ground Bird"]
		&"turtle": return ["Rock With Legs", "Slow Plate", "Shell Blob", "Pond Rock"]
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
	if god_in_garden: _draw_god(Vector2(240, 55))
	for animal in ANIMALS: _draw_animal(animal)
	if serpent_unlocked or fall_started: _draw_serpent(Vector2(415, 134))
	if fall_started:
		_draw_modesty(player.global_position, adam_clothed if role == &"adam" else true)
		if follower != null: _draw_modesty(follower.global_position, adam_clothed)

func _draw_tree(position: Vector2) -> void:
	draw_rect(Rect2(position - Vector2(3, 0), Vector2(6, 17)), Color("#70431f"))
	for offset in [Vector2(-7,-4),Vector2(7,-4),Vector2(0,-10)]: draw_circle(position + offset, 10, Color("#35733c"))

func _draw_rock(position: Vector2) -> void:
	draw_circle(position, 12, Color("#515963"))
	draw_circle(position - Vector2(3,3), 7, Color("#77808a"))
	draw_string(ThemeDB.fallback_font, position + Vector2(-20,21), "ROCK", HORIZONTAL_ALIGNMENT_CENTER, 40, 7, Color("#fff4d5"))

func _draw_god(position: Vector2) -> void:
	draw_circle(position - Vector2(0,7), 7, Color("#d89a61"))
	draw_arc(position - Vector2(0,8), 9, PI, TAU, 12, Color("#eee9d9"), 4)
	draw_rect(Rect2(position - Vector2(7,1), Vector2(14,17)), Color("#eee9d9"))
	draw_string(ThemeDB.fallback_font, position + Vector2(-20,23), "GOD", HORIZONTAL_ALIGNMENT_CENTER, 40, 7, Color("#fff4d5"))

func _draw_animal(animal: Dictionary) -> void:
	var position: Vector2 = animal["at"]
	var color := Color("#eee5d1")
	match animal["id"]:
		&"cow": color = Color("#eee5d1")
		&"sheep": color = Color("#f7f0dd")
		&"rabbit": color = Color("#d9c2b0")
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

func _draw_modesty(position: Vector2, clothed: bool) -> void:
	var color := Color("#397b3f") if clothed else Color("#111111")
	draw_rect(Rect2(position + Vector2(-6,1), Vector2(12,7)), color)
