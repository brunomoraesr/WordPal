"""
Run this script once to generate placeholder app icons.
Requires: pip install pillow
"""
import os
from PIL import Image, ImageDraw, ImageFont

SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

BG_COLOR = (59, 63, 143)   # #3B3F8F  (WordPal primary)
TEXT_COLOR = (255, 255, 255)

BASE = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "res")

for folder, size in SIZES.items():
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Rounded square background
    radius = size // 5
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=BG_COLOR)

    # Letter "W"
    font_size = int(size * 0.58)
    try:
        font = ImageFont.truetype("arial.ttf", font_size)
    except OSError:
        font = ImageFont.load_default()

    bbox = draw.textbbox((0, 0), "W", font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = (size - tw) // 2 - bbox[0]
    y = (size - th) // 2 - bbox[1]
    draw.text((x, y), "W", fill=TEXT_COLOR, font=font)

    out_dir = os.path.join(BASE, folder)
    os.makedirs(out_dir, exist_ok=True)
    img.save(os.path.join(out_dir, "ic_launcher.png"))
    img.save(os.path.join(out_dir, "ic_launcher_round.png"))
    print(f"Generated {folder}/ic_launcher.png ({size}x{size})")

print("Done!")
