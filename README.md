# ZypeHost Pterodactyl Theme

Eigenständiges ZypeHost-Branding für ein Pterodactyl Panel.

Enthält:
- ZypeHost Branding und Favicon
- globale Dark-Oberfläche
- Login-Seite Styling
- Dashboard-/Karten-/Button-Styling
- Sidebar/Navigation Styling
- Server-/Console-Styling
- responsive Mobile-Regeln
- dezente Animationen
- Admin-CSS
- Backup vor Installation
- Uninstaller mit Wiederherstellung des letzten Backups

## Installation

ZIP auf den Server kopieren, z.B. nach `/root`, dann:

```bash
unzip ZypeHost-Pterodactyl-Theme.zip -d /root/zypehost-theme
cd /root/zypehost-theme
bash install.sh
```

Standard ist `/var/www/pterodactyl`.

Alternative:

```bash
PTERODACTYL_DIR=/var/www/pterodactyl bash install.sh
```

## Entfernen

```bash
cd /root/zypehost-theme
bash uninstall.sh
```

## GitHub Ein-Befehl-Installation

Nachdem du den Inhalt in ein öffentliches GitHub-Repository hochgeladen hast:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/DEIN-ACCOUNT/zypehost-theme/main/install.sh)
```

Vor produktivem Einsatz zuerst auf einer Testinstallation prüfen. Das Paket verändert das Pterodactyl-Frontend und erstellt deshalb vor der Installation ein Backup.
