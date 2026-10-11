# The Bible: Sort Of

## Game Script & Narrative Design

> **Source of truth:** This document defines the authored story beats, dialogue, gameplay flow, and canonical comedy for the game. Implementation can prototype mechanics and staging, but unscripted material should not silently become canon.

# Opening — Day Seven

## Scene Setup

God sits on a beach after Creation, drinking from a **World's Greatest Creator** mug and enjoying His day of rest. Palm trees sit behind Him while waves roll in.

## Scene Script

Soft surf.
Fade in on an absurdly peaceful beach.
God is sitting in a chair facing the water, sandals kicked off, robe sleeves rolled slightly, holding the mug.
God takes a drink.
Long pause.
Another wave rolls in.
**GOD:** This is nice.
He takes another drink.
**GOD:** I should do absolutely nothing more often.
A rustling noise comes from somewhere behind Him.
God freezes and looks over one shoulder.
Silence.
He turns back toward the ocean.
Another rustle.
**GOD:** No.
A much louder series of snapping branches.
God slowly closes His eyes.
**GOD:** Please no.
Adam drops violently out of a tree behind Him and gets caught upside-down in a mess of vines a few feet above the ground.
Silence.
Adam swings gently.
God does not turn around.
**ADAM:** ...Adam.
God opens His eyes, slowly looks toward the player, takes one final drink from the mug, and sets it down.
**GOD:** I guess my break is over.
Cut to title.

# Title Screen

**THE BIBLE: SORT OF**
Menu:
- New Game
- Continue — resumes the last game played
- Load — three save slots
- Chapter Selection
- Options

# Episode One — Adam & Eve

# Adam Introduction

## Scene Setup

Initial cutscenes establish the Creation story. God then goes to speak to Adam, who has existed for roughly five minutes and understands almost nothing.

## Scene Script

Fade in.
Adam is standing in Eden.
God stands across from him.
Adam is staring intensely at his own hand.
God waits.
Adam rotates his hand, then opens and closes his fingers.
**GOD:** Adam.
Adam looks up.
**ADAM:** Adam.
**GOD:** Yes. You're Adam.
Adam smiles proudly.
**ADAM:** Adam.
**GOD:** Right.
God points to Himself.
**GOD:** God.
Adam studies Him.
**ADAM:** Adam.
God pauses.
**GOD:** No, you're Adam.
God points to Adam.
**GOD:** Adam.
God points to Himself.
**GOD:** God.
Adam thinks very hard, then points at God.
**ADAM:** Adam?
God looks away for a moment.
**GOD:** We have time.
Cut to black.

## Five Hours Later

Fade back in.
God looks considerably less rested.
Adam is sitting happily on the ground.
**GOD:** Okay.
God crouches in front of him.
**GOD:** Tell me something you've learned.
Adam thinks very hard.
God waits.
Adam suddenly lights up.
**ADAM:** Adam!
Long silence.
God stares at him.
Adam beams.
**GOD:** Fantastic.
Beat.
**GOD:** Five hours.
Adam gives Him a thumbs-up despite nobody having taught him what a thumbs-up is.
God looks directly at the player.
**GOD:** I made that.

## Teaching Montage

God holds up a rock.
**GOD:** Rock.
**ADAM:** Adam.
God holds up an apple.
**GOD:** Apple.
**ADAM:** Rock.
God points at a tree.
**GOD:** Tree.
**ADAM:** Apple.
God points to Himself.
**GOD:** God.
Adam pauses.
**ADAM:** ...God.
God's eyes widen.
**GOD:** YES.
Adam immediately points at the tree.
**ADAM:** God.
God's shoulders drop.
Cut.
God is drawing simple pictures in the dirt.
Adam is eating the stick.
Cut.
God demonstrates walking around a rock.
Adam walks directly into it.
Cut.
God points toward several animals in the distance.
**GOD:** You know what?
Adam looks at Him.
**GOD:** Go explore.
Adam smiles.
**ADAM:** Adam.
**GOD:** Sure.
Control passes to the player.

# Gameplay — Explore Eden

## Purpose

This is the first open gameplay section. Adam can wander the Garden, meet the animals, and discover the obvious Rock in any reasonable order.
The Garden should be a reasonable-sized square area with clear natural boundaries, broadly top-down like a classic creature-collecting RPG overworld, but with better sprites and its own visual identity.

## State Rule — Rock Discovery

Track whether Adam has interacted with the specific obvious Rock in Eden.
This state does not mean whether Adam has ever seen the concept of a rock during the earlier teaching montage.
The Turtle's dialogue and later naming choices change depending on this state. The callback should feel earned, not psychic.

## Cow — Free-roam

**ADAM:** Hello.
**COW:** Moooooo.
Adam waits.
**ADAM:** ...Adam.
**COW:** Moo.
Adam nods.
**ADAM:** Good.
Beat.
**ADAM:** We understand each other.
Repeat interaction:
**COW:** Moooo.
**ADAM:** You already told me that.

## Turtle — Before Rock Discovery

