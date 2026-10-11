# The Bible Sort Of

A satirical narrative/adventure game. The old theater/burning-bush vertical slice
is archived reference material; it does not define the new game's structure.
The playable opening is now **Adam and Eve in Eden**.

## Run and validate

Use **Godot 4.7.2**, matching CI. Open `project.godot` and run the project (F6 runs
only the selected scene; F5 runs the application). From the repository root:

```sh
godot --headless --editor --path . --quit   # import resources first
godot --path .                              # boot -> title -> episode
bash tools/check.sh                         # integration/resource checks
bash tools/check.sh --clean                 # delete .godot, reimport, then validate
bash tools/check.sh --visual                # rendered captures; requires xvfb-run + software GL
```

`GODOT_BIN=/absolute/path/to/godot bash tools/check.sh` selects a particular binary.
Tests use temporary XDG user data/settings/cache, leaving player saves alone.

The validation suite now checks more than node existence. It verifies that required
title/character PNGs import as visible images, all 4x4 actor frames contain visible
pixels, title routing works, Adam and God render in Eden, dialogue/progression works,
save/restart behavior survives a fresh process, and title/quit recovery remains usable.
Visual mode captures representative title and Eden states into ignored
`ci_artifacts/`.

## Startup and controls

`app/boot.tscn` mounts the approved illustrated beach title. The title uses a
high-resolution 1440x810 16:9 presentation, then gameplay returns to the normal
480x270 logical viewport.

The title loads the approved original
`art/title/gods_beach_day_adams_tumble.png`, patches the baked NEW GAME selector
in memory, and reuses that selector as the single live focus marker. Hitboxes and
selector placement share the original 1672x941 source-coordinate system.

New Game creates a single local save and begins Adam's introduction, then releases
the player into Eden. Continue restores the latest coherent Eden milestone. New Game
asks before replacing existing progress; incompatible or damaged saves are preserved
and surfaced with a recovery path instead of silently trapping the player.

- WASD / arrows / controller D-pad or left stick: move in Eden and navigate menus.
- Enter / Space / controller A: activate the focused button, interact, or advance dialogue.
- E: interact in Eden. I: open the leaves inventory after the Fall.
- Escape / controller B: back out of submenus or return to title when appropriate.
- Root title Escape / B: quit confirmation.

The save is `user://progress.json` (Godot's per-application user data folder).
It stores a schema version, stable episode ID, checkpoint, and JSON-compatible
flags. Writes use a temporary file and rename so a failed write keeps the previous
save. Future schema changes need explicit migrations.

## Current playable slice

The active branch now implements the authored Eden material through the leaves
prototype boundary:

1. Adam's basic-language introduction and exploration release.
2. Free-roam Eden interactions.
3. The full authored Rock conversation with persistent branches and callbacks.
4. Authored animal naming choices, including **FIRST JEFF**.
5. Eve creation and control switch.
6. Adam following Eve with directional movement/animation.
7. Serpent/Fall placeholder transition using safe covered fallback art.
8. Leaves interaction and current prototype stop.
9. Continue/load/chapter-selection/options/title recovery around the episode.

The serpent's finished dialogue and the exile/consequence sequence remain
intentionally unwritten. Do not invent them as canon until the narrative source is
extended.

## Character presentation

Adam, Eve, and God now render through reusable 4-direction 4x4 sprite sheets in
`art/characters/`.

- 256x256 sheet
- 64x64 cells
- rows: down, left, right, up
- columns: idle, step A, idle, step B
- nearest-neighbor filtering

Adam and Eve must never render an uncovered/base-body-only state. Current safe
runtime fallback is the leaf-covered sheet. Future presentation states are:

- `PRE_FALL_MODESTY`
- `POST_FALL_CENSOR`
- `LEAVES`

If a future state is missing or fails to load, the runtime must fall back to a
covered asset rather than disappearing or exposing a base sprite.

## Structure

| Path | Responsibility |
| --- | --- |
| `app/` | Boot scene and screen routing; no episode choreography |
| `state/` | `GameState` autoload, validated progress and save I/O |
| `episodes/` | Episode definition resource, catalog and content folders |
| `episodes/eden/` | Adam and Eve episode, milestones and choreography |
| `gameplay/` | Reusable interactable discovery and interaction support |
| `narrative/` | Shared typed dialogue-line resources |
| `characters/` | Reusable directional actor rendering and movement |
| `ui/title/` | Approved beach title art and live accessible controls |
| `ui/dialogue/` | Reusable player-paced dialogue and choice UI |
| `ui/achievement/` | Lightweight in-game event notifications |
| `ui/shared/` | Common UI theme |
| `art/` | Character and title source art |
| `docs/` | Canonical repo script mirror, detailed dialogue and pause checkpoints |
| `archive/prototype/` | Obsolete theater, Father experiments and burning-bush prototype |
| `ci/`, `tools/check.sh` | Resource, content, save, foundation and rendered validation |
| `tools/art-drop.ps1`, `DROP_ART_HERE.bat` | Existing Windows art intake utility |

The Windows art helper commits and pushes by default. Use `-NoPush` to commit
locally; import art deliberately rather than invoking it as part of setup.

## Narrative authority

The live Google Doc **The Bible: Sort Of Game Scripting** is the narrative source
of truth. `docs/game-script.md` is the repo mirror of the broader script, while
large implementation-ready branches such as the Rock conversation also live under
`docs/dialogue/`.

Implementation may prototype mechanics and staging, but unscripted material should
not silently become canon.

## Highest-value next work

1. Replace Eden animal/environment placeholders with approved production art.
2. Produce dedicated Adam/Eve `PRE_FALL_MODESTY` and `POST_FALL_CENSOR` sheets,
   keeping the covered-runtime safety rule.
3. Polish character anchors, labels, staging and dialogue presentation against real
   local play captures.
4. Author the missing serpent dialogue before extending the Fall/exile story.
5. Continue the theater presentation layer only as a story/staging location, not as
   application infrastructure.

## Session checkpoint

The detailed stop point for the October 11, 2026 build sprint is recorded in
`docs/PAUSE_CHECKPOINT_2026-10-11.md`.
