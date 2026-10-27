#!/usr/bin/env python3
"""Draw assets/cover.png (630x500) from the game's own sprite atlas.

Needs Pillow and a built build/web/art.png (tools/build.sh). The font is Public Pixel
(CC0; see the BOK's Tech/Public Pixel Font.md for the licence).
"""
from PIL import Image, ImageDraw, ImageFont

FONT = "/home/yermom/git/bok-of-splorr/splorr/Assets/PublicPixel.ttf"
W, H, S = 630, 500, 16
SPRITES = ["Player", "Baron", "Widow", "Cousin", "Chef", "Vicar", "Hound", "Dead", "Chair", "Table", "Knife",
           "Fork", "Cup", "Napkin", "Aid", "Crank_Cw", "Crank_Ccw", "Wound"]  # order of Sprite in src/game/art.odin
atlas = Image.open("build/web/art.png").convert("RGBA")
K = 6  # pixel scale of the picture

def sprite(name):
    i = SPRITES.index(name)
    return atlas.crop((i * S, 0, i * S + S, S)).resize((S * K, S * K), Image.NEAREST)

img = Image.new("RGBA", (W, H), (0x1a, 0x1c, 0x2c, 255))
d = ImageDraw.Draw(img)
for y in range(0, H, S * K // 2):  # a chequered floor under the table
    for x in range(0, W, S * K // 2):
        if (x // (S * K // 2) + y // (S * K // 2)) % 2:
            d.rectangle((x, y, x + S * K // 2 - 1, y + S * K // 2 - 1), fill=(0x2b, 0x31, 0x50, 255))

big = ImageFont.truetype(FONT, 38)
small = ImageFont.truetype(FONT, 18)
def line(text, y, fill, font):
    w = d.textlength(text, font=font)
    d.text(((W - w) / 2 + 3, y + 3), text, font=font, fill="#000000")
    d.text(((W - w) / 2, y), text, font=font, fill=fill)
line("Table Turners", 26, "#f4f4f4", big)
line("of SPLORR!!", 74, "#ffec27", big)
line("Turn the tables. Betray everyone.", 128, "#94b0c2", small)

# A dinner party gone wrong: the Baron's knife has reached the Widow's seat across the table.
cx, cy = W // 2, 318
T = S * K
def put(name, dx, dy, shift=(0, 0)):
    img.alpha_composite(sprite(name), (cx - T // 2 + dx * T + shift[0], cy - T // 2 + dy * T + shift[1]))
put("Table", 0, 0)
for name, (dx, dy) in (("Chair", (0, -1)), ("Chair", (1, 0)), ("Chair", (0, 1)), ("Chair", (-1, 0))):
    put(name, dx, dy)
put("Baron", 0, -1); put("Dead", 0, 1); put("Chef", 1, 0); put("Hound", -1, 0)
put("Wound", 0, 1)
put("Knife", 0, 0, (0, -5 * K)); put("Fork", 0, 0, (5 * K, 0)); put("Napkin", 0, 0, (-5 * K, 0)); put("Cup", 0, 0, (0, 5 * K))
put("Player", 2, 1); put("Crank_Cw", 3, 1)
img.convert("RGB").save("assets/cover.png")
print("assets/cover.png", img.size)
