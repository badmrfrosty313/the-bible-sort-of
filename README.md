# The Bible: Sort Of

> **Production checkpoint — October 8, 2026:** Story expansion is intentionally paused while a dedicated sprite-animation pipeline is built. The current God/Adam/Eve sprites are temporary and should not be treated as final art. Resume from `docs/PAUSE_CHECKPOINT_2026-10-08.md` before making new production changes.

A narrative game in Godot. The beach opening and title screen are the new starting point.

## Run

Open `project.godot` in Godot 4.7.2 and press Play. The game currently starts immediately on a **static illustrated beach title screen**, with no camera pan, Adam-fall sequence, or thought bubble. The original animated concept remains documented for later production.

- **New Game** chooses one of three local save slots and starts the prologue.
- **Continue** opens the most recently used slot.
- **Load** chooses an occupied slot.
- **Chapter Selection** currently contains the prologue.
- **Options** toggles fullscreen.

The title screen now uses the **full-resolution approved 1448×1086 artwork** at `art/title/approved_title_original.png`, rendered into the native **1200×900 (4:3)** game viewport. The smaller `approved_title.webp` remains only as a fallback. Invisible native Godot hitboxes over the printed options preserve keyboard and mouse selection without repainting the menu, and submenus switch to the clean beach plate so baked title lettering never shows through.

The playable **Eden vertical slice** now runs through several authored beats. From a save-slot prologue screen choose **Enter Eden** to free-roam the garden, talk to animals, exhaust Adam's conversation with the suspiciously obvious rock, and play the five-animal naming quest ending in **Achievement: First Jeff**. From there the optional story path continues into the log / **“And I PUT HIM TO SLEEP”** Eve-creation scene, an Eve-controlled naming round with Adam following her, the serpent reveal, and a Fall prototype with the blur-to-black-box modesty gag, leaves inventory, and God commenting from the theater until Adam uses the leaves. The vertical slice stops before inventing finished serpent dialogue or the exile/consequence sequence. The Google Doc **The Bible: Sort Of Game Scripting** remains the narrative authority; `docs/game-script.md` is the synced implementation copy.

The previous theater/Burning Bush prototype remains in Git history. The current main scene is `scenes/title/title_screen.tscn`.

## Visual checks

The Godot CI workflow captures the title/menu states plus Eden free-roam, the rock punchline, First Jeff, Eve creation, Eve day, serpent unlock, the post-fruit black boxes, and the leaves payoff. It validates scene parsing, navigation, save/load routing, and these story interaction hooks without requiring an interactive desktop.
