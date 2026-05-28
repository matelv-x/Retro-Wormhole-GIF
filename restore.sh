#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-/home/pi/sg1_v4/web}"
if [[ "$TARGET" == "--target" ]]; then
  TARGET="${2:-/home/pi/sg1_v4/web}"
fi
if [[ "$TARGET" == */sg1_v4 ]]; then
  TARGET="$TARGET/web"
fi

fail() { echo "ERROR: $1" >&2; exit 1; }

[ -d "$TARGET" ] || fail "Target web folder not found: $TARGET"

if ! sudo -n true 2>/dev/null; then
  echo "This restore needs sudo because stargate files may be owned by root."
  sudo true
fi

BACKUP="$(ls -dt "$TARGET"/backups/wormhole-blackhole-gif-universal-* 2>/dev/null | head -n 1 || true)"
[ -n "$BACKUP" ] || fail "No Retro Wormhole GIF backup found in $TARGET/backups"
[ -d "$BACKUP" ] || fail "Backup folder does not exist: $BACKUP"

echo "Restoring Retro Wormhole GIF files from:"
echo "  $BACKUP"

sudo systemctl stop stargate.service || true

for rel in \
  "retro/dial.html" \
  "retro/dial9.html" \
  "retro/css/dial.css" \
  "retro/css/dial9.css" \
  "retro/js/dial.js" \
  "retro/images/wormhole.gif" \
  "retro/images/blackhole.gif"
do
  if [ -e "$BACKUP/$rel" ]; then
    sudo mkdir -p "$(dirname "$TARGET/$rel")"
    sudo rm -rf "$TARGET/$rel"
    sudo cp -a "$BACKUP/$rel" "$TARGET/$rel"
    echo "Restored: $rel"
  else
    sudo rm -rf "$TARGET/$rel"
    echo "Removed installed file with no original backup: $rel"
  fi
done

sudo chown -R pi:pi "$TARGET/retro" "$TARGET/backups" 2>/dev/null || true
sudo systemctl start stargate.service

echo "=== RETRO WORMHOLE GIF RESTORE COMPLETE ==="
