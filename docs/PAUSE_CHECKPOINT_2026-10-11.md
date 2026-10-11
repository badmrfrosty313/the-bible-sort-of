# Pause Checkpoint — 2026-10-11

## Status

Session paused because the current Codex five-hour usage window was exhausted.
This is **not** a project blocker and the project is not abandoned or frozen.

Active branch:

```text
codex/foundation-rebuild
```

Latest implementation head before documentation updates:

```text
73198abbcd041342d8408941dacfe9c9ae42a7cc
```

The playable Eden slice is materially healthier than it was at the start of the
session. The title renders correctly from the approved source artwork, Adam/God
are visible in Eden, directional character sprites are active, the complete Rock
conversation is implemented, the authored naming/Eve beats are aligned, and save
recovery/title state have been hardened.

## What changed this session

### Title / resource repair

Commit:

```text
b6d1218ba5150ece1e6594050de656366c408cb6
Repair clean title loading and extract the live selector from original art
```

The title no longer depends on a fragile pre-generated clean PNG. Runtime now uses
the approved original:

```text
art/title/gods_beach_day_adams_tumble.png
```

The baked NEW GAME selector is patched in memory and its appearance is reused for
the one live selector. Menu hitboxes and selector placement share the source
1672x941 coordinate system.

### Eden actor visibility / animation

Commit:

```text
913a12dcc91de3e930f2a8df51c8633dd6dd5052
Keep Eden actors visible and covered with directional follower movement
```

Adam, Eve and God use the production-candidate 4x4 character sheets.

Adam/Eve coverage rule remains hard:

- never render an uncovered/base-body-only state
- missing presentation state falls back to the covered leaves asset
- no one-frame uncovered flash during switching/loading/checkpoint restore

God uses the robe sheet with both shoulders covered.

Adam follower movement was improved to use directional movement instead of an
idle-only positional lerp.

### Rendering/resource regression tests

Commit:

```text
109d756a6d354beabf81feae2a43a5126f3b193b
Validate clean imported art and actual rendered actor pixels
```

The test suite now validates actual imported image content and actor frames rather
than merely checking node existence. A clean-import path is available through:

```sh
bash tools/check.sh --clean
```

The high-effort repair pass also established usable virtual-display capture in its
cloud environment and visually inspected rendered title/Eden screenshots.

### Full Rock conversation

Commit:

```text
d6bc886bf39f7fc079870a0aa20b0ab20f4b2a00
Implement the complete authored Rock conversation with persistent branches and callbacks
```

The previous tiny placeholder Rock interaction was replaced with the authored
conversation from:

```text
docs/dialogue/rock/01-opening.md
docs/dialogue/rock/02-middle.md
docs/dialogue/rock/03-payoff.md
```

Persistent branches/callbacks are implemented, including the central
"That's a rock, Adam." payoff and post-conversation state.

### Eden script alignment

Commit:

```text
2efa2f0d7372d1f00b0b4d98ea77f64176bf9577
Align Eden exploration, naming and Eve creation with the authored script
```

The playable content was brought back toward the narrative source of truth:

- authored Adam/Eden progression
- Rock-aware interaction state
- authored animal naming choices
- FIRST JEFF
- Eve creation
- Eve control
- Adam follower state

The user locally reached **FIRST JEFF COMPLETE • TALK TO GOD** with both Adam and
God visibly rendered, confirming that the character pipeline is now functioning
in a real local run.

### Save/title recovery hardening

Commit:

```text
73198abbcd041342d8408941dacfe9c9ae42a7cc
Preserve incompatible saves and harden title recovery, settings and progress display
```

Incompatible/damaged saves are handled without silently destroying them or
stranding the title flow. Load/progress/options behavior was hardened.

## Current visual state

Functional, but still intentionally prototype-heavy.

Working:

- approved illustrated 16:9 title
- one live title selector
- Adam sprite
- God sprite
- Eve sprite pipeline
- directional walk/idle framework
- story-state UI
- Rock dialogue
- naming progression
- First Jeff
- Eve creation/control
- save/title recovery

Still placeholder / polish-needed:

- Eden map/background
- trees
- animal sprites
- Rock visual
- labels/anchors
- some staging and dialogue-box composition
- dedicated pre-Fall modesty art
- dedicated post-Fall censor art

## Narrative boundary

The live Google Doc **The Bible: Sort Of Game Scripting** remains the narrative
source of truth.

The currently authored Adam-and-Eve material stops after the leaves interaction.

Do **not** invent finished exile/consequence content until it is written.

The full serpent dialogue is also still intentionally unwritten.

## Next starting point

Do not start by rebuilding architecture.

Start with a fresh local pull/import/playtest of the current branch and inspect:

1. title selector alignment across all five entries
2. Adam/God scale and sprite anchors
3. name-label placement
4. full Rock branch behavior
5. naming choices / First Jeff
6. Eve creation and follower movement
7. save/Continue after restart

After those are visually sound, the next major production pass should be:

1. animal sprite sheets
2. Eden environment art
3. Adam/Eve PRE_FALL_MODESTY sheets
4. Adam/Eve POST_FALL_CENSOR sheets
5. staging/UI polish
6. author serpent dialogue before expanding the story

## Useful local commands

From the repository root:

```powershell
& "C:\Users\Badmrfrosty313\Desktop\Godot.exe" --headless --editor --path . --quit
& "C:\Users\Badmrfrosty313\Desktop\Godot.exe" --path .
```

Repository-agnostic equivalents:

```sh
godot --headless --editor --path . --quit
godot --path .
bash tools/check.sh --clean
```

## Resume rule

The next session should treat this checkpoint plus the active branch as canonical
implementation state. Do not resurrect the old theater/burning-bush prototype as
application architecture. The theater remains a future story/staging location.
