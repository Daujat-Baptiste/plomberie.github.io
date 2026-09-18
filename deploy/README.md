# Déploiement sur VPS (Nginx)

Le site est statique : il est servi directement depuis un clone du dépôt.

## Première installation

Prérequis : enregistrements DNS `A` (et `AAAA` si IPv6) de `beja-chauffage-plomberie.fr`
et `www.beja-chauffage-plomberie.fr` pointant vers le VPS, ports 80 et 443 ouverts.

```bash
ssh root@VPS
curl -fsSL https://raw.githubusercontent.com/Daujat-Baptiste/plomberie.github.io/main/deploy/setup-vps.sh | bash
```

Le script installe Nginx, Git et Certbot, clone le dépôt dans
`/var/www/beja-chauffage-plomberie.fr`, obtient le certificat Let's Encrypt
puis active `deploy/nginx/beja-chauffage-plomberie.fr.conf`.

## Mise à jour

Après un `git push` sur `main` :

```bash
ssh root@VPS bash /var/www/beja-chauffage-plomberie.fr/deploy/deploy.sh
```

## Vérification

```bash
curl -I http://beja-chauffage-plomberie.fr/                 # 301 vers https://www.
curl -I https://beja-chauffage-plomberie.fr/                # 301 vers https://www.
curl -I https://www.beja-chauffage-plomberie.fr/            # 200
curl -I https://www.beja-chauffage-plomberie.fr/index.html          # 301 vers /
curl -I https://www.beja-chauffage-plomberie.fr/realisations.html   # 301 vers /realisations
curl -I https://www.beja-chauffage-plomberie.fr/realisations        # 200
curl -I https://www.beja-chauffage-plomberie.fr/inexistant  # 404 (page 404.html)
curl -I https://www.beja-chauffage-plomberie.fr/.git/config # 404
```

Le fichier `.htaccess` à la racine est ignoré par Nginx. Il ne sert que si le
site est un jour hébergé sous Apache.
