# The Bible: Sort Of

A narrative game in Godot. The beach opening and title screen are the new starting point.

## Run

Open `project.godot` in Godot 4.7.2 and press Play. The game currently starts immediately on a **static illustrated beach title screen**, with no camera pan, Adam-fall sequence, or thought bubble. The original animated concept remains documented for later production.

- **New Game** chooses one of three local save slots and starts the prologue.
- **Continue** opens the most recently used slot.
- **Load** chooses an occupied slot.
- **Chapter Selection** currently contains the prologue.
- **Options** toggles fullscreen.

The title art is a clean background plate; logo, menu, focus states, and save slot controls are native Godot UI. The beach background remains a single illustrated plate already containing God, Adam, the vines, and the mug. All title and submenu actions use consistent, unboxed text over the scene. Actual character animation, environmental motion, and full chapter gameplay remain future work. The previous animatic script is retained in the repository but is not loaded by the title scene. The Google Doc **The Bible: Sort Of Game Scripting** governs the story, with the current outline reflected in `docs/game-script.md`.

The previous theater/Burning Bush prototype remains in Git history. The current main scene is `scenes/title/title_screen.tscn`.

## Visual checks

The Godot CI workflow captures the title screen, new-game slots, prologue placeholder, load slots, chapter selection, options, and a return to title. It also tests navigation through New Game, Continue, Load, Chapters, Options and Back without requiring an interactive desktop.
