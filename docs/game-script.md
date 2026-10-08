# The Bible: Sort Of — Game Script

Source: Kyle's opening-screen outline, October 8, 2026. This is a transcription of the current authored beats. Dialogue and actions below are the source for implementation; details not specified here remain open.

## 1. Opening Screen

### 1a. Beach after creation

**Setting:** God sits on a beach after creation, drinking from a “World's Greatest Creator” mug and enjoying His day of rest. Palm trees stand behind Him. Waves crash in.

**Action:** After a few seconds, Adam falls from a tree and is caught by vines on the way down.

**Reaction:** God rolls His eyes.

**God:** “I guess my break is over.”

### 1b. Title screen

The screen shows:

- *The Bible: Sort Of* logo
- **New Game**
- **Continue** — continues from the last game played
- **Load** — three save slots
- **Chapter Selection**
- **Options**

## Open production details

- Shot framing, animation timing beyond “a few seconds,” and the transition from beach to title menu
- Logo treatment and exact menu layout
- Save slot naming, Chapter Selection availability, and Options contents

## 2. Planned stories (author's Google Docs outline)

The native Google Doc **The Bible: Sort Of Game Scripting** is the narrative source
of truth. These are recorded topics, **not** permission to invent finished scenes
or dialogue.

- **Adam and Eve:** Initial cutscenes show the creation story. The draft
  continues with "God goes to speak to Adam who be" and stops mid-sentence.
  The remainder of this scene is still unwritten.
- **Noah's Story:** Listed for a future chapter; no scene script yet.
- **Tower of Babel:** Listed for a future chapter; no scene script yet.

## 3. Planned DLC: New Testament

- **Gospels:** Jesus has an earpiece that lets Him communicate with the Father.
  Establish this device consistently during gameplay.
- **Crucifixion payoff:** During "Father, Father why have you forsaken me,"
  the earpiece and the Father's visible distress at His control desk convey
  that He hears Jesus. Emotional staging matters here. The full scene and
  exact dialogue beyond the original biblical line have not been scripted.

## Implementation notes (not additions to the story)

- The beach opening now uses the existing still background plus a separate,
  temporary animated Adam/vines/reaction layer.
- The sequence is: beach rest -> Adam falls -> vines catch -> Father reacts
  -> "I guess my break is over." -> title menu.
- Character drawings and the floating eye-roll indicator are animatic
  placeholders. Final transparent animation sprites, God sipping from the
  "World's Greatest Creator" mug, and animated environment art remain to do.
- The prologue still has a placeholder screen, not completed gameplay.
