#!/usr/bin/env python3
"""Create the clean title image by removing only the baked NEW GAME arrow."""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "art/title/gods_beach_day_adams_tumble.png"
OUTPUT = ROOT / "art/title/gods_beach_day_adams_tumble_clean.png"

# Source-pixel bounds of the baked selector. The left and right edge samples are
# untouched sunset pixels, so row-by-row interpolation restores the gradient
# without changing the lettering or surrounding scene.
LEFT, TOP, RIGHT, BOTTOM = 925, 418, 960, 455


def blend(left: tuple[int, int, int], right: tuple[int, int, int], amount: float) -> tuple[int, int, int]:
    return tuple(round(a + (b - a) * amount) for a, b in zip(left, right))


image = Image.open(SOURCE).convert("RGB")
pixels = image.load()
for y in range(TOP, BOTTOM):
    left = pixels[LEFT - 1, y]
    right = pixels[RIGHT, y]
    for x in range(LEFT, RIGHT):
        pixels[x, y] = blend(left, right, (x - LEFT + 1) / (RIGHT - LEFT + 1))
image.save(OUTPUT)