Adam crouches beside the turtle.
**ADAM:** Hello.
The turtle pulls its head into its shell.
Adam waits.
**ADAM:** Gone?
The turtle slowly pokes its head back out.
**ADAM:** Not gone.
The turtle takes one tiny step.
Adam follows it with his eyes.
**ADAM:** Slow.
Another tiny step.
**ADAM:** Very slow.
Adam crouches lower and studies the shell.
**ADAM:** You carry this?
The turtle keeps walking.
Adam thinks about this.
**ADAM:** That seems heavy.

## Turtle — After Rock Discovery

The turtle takes one tiny step.
Adam's eyes widen.
**ADAM:** Rock moves.
The turtle takes another step.
Adam follows it.
**ADAM:** Rock?
No answer.
**ADAM:** Moving rock.
Repeat interaction after the Rock conversation:
**ADAM:** You are confusing.

## Lion — Free-roam

The lion growls.
Adam stops.
**ADAM:** Hello.
The lion ROARS.
Adam takes several steps backward.
Long pause.
**ADAM:** No.
Second interaction:
**ADAM:** We have spoken.
The lion growls.
**ADAM:** We disagree.
Third interaction:
Adam begins approaching.
The lion raises its head.
Adam immediately stops.
**ADAM:** Goodbye.

## Elephant — Free-roam

Adam stares upward.
The elephant trumpets.
Adam jumps.
**ADAM:** Why are you so much?
He walks around it.
**ADAM:** You have...
He counts the legs.
**ADAM:** One.
**ADAM:** Two.
Pause.
**ADAM:** Three.
Moves around.
**ADAM:** Four.
He sees the trunk.
Long pause.
**ADAM:** Five?
The elephant trumpets.
**ADAM:** I knew it.

## Eagle — Free-roam

The eagle is perched slightly above Adam.
**ADAM:** Hello.
The eagle screeches.
Adam waves.
**ADAM:** Come down.
Nothing.
**ADAM:** I am down.
Beat.
**ADAM:** Down is good.
The eagle flies to another perch.
Adam watches it.
**ADAM:** Show-off.

# Optional Interaction — The Rock

The Rock exists in the same Garden sandbox as the animals.
If Adam talks to the very obvious Rock, begin a disproportionately long optional conversation in which he tells it everything he thinks and knows about his extremely short existence.
The interaction eventually resolves with God stepping in.
**GOD:** That's a rock, Adam.
Adam smiles and nods.
The full Rock dialogue will be expanded separately. Its existence and resolution are canonical.

# Quest — Name the Animals

## Quest Start

After enough exploration, God calls Adam over.
**GOD:** Adam.
Adam approaches.
**ADAM:** God.
God is pleased he got that right.
**GOD:** Very good.
Adam smiles.
**GOD:** I've got something for you to do.
Adam looks concerned.
**ADAM:** Do?
**GOD:** A job.
Adam stares.
**ADAM:** Job.
**GOD:** We're going to learn that one the hard way.
God gestures toward the Garden.
**GOD:** All of these creatures need names.
Adam looks around.
**ADAM:** Names.
**GOD:** Exactly.
God points to Adam.
**GOD:** Adam.
God points to Himself.
**GOD:** God.
God gestures toward the animals.
**GOD:** And now you get to decide what they're called.
For possibly the first time in his existence, power enters Adam's tiny brain.
**ADAM:** I decide?
God hesitates just long enough to realize He may have made a terrible mistake.
**GOD:** ...Yes.
Quest begins.

## Cow — Naming

**COW:** Moooo.
**ADAM:** I know this one.
**GOD:** Really?
Choices:
- Moo
- Grass Dog
- Big
- Wednesday
If **Moo**:
**GOD:** You named it after the noise it makes?
**COW:** Moo.
**ADAM:** Yes.
God considers it.
**GOD:** Actually, that one's defensible.
If **Wednesday**:
**ADAM:** Wednesday.
**GOD:** Wednesday?
**ADAM:** Wednesday.
God starts to object, realizes days do not technically have names yet either, then stops.
**GOD:** Never mind.
Other choices can receive short appropriate reactions without turning each branch into a separate scene.

## Turtle — Naming Before Rock Discovery

If the naming quest begins before Adam discovers the Rock, do not use Moving Rock or Other Rock callbacks.
Choices:
- Slow
- Shell
- Round
- Small
Adam confidently announces the selected name.
God may react briefly, but this version must not imply Adam has already had the Rock interaction.

## Turtle — Naming After Rock Discovery

If Adam has already discovered the Rock, the choices become:
- Moving Rock
- Small Ground
- Round
- Other Rock
If the player chooses something other than Moving Rock, Adam can still look at the turtle afterward.
**ADAM:** Moving rock.
**GOD:** That's not what you picked.
**ADAM:** Moving rock.
If the player chooses **Moving Rock**:
God looks toward the player for a beat.
**GOD:** Of course you did.
The chosen animal name can persist as its interaction label for the rest of the chapter.

## Lion — Naming

