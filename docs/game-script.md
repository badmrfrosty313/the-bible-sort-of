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

Control passes to Adam in the Garden. The animal interactions and the Rock are available in the same free-roam space before and during the naming quest.

The player should be able to discover these in any reasonable order. Dialogue must respect discovery state rather than assuming the player has already encountered another object or animal.

The Garden remains a reasonable-sized square map with clear natural/playable boundaries, broadly top-down like a Pokémon-style overworld with better sprites.

#### State Requirement: Rock Discovery

Track whether Adam has discovered/interacted with the **obvious Eden Rock**.

This state is about the specific Rock interaction in the Garden, not whether Adam has ever seen the concept of a rock during the earlier teaching montage.

The Turtle's dialogue and naming choices change depending on whether that Rock interaction has happened. The callback must feel earned rather than psychic.

#### Cow — Free-roam Interaction

**Adam:** "Hello."

**Cow:** "Moooooo."

Adam waits.

**Adam:** "...Adam."

**Cow:** "Moo."

Adam nods.

**Adam:** "Good."

Beat.

**Adam:** "We understand each other."

Repeat interaction:

**Cow:** "Moooo."

**Adam:** "You already told me that."

#### Turtle — Before Rock Discovery

Adam crouches beside the turtle.

**Adam:** "Hello."

The turtle pulls its head into its shell.

Adam waits.

**Adam:** "Gone?"

The turtle slowly pokes its head back out.

**Adam:** "Not gone."

The turtle takes one tiny step.

Adam follows it with his eyes.

**Adam:** "Slow."

Another tiny step.

**Adam:** "Very slow."

Adam crouches lower and studies the shell.

**Adam:** "You carry this?"

The turtle keeps walking.

Adam thinks about this.

**Adam:** "That seems heavy."

Use this version if Adam has not yet discovered/interacted with the obvious Eden Rock.

#### Turtle — After Rock Discovery

The turtle takes one tiny step.

Adam's eyes widen.

**Adam:** "Rock moves."

The turtle takes another step.

Adam follows it.

**Adam:** "Rock?"

No answer.

**Adam:** "Moving rock."

Repeat interaction after the Rock conversation:

**Adam:** "You are confusing."

The moving-rock callback must only become available once the player has established the Rock interaction in Eden.

#### Lion — Free-roam Interaction

The lion growls.

Adam stops.

**Adam:** "Hello."

The lion ROARS.

Adam takes several steps backward.

Long pause.

**Adam:** "No."

Second interaction:

**Adam:** "We have spoken."

The lion growls.

**Adam:** "We disagree."

Third interaction:

Adam begins approaching.

The lion raises its head.

Adam immediately stops.

**Adam:** "Goodbye."

#### Elephant — Free-roam Interaction

Adam stares upward.

The elephant trumpets.

Adam jumps.

**Adam:** "Why are you so much?"

He walks around it.

**Adam:** "You have..."

He counts the legs.

**Adam:** "One."

**Adam:** "Two."

Pause.

**Adam:** "Three."

Moves around.

**Adam:** "Four."

He sees the trunk.

Long pause.

**Adam:** "Five?"

The elephant trumpets.

**Adam:** "I knew it."

#### Eagle — Free-roam Interaction

The eagle is perched slightly above Adam.

**Adam:** "Hello."

The eagle screeches.

Adam waves.

**Adam:** "Come down."

Nothing.

**Adam:** "I am down."

Beat.

**Adam:** "Down is good."

The eagle flies to another perch.

Adam watches it.

**Adam:** "Show-off."

After a few interactions/exploration beats, God calls Adam over and introduces the naming job.

### The Rock

If Adam speaks to the very obvious rock, create a giant dialogue tree where he tells it everything he thinks and knows of his short existence.

After enough, God steps in and says:

> **God:** "That's a rock, Adam."

Adam just smiles and nods.

### Animal Naming Quest

God calls Adam over.

**God:** "Adam."

Adam approaches.

**Adam:** "God."

God is pleased he got that right.

**God:** "Very good."

Adam smiles.

**God:** "I've got something for you to do."

Adam looks concerned.

**Adam:** "Do?"

**God:** "A job."

Adam stares.

**Adam:** "Job."

**God:** "We're going to learn that one the hard way."

God gestures toward the Garden.

**God:** "All of these creatures need names."

Adam looks around.

**Adam:** "Names."

**God:** "Exactly."

God points to Adam.

**God:** "Adam."

God points to Himself.

**God:** "God."

