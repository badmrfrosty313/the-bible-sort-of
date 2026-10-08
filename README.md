# The Bible: Sort Of

A narrative game in Godot. The beach opening and title screen are the new starting point.

## Run

Open `project.godot` in Godot 4.7.2 and press Play. The beach intro uses cinematic framing: a quiet shot of God, a camera reveal of Adam already caught in the vines, God's reaction framing and his authored punchline, then the title menu. Press a key or click to skip the intro.

- **New Game** chooses one of three local save slots and starts the prologue.
- **Continue** opens the most recently used slot.
- **Load** chooses an occupied slot.
- **Chapter Selection** currently contains the prologue.
- **Options** toggles fullscreen.

The title art is a clean background plate; logo, menu, focus states, and save slot controls are native Godot UI. The beach background remains a single illustrated plate already containing God, Adam, the vines, and the mug. The camera moves across that image without duplicating characters. A real animated fall, vine catch, eye roll, and independent environmental motion require separate transparent artwork; full chapter gameplay is also unfinished. The Google Doc **The Bible: Sort Of Game Scripting** governs the story, with the current outline reflected in `docs/game-script.md`.

The previous theater/Burning Bush prototype remains in Git history. The current main scene is `scenes/title/title_screen.tscn`.
