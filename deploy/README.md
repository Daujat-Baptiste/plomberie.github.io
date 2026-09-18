# Déploiement sur VPS (Nginx derrière Traefik)

Le site est statique : il est servi directement depuis un clone du dépôt.

Ce VPS héberge plusieurs sites derrière un reverse proxy **Traefik** partagé
(conteneur Docker) qui termine le TLS (Let's Encrypt via DNS OVH) et gère la
redirection apex → www. Le vhost Nginx de ce site n'écoute donc **pas** sur
80/443 : il écoute en interne sur `127.0.0.1:8080` / `172.18.0.1:8080` et
Traefik lui transmet le trafic déjà déchiffré. La config Traefik correspondante
vit dans `/srv/traefik/dynamic/beja-chauffage-plomberie.yml` (hors de ce
dépôt).

## Première installation

Prérequis : le site est déjà enregistré dans `/srv/traefik/dynamic/` (DNS +
certificat gérés par Traefik). Sur le VPS :

```bash
bash deploy/setup-vps.sh
```

Le script installe Nginx et Git si besoin, clone le dépôt dans
`/srv/apps/beja-chauffage-plomberie/app`, puis active
`deploy/nginx/beja-chauffage-plomberie.conf`. Si le site n'est pas encore
enregistré dans Traefik, le script l'indique à la fin (voir son sortie).

## Mise à jour

Après un `git push` sur `main`, sur le VPS :

```bash
bash /srv/apps/beja-chauffage-plomberie/app/deploy/deploy.sh
```

(`git pull` tourne avec l'utilisateur propriétaire du dépôt ; seules la copie
de la conf Nginx et le reload utilisent `sudo`.)

## Vérification

```bash
curl -I http://beja-chauffage-plomberie.fr/                 # 301 vers https://www. (Traefik)
curl -I https://beja-chauffage-plomberie.fr/                # 301 vers https://www. (Traefik)
curl -I https://www.beja-chauffage-plomberie.fr/            # 200
curl -I https://www.beja-chauffage-plomberie.fr/index.html          # 301 vers /
curl -I https://www.beja-chauffage-plomberie.fr/realisations.html   # 301 vers /realisations
curl -I https://www.beja-chauffage-plomberie.fr/realisations        # 200
curl -I https://www.beja-chauffage-plomberie.fr/inexistant  # 404 (page 404.html)
curl -I https://www.beja-chauffage-plomberie.fr/.git/config # 404
```

Le fichier `.htaccess` à la racine est ignoré par Nginx. Il ne sert que si le
site est un jour hébergé sous Apache (ex. mutualisé OVH).
