#!/usr/bin/env bash
# Installation initiale du site sur ce VPS partagé.
#
# Ce VPS heberge plusieurs sites derriere un reverse proxy Traefik commun
# (TLS Let's Encrypt + redirection apex -> www geres par Traefik, pas par ce
# script). Ce script se contente de :
#   - cloner le depot
#   - installer/activer le vhost Nginx interne (ecoute 127.0.0.1:8080 et
#     172.18.0.1:8080, JAMAIS 80/443 : ces ports appartiennent a Traefik)
#
# A lancer UNE FOIS, en tant qu'utilisateur proprietaire du dossier
# /srv/apps (ubuntu sur ce VPS) :
#   bash deploy/setup-vps.sh
set -euo pipefail

DOMAIN="beja-chauffage-plomberie.fr"
REPO="https://github.com/Daujat-Baptiste/plomberie.github.io.git"
ROOT="/srv/apps/beja-chauffage-plomberie/app"
CONF="beja-chauffage-plomberie.conf"

echo "== Paquets"
sudo apt-get update -qq
sudo apt-get install -y -qq nginx git

echo "== Code du site -> ${ROOT}"
if [ -d "${ROOT}/.git" ]; then
  git -C "${ROOT}" pull --ff-only
else
  git clone --depth 1 "${REPO}" "${ROOT}"
fi

echo "== Config Nginx (vhost interne, derriere Traefik)"
sudo cp "${ROOT}/deploy/nginx/${CONF}" "/etc/nginx/sites-available/${CONF}"
sudo ln -sf "/etc/nginx/sites-available/${CONF}" "/etc/nginx/sites-enabled/${CONF}"
sudo nginx -t && sudo systemctl reload nginx

echo
echo "== Reste a faire manuellement =="
echo "Ce site doit etre enregistre aupres de Traefik pour recevoir le trafic"
echo "public (TLS + routage par domaine). Cree"
echo "  /srv/traefik/dynamic/beja-chauffage-plomberie.yml"
echo "sur le modele d'un site voisin deja en place (ex: /srv/traefik/dynamic/portfolio.yml),"
echo "en pointant le service vers http://172.18.0.1:8080 et en adaptant server_name/domains"
echo "a ${DOMAIN} et www.${DOMAIN}. Aucun redemarrage de Traefik n'est necessaire :"
echo "le provider file recharge automatiquement les fichiers de /srv/traefik/dynamic/."
echo
echo "Mise a jour ulterieure du site : bash ${ROOT}/deploy/deploy.sh"
