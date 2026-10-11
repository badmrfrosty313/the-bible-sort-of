extends RefCounted
class_name EdenDialogue
## Dialogue and staging transcribed from docs/game-script.md. No missing story is invented.

const INTRO := [
	[
		"STORY",
		"Adam is staring intensely at his own hand. God waits. Adam rotates his hand, then opens and closes his fingers."
	],
	[
		"GOD",
		"Adam."
	],
	[
		"STORY",
		"Adam looks up."
	],
	[
		"ADAM",
		"Adam."
	],
	[
		"GOD",
		"Yes. You're Adam."
	],
	[
		"STORY",
		"Adam smiles proudly."
	],
	[
		"ADAM",
		"Adam."
	],
	[
		"GOD",
		"Right."
	],
	[
		"STORY",
		"God points to Himself."
	],
	[
		"GOD",
		"God."
	],
	[
		"STORY",
		"Adam studies Him."
	],
	[
		"ADAM",
		"Adam."
	],
	[
		"STORY",
		"God pauses."
	],
	[
		"GOD",
		"No, you're Adam."
	],
	[
		"STORY",
		"God points to Adam."
	],
	[
		"GOD",
		"Adam."
	],
	[
		"STORY",
		"God points to Himself."
	],
	[
		"GOD",
		"God."
	],
	[
		"STORY",
		"Adam thinks very hard, then points at God."
	],
	[
		"ADAM",
		"Adam?"
	],
	[
		"STORY",
		"God looks away for a moment."
	],
	[
		"GOD",
		"We have time."
	],
	[
		"STORY",
		"Cut to black."
	],
	[
		"STORY",
		"Five hours later."
	],
	[
		"STORY",
		"Fade back in. God looks considerably less rested. Adam is sitting happily on the ground."
	],
	[
		"GOD",
		"Okay."
	],
	[
		"STORY",
		"God crouches in front of him."
	],
	[
		"GOD",
		"Tell me something you've learned."
	],
	[
		"STORY",
		"Adam thinks very hard. God waits. Adam suddenly lights up."
	],
	[
		"ADAM",
		"Adam!"
	],
	[
		"STORY",
		"Long silence. God stares at him. Adam beams."
	],
	[
		"GOD",
		"Fantastic."
	],
	[
		"STORY",
		"Beat."
	],
	[
		"GOD",
		"Five hours."
	],
	[
		"STORY",
		"Adam gives Him a thumbs-up despite nobody having taught him what a thumbs-up is. God looks directly at the player."
	],
	[
		"GOD",
		"I made that."
	],
	[
		"STORY",
		"God holds up a rock."
	],
	[
		"GOD",
		"Rock."
	],
	[
		"ADAM",
		"Adam."
	],
	[
		"STORY",
		"God holds up an apple."
	],
	[
		"GOD",
		"Apple."
	],
	[
		"ADAM",
		"Rock."
	],
	[
		"STORY",
		"God points at a tree."
	],
	[
		"GOD",
		"Tree."
	],
	[
		"ADAM",
		"Apple."
	],
	[
		"STORY",
		"God points to Himself."
	],
	[
		"GOD",
		"God."
	],
	[
		"STORY",
		"Adam pauses."
	],
	[
		"ADAM",
		"...God."
	],
	[
		"STORY",
		"God's eyes widen."
	],
	[
		"GOD",
		"YES."
	],
	[
		"STORY",
		"Adam immediately points at the tree."
	],
	[
		"ADAM",
		"God."
	],
	[
		"STORY",
		"God's shoulders drop. Cut. God is drawing simple pictures in the dirt. Adam is eating the stick. Cut. God demonstrates walking around a rock. Adam walks directly into it. Cut."
	],
	[
		"STORY",
		"God points toward several animals in the distance."
	],
	[
		"GOD",
		"You know what?"
	],
	[
		"STORY",
		"Adam looks at Him."
	],
	[
		"GOD",
		"Go explore."
	],
	[
		"STORY",
		"Adam smiles."
	],
	[
		"ADAM",
		"Adam."
	],
	[
		"GOD",
		"Sure."
	]
]

const QUEST_START := [
	[
		"GOD",
		"Adam."
	],
	[
		"STORY",
		"Adam approaches."
	],
	[
		"ADAM",
		"God."
	],
	[
		"STORY",
		"God is pleased he got that right."
	],
	[
		"GOD",
		"Very good."
	],
	[
		"STORY",
		"Adam smiles."
	],
	[
		"GOD",
		"I've got something for you to do."
	],
	[
		"STORY",
		"Adam looks concerned."
	],
	[
		"ADAM",
		"Do?"
	],
	[
		"GOD",
		"A job."
	],
	[
		"STORY",
		"Adam stares."
	],
	[
		"ADAM",
		"Job."
	],
	[
		"GOD",
		"We're going to learn that one the hard way."
	],
	[
		"STORY",
		"God gestures toward the Garden."
	],
	[
		"GOD",
		"All of these creatures need names."
	],
	[
		"STORY",
		"Adam looks around."
	],
	[
		"ADAM",
		"Names."
	],
	[
		"GOD",
		"Exactly."
	],
	[
		"STORY",
		"God points to Adam."
	],
	[
		"GOD",
		"Adam."
	],
	[
		"STORY",
		"God points to Himself."
	],
	[
		"GOD",
		"God."
	],
	[
		"STORY",
		"God gestures toward the animals."
	],
	[
		"GOD",
		"And now you get to decide what they're called."
	],
	[
		"STORY",
		"For possibly the first time in his existence, power enters Adam's tiny brain."
	],
	[
		"ADAM",
		"I decide?"
	],
	[
		"STORY",
		"God hesitates just long enough to realize He may have made a terrible mistake."
	],
	[
		"GOD",
		"...Yes."
	]
]

