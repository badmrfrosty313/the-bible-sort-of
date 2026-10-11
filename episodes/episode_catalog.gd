extends RefCounted
class_name EpisodeCatalog

const FIRST_EPISODE: StringName = &"development"
const DEFINITIONS: Array[String] = ["res://episodes/development/episode.tres"]

static func find_episode(id: StringName) -> EpisodeDefinition:
	for path in DEFINITIONS:
		var definition := load(path) as EpisodeDefinition
		if definition != null and definition.id == id:
			return definition
	return null
