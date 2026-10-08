# Visual direction — Burning Bush theater

This is the target for the first playable vertical slice. The concept image at `docs/concepts/burning-bush-theater-v1.png` establishes composition, mood, and relative scale. It is **reference art**, not a game texture: the 1672 × 941 image is a single flattened frame and would duplicate the existing Father and Moses if dropped into the scene.

## What the current prototype does

- Godot boots into a 480 × 270 theater scene. Father walks to the chair and the Burning Bush episode begins automatically.
- The episode has Moses's objections, Father responses, the repeated “ACCEPT QUEST? NO” gag, Aaron, and a quest accepted ending.
- Theater, desk, chair, and curtains are drawn in `scenes/theater/theater.gd` with polygons. The episode mixes SVG desert, bush, flames, and Moses with a generated PNG walk sheet for Father.
- The scene is a timed sequence; the labeled console has no input yet. CI verifies startup and captures snapshots, but cannot judge whether the scene looks coherent or feels playable.

## Target image grammar

- The theater is a persistent outer world. The stage opening is a hard spatial boundary. Father watches from the foreground; Moses and the bush exist inside the screen.
- One consistent authored pixel grid at the 480 × 270 logical resolution. Silhouettes and expressions must survive at that size. The concept is a composition guide; redraw deliberately for the target resolution.
- Burgundy velvet and dark wood frame the warm desert. Fire is the strongest light source onstage and lights Moses, sand, and nearby rock. Console lights provide a quieter foreground accent.
- Use separate layers so characters, flames, curtains, and Father's reactions can move independently.

## Production asset breakdown

| Plane | Asset | Runtime role |
| --- | --- | --- |
| Theater back | Auditorium and proscenium, transparent stage opening | Persistent frame behind the episode |
| Stage back | Desert cliffs, horizon, ground | Episode background with subtle parallax |
| Stage actors | Moses idle, recoil, shrug, and later walking frames | Expressive animation and dialogue |
| Stage effect | Bush body, flame frames, glow, embers | Fire can respond to Father's speech |
| Theater actor | Father from behind seated, standing, walking, reacting | Moves between desk and stage |
| Theater front | Curtain edges, desk, chair edge, practical lights | Foreground occlusion and input affordance |

## First implementation pass

1. Rebuild the theater frame as back and foreground assets, retaining the existing stage bounds and movement anchors.
2. Replace the Burning Bush SVG stack with separate art at consistent scale. Keep the current dialogue and timing while checking occlusion and readability.
3. Replace the Father placeholder frames with a matching small sprite set. Keep his seated silhouette readable from behind.
4. Add one actual console choice after the presentation works: wait or intervene during Moses's final objection. Moses still makes the decision; the choice changes the Father's reaction and staging.
5. Capture the opening, an objection, and the ending at native resolution in CI, then review visually. A passing smoke test alone is insufficient for art approval.

The reusable theater and episode boundaries matter more than matching every decorative detail in the concept image. This first scene should prove the production pipeline for later episodes.
