#!/usr/bin/env python3
from pathlib import Path
import re
import sys


def write_if_changed(path, text):
    original = path.read_text(encoding="utf-8", errors="ignore")
    if text == original:
        print(f"Already clean: {path}")
        return
    path.write_text(text, encoding="utf-8")
    print(f"Updated: {path}")


target = Path(sys.argv[1] if len(sys.argv) > 1 else "/home/pi/sg1_v4/web")
if (target / "web/retro").is_dir():
    target = target / "web"
if not (target / "retro").is_dir():
    raise SystemExit(f"ERROR: target web folder not found: {target}")

for rel in ("retro/dial.html", "retro/dial9.html"):
    path = target / rel
    text = path.read_text(encoding="utf-8", errors="ignore")
    text = re.sub(r"\s*<!-- WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH -->\s*", "\n", text)
    text = re.sub(r'\s*<image class="wormhole-gif"[^>]*/>\s*', "\n", text)
    text = re.sub(r'\s*<image class="blackhole-gif"[^>]*/>\s*', "\n", text)
    text = re.sub(
        r'\s*<clipPath id="wormholeClip">\s*<circle cx="337" cy="335" r="237" />\s*</clipPath>\s*',
        "\n",
        text,
    )
    text = text.replace('fill="transparent" stroke-width="4.96px"', 'fill="url(#radialGradient)" stroke-width="4.96px"')
    write_if_changed(path, text)

for rel in ("retro/css/dial.css", "retro/css/dial9.css"):
    path = target / rel
    text = path.read_text(encoding="utf-8", errors="ignore")
    text = re.sub(
        r"\n?/\* WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH START \*/[\s\S]*?/\* WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH END \*/\n?",
        "\n",
        text,
    )
    write_if_changed(path, text)

path = target / "retro/js/dial.js"
text = path.read_text(encoding="utf-8", errors="ignore")
text = text.replace("\nconst CLASS_BLACK_HOLE = 'black-hole-active';", "")
text = re.sub(
    r"\nfunction updateBlackHoleGifState\(\) \{[\s\S]*?\n\}\n\n(?=function updateDestination)",
    "\n",
    text,
    count=1,
)
text = text.replace("  updateBlackHoleGifState();\n\n", "")
write_if_changed(path, text)

for rel in ("retro/images/wormhole.gif", "retro/images/blackhole.gif"):
    path = target / rel
    if path.exists():
        path.unlink()
        print(f"Removed: {path}")

print("Retro Wormhole GIF overlay removed.")
