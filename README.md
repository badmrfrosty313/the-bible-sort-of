# The Bible Sort Of

A satirical narrative/adventure game. The old theater/burning-bush vertical slice
is archived reference material; it does not define the new game's structure.
The playable opening is now **Adam and Eve in Eden**.

## Run and validate

Use **Godot 4.7.2**, matching CI. Open `project.godot` and run the project (F6 runs
only the selected scene; F5 runs the application). From the repository root:

```sh
godot --headless --editor --path . --quit   # import resources first
godot --path .                            # boot -> title -> episode
bash tools/check.sh                       # isolated integration checks
bash tools/check.sh --visual              # also requires xvfb-run + software GL
```

`GODOT_BIN=/absolute/path/to/godot bash tools/check.sh` selects a particular binary.
Tests use temporary XDG user data/settings/cache, leaving player saves alone.
They exercise the approved title, Eden startup, keyboard and controller movement,
collision bounds, interaction detection, the Rock conversation, First Jeff,
Eve/follower switching, the Fall/leaves checkpoint, title return, and Continue
after a fresh process. Visual checks produce representative 480x270 captures in
ignored `ci_artifacts/`. These are inspection artifacts, not golden-image
regression comparisons. CI runs the same script and rejects engine errors.

## Startup and controls

`app/boot.tscn` mounts the approved illustrated beach title. The title uses a
high-resolution 1440x810 16:9 presentation, then gameplay returns to the normal
480x270 logical viewport. New Game
creates a single local save and begins Adam's introduction, then releases the
player into Eden. Continue restores the latest coherent Eden milestone. New Game
asks before replacing existing progress; damaged saves display a recovery message.

- WASD / arrows / controller D-pad or left stick: move in Eden and navigate menus.
- Enter / Space / controller A: activate the focused button, interact, or advance dialogue.
- E: interact in Eden. I: open the leaves inventory after the Fall.
- Escape / controller B: return to title when a dialogue interaction is not active.
- Quit closes the application.

The save is `user://progress.json` (Godot's per-application user data folder).
It stores a schema version, stable episode ID, checkpoint, and JSON-compatible
flags. Writes use a temporary file and rename so a failed write keeps the previous
save. Checkpoint writes restore in-memory state on failure. Future schema changes
need explicit migrations; incompatible versions are currently rejected safely.

## Structure

| Path | Responsibility |
| --- | --- |
| `app/` | Boot scene and screen routing; no episode choreography |
| `state/` | `GameState` autoload, validated progress and save I/O |
| `episodes/` | Episode definition resource, catalog and content folders |
| `episodes/eden/` | Adam and Eve episode, its milestones and choreography |
| `gameplay/` | Reusable interactable discovery and interaction support |
| `narrative/` | Shared typed dialogue-line resources |
| `ui/title/` | Approved beach title art and live accessible controls |
| `ui/dialogue/` | Reusable player-paced dialogue and choice UI |
| `ui/achievement/` | Lightweight in-game event notifications |
| `ui/shared/` | Common UI theme |
| `characters/` | Home for future reusable characters; currently documentation |
| `art/` | Preserved character and episode source art |
| `archive/prototype/` | Obsolete theater, Father experiments, burning bush and capture helper |
| `ci/`, `tools/check.sh` | Executable foundation validation and UI captures |
| `tools/art-drop.ps1`, `DROP_ART_HERE.bat` | Existing Windows art intake utility |

The Windows art helper commits and pushes by default. Use `-NoPush` to commit
locally; import art deliberately rather than invoking it as part of setup.

## Add an episode

1. Create `episodes/<story>/` with its scene, script and episode-specific content.
2. Create an `EpisodeDefinition` `.tres` with a stable unique `id`, a display `title`,
   `scene_path`, and the largest checkpoint the scene knows how to restore.
3. Register the definition path in `EpisodeCatalog.DEFINITIONS`. To change the
   opening episode, update `FIRST_EPISODE`.
4. The episode root exposes `signal return_to_title_requested`. The shell connects
   it; the episode emits it rather than reaching into the shell. Restore content
   from `GameState.checkpoint` and save meaningful milestones with
   `GameState.commit_progress()` so a checkpoint and its flags are written together.

Definitions use paths rather than preloading every episode into the title screen.
The shell validates and instantiates content before replacing the current screen.
For dialogue, instance `ui/dialogue/dialogue_box.tscn`, provide an
`Array[DialogueLine]`, call `start(lines)`, and connect or await `finished`.
Use `ask(speaker, text, options)` for a small player choice and subscribe to
`choice_selected`; it is intentionally not a general-purpose scripting language.
Scene-local scripts can sequence dialogue with Godot signals, timers and
AnimationPlayer; no bespoke cutscene language is needed yet. The current dialogue
box is sized for short exchanges. Long prose should be authored as multiple lines
until pagination is implemented.

## Presentation and art

Gameplay keeps the existing 480x270 viewport, 1440x810 window override, aspect
preservation, integer scaling, and nearest-neighbor canvas filtering. The title
uses the 16:9 `gods_beach_day_adams_tumble.png` artwork at a high-resolution
1440x810 logical presentation before Boot restores gameplay mode. Eden uses
deliberate simple draw-time placeholders for its map, animals, and animation-ready
actors; they are not final production sprites. `art/title/` contains the approved
title source artwork.

## Prototype decisions and remaining work

History documents many Father artwork/controller iterations followed by theater
staging refinements. The theater director combines procedural drawing, character
routing and dialogue; burning-bush content calls directly back into that director.
Those are useful references but unsuitable as application infrastructure. They
are relocated together and retain working resource paths, with `Prototype` class
names to avoid claiming the new reusable character namespace. Source art and the
sprite cleanup techniques are preserved. The orphan UID of the deleted original
Father controller was removed. No new runtime scene references the prototype.
See `archive/prototype/README.md` for explicitly running it.

Eden currently covers the authored material from Adam's basic-language joke
through Adam using leaves after the Fall. The serpent's finished dialogue and the
exile/consequence sequence remain intentionally unwritten in `docs/game-script.md`;
the game stops at a clear prototype boundary instead of inventing canon.

The large Rock conversation includes small prototype connective lines beyond the
authored "That's a rock, Adam" punchline. Animal names, First Jeff, Eve's cow
line, Adam's "pretty lady" reason, and the leaves gag follow the authored script.

Highest-value next work:

1. Replace Eden's deliberate placeholder actors/map with approved animation-ready art.
2. Author the missing serpent dialogue and the next canonical story beat before extending exile.
3. Add the script's Load / chapter-selection / options features if multi-slot saves are approved.
