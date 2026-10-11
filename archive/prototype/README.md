# Obsolete theater prototype

Reference only. The application shell and episode catalog do not load this code.
Theater staging, Moses/burning-bush dialogue, the experimental Father controller,
and their original capture script are preserved together so animation and art
techniques remain inspectable. Classes are prefixed `Prototype` to keep them
separate from future reusable characters. All original source art remains under
`art/`; none has been promoted to the new title screen or development episode.

Run the reference explicitly, after importing the project:

```sh
godot --path . res://archive/prototype/theater/theater.tscn
```

The archived capture script is `res://archive/prototype/capture_theater.gd`.
It is no longer a required CI target. Do not use its theater director as the
architecture for new episodes. The stale UID for the deleted `scripts/father.gd`
was removed; the surviving experimental controller now lives here.