const EVE_CREATION := [
	[
		"STORY",
		"God realizes Adam needs help. God picks up a log."
	],
	[
		"STORY",
		"Cut to black. When the image returns, Adam is clearly unconscious. God looks directly toward the player and speaks very seriously."
	],
	[
		"GOD",
		"And I PUT HIM TO SLEEP."
	],
	[
		"STORY",
		"God takes Adam's rib and creates the woman who will be Eve. He immediately tests her with a cow."
	],
	[
		"GOD",
		"What is this?"
	],
	[
		"EVE",
		"That's a cow."
	],
	[
		"STORY",
		"God indicates that He likes this one, then turns toward unconscious Adam and shakes His head."
	]
]

const FREE_ROAM := {
	"cow": [
		[
			"ADAM",
			"Hello."
		],
		[
			"COW",
			"Moooooo."
		],
		[
			"STORY",
			"Adam waits."
		],
		[
			"ADAM",
			"...Adam."
		],
		[
			"COW",
			"Moo."
		],
		[
			"STORY",
			"Adam nods."
		],
		[
			"ADAM",
			"Good."
		],
		[
			"STORY",
			"Beat."
		],
		[
			"ADAM",
			"We understand each other."
		]
	],
	"cow_repeat": [
		[
			"COW",
			"Moooo."
		],
		[
			"ADAM",
			"You already told me that."
		]
	],
	"turtle": [
		[
			"STORY",
			"Adam crouches beside the turtle."
		],
		[
			"ADAM",
			"Hello."
		],
		[
			"STORY",
			"The turtle pulls its head into its shell. Adam waits."
		],
		[
			"ADAM",
			"Gone?"
		],
		[
			"STORY",
			"The turtle slowly pokes its head back out."
		],
		[
			"ADAM",
			"Not gone."
		],
		[
			"STORY",
			"The turtle takes one tiny step. Adam follows it with his eyes."
		],
		[
			"ADAM",
			"Slow."
		],
		[
			"STORY",
			"Another tiny step."
		],
		[
			"ADAM",
			"Very slow."
		],
		[
			"STORY",
			"Adam crouches lower and studies the shell."
		],
		[
			"ADAM",
			"You carry this?"
		],
		[
			"STORY",
			"The turtle keeps walking. Adam thinks about this."
		],
		[
			"ADAM",
			"That seems heavy."
		]
	],
	"turtle_rock": [
		[
			"STORY",
			"The turtle takes one tiny step. Adam's eyes widen."
		],
		[
			"ADAM",
			"Rock moves."
		],
		[
			"STORY",
			"The turtle takes another step. Adam follows it."
		],
		[
			"ADAM",
			"Rock?"
		],
		[
			"STORY",
			"No answer."
		],
		[
			"ADAM",
			"Moving rock."
		]
	],
	"turtle_repeat": [
		[
			"ADAM",
			"You are confusing."
		]
	],
	"lion": [
		[
			"STORY",
			"The lion growls. Adam stops."
		],
		[
			"ADAM",
			"Hello."
		],
		[
			"STORY",
			"The lion ROARS. Adam takes several steps backward. Long pause."
		],
		[
			"ADAM",
			"No."
		]
	],
	"lion_second": [
		[
			"ADAM",
			"We have spoken."
		],
		[
			"STORY",
			"The lion growls."
		],
		[
			"ADAM",
			"We disagree."
		]
	],
	"lion_repeat": [
		[
			"STORY",
			"Adam begins approaching. The lion raises its head. Adam immediately stops."
		],
		[
			"ADAM",
			"Goodbye."
		]
	],
	"elephant": [
		[
			"STORY",
			"Adam stares upward. The elephant trumpets. Adam jumps."
		],
		[
			"ADAM",
			"Why are you so much?"
		],
		[
			"STORY",
			"He walks around it."
		],
		[
			"ADAM",
			"You have..."
		],
		[
			"STORY",
			"He counts the legs."
		],
		[
			"ADAM",
			"One."
		],
		[
			"ADAM",
			"Two."
		],
		[
			"STORY",
			"Pause."
		],
		[
			"ADAM",
			"Three."
		],
		[
			"STORY",
			"Moves around."
		],
		[
			"ADAM",
			"Four."
		],
		[
			"STORY",
			"He sees the trunk. Long pause."
		],
		[
			"ADAM",
			"Five?"
		],
		[
			"STORY",
			"The elephant trumpets."
		],
		[
			"ADAM",
			"I knew it."
		]
	],
	"eagle": [
		[
			"STORY",
			"The eagle is perched slightly above Adam."
		],
		[
			"ADAM",
			"Hello."
		],
		[
			"STORY",
			"The eagle screeches. Adam waves."
		],
		[
			"ADAM",
			"Come down."
		],
		[
			"STORY",
			"Nothing."
		],
		[
			"ADAM",
			"I am down."
		],
		[
			"STORY",
			"Beat."
		],
		[
			"ADAM",
			"Down is good."
		],
		[
			"STORY",
			"The eagle flies to another perch. Adam watches it."
		],
		[
			"ADAM",
			"Show-off."
		]
	],
	"eagle_jeff": [
		[
			"ADAM",
			"Jeff."
		],
		[
			"JEFF",
			"*screech*"
		],
		[
			"ADAM",
			"Yes."
		]
	]
}

