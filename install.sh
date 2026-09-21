#!/usr/bin/env bash
set -Eeuo pipefail

PANEL_DIR="${PTERODACTYL_DIR:-/var/www/pterodactyl}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/theme"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$PANEL_DIR/storage/zypehost-backups/$STAMP"

fail(){ echo "[ZypeHost] ERROR: $*" >&2; exit 1; }

[[ -d "$PANEL_DIR" ]] || fail "Panel-Verzeichnis nicht gefunden: $PANEL_DIR"
[[ -f "$PANEL_DIR/artisan" ]] || fail "artisan fehlt."
[[ -f "$PANEL_DIR/package.json" ]] || fail "package.json fehlt."
[[ -f "$PANEL_DIR/resources/scripts/index.tsx" ]] || fail "resources/scripts/index.tsx fehlt."
[[ -d "$SOURCE_DIR" ]] || fail "Theme-Dateien fehlen."

mkdir -p "$BACKUP_DIR"

backup(){
  local src="$1" rel="$2"
  if [[ -e "$src" ]]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    cp -a "$src" "$BACKUP_DIR/$rel"
  fi
}

echo "[ZypeHost] Backup wird erstellt..."
backup "$PANEL_DIR/resources/scripts/index.tsx" "resources/scripts/index.tsx"
backup "$PANEL_DIR/resources/views/layouts/admin.blade.php" "resources/views/layouts/admin.blade.php"
backup "$PANEL_DIR/.env" ".env"

mkdir -p "$PANEL_DIR/resources/scripts/zypehost" "$PANEL_DIR/public/themes/zypehost"
cp -a "$SOURCE_DIR/resources/scripts/zypehost/." "$PANEL_DIR/resources/scripts/zypehost/"
cp -a "$SOURCE_DIR/public/themes/zypehost/." "$PANEL_DIR/public/themes/zypehost/"

# ZypeHost-Logo von dem von dir angegebenen GitHub-Commit laden.
if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --connect-timeout 10 "https://raw.githubusercontent.com/vrbrille053-boop/Teama/5988d018d2e8674cac0a84c8c4be3ce6531e6951/0cac12af-dfee-416c-ae51-baf13e899cee.jpeg" \
        -o "$PANEL_DIR/public/themes/zypehost/logo.jpeg"
else
    echo "[ZypeHost] WARNUNG: curl fehlt; Logo wurde nicht geladen."
fi

INDEX="$PANEL_DIR/resources/scripts/index.tsx"
if ! grep -q "./zypehost/theme" "$INDEX"; then
  tmp=$(mktemp)
  printf "%s\n" "import './zypehost/theme';" > "$tmp"
  cat "$INDEX" >> "$tmp"
  mv "$tmp" "$INDEX"
fi

if [[ -f "$PANEL_DIR/.env" ]]; then
  if grep -q '^APP_NAME=' "$PANEL_DIR/.env"; then
    sed -i -E 's/^APP_NAME=.*/APP_NAME=ZypeHost/' "$PANEL_DIR/.env"
  else
    printf '\nAPP_NAME=ZypeHost\n' >> "$PANEL_DIR/.env"
  fi
fi

# Admin-Vue: keine harte Ersetzung des kompletten Layouts, nur das ZypeHost-CSS/Favicon einhängen.
ADMIN="$PANEL_DIR/resources/views/layouts/admin.blade.php"
if [[ -f "$ADMIN" ]] && ! grep -q "/themes/zypehost/admin.css" "$ADMIN"; then
python3 - "$ADMIN" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
needle='</head>'
block='''<!-- ZypeHost Theme -->\n<link rel="icon" type="image/svg+xml" href="/themes/zypehost/zypehost.svg">\n<link rel="stylesheet" href="/themes/zypehost/admin.css">\n<!-- /ZypeHost Theme -->\n'''
if needle in s:
    p.write_text(s.replace(needle, block+needle, 1), encoding='utf-8')
PY
fi

cd "$PANEL_DIR"
php artisan optimize:clear
php artisan view:clear || true

if command -v yarn >/dev/null 2>&1; then
  if yarn run 2>/dev/null | grep -q 'build:production'; then
    yarn build:production
  elif yarn run 2>/dev/null | grep -q '^  build'; then
    yarn build || true
  else
    echo "[ZypeHost] Kein kompatibler Frontend-Build erkannt."
  fi
else
  echo "[ZypeHost] yarn nicht gefunden. Frontend bitte passend zur Panel-Version bauen."
fi

if id www-data >/dev/null 2>&1; then
  chown -R www-data:www-data "$PANEL_DIR/resources/scripts/zypehost" "$PANEL_DIR/public/themes/zypehost"
fi

php artisan up || true

echo
echo "=========================================="
echo "ZypeHost Theme installiert."
echo "Backup: $BACKUP_DIR"
echo "=========================================="