God gestures toward the animals.

**God:** "And now you get to decide what they're called."

For possibly the first time in his existence, power enters Adam's tiny brain.

**Adam:** "I decide?"

God hesitates just long enough to realize He may have made a terrible mistake.

**God:** "...Yes."

Quest begins.

#### Cow Naming

**Cow:** "Moooo."

**Adam:** "I know this one."

**God:** "Really?"

Choices:

- **Moo**
- **Grass Dog**
- **Big**
- **Wednesday**

If **Moo**:

**God:** "You named it after the noise it makes?"

**Cow:** "Moo."

**Adam:** "Yes."

God considers it.

**God:** "Actually, that one's defensible."

If **Wednesday**:

**Adam:** "Wednesday."

**God:** "Wednesday?"

**Adam:** "Wednesday."

God starts to object, realizes days do not technically have names yet either, then stops.

**God:** "Never mind."

Other choices can receive short appropriate reactions, but do not over-write them.

#### Turtle Naming — Before Rock Discovery

If the player begins the naming quest without discovering the Rock, do **not** use Moving Rock / Other Rock callbacks yet.

Choices:

- **Slow**
- **Shell**
- **Round**
- **Small**

Adam confidently announces the selected name.

God may react briefly, but this version must not imply Adam has already had the Rock interaction.

#### Turtle Naming — After Rock Discovery

If the Rock has already been discovered, the naming choices become:

- **Moving Rock**
- **Small Ground**
- **Round**
- **Other Rock**

If the player chooses something other than Moving Rock, Adam can still look at the turtle afterward and quietly say:

**Adam:** "Moving rock."

**God:** "That's not what you picked."

**Adam:** "Moving rock."

If the player chooses **Moving Rock**:

God looks toward the player for a beat.

**God:** "Of course you did."

The animal's chosen name can persist as its interaction label for the rest of the chapter.

#### Lion Naming

The lion growls.

**Adam:** "No."

**God:** "It still needs a name."

Choices:

- **No**
- **Loud**
- **Hair Mouth**
- **Do Not**

If **Do Not**:

**Adam:** "Do Not."

**God:** "That's an instruction."

**Adam:** "Do Not."

The lion ROARS.

Adam points at it.

**Adam:** "See?"

**God:** "...Fine."

If **Hair Mouth**:

God starts to object, looks at the mane, then the mouth.

**God:** "I hate that I understand it."

#### Elephant Naming

Adam looks up at the elephant.

**Adam:** "Big."

**God:** "We've already established that."

Choices:

- **Very Big**
- **Five Legs**
- **Long Face**
- **Kevin**

If **Five Legs**:

**God:** "Four."

Adam points to the trunk.

**Adam:** "Five."

**God:** "That's its nose."

Adam studies the trunk.

**Adam:** "That is too much nose."

If **Kevin**:

**God:** "Where did you get Kevin?"

Adam shrugs.

Never explain Kevin.

#### Eagle Naming — First Jeff

The eagle screeches.

**God:** "All right."

Beat.

**God:** "Last one."

Naming menu:

- **Jeff**
- **Jeff**
- **Jeff**
- **Jeff**

All four choices must genuinely display Jeff.

If the player backs out and reopens the menu, all four are still Jeff.

If the player waits too long:

**Adam:** "Jeff."

**God:** "You haven't picked yet."

Adam looks at the eagle.

**Adam:** "Jeff."

After the player selects any Jeff:

**God:** "Adam..."

Adam smiles.

**Adam:** "Jeff."

God looks at the eagle.

The eagle looks back.

God looks at Adam.

**God:** "You know what?"

God gestures toward the eagle.

**God:** "That's Jeff."

Trigger notification:

**ACHIEVEMENT UNLOCKED — FIRST JEFF**

**Adam:** "Jeff!"

The eagle screeches.

**Adam:** "Jeff."

Afterward, interacting with the eagle:

**Adam:** "Jeff."

**Jeff:** *screech*

**Adam:** "Yes."

#### Rock / Naming Quest Crossover

The Rock remains available throughout this same Garden section.

If Adam has received naming authority and then returns to the Rock:

**Adam:** "I can name things now."

Silence.

Adam looks at the Rock.

A naming menu begins to appear:

- **Rock**
- **Friend**
- **Adam**
- **Jeff**

Before the player can commit to one:

**God, somewhere offscreen:** "DON'T."

This is a callback only. The Rock's actual long conversation and eventual **"That's a rock, Adam."** resolution remain their own optional interaction chain.

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
