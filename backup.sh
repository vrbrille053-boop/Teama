#!/usr/bin/env bash
set -Eeuo pipefail
PANEL_DIR="${PTERODACTYL_DIR:-/var/www/pterodactyl}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="$PANEL_DIR/storage/zypehost-backups/manual-$STAMP"
mkdir -p "$DEST"
for rel in resources/scripts/index.tsx resources/views/layouts/admin.blade.php .env; do
  [[ -e "$PANEL_DIR/$rel" ]] || continue
  mkdir -p "$(dirname "$DEST/$rel")"
  cp -a "$PANEL_DIR/$rel" "$DEST/$rel"
done
echo "Backup: $DEST"
