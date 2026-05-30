#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-/home/pi/sg1_v4/web}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TARGET" == "--target" ]]; then
  TARGET="${2:-/home/pi/sg1_v4/web}"
fi

python3 "$SCRIPT_DIR/remove_overlay.py" "$TARGET"

echo "=== RETRO WORMHOLE GIF SURGICAL REMOVE COMPLETE ==="
