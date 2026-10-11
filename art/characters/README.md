# Character Sprite Assets

Runtime-safe candidate sheets for The Bible: Sort Of.

## Grid
- Sheet size: 256x256
- Frame size: 64x64
- Grid: 4x4
- Rows: down, left, right, up
- Columns: idle, step A, idle, step B

## Assets
- `art/characters/adam/adam_leaves_walk.png`
- `art/characters/eve/eve_leaves_walk.png`
- `art/characters/god/god_walk.png`

## Runtime safety rule
Adam and Eve must never render an uncovered/base-body-only state.

Allowed runtime presentation states:
- PRE_FALL_MODESTY
- POST_FALL_CENSOR
- LEAVES

Current Adam/Eve candidate sheets are covered leaf-garment walk cycles and are safe fallbacks while dedicated pre-Fall modesty and post-Fall censor variants are produced.

If a presentation state is missing, unknown, or loading, default to a covered runtime asset. Never display a base/reference body sprite for even one frame.

God's current sheet is the revised robe treatment with both shoulders covered.