const NAMING_INTRO := {
	"cow": [
		[
			"COW",
			"Moooo."
		],
		[
			"ADAM",
			"I know this one."
		],
		[
			"GOD",
			"Really?"
		]
	],
	"turtle": [],
	"lion": [
		[
			"STORY",
			"The lion growls."
		],
		[
			"ADAM",
			"No."
		],
		[
			"GOD",
			"It still needs a name."
		]
	],
	"elephant": [
		[
			"STORY",
			"Adam looks up at the elephant."
		],
		[
			"ADAM",
			"Big."
		],
		[
			"GOD",
			"We've already established that."
		]
	],
	"eagle": [
		[
			"STORY",
			"The eagle screeches."
		],
		[
			"GOD",
			"All right."
		],
		[
			"STORY",
			"Beat."
		],
		[
			"GOD",
			"Last one."
		]
	]
}

const REACTIONS := {
	"cow_Moo": [
		[
			"GOD",
			"You named it after the noise it makes?"
		],
		[
			"COW",
			"Moo."
		],
		[
			"ADAM",
			"Yes."
		],
		[
			"STORY",
			"God considers it."
		],
		[
			"GOD",
			"Actually, that one's defensible."
		]
	],
	"cow_Wednesday": [
		[
			"ADAM",
			"Wednesday."
		],
		[
			"GOD",
			"Wednesday?"
		],
		[
			"ADAM",
			"Wednesday."
		],
		[
			"STORY",
			"God starts to object, realizes days do not technically have names yet either, then stops."
		],
		[
			"GOD",
			"Never mind."
		]
	],
	"turtle_Moving_Rock": [
		[
			"STORY",
			"God looks toward the player for a beat."
		],
		[
			"GOD",
			"Of course you did."
		]
	],
	"turtle_other": [
		[
			"ADAM",
			"Moving rock."
		],
		[
			"GOD",
			"That's not what you picked."
		],
		[
			"ADAM",
			"Moving rock."
		]
	],
	"lion_Do_Not": [
		[
			"ADAM",
			"Do Not."
		],
		[
			"GOD",
			"That's an instruction."
		],
		[
			"ADAM",
			"Do Not."
		],
		[
			"STORY",
			"The lion ROARS. Adam points at it."
		],
		[
			"ADAM",
			"See?"
		],
		[
			"GOD",
			"...Fine."
		]
	],
	"lion_Hair_Mouth": [
		[
			"STORY",
			"God starts to object, looks at the mane, then the mouth."
		],
		[
			"GOD",
			"I hate that I understand it."
		]
	],
	"elephant_Five_Legs": [
		[
			"GOD",
			"Four."
		],
		[
			"STORY",
			"Adam points to the trunk."
		],
		[
			"ADAM",
			"Five."
		],
		[
			"GOD",
			"That's its nose."
		],
		[
			"STORY",
			"Adam studies the trunk."
		],
		[
			"ADAM",
			"That is too much nose."
		]
	],
	"elephant_Kevin": [
		[
			"GOD",
			"Where did you get Kevin?"
		],
		[
			"STORY",
			"Adam shrugs."
		]
	],
	"eagle_Jeff": [
		[
			"GOD",
			"Adam..."
		],
		[
			"STORY",
			"Adam smiles."
		],
		[
			"ADAM",
			"Jeff."
		],
		[
			"STORY",
			"God looks at the eagle. The eagle looks back. God looks at Adam."
		],
		[
			"GOD",
			"You know what?"
		],
		[
			"STORY",
			"God gestures toward the eagle."
		],
		[
			"GOD",
			"That's Jeff."
		],
		[
			"STORY",
			"**Achievement unlocked: FIRST JEFF**"
		],
		[
			"ADAM",
			"Jeff!"
		],
		[
			"STORY",
			"The eagle screeches."
		],
		[
			"ADAM",
			"Jeff."
		]
	]
}

const JEFF_HESITATION := [
	[
		"ADAM",
		"Jeff."
	],
	[
		"GOD",
		"You haven't picked yet."
	],
	[
		"STORY",
		"Adam looks at the eagle."
	],
	[
		"ADAM",
		"Jeff."
	]
]
