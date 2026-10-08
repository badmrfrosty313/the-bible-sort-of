# The Bible: Sort Of

A narrative game in Godot. The beach opening and title screen are the new starting point.

## Run

Open `project.godot` in Godot 4.7.2 and press Play. The game currently starts immediately on a **static illustrated beach title screen**, with no camera pan, Adam-fall sequence, or thought bubble. The original animated concept remains documented for later production.

- **New Game** chooses one of three local save slots and starts the prologue.
- **Continue** opens the most recently used slot.
- **Load** chooses an occupied slot.
- **Chapter Selection** currently contains the prologue.
- **Options** toggles fullscreen.

The title screen uses the **approved complete illustrated title artwork** (`art/title/approved_title.webp`). The game now renders at **1200×900 (4:3)** and preserves the authored menu geometry by uniformly scaling the 480×360 UI layout. The image currently committed is a 480×360 WebP copy of the approved 1448×1086 illustration; Godot reconstructs it once with Lanczos for a sharper full-size render. For original visual sharpness, copy the **1448×1086 approved concept** to `art/title/approved_title_original.png`. The game automatically prefers that high-resolution file over the compressed fallback, and resizes it once to the native 1200×900 viewport with Lanczos. Import it in Godot if prompted. To distribute the full-quality artwork to other computers, commit that original PNG to this branch. Invisible native Godot hitboxes over the printed options support keyboard and mouse selection, while a small focus diamond provides navigation feedback. Submenus switch to the clean God-and-Adam beach plate (`art/title/beach_title_plate.png`) with live unboxed controls, so the baked-in title lettering never shows through. The earlier constructed SVG wordmark (`art/title/bible_logo.svg`) is retained as unused concept history. Actual character animation, environmental motion, and full chapter gameplay remain future work. The previous animatic script is retained in the repository but is not loaded by the title scene. The Google Doc **The Bible: Sort Of Game Scripting** governs the story, with the current outline reflected in `docs/game-script.md`.

The previous theater/Burning Bush prototype remains in Git history. The current main scene is `scenes/title/title_screen.tscn`.

## Visual checks

The Godot CI workflow captures the title screen, new-game slots, prologue placeholder, load slots, chapter selection, options, and a return to title. It also tests navigation through New Game, Continue, Load, Chapters, Options and Back without requiring an interactive desktop.
