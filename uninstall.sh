#!/usr/bin/env bash
set -Eeuo pipefail
PANEL_DIR="${PTERODACTYL_DIR:-/var/www/pterodactyl}"
ROOT="$PANEL_DIR/storage/zypehost-backups"
die(){ echo "[ZypeHost] ERROR: $*" >&2; exit 1; }
[[ -d "$ROOT" ]] || die "Kein ZypeHost-Backup gefunden."
LATEST="$(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)"
[[ -n "$LATEST" && -d "$LATEST" ]] || die "Kein Backup gefunden."
echo "Letztes Backup: $LATEST"
read -r -p "Theme entfernen und letztes Backup wiederherstellen? [yes/no] " answer
[[ "$answer" == yes ]] || exit 0
restore(){ local rel="$1"; [[ -e "$LATEST/$rel" ]] || return 0; mkdir -p "$(dirname "$PANEL_DIR/$rel")"; cp -a "$LATEST/$rel" "$PANEL_DIR/$rel"; }
restore resources/scripts/index.tsx
restore resources/views/layouts/admin.blade.php
restore .env
rm -rf "$PANEL_DIR/resources/scripts/zypehost" "$PANEL_DIR/public/themes/zypehost"
cd "$PANEL_DIR"
php artisan optimize:clear
php artisan view:clear || true
if command -v yarn >/dev/null 2>&1 && yarn run 2>/dev/null | grep -q 'build:production'; then yarn build:production; fi
php artisan up || true
echo "ZypeHost Theme entfernt."
