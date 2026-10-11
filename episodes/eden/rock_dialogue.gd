extends RefCounted
class_name RockDialogue
## Authored verbatim from docs/dialogue/rock/01-opening.md, 02-middle.md, 03-payoff.md.
## STORY rows retain staging until dedicated cutscene art exists.

const NODES := {
	"opening": {
		"lines": [
			[
				"STORY",
				"Adam approaches a conspicuously obvious rock. He stops and looks at it. The Rock remains extremely committed to being a rock."
			],
			[
				"ADAM",
				"Hello."
			],
			[
				"STORY",
				"Silence. Adam waits."
			],
			[
				"ADAM",
				"Adam."
			],
			[
				"STORY",
				"Silence. Adam smiles."
			],
			[
				"ADAM",
				"You are quiet."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"God is not quiet."
			],
			[
				"STORY",
				"Adam looks around to make sure God is not immediately nearby."
			],
			[
				"ADAM",
				"God knows many words."
			],
			[
				"STORY",
				"He thinks."
			],
			[
				"ADAM",
				"I know Adam."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"And God."
			],
			[
				"STORY",
				"Another pause."
			],
			[
				"ADAM",
				"And tree."
			],
			[
				"STORY",
				"Adam points toward a tree."
			],
			[
				"ADAM",
				"Tree."
			],
			[
				"STORY",
				"He looks back at the Rock."
			],
			[
				"ADAM",
				"You are not tree."
			],
			[
				"STORY",
				"A small realization."
			],
			[
				"ADAM",
				"Good."
			]
		],
		"next": "opening_choice"
	},
	"opening_choice": {
		"choices": [
			{
				"label": "KEEP TALKING",
				"target": "food"
			},
			{
				"label": "LEAVE",
				"target": "leave"
			}
		]
	},
	"food": {
		"lines": [
			[
				"ADAM",
				"There is also apple."
			],
			[
				"STORY",
				"He thinks about this."
			],
			[
				"ADAM",
				"Apple is food."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"I learned that after I ate it."
			],
			[
				"STORY",
				"Adam looks at the Rock seriously."
			],
			[
				"ADAM",
				"You should not eat the stick."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"It is not food."
			],
			[
				"STORY",
				"Longer pause."
			],
			[
				"ADAM",
				"I learned that too."
			]
		],
		"next": "stop_choice"
	},
	"stop_choice": {
		"choices": [
			{
				"label": "KEEP TALKING",
				"target": "hands"
			},
			{
				"label": "PLEASE STOP",
				"target": "stop"
			}
		]
	},
	"stop": {
		"lines": [
			[
				"ADAM",
				"Stop."
			],
			[
				"STORY",
				"He nods proudly."
			],
			[
				"ADAM",
				"That is another word."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"God says it to me."
			],
			[
				"STORY",
				"And he continues anyway."
			]
		],
		"next": "hands"
	},
	"hands": {
		"lines": [
			[
				"STORY",
				"Adam holds up both hands."
			],
			[
				"ADAM",
				"I have hands."
			],
			[
				"STORY",
				"He looks at one, then the other."
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
				"I think."
			],
			[
				"STORY",
				"He looks at the Rock."
			],
			[
				"ADAM",
				"You have no hands."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"That seems difficult."
			],
			[
				"STORY",
				"Adam pats the Rock sympathetically."
			],
			[
				"ADAM",
				"I can help."
			],
			[
				"STORY",
				"He grabs it with both hands and strains. The Rock moves approximately two inches."
			],
			[
				"STORY",
				"Adam sits back, deeply satisfied."
			],
			[
				"ADAM",
				"There."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"Better."
			]
		],
		"next": "early_choice"
	},
	"early_choice": {
		"choices": [
			{
				"label": "ASK WHAT IT IS",
				"target": "identity"
			},
			{
				"label": "TELL IT ABOUT GOD",
				"target": "god"
			},
			{
				"label": "TELL IT ABOUT ADAM",
				"target": "adam"
			},
			{
				"label": "LEAVE",
				"target": "leave"
			}
		]
	},
	"identity": {
		"lines": [
			[
				"ADAM",
				"What are you?"
			],
			[
				"STORY",
				"Silence. Adam waits."
			],
			[
				"ADAM",
				"You do not know."
			],
			[
				"STORY",
				"He nods sympathetically."
			],
			[
				"ADAM",
				"I did not know either."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"Then God said Adam."
			],
			[
				"STORY",
				"He points to himself."
			],
			[
				"ADAM",
				"Adam."
			],
			[
				"STORY",
				"He points at the Rock."
			],
			[
				"STORY",
				"Long pause."
			],
			[
				"ADAM",
				"Hmm."
			]
		],
		"next": "bird"
	},
	"god": {
		"lines": [
			[
				"ADAM",
				"God made everything."
			],
			[
				"STORY",
				"Adam gestures broadly at Eden."
			],
			[
				"ADAM",
				"Tree."
			],
			[
				"STORY",
				"He points elsewhere."
			],
			[
				"ADAM",
				"Apple."
			],
			[
				"STORY",
				"He points at himself."
			],
			[
				"ADAM",
				"Adam."
			],
			[
				"STORY",
				"He looks at the Rock."
			],
			[
				"STORY",
				"Long pause."
			],
			[
				"ADAM",
				"Probably you."
			],
			[
				"STORY",
				"Adam leans closer."
			],
			[
				"ADAM",
				"God knows things before I ask."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"Sometimes I ask anyway."
			],
			[
				"STORY",
				"Another beat."
			],
			[
				"ADAM",
				"He makes a face."
			],
			[
				"STORY",
				"Adam attempts God's exhausted expression. It is terrible."
			]
		],
		"next": "bird"
	},
	"adam": {
		"lines": [
			[
				"STORY",
				"Adam points at himself."
			],
			[
				"ADAM",
				"Adam is me."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"I learned that first."
			],
			[
				"STORY",
				"He thinks."
			],
			[
				"ADAM",
				"For a long time it was all I knew."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"It was enough."
			],
			[
				"STORY",
				"Adam looks slightly proud of this."
			]
		],
		"next": "bird"
	},
	"bird": {
		"lines": [
			[
				"ADAM",
				"I saw a bird."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"It went up."
			],
			[
				"STORY",
				"Adam points toward the sky."
			],
			[
				"ADAM",
				"I cannot do that."
			],
			[
				"STORY",
				"He looks at the Rock."
			],
			[
				"ADAM",
				"You cannot either."
			],
			[
				"STORY",
				"Adam smiles."
			],
			[
				"ADAM",
				"We have that."
			]
		],
		"next": "sky_choice"
	},
	"sky_choice": {
		"choices": [
			{
				"label": "CONTINUE",
				"target": "sky"
			},
			{
				"label": "FOR THE LOVE OF GOD, WALK AWAY",
				"target": "busy"
			}
		]
	},
	"busy": {
		"lines": [
			[
				"STORY",
				"Adam looks around."
			],
			[
				"ADAM",
				"God?"
			],
			[
				"STORY",
				"He waits. No response."
			],
			[
				"STORY",
				"Adam turns back to the Rock."
			],
			[
				"ADAM",
				"He is busy."
			],
			[
				"STORY",
				"And he continues."
			]
		],
		"next": "sky"
	},
	"sky": {
		"lines": [
			[
				"STORY",
				"Adam looks toward the sky."
			],
			[
				"ADAM",
				"Do you think the sky ends?"
			],
			[
				"STORY",
				"Silence."
			],
			[
				"ADAM",
				"I asked God."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"He said no."
			],
			[
				"STORY",
				"Adam stares upward for a while."
			],
			[
				"ADAM",
				"That seems excessive."
			],
			[
				"STORY",
				"He looks around Eden."
			],
			[
				"ADAM",
				"There are many trees."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"One tree would have been easier."
			],
			[
				"STORY",
				"He considers this."
			],
			[
				"ADAM",
				"But then everyone would be at the same tree."
			],
			[
				"STORY",
				"A longer pause. Adam slowly nods."
			],
			[
				"ADAM",
				"Maybe God is right."
			],
			[
				"STORY",
				"Beat. Adam leans toward the Rock and lowers his voice."
			],
			[
				"ADAM",
				"Do not tell Him I said that."
			],
			[
				"STORY",
				"Silence. Adam smiles."
			],
			[
				"ADAM",
				"I knew I could trust you."
			]
		],
		"next": "mistake_choice"
	},
	"mistake_choice": {
		"choices": [
			{
				"label": "KEEP GOING",
				"target": "existence"
			},
			{
				"label": "I HAVE MADE A TERRIBLE MISTAKE",
				"target": "existence"
			}
		]
	},
	"existence": {
		"lines": [
			[
				"STORY",
				"Adam lies back in the grass beside the Rock."
			],
			[
				"ADAM",
				"I think God likes me."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"He makes this face sometimes."
			],
			[
				"STORY",
				"Adam makes God's exhausted expression again."
			],
			[
				"ADAM",
				"I do not know what it means."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"Maybe happy."
			],
			[
				"GOD, OFFSCREEN",
				"It isn't."
			],
			[
				"STORY",
				"Adam immediately sits upright and looks around. Nothing."
			],
			[
				"STORY",
				"He looks back at the Rock."
			],
			[
				"ADAM",
				"He hears very well."
			],
			[
				"STORY",
				"Adam lowers his voice."
			],
			[
				"ADAM",
				"Very well."
			],
			[
				"STORY",
				"Adam studies the Rock again."
			],
			[
				"ADAM",
				"Do you think God made you before me?"
			],
			[
				"STORY",
				"Silence."
			],
			[
				"ADAM",
				"Probably."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"You seem older."
			],
			[
				"STORY",
				"Adam pats it."
			],
			[
				"ADAM",
				"Not bad old."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"Just..."
			],
			[
				"STORY",
				"Adam struggles for the word."
			],
			[
				"ADAM",
				"Rock old."
			],
			[
				"STORY",
				"He seems pleased with this phrase."
			],
			[
				"ADAM",
				"I am Adam old."
			],
			[
				"STORY",
				"Adam thinks."
			],
			[
				"ADAM",
				"Adam old is not very old."
			],
			[
				"STORY",
				"Another silence."
			],
			[
				"ADAM",
				"Everything happened before me."
			],
			[
				"STORY",
				"Adam looks around Eden."
			],
			[
				"ADAM",
				"Tree was here."
			],
			[
				"STORY",
				"He looks at the sky."
			],
			[
				"ADAM",
				"Sky was here."
			],
			[
				"STORY",
				"At the Rock."
			],
			[
				"ADAM",
				"You were here."
			],
			[
				"STORY",
				"Then at himself."
			],
			[
				"ADAM",
				"Then Adam."
			],
			[
				"STORY",
				"He sits with that."
			],
			[
				"ADAM",
				"That is strange."
			],
			[
				"STORY",
				"Silence."
			],
			[
				"ADAM",
				"But now I am here."
			],
			[
				"STORY",
				"Adam smiles."
			],
			[
				"ADAM",
				"So that is good."
			]
		],
		"next": "friend_choice"
	},
	"friend_choice": {
		"choices": [
			{
				"label": "TELL THE ROCK A SECRET",
				"target": "secret"
			},
			{
				"label": "ASK IF YOU ARE FRIENDS",
				"target": "friends"
			},
			{
				"label": "LEAVE BEFORE THIS GETS WEIRDER",
				"target": "one_more"
			}
		]
	},
	"secret": {
		"lines": [
			[
				"STORY",
				"Adam checks around him."
			],
			[
				"ADAM",
				"I ate the stick twice."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"God only saw once."
			],
			[
				"STORY",
				"Silence. Adam nods."
			],
			[
				"ADAM",
				"Good."
			]
		],
		"next": "learning"
	},
	"friends": {
		"lines": [
			[
				"STORY",
				"Adam looks at the Rock."
			],
			[
				"ADAM",
				"Are we friends?"
			],
			[
				"STORY",
				"Silence. Adam waits a surprisingly long time."
			],
			[
				"ADAM",
				"I think yes."
			],
			[
				"STORY",
				"Pause."
			],
			[
				"ADAM",
				"I have never had a friend."
			],
			[
				"STORY",
				"He considers that."
			],
			[
				"ADAM",
				"I have also never not had a friend."
			],
			[
				"STORY",
				"Adam frowns."
			],
			[
				"ADAM",
				"This is difficult."
			],
			[
				"STORY",
				"He pats the Rock."
			],
			[
				"ADAM",
				"You understand."
			]
		],
		"next": "learning"
	},
	"one_more": {
		"lines": [
			[
				"STORY",
				"Adam starts to stand, stops, looks at the Rock, and sits back down."
			],
			[
				"ADAM",
				"One more thing."
			]
		],
		"next": "learning"
	},
	"learning": {
		"lines": [
			[
				"ADAM",
				"God says I need to learn."
			],
			[
				"STORY",
				"Beat."
			],
			[
				"ADAM",
				"I think I am learning."
			],
			[
				"STORY",
				"He starts counting on his fingers."
			],
			[
				"ADAM",
				"Adam. God. Tree. Apple. Bird. Hand. Sky."
			],
			[
				"STORY",
				"He runs out of fingers, looks down at them, then starts over using the same fingers."
			],
			[
				"ADAM",
				"Food. Stop. Up. Down."
			],
			[
				"STORY",
				"He points at the Rock and pauses. He does not know the word."
			],
			[
				"ADAM",
				"And you."
			]
		],
		"next": "payoff"
	},
	"payoff": {
		"lines": [
			[
				"STORY",
				"At that exact moment, God walks into frame. He stops, looks at Adam, looks at the Rock, then looks back at Adam."
			],
			[
				"GOD",
				"Adam."
			],
			[
				"STORY",
				"Adam looks up happily."
			],
			[
				"ADAM",
				"God."
			],
			[
				"STORY",
				"God gestures."
			],
			[
				"GOD",
				"What are you doing?"
			],
			[
				"STORY",
				"Adam gestures toward the Rock as though the answer is painfully obvious."
			],
			[
				"ADAM",
				"Talking."
			],
			[
				"STORY",
				"God looks at the Rock."
			],
			[
				"GOD",
				"To that?"
			],
			[
				"STORY",
				"Adam nods."
			],
			[
				"STORY",
				"God studies him for a moment, then crouches beside them. He looks at the Rock, then back at Adam."
			],
			[
				"GOD",
				"That's a rock, Adam."
			],
			[
				"STORY",
				"Silence."
			],
			[
				"STORY",
				"Adam looks at the Rock, then God, then the Rock again. Something clicks. His face lights up."
			],
			[
				"ADAM",
				"Rock."
			],
			[
				"STORY",
				"God pauses."
			],
			[
				"ADAM",
				"Rock."
			],
			[
				"STORY",
				"God nods."
			],
			[
				"GOD",
				"Yes."
			],
			[
				"STORY",
				"Adam looks delighted."
			],
			[
				"ADAM",
				"I know another word."
			],
			[
				"STORY",
				"God looks at him. For once, no exhaustion. A small smile."
			],
			[
				"GOD",
				"You do."
			],
			[
				"STORY",
				"Adam pats the Rock."
			],
			[
				"ADAM",
				"Rock."
			],
			[
				"STORY",
				"God stands."
			],
			[
				"GOD",
				"Come on."
			],
			[
				"STORY",
				"Adam gets up and follows. After a few steps, Adam looks back."
			],
			[
				"ADAM",
				"Bye, Rock."
			],
			[
				"STORY",
				"God stops walking, does not turn around, waits a beat, then keeps going."
			]
		],
		"next": "complete"
	},
	"repeat_first": {
		"lines": [
			[
				"ADAM",
				"Hello, Rock."
			],
			[
				"GOD, IMPOSSIBLY DISTANT",
				"NO."
			],
			[
				"STORY",
				"Adam smiles."
			]
		],
		"next": "end"
	},
	"repeat_later": {
		"lines": [
			[
				"ADAM",
				"Rock."
			],
			[
				"STORY",
				"Silence."
			],
			[
				"ADAM",
				"Good."
			]
		],
		"next": "end"
	},
	"authority": {
		"lines": [
			[
				"ADAM",
				"I can name things now."
			],
			[
				"STORY",
				"Rock    Friend    Adam    Jeff"
			],
			[
				"GOD, OFFSCREEN",
				"DON'T."
			]
		],
		"next": "end"
	}
}

