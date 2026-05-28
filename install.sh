#!/usr/bin/env bash
set -euo pipefail

TARGET="/home/pi/sg1_v4/web"
DRY_RUN=0
HIDE_CROSSHAIR=1

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [--target /home/pi/sg1_v4/web] [--dry-run] [--keep-crosshair]

Universal SG1 retro wormhole/blackhole GIF injector.

Compatible targets:
  --target /home/pi/sg1_v4
  --target /home/pi/sg1_v4/web

What it changes:
  - copies wormhole.gif and blackhole.gif into retro/images/
  - injects GIF image layers into retro/dial.html and retro/dial9.html
  - appends safe CSS rules into retro/css/dial.css and retro/css/dial9.css
  - patches retro/js/dial.js so blackhole.gif is shown for black hole wormholes
  - hides center crosshair by default
  - creates a timestamped backup before editing

Options:
  --keep-crosshair  Do not hide the yellow + / red dot crosshair
  --dry-run         Check files and show actions without writing changes
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --keep-crosshair)
      HIDE_CROSSHAIR=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -d "$TARGET/web/retro" ]; then
  TARGET="$TARGET/web"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSET_DIR="$SCRIPT_DIR/assets/retro/images"

need_file() {
  if [ ! -f "$1" ]; then
    echo "Missing required file: $1" >&2
    exit 1
  fi
}

need_dir() {
  if [ ! -d "$1" ]; then
    echo "Missing required directory: $1" >&2
    exit 1
  fi
}

need_file "$ASSET_DIR/wormhole.gif"
need_file "$ASSET_DIR/blackhole.gif"
need_dir "$TARGET/retro"

mkdir -p "$TARGET/retro/images" "$TARGET/retro/css"

for f in \
  "$TARGET/retro/dial.html" \
  "$TARGET/retro/dial9.html" \
  "$TARGET/retro/css/dial.css" \
  "$TARGET/retro/css/dial9.css"; do
  need_file "$f"
done

BACKUP_BASE="$TARGET/backups/wormhole-blackhole-gif-universal-$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_BASE"
suffix=1
while [ -e "$BACKUP_DIR" ]; do
  BACKUP_DIR="${BACKUP_BASE}-${suffix}"
  suffix=$((suffix + 1))
done

echo "Target web folder: $TARGET"
echo "Backup: $BACKUP_DIR"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run only. No files will be changed."
else
  mkdir -p "$BACKUP_DIR/retro/css" "$BACKUP_DIR/retro/images"

  cp "$TARGET/retro/dial.html" "$BACKUP_DIR/retro/dial.html"
  cp "$TARGET/retro/dial9.html" "$BACKUP_DIR/retro/dial9.html"
  cp "$TARGET/retro/css/dial.css" "$BACKUP_DIR/retro/css/dial.css"
  cp "$TARGET/retro/css/dial9.css" "$BACKUP_DIR/retro/css/dial9.css"
  [ -f "$TARGET/retro/js/dial.js" ] && mkdir -p "$BACKUP_DIR/retro/js" && cp "$TARGET/retro/js/dial.js" "$BACKUP_DIR/retro/js/dial.js" || true

  [ -f "$TARGET/retro/images/wormhole.gif" ] && cp "$TARGET/retro/images/wormhole.gif" "$BACKUP_DIR/retro/images/wormhole.gif" || true
  [ -f "$TARGET/retro/images/blackhole.gif" ] && cp "$TARGET/retro/images/blackhole.gif" "$BACKUP_DIR/retro/images/blackhole.gif" || true

  cp "$ASSET_DIR/wormhole.gif" "$TARGET/retro/images/wormhole.gif"
  cp "$ASSET_DIR/blackhole.gif" "$TARGET/retro/images/blackhole.gif"
fi

python3 - "$TARGET" "$DRY_RUN" "$HIDE_CROSSHAIR" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
dry_run = sys.argv[2] == "1"
hide_crosshair = sys.argv[3] == "1"

PATCH_START = "/* WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH START */"
PATCH_END = "/* WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH END */"

HTML_PATCH_NOTE = "<!-- WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH -->"

CLIP = """<clipPath id="wormholeClip">
  <circle cx="337" cy="335" r="237" />
</clipPath>
"""

GIF_LAYERS = """<image class="wormhole-gif" href="images/wormhole.gif" x="29" y="27" width="616" height="616" preserveAspectRatio="xMidYMid slice" clip-path="url(#wormholeClip)"/>
<image class="blackhole-gif" href="images/blackhole.gif" x="29" y="27" width="616" height="616" preserveAspectRatio="xMidYMid slice" clip-path="url(#wormholeClip)"/>
"""

CSS_RULES_BASE = """
/* WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH START */
div:not(.active) .ring-1 .wormhole-gif,
div:not(.active) .ring-1 .blackhole-gif {
  display: none;
}

.ring-1 .blackhole-gif,
.border.black-hole-active .ring-1 .wormhole-gif {
  display: none;
}

.border.black-hole-active .ring-1 .blackhole-gif {
  display: block;
}

.ring-1 .wormhole-gif {
  pointer-events: none;
  animation: wormholeSpin 240s linear infinite;
  transform-box: fill-box;
  transform-origin: center center;
}

.ring-1 .blackhole-gif {
  pointer-events: none;
}

@keyframes wormholeSpin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
"""

CSS_CROSSHAIR = """
.crosshair {
  display: none !important;
}
"""

