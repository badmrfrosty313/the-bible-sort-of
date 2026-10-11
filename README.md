# The Bible Sort Of

A satirical narrative/adventure game. The old theater/burning-bush vertical slice
is archived reference material; it does not define the new game's structure.
The current playable content is a clearly labeled development room, not the
first biblical episode.

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
They exercise keyboard and controller UI input, all fixture dialogue lines,
checkpoint saving, return to title, Continue in a new process, confirmation
before replacing a save, corrupt/unsupported save recovery, layout bounds, and
Quit. Visual checks produce five 480x270 captures and one 1440x810 capture in
ignored `ci_artifacts/`. These are inspection artifacts, not golden-image
regression comparisons. CI runs the same script and rejects engine errors.

## Startup and controls

`app/boot.tscn` mounts the title screen. New Game creates a single local save and
loads the first episode from the catalog. The development room's **Read exchange**
button plays three shared dialogue lines. Finishing saves checkpoint 1; returning
to title and choosing Continue restores that checkpoint and the room offers
**Read again**. New Game asks before replacing an existing save. Continue is
disabled without compatible progress; damaged saves display a recovery message.

- Arrows / controller D-pad or left stick: navigate menus.
- Enter / Space / controller A: activate the focused button or advance dialogue.
- Escape / controller B: return from the development room; active dialogue must
  finish first. Mouse clicks work on all buttons.
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
| `episodes/development/` | Test episode and its own dialogue data/behavior |
| `narrative/` | Shared typed dialogue-line resources |
| `ui/title/` | Title menu and optional final title-art slot |
| `ui/dialogue/` | Reusable player-paced dialogue sequence UI |
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
   `GameState.set_checkpoint()`. Check save results and display failures.

Definitions use paths rather than preloading every episode into the title screen.
The shell validates and instantiates content before replacing the current screen.
For dialogue, instance `ui/dialogue/dialogue_box.tscn`, provide an
`Array[DialogueLine]`, call `start(lines)`, and connect or await `finished`.
Scene-local scripts can sequence dialogue with Godot signals, timers and
AnimationPlayer; no bespoke cutscene language is needed yet. The current dialogue
box is sized for short exchanges. Long prose should be authored as multiple lines
until pagination is implemented.

## Presentation and art

The existing 480x270 viewport, 1440x810 window override, aspect preservation,
integer scaling, and nearest-neighbor canvas filtering remain unchanged. Layouts
use anchors/containers and a shared theme with native-resolution text/buttons.
The title currently uses typeset text; no final logo exists in the source assets.
Set `title_art` on `ui/title/title_screen.tscn` when approved artwork arrives. Its
68-pixel-high slot preserves aspect ratio and replaces only the text title.
The artwork does not dictate the menu layout. Nothing is stretched to fill it.

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

The foundation intentionally has no real first episode, movement controller,
production logo, episode-selection/progression policy, save migrations, or
minigame framework. Controllers are supported for the present menus/dialogue;
future gameplay must define its own actions. Highest-value next work:

1. Choose and script the first real episode, including its playable interactions
   and meaningful checkpoints.
2. Establish approved character/title art and a reusable movement/interact
   controller with keyboard and controller actions.
3. Expand dialogue with choices and pagination, then define episode completion
   and progression/save migration behavior around real story needs.