The lion growls.
**ADAM:** No.
**GOD:** It still needs a name.
Choices:
- No
- Loud
- Hair Mouth
- Do Not
If **Do Not**:
**ADAM:** Do Not.
**GOD:** That's an instruction.
**ADAM:** Do Not.
The lion ROARS.
Adam points at it.
**ADAM:** See?
**GOD:** ...Fine.
If **Hair Mouth**:
God starts to object, looks at the mane, then the mouth.
**GOD:** I hate that I understand it.

## Elephant — Naming

Adam looks up at the elephant.
**ADAM:** Big.
**GOD:** We've already established that.
Choices:
- Very Big
- Five Legs
- Long Face
- Kevin
If **Five Legs**:
**GOD:** Four.
Adam points to the trunk.
**ADAM:** Five.
**GOD:** That's its nose.
Adam studies the trunk.
**ADAM:** That is too much nose.
If **Kevin**:
**GOD:** Where did you get Kevin?
Adam shrugs.
Never explain Kevin.

## Eagle — First Jeff

The eagle screeches.
**GOD:** All right.
Beat.
**GOD:** Last one.
Choices:
- Jeff
- Jeff
- Jeff
- Jeff
All four choices genuinely display Jeff.
If the player backs out and reopens the menu, all four are still Jeff.
If the player waits too long:
**ADAM:** Jeff.
**GOD:** You haven't picked yet.
Adam looks at the eagle.
**ADAM:** Jeff.
After the player selects any Jeff:
**GOD:** Adam...
Adam smiles.
**ADAM:** Jeff.
God looks at the eagle.
The eagle looks back.
God looks at Adam.
**GOD:** You know what?
God gestures toward the eagle.
**GOD:** That's Jeff.
**Achievement unlocked: FIRST JEFF**
**ADAM:** Jeff!
The eagle screeches.
**ADAM:** Jeff.
Afterward:
**ADAM:** Jeff.
**JEFF:** *screech*
**ADAM:** Yes.

## Rock Callback During Naming Quest

If Adam has received naming authority and returns to the Rock:
**ADAM:** I can name things now.
Silence.
Adam looks at the Rock.
A naming menu begins to appear:
- Rock
- Friend
- Adam
- Jeff
Before the player can commit:
**GOD, OFFSCREEN:** DON'T.
This is a callback only. The Rock's long conversation and **“That's a rock, Adam.”** resolution remain their own optional interaction chain.

# Scene — Creation of Eve

God realizes Adam needs help.
God picks up a log.
Cut to black.
When the image returns, Adam is clearly unconscious.
God looks directly toward the player and speaks very seriously.
**GOD:** And I PUT HIM TO SLEEP.
God takes Adam's rib and creates the woman who will be Eve.
He immediately tests her with a cow.
**GOD:** What is this?
**EVE:** That's a cow.
God indicates that He likes this one, then turns toward unconscious Adam and shakes His head.
End scene.

# Gameplay — Eve in Eden

The next day, Adam wakes up and sees Eve.
Control switches to Eve.
Adam follows her around while she properly names the animals.
God sees that Eve is doing well and Adam is occupied, so He returns to the theater.

# Serpent & Fall

Eve eventually encounters the serpent, who tempts her to eat the fruit.
The exact serpent conversation is not yet fully authored. Keep this section minimal until its dialogue is written.
Adam eats the fruit because the pretty lady told him to.
Before eating the fruit, Adam and Eve's nude regions use a blurred visual treatment.
After eating, the blur gradually becomes obvious black censorship boxes.
Eve notices and covers herself with leaves.

# Gameplay — Adam & the Leaves

Control returns to Adam.
The player can open the inventory, select leaves, and cover him.
If the player refuses and leaves Adam standing there, God is outside the story in the theater and keeps making comments until Adam finally clothes himself.
The joke should increasingly feel like God is speaking partly to the player, not only to Adam.

# Prototype Story Boundary

The currently authored Adam-and-Eve material stops after the leaves interaction.
Do not invent the exile or consequence sequence as finished canon until it is written.

# Future Episode Notes

## Noah

Gameplay concept:
> Matching game. Something something. Figure it the fuck out.
Still open for design.

## Tower of Babel

Core gameplay: Tetris-esque tower-building game.
The game begins easy, allowing the tower to become uncomfortably tall.
A button appears on God's desk.
Pressing it makes the game extremely difficult.
Commands are no longer understandable to the other characters.
Chaos follows.
Everyone gives up and goes their separate ways.

## Jonah and the Whale

Core gameplay: dungeon-crawler platformer.

## New Testament DLC — Gospels

When Jesus prays to the Father, He uses an earpiece to communicate with the Father.
Establish the device throughout gameplay so the later payoff is already understood.
At **“Father, Father, why have you forsaken me?”** the player should still understand that the Father can hear Him.
Father is visible at the control desk, with visible distress in His posture.

# God in the Theater — Staging Rule

When God is not physically in the field of play, He returns to the theater.
He exits the active story scene and re-enters the theater through the stage door on whichever side best matches the direction needed for His next entrance or exit.
The theater is a story location and staging device, not the application controller.
