extends Resource
class_name EpisodeDefinition
## An episode's stable save identity and entry scene. Content owns its own logic.

@export var id: StringName
@export var title: String
@export_file("*.tscn") var scene_path: String
@export_range(0, 10000) var last_checkpoint: int = 0
