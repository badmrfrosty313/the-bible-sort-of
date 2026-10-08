# The Bible: Sort Of

A narrative game in Godot. The beach opening and title screen are the new starting point.

## Run

Open `project.godot` in Godot 4.7.2 and press Play. The beach intro now animates Adam's fall, the vine catch, a temporary eye-roll reaction marker, then shows God's authored punchline before the title menu. Press a key or click to skip the intro.

- **New Game** chooses one of three local save slots and starts the prologue.
- **Continue** opens the most recently used slot.
- **Load** chooses an occupied slot.
- **Chapter Selection** currently contains the prologue.
- **Options** toggles fullscreen.

The title art is a clean background plate; logo, menu, focus states, and save slot controls are native Godot UI. The beach background remains a still frame, with separately drawn animation stand-ins for Adam, the vines, and the reaction. Final character/environment art and full chapter gameplay remain unfinished. The Google Doc **The Bible: Sort Of Game Scripting** governs the story, with the current outline reflected in `docs/game-script.md`.

The previous theater/Burning Bush prototype remains in Git history. The current main scene is `scenes/title/title_screen.tscn`.
