extends RefCounted
class_name EpisodeCatalog

const FIRST_EPISODE: StringName = &"eden"
const DEFINITIONS: Array[String] = ["res://episodes/eden/episode.tres"]

static func find_episode(id: StringName) -> EpisodeDefinition:
	for path in DEFINITIONS:
		var definition := load(path) as EpisodeDefinition
		if definition != null and definition.id == id:
			return definition
	return null
