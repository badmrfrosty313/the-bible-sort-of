extends Node2D
class_name Interactable
## Small data component shared by props, animals, and NPCs.

@export var interaction_id: StringName
@export var prompt: String
@export var radius: float = 22.0

func is_available(_context: Node) -> bool:
	return visible
