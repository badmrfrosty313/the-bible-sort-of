# Project Pause Checkpoint — October 8, 2026

> **Status:** Paused intentionally while a dedicated sprite-animation tool is built.
>
> **Resume point:** Do not continue expanding story content first. Resume by replacing the current placeholder character art with the approved sprite pipeline, beginning with God.

## Why the project is paused

The gameplay prototype has advanced far enough that character animation is now the main production bottleneck.

The current temporary sprites are too toy-like / chibi for the intended look. The target has shifted toward a **Final Fantasy-remake-inspired 2D RPG sprite language**:

- stylized rather than realistic,
- adult proportions rather than Little Tikes / toddler proportions,
- expressive faces and silhouettes,
- readable at gameplay scale,
- detailed enough to feel premium,
- suitable for multi-frame movement,
- consistent character identity across every animation frame.

Image generation was useful for finding the visual direction, but it was not reliable enough for consistent walk cycles. The next tool project exists specifically to solve that problem.

## Sprite pipeline goal before resuming

Build a small dedicated sprite animator / rigging tool with one immediate success condition:

1. Import the approved God sprite.
2. Preserve the exact character identity across frames.
3. Create a real side-view walk cycle with alternating legs and proper stride phases.
4. Preview the character actually traveling across the screen.
5. Export transparent frames / sprite sheet.
6. Export cleanly into Godot.
7. Replace the current placeholder God art in this project.

Only after that pipeline works should Adam, Eve, serpent, animals, and later characters receive final sprite passes.

## Current visual direction

### God

God is the first canonical character to lock.

Current target:

- elderly but energetic,
- long white hair and full white beard,
- cream / white robe with gold trim,
- warm, expressive face,
- fantasy-JRPG readability,
- proportions closer to classic / remake-era Final Fantasy overworld characters,
- **not** super-deformed toddler proportions,
- movement should feel deliberate and readable, not shuffle in place.

The successful walk reference uses visible **contact → down → passing → up → opposite contact** phases. One leg must clearly pass the other. Robe, hair, and beard can provide secondary motion after the body mechanics read correctly.

### Title screen

Approved title composition is locked.

- Full-resolution approved artwork: `art/title/approved_title_original.png`
- Fallback: `art/title/approved_title.webp`
- Native viewport: **1200×900 (4:3)**
- Menu entries are baked into the artwork with invisible live Godot hitboxes over them.
- Do not return to the hand-built SVG logo approach.
- The static title screen is intentional for now; the authored Adam-falling intro remains a later animation pass.

## Current playable implementation

The working vertical slice currently includes:

- static approved title screen,
- New Game / Continue / Load,
- three local save slots,
- Chapter Selection,
- Options,
- playable Eden free roam,
- animal interaction noises,
- the long Rock interaction ending with **“That’s a rock, Adam.”**,
- five-animal naming quest,
- eagle choices all resolving to **Jeff**,
- **Achievement: First Jeff**,
- optional Eve-creation sequence,
- **“And I PUT HIM TO SLEEP.”** gag,
- Eve-controlled follow-up naming section,
- Adam following Eve,
- serpent reveal,
- prototype Fall sequence,
- blur-to-black-box modesty gag,
- leaves inventory interaction,
- God commenting from the theater until Adam covers himself,
- save/load support for the Eden vertical-slice state.

## Intentional story stopping point

The Google Doc **The Bible: Sort Of Game Scripting** remains the narrative source of truth:

https://docs.google.com/document/d/1_MmIf1EctZjJ9sY52Uo4fxGNLpk2AS06WW0-h0qbh18/edit

The repository mirror is `docs/game-script.md`.

The implemented prototype stops after Adam uses the leaves because the next exile / consequence sequence is not yet scripted in enough detail to treat as canonical.

Do **not** silently invent final dialogue or story canon beyond the authored source. Gameplay experiments, staging ideas, jokes, and temporary mechanics are fine as prototypes, but they should remain clearly marked as such until accepted.

## Next story beats already recorded for later

After the sprite pipeline is stable, return to the Google Doc before extending the story.

Already recorded future sections include:

- Noah — matching-game concept still unresolved,
- Tower of Babel — Tetris-like tower construction followed by language-chaos difficulty,
- Jonah and the Whale — dungeon-crawler / platformer concept,
- New Testament DLC concepts,
- God returning to the theater through the stage door when outside the field of play.

## Resume checklist

When returning to this repository:

1. Pull `visual-direction-reboot`.
2. Read this checkpoint.
3. Read `docs/game-script.md`.
4. Check the Google Doc for newer scripting.
5. Import the finished God sprite/walk assets from the sprite animator project.
6. Replace the placeholder God sprite and validate movement in-engine.
7. Establish the same sprite spec for Adam and Eve.
8. Only then continue polishing / expanding Eden.
9. Do not redesign the approved title screen unless an actual rendering bug appears.

## Git / production state at pause

- Working branch: `visual-direction-reboot`
- Draft PR: **#2 — Approved title screen + playable Eden story vertical slice**
- Main remains intentionally untouched.
- This checkpoint was created specifically so the project can be resumed without reconstructing context from chat history.

## Definition of “ready to resume”

The Bible project comes off pause when the sprite-animation project can take the canonical God design and produce a clean, repeatable, Godot-ready walk cycle that preserves:

- character identity,
- proportions,
- palette,
- baseline,
- stride mechanics,
- transparent background,
- frame alignment.

That tool is the dependency. Once it works, return here and continue production.
