# The Bible: Sort Of — Game Script

Narrative source of truth: **The Bible: Sort Of Game Scripting** (Google Doc, synced October 8, 2026).

This repository copy exists so implementation work can proceed without inventing story beats. The Google Doc wins if the two ever disagree.

## Opening Screen

- God sits on a beach post-creation, drinking from a **World's Greatest Creator** mug and enjoying His day of rest.
- Palm trees behind Him, waves crashing in.
- After a few seconds Adam falls from a tree and gets caught by vines on the way down.
- God rolls His eyes: **"I guess my break is over."**
- Title screen:
  - The Bible: Sort Of logo
  - New Game
  - Continue — resumes the last game played
  - Load — three save slots
  - Chapter Selection
  - Options

> Current production decision: the title screen is static for now. The authored Adam-fall intro remains a later animation pass.

---

# Adam and Eve's Story

## Creation / Adam introduction

- Initial cutscenes show the creation story.
- God goes to speak to Adam, who has existed for roughly five minutes and is, currently, a bit of a dumbass.
- God attempts to speak with him. Adam cannot figure much of anything out.
- Cut to five hours later:
  - God asks what Adam has learned.
  - Adam proudly answers: **"Adam."**
  - God shakes His head.
  - Montage of God teaching Adam basic words.

## Free-roam Eden

- Player can free roam the Garden before the animal-naming quest.
- Eden should be a reasonable-sized square map with clear natural boundaries, broadly top-down like a Pokémon overworld with better sprites.
- Animals are inside the playable garden boundary.
- Talking to animals makes them respond with animal noises.

### The Rock

A very obvious rock is interactable.

If Adam talks to it, open a ridiculously large dialogue tree where Adam tells the rock everything he thinks and knows about his extremely short existence.

If the player keeps going long enough, God finally interrupts:

> **God:** "That's a rock, Adam."

Adam smiles and nods.

## Animal Naming Quest

Gameplay section.

Adam attempts to name animals. His available names are mostly nonsense, increasingly exasperating God.

Use a group of roughly five animals, each with selectable name choices.

### Eagle

When Adam reaches the eagle, **every choice is Jeff**.

God gives in:

> **God:** "You know what? That's Jeff."

**Achievement: First Jeff**

## Creation of Eve

God realizes Adam needs help.

- God picks up a log.
- Screen cuts to black.
- When the image returns Adam is very clearly unconscious.
- God looks directly toward the player and states very seriously:

> **God:** "And I PUT HIM TO SLEEP."

God takes Adam's rib and creates the woman who will be Eve.

He immediately tests her by showing her a cow.

> **God:** "What is this?"
>
> **Eve:** "That's a cow."

God responds that He likes this one, then turns toward unconscious Adam and shakes His head.

End scene.

## Eve gameplay

The next day:

- Adam wakes up and sees Eve.
- Player now controls Eve.
- Adam follows her around.
- Eve properly names the animals.

God sees Eve doing well and Adam occupied, so He goes back to the theater.

## Serpent / Fall

Eve eventually meets the serpent, who tempts her to eat the fruit.

Adam eats it because the pretty lady told him to.

Before eating the fruit, both characters' nude regions use a blurred visual treatment.

After eating:
- the blur gradually becomes black censorship boxes,
- Eve notices and covers herself with leaves,
- control later returns to Adam.

While controlling Adam, the player can open inventory, select leaves, and cover him.

If the player refuses and simply leaves Adam standing there, God is outside the story in the theater and continues making comments until the player finally clothes Adam. The joke should feel like God talking partly to the player rather than only to Adam.

---

# Noah's Story

Gameplay note from source:

> Matching game. Something something. Figure it the fuck out.

Still open for design.

---

# Tower of Babel

- Tetris-esque construction game.
- Starts easy, allowing the tower to get uncomfortably close.
- A button appears on God's desk.
- Pressing it makes the game extremely difficult.
- Commands cease being understandable to the other characters.
- Chaos follows.
- Everyone gives up and separates.

---

# Jonah and the Whale

- Dungeon-crawler platformer.

---

# DLC — New Testament

## Gospels

When Jesus prays to the Father, He uses an earpiece to communicate with the Father.

Establish this device throughout gameplay so the later payoff is already understood.

### Crucifixion payoff

At **"Father, Father, why have you forsaken me?"**

- the established earpiece makes clear that the Father can still hear Him,
- Father is visible at the control desk,
- Father's posture shows visible distress.

Exact staging beyond this beat remains unwritten.

---

# God in the Theater — Basic Behavior

When God is not physically in the field of play, He returns to the theater.

He exits the playable scene and re-enters the theater through the stage door on whichever side matches the direction needed for His next entrance or exit.

---

# Implementation Guardrails

- **Story source:** Google Doc is authoritative.
- **Do not silently invent finished dialogue** for unscripted beats.
- New jokes, mechanics, staging, map layout, and interaction ideas are welcome during prototyping, but should be clearly treated as implementation/design additions until accepted.
- Title screen is currently static even though the eventual authored opening includes Adam's fall and God's punchline.
- First gameplay vertical slice should prioritize:
  1. Eden free roam
  2. animal interaction noises
  3. Rock conversation
  4. animal naming quest
  5. First Jeff achievement
