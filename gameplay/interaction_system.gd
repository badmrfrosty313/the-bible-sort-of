extends Node
class_name InteractionSystem
## Finds the closest enabled Interactable without episode-specific type checks.

@export var range: float = 26.0

func nearest(origin: Vector2, context: Node) -> Interactable:
	var closest: Interactable
	var closest_distance := range
	for node in get_tree().get_nodes_in_group(&"interactable"):
		var candidate := node as Interactable
		if candidate == null or not candidate.is_available(context):
			continue
		var distance := origin.distance_to(candidate.global_position)
		if distance <= closest_distance:
			closest = candidate
			closest_distance = distance
	return closest
