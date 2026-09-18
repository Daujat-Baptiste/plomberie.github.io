#!/usr/bin/env bash
# Mise a jour du site sur le VPS : recupere la derniere version de main
# depuis GitHub et recharge Nginx.
#
# Le repo (proprietaire ubuntu:ubuntu, lisible par www-data) est mis a jour
# avec l'utilisateur courant ; seule la copie de la conf Nginx et le reload
# necessitent root (sudo).
set -euo pipefail

DOMAIN="beja-chauffage-plomberie.fr"
ROOT="/srv/apps/beja-chauffage-plomberie/app"
CONF="beja-chauffage-plomberie.conf"

echo "== git pull"
git -C "${ROOT}" pull --ff-only

echo "== Config Nginx"
sudo cp "${ROOT}/deploy/nginx/${CONF}" "/etc/nginx/sites-available/${CONF}"
sudo nginx -t && sudo systemctl reload nginx

echo "OK  Deploye : $(git -C "${ROOT}" log -1 --format='%h %s')"