CSS_END = """/* WORMHOLE BLACKHOLE GIF UNIVERSAL PATCH END */
"""

def write(path: Path, text: str):
    if not dry_run:
        path.write_text(text, encoding="utf-8")

def patch_html(path: Path):
    text = path.read_text(encoding="utf-8", errors="ignore")
    original = text

    if 'class="wormhole-gif"' in text and 'class="blackhole-gif"' in text:
        print(f"already has GIF layers: {path}")
    else:
        if 'id="wormholeClip"' not in text:
            new_text = re.sub(
                r'(<radialGradient\b[^>]*id=["\']radialGradient["\'])',
                CLIP + r'\n\1',
                text,
                count=1,
                flags=re.I
            )
            text = new_text

        exact = '<circle cx="337" cy="335" r="237" stroke="var(--color)" fill="url(#radialGradient)" stroke-width="4.96px"/></svg>'
        if exact in text:
            repl = HTML_PATCH_NOTE + "\n" + GIF_LAYERS + '<circle cx="337" cy="335" r="237" stroke="var(--color)" fill="transparent" stroke-width="4.96px"/></svg>'
            text = text.replace(exact, repl, 1)
        else:
            pattern = re.compile(
                r'(<circle\b(?=[^>]*\bcx=["\']337["\'])(?=[^>]*\bcy=["\']335["\'])(?=[^>]*\br=["\']237["\'])(?=[^>]*fill=["\']url\(#radialGradient\)["\'])[^>]*/?>)',
                re.I
            )
            m = pattern.search(text)
            if m:
                circle = m.group(1)
                new_circle = re.sub(r'fill=["\']url\(#radialGradient\)["\']', 'fill="transparent"', circle, count=1, flags=re.I)
                text = text[:m.start()] + HTML_PATCH_NOTE + "\n" + GIF_LAYERS + new_circle + text[m.end():]
            else:
                ring = re.search(r'(<div[^>]+class=["\'][^"\']*ring-1[^"\']*["\'][\s\S]*?</svg>)', text, flags=re.I)
                if not ring:
                    raise SystemExit(f"ERROR: Cannot find ring-1 SVG block in {path}")

                block = ring.group(1)
                if 'id="wormholeClip"' not in block and 'id="wormholeClip"' not in text:
                    block = block.replace("<defs>", "<defs>\n" + CLIP, 1)

                insert_at = block.rfind("</svg>")
                if insert_at == -1:
                    raise SystemExit(f"ERROR: Cannot find </svg> in ring-1 block in {path}")

                block = block[:insert_at] + HTML_PATCH_NOTE + "\n" + GIF_LAYERS + block[insert_at:]
                text = text[:ring.start()] + block + text[ring.end():]

    if text != original:
        write(path, text)
        print(f"patched HTML: {path}")
    else:
        print(f"no HTML changes needed: {path}")

def patch_css(path: Path):
    text = path.read_text(encoding="utf-8", errors="ignore")
    original = text

    text = re.sub(
        re.escape(PATCH_START) + r'[\s\S]*?' + re.escape(PATCH_END),
        '',
        text,
        flags=re.I
    ).rstrip() + "\n\n"

    rules = CSS_RULES_BASE
    if hide_crosshair:
        rules += CSS_CROSSHAIR
    rules += CSS_END

    text += rules

    if text != original:
        write(path, text)
        print(f"patched CSS: {path}")
    else:
        print(f"no CSS changes needed: {path}")

def patch_dial_js(path: Path):
    if not path.exists():
        print(f"missing JS, skipping black hole state patch: {path}")
        return

    text = path.read_text(encoding="utf-8", errors="ignore")
    original = text

    if "const CLASS_BLACK_HOLE = 'black-hole-active';" not in text:
        marker = "const STATE_DIAL_IN = 'dialing_in';"
        if marker not in text:
            raise SystemExit(f"ERROR: Cannot find state constants in {path}")
        text = text.replace(
            marker,
            marker + "\nconst CLASS_BLACK_HOLE = 'black-hole-active';",
            1
        )

    if "function updateBlackHoleGifState()" not in text:
        marker = "function updateDestination(lastXGlyphs) {"
        if marker not in text:
            raise SystemExit(f"ERROR: Cannot find updateDestination() in {path}")
        fn = """function updateBlackHoleGifState() {
  border.classList.toggle(
    CLASS_BLACK_HOLE,
    state === STATE_ACTIVE &&
      gateStatus.wormhole_active &&
      gateStatus.black_hole_connected,
  );
}

"""
        text = text.replace(marker, fn + marker, 1)

    if "updateBlackHoleGifState();" not in text:
        marker = "  if (gdo.state === 'recognized' || gdo.state === 'complete') {"
        if marker not in text:
            raise SystemExit(f"ERROR: Cannot find GDO status block in {path}")
        text = text.replace(marker, "  updateBlackHoleGifState();\n\n" + marker, 1)

    if text != original:
        write(path, text)
        print(f"patched JS black hole state: {path}")
    else:
        print(f"no JS black hole state changes needed: {path}")

for rel in ("retro/dial.html", "retro/dial9.html"):
    patch_html(target / rel)

for rel in ("retro/css/dial.css", "retro/css/dial9.css"):
    patch_css(target / rel)

patch_dial_js(target / "retro/js/dial.js")
PY

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run completed."
else
  echo "Installed successfully."
  echo "Backup saved at: $BACKUP_DIR"
fi
