#!/usr/bin/env bash
# Installation initiale du site sur un VPS Debian/Ubuntu avec Nginx.
# A lancer UNE FOIS, en root, une fois que le DNS de
# beja-chauffage-plomberie.fr et www.beja-chauffage-plomberie.fr pointe vers ce VPS.
#
#   curl -fsSL https://raw.githubusercontent.com/Daujat-Baptiste/plomberie.github.io/main/deploy/setup-vps.sh | bash
#   ou : bash deploy/setup-vps.sh
set -euo pipefail

DOMAIN="beja-chauffage-plomberie.fr"
REPO="https://github.com/Daujat-Baptiste/plomberie.github.io.git"
ROOT="/var/www/${DOMAIN}"
CONF_SRC="${ROOT}/deploy/nginx/${DOMAIN}.conf"
CONF_DST="/etc/nginx/sites-available/${DOMAIN}.conf"
EMAIL="${CERTBOT_EMAIL:-contact@beja-chauffage.fr}"

[ "$(id -u)" -eq 0 ] || { echo "Lancer en root (sudo)." >&2; exit 1; }

echo "== Paquets"
apt-get update -qq
apt-get install -y -qq nginx git certbot

echo "== Code du site -> ${ROOT}"
if [ -d "${ROOT}/.git" ]; then
  git -C "${ROOT}" pull --ff-only
else
  git clone --depth 1 "${REPO}" "${ROOT}"
fi
chown -R root:www-data "${ROOT}"
chmod -R u=rwX,g=rX,o=rX "${ROOT}"

echo "== Config Nginx temporaire (HTTP seul) pour le challenge ACME"
cat > "${CONF_DST}" <<NGX
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${ROOT};
    location ^~ /.well-known/acme-challenge/ { root ${ROOT}; }
    location / { try_files \$uri \$uri/ =404; }
}
NGX
ln -sf "${CONF_DST}" "/etc/nginx/sites-enabled/${DOMAIN}.conf"
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "== Certificat Let's Encrypt"
certbot certonly --webroot -w "${ROOT}" \
  -d "${DOMAIN}" -d "www.${DOMAIN}" \
  --email "${EMAIL}" --agree-tos --no-eff-email --non-interactive

# Fichiers SSL partages references par la config finale
if [ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]; then
  curl -fsSL https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf \
    -o /etc/letsencrypt/options-ssl-nginx.conf
fi
if [ ! -f /etc/letsencrypt/ssl-dhparams.pem ]; then
  openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
fi

echo "== Config Nginx finale (HTTPS, redirections, cache, 404)"
cp "${CONF_SRC}" "${CONF_DST}"
nginx -t && systemctl reload nginx

echo "== Renouvellement automatique"
systemctl enable --now certbot.timer 2>/dev/null || true

echo
echo "OK  Site en ligne : https://www.${DOMAIN}/"
echo "    Mise a jour ulterieure : bash ${ROOT}/deploy/deploy.sh"
