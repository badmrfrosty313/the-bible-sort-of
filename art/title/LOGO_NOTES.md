# Title logo treatment

The title is a resolution-independent SVG whose characters are **converted
to vector paths**. It does not require a system font to render, which keeps
Godot/Linux CI and the user's Windows build visually consistent.

- **THE / BIBLE:** use letterforms based on Noto Serif Display (bold/black).
- **SORT OF** uses letterforms based on Inter Display Bold to underline the joke.
- Cream parchment fills, dark plum-brown edges, restrained gold accents.
- The five navigation choices and their submenus remain editable Godot
  buttons, not baked into the logo. Their type is intentionally simpler.

The underlying typefaces are open-source under the SIL Open Font License 1.1.
No font software is committed here, only the outlined artwork.

For future changes, regenerate the SVG outlines rather than substituting
`<text>` elements, because Godot SVG import does not support font rendering
of arbitrary SVG text reliably.
