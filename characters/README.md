# Reusable characters

Reusable runtime character movement/rendering lives here.

The active Eden slice uses `TopDownActor` to drive the production-candidate
4-direction sheets for Adam, Eve and God. It owns:

- directional facing
- idle/walk animation selection
- 64x64 frame slicing from 4x4 sheets
- nearest-neighbor rendering
- visible fallback behavior when required art fails to load
- reusable player/follower/NPC presentation

Episode choreography still belongs in the episode itself. Eden decides when Adam,
Eve or God exist, who is player-controlled, and when follower/story transitions
occur; the reusable actor layer should not absorb narrative logic.

The old Father controller remains archived under
`archive/prototype/characters/`. Do not promote its theater-specific staging
behavior into the current character runtime.

Source/runtime-safe character art lives in `art/characters/`.
