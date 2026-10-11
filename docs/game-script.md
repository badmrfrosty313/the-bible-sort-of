# The Bible: Sort Of — Game Scripting

> Synced from the Google Doc **The Bible: Sort Of Game Scripting** on October 11, 2026.
> This file is a repository mirror for implementation work. The Google Doc remains the narrative source of truth.

## Opening Screen

God sits on a beach after Creation, drinking from a **World's Greatest Creator** mug and enjoying His day of rest. Palm trees behind Him, waves rolling in.

### Opening Scene Script

Soft surf.

Fade in on an absurdly peaceful beach.

God is sitting in a chair facing the water, sandals kicked off, robe sleeves rolled slightly, holding the mug.

God takes a drink.

Long pause.

Another wave rolls in.

**God:** "This is nice."

He takes another drink.

**God:** "I should do absolutely nothing more often."

A rustling noise comes from somewhere behind Him.

God freezes and looks over one shoulder.

Silence.

He turns back toward the ocean.

Another rustle.

**God:** "No."

A much louder series of snapping branches.

God slowly closes His eyes.

**God:** "Please no."

Adam drops violently out of a tree behind Him and gets caught upside-down in a mess of vines a few feet above the ground.

Silence.

Adam swings gently.

God does not turn around.

**Adam:** "...Adam."

God opens His eyes, slowly looks toward the player, takes one final drink from the mug, and sets it down.

**God:** "I guess my break is over."

Cut to title:

# **THE BIBLE: SORT OF**
- Screen shows:
  - The Bible: Sort Of logo
  - New Game
  - Continue
    - Continues from the last game played.
  - Load
    - 3 save slots
  - Chapter Selection
  - Options

## Adam and Eve's Story

- Initial cut scenes showing the creation story.
- God goes to speak to Adam who, being born 5 minutes ago, is a bit of a dumb ass.
### Adam Introduction Script

Fade in.

Adam is standing in Eden.

God stands across from him.

Adam is staring intensely at his own hand.

God waits.

Adam rotates his hand, then opens and closes his fingers.

**God:** "Adam."

Adam looks up.

**Adam:** "Adam."

**God:** "Yes. You're Adam."

Adam smiles proudly.

**Adam:** "Adam."

**God:** "Right."

God points to Himself.

**God:** "God."

Adam studies Him.

**Adam:** "Adam."

God pauses.

**God:** "No, you're Adam."

God points to Adam.

**God:** "Adam."

God points to Himself.

**God:** "God."

Adam thinks very hard, then points at God.

**Adam:** "Adam?"

God looks away for a moment.

**God:** "We have time."

Cut to black.

### FIVE HOURS LATER

Fade back in.

God looks considerably less rested.

Adam is sitting happily on the ground.

**God:** "Okay."

God crouches in front of him.

**God:** "Tell me something you've learned."

Adam thinks very hard.

God waits.

Adam suddenly lights up.

**Adam:** "Adam!"

Long silence.

God stares at him.

Adam beams.

**God:** "Fantastic."

Beat.

**God:** "Five hours."

Adam gives Him a thumbs-up despite nobody having taught him what a thumbs-up is.

God looks directly at the player.

**God:** "I made that."

### Teaching Montage

Quick cuts:

God holds up a rock.

**God:** "Rock."

**Adam:** "Adam."

God holds up an apple.

**God:** "Apple."

**Adam:** "Rock."

God points at a tree.

**God:** "Tree."

**Adam:** "Apple."

God points to Himself.

**God:** "God."

Adam pauses.

**Adam:** "...God."

God's eyes widen.

**God:** "YES."

Adam immediately points at the tree.

**Adam:** "God."

God's shoulders drop.

Cut.

God is drawing simple pictures in the dirt.

Adam is eating the stick.

Cut.

God demonstrates walking around a rock.

Adam walks directly into it.

Cut.

God points toward several animals in the distance.

**God:** "You know what?"

Adam looks at Him.

**God:** "Go explore."

Adam smiles.

**Adam:** "Adam."

**God:** "Sure."

Control passes to the player.

### Free-roam Garden

- Ability to free roam the Garden area before the naming quest.
- Reasonable size map.
- Make it so Adam can try to talk to animals and they just make noises at him.
- Eden should be set up as a square to keep boundaries with the animals inside.
- Almost like a top-down view like a Pokémon game with better sprites.

### The Rock

If Adam speaks to the very obvious rock, create a giant dialogue tree where he tells it everything he thinks and knows of his short existence.

After enough, God steps in and says:

> **God:** "That's a rock, Adam."

Adam just smiles and nods.

### Animal Naming Quest

Adam keeps saying random words or phrases, exasperating God.

Use a group of five animals with names available to pick from, but they are all nonsense except the eagle.

When Adam gets to the eagle, all four choices are **Jeff**.

God says:

> **God:** "You know what? That's Jeff."

**Achievement: First Jeff**

This is an actual gameplay section.

### Creation of Eve

God realizes Adam needs help, so he knocks him out.

- God picks up a log.
- Screen goes to black.
- When the image returns, Adam is clearly knocked out.
- God very seriously looks at the screen and says:

> **God:** "And I PUT HIM TO SLEEP."

God takes Adam's rib and creates a woman, who will be named Eve.

He immediately asks her what the name of an animal is. It is a cow.

> **Eve:** "That's a cow."

God states that he likes this one, then turns around, looks at Adam, and shakes his head.

End scene.

### Eve Gameplay

The next day Adam wakes up and sees Eve, who we are playing as at this point, and follows her around as she properly names the animals.

God sees that she is doing good and Adam is occupied, so he goes back to the theater.

She eventually meets the serpent who tempts her to eat the fruit.

Adam eats it because the pretty lady told him to.

### Fall / Modesty Gag

Both characters will have blurred-out nude regions until after eating the apple, as they slowly turn to blacked-out boxes.

Eve realizes this and covers herself with leaves.

While you are in control of Adam, the player has the option to go into inventory, pick leaves, and cover up.

If the player does not and Adam just keeps standing there, God, who is outside the story and in the theater at this point, will keep making comments until Adam is clothed.

This should feel almost like God is talking to the player instead of only to Adam.

## Noah's Story

> "Gameplay ideas: Matching Game something something figure it the fuck out"

## Tower of Babel

- Tetris-esque game.
- Easy at first, which allows the tower to get way too close for comfort.
- A button appears on God's desk that makes the game extremely hard.
- Commands are no longer in a language the other characters can understand.
- Chaos ensues.
- Everyone gives up and goes their separate ways.

## Jonah and the Whale

- Dungeon crawler platformer.

## DLC (New Testament)

### Gospels

When Jesus prays to the Father, he has an earpiece that he can communicate to the Father through.

Establish throughout gameplay that this is a thing so when we get to:

> **"Father, Father, why have you forsaken me?"**

we can still tell God hears him.

Show visible distress in Father's posture while he sits at the control desk.

## God in Theater Scripting

### God in Theater Basic Scripting

If God is not in the field of play, he will return to the theater by walking out of the scene and back through the door on either side of the stage depending on which way we need him to enter and exit from.
