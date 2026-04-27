# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Site web statique pour un plombier chauffagiste. Pages HTML/CSS/JS pures, sans framework ni build step — déployable directement sur un hébergement mutualisé ou GitHub Pages.

## Structure cible

```
index.html          # Accueil
services.html       # Services (plomberie, chauffage, sanitaire…)
realisations.html   # Galerie de réalisations
contact.html        # Formulaire de contact / coordonnées
css/
  style.css         # Feuille de styles principale
js/
  main.js           # Scripts communs (menu mobile, etc.)
img/                # Images optimisées (WebP prioritaire)
```

## Développement local

Ouvrir directement les fichiers HTML dans un navigateur, ou lancer un serveur local simple :

```bash
# Python (disponible partout)
python -m http.server 8080

# Node (si npx disponible)
npx serve .
```

Aucun build, aucune compilation nécessaire.

## Conventions

- HTML sémantique (`<header>`, `<main>`, `<section>`, `<footer>`, `<nav>`).
- CSS sans préprocesseur ; variables CSS (`--color-primary`, etc.) pour la cohérence.
- Pas de dépendances JS externes sauf justification explicite.
- Images : format WebP, dimensions raisonnables (max ~1200 px large), attributs `alt` obligatoires.
- Le formulaire de contact doit fonctionner sans JS côté client (attribut `action` vers un service tiers ou PHP si l'hébergeur le propose).

## SEO / accessibilité

- Balises `<title>` et `<meta name="description">` propres à chaque page.
- Balise `<meta name="viewport" content="width=device-width, initial-scale=1">` présente.
- Contraste suffisant (WCAG AA).
- Site responsive mobile-first.
