# Character Sprite Assets

Runtime-safe production-candidate sheets for The Bible: Sort Of.

## Grid

- Sheet size: 256x256
- Frame size: 64x64
- Grid: 4x4
- Rows: down, left, right, up
- Columns: idle, step A, idle, step B

## Active assets

- `art/characters/adam/adam_leaves_walk.png`
- `art/characters/eve/eve_leaves_walk.png`
- `art/characters/god/god_walk.png`

These sheets are now wired into the active Eden runtime through the reusable
character layer in `characters/`.

The import/resource checks verify that each required image loads as visible data
and that all sixteen 64x64 character cells contain visible pixels. Runtime actor
failure should be loud/visible rather than silently making a character disappear.

## Runtime safety rule

Adam and Eve must never render an uncovered/base-body-only state.

Allowed runtime presentation states:

- `PRE_FALL_MODESTY`
- `POST_FALL_CENSOR`
- `LEAVES`

Current Adam/Eve sheets are covered leaf-garment walk cycles and remain the safe
fallback while dedicated pre-Fall modesty and post-Fall censor variants are
produced.

If a presentation state is missing, unknown, loading, or fails resource
validation, default to a covered runtime asset. Never display a base/reference
body sprite for even one frame.

God's current sheet is the revised robe treatment with both shoulders covered.

## Next art work

1. Adam/Eve PRE_FALL_MODESTY sheets using the same exact grid/anchor contract.
2. Adam/Eve POST_FALL_CENSOR sheets using the same exact grid/anchor contract.
3. Animal sprite sheets.
4. Eden environment replacement art.

Do not change the grid contract casually; the runtime animation code and validation
suite intentionally depend on it.
