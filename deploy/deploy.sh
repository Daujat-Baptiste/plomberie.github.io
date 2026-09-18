#!/usr/bin/env bash
# Mise a jour du site sur le VPS : recupere la derniere version de main
# depuis GitHub et recharge Nginx. A lancer en root sur le VPS.
set -euo pipefail

DOMAIN="beja-chauffage-plomberie.fr"
ROOT="/var/www/${DOMAIN}"

[ "$(id -u)" -eq 0 ] || { echo "Lancer en root (sudo)." >&2; exit 1; }

echo "== git pull"
git -C "${ROOT}" pull --ff-only
chown -R root:www-data "${ROOT}"
chmod -R u=rwX,g=rX,o=rX "${ROOT}"

echo "== Config Nginx"
cp "${ROOT}/deploy/nginx/${DOMAIN}.conf" "/etc/nginx/sites-available/${DOMAIN}.conf"
nginx -t && systemctl reload nginx

echo "OK  Deploye : $(git -C "${ROOT}" log -1 --format='%h %s')"
