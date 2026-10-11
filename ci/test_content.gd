extends SceneTree
## Cross-check implemented spoken dialogue against the author's documents.

func _initialize() -> void:
	var spoken: Array = []
	var failures := 0
	var count := 0
	for rows in [EdenDialogue.INTRO, EdenDialogue.QUEST_START, EdenDialogue.EVE_CREATION, EdenDialogue.JEFF_HESITATION]:
		spoken.append_array(rows)
	for section in [EdenDialogue.FREE_ROAM, EdenDialogue.NAMING_INTRO, EdenDialogue.REACTIONS]:
		for rows in section.values(): spoken.append_array(rows)
	for node in RockDialogue.NODES.values():
		spoken.append_array(node.get("lines", []))
		for choice in node.get("choices", []):
			if choice.target != "leave" and not RockDialogue.NODES.has(choice.target):
				printerr("FAIL: Rock choice has no destination: ", choice.target)
				failures += 1
		if node.has("next") and node.next not in ["complete", "end"] and not RockDialogue.NODES.has(node.next):
			printerr("FAIL: Rock node has no continuation: ", node.next)
			failures += 1
	var expression := RegEx.new()
	expression.compile("^\\*\\*([^*]+?):\\*\\*\\s*(.*)$")
	for path in ["res://docs/game-script.md", "res://docs/dialogue/rock/01-opening.md", "res://docs/dialogue/rock/02-middle.md", "res://docs/dialogue/rock/03-payoff.md"]:
		var source := FileAccess.get_file_as_string(path)
		if path.ends_with("game-script.md"): source = source.substr(source.find("# Adam Introduction"))
		for line in source.split("\n"):
			var match_line := expression.search(line.strip_edges())
			if match_line == null: continue
			var row := [match_line.get_string(1), match_line.get_string(2)]
			count += 1
			if row not in spoken:
				printerr("FAIL: Authored spoken line missing: ", row)
				failures += 1
	print("Authored spoken lines checked: ", count, "; failures: ", failures)
	quit(0 if failures == 0 else 1)
