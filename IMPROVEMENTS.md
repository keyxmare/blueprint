# 🔧 Axes d'amélioration

## Court terme
### Support PostgreSQL
- Permettre à Blueprint de générer une stack backend avec PostgreSQL comme alternative à MySQL.
- Ajouter le fragment `postgres.yml` dans `templates/modules/compose` et la configuration Doctrine associée.

### Support Caddy
- Proposer un serveur Caddy en option à la place de nginx.
- Inclure un fragment de configuration Caddy prêt à l’emploi.

### Interface de configuration
- Développer une interface CLI interactive ou web pour sélectionner les options du projet sans passer par des flags.
- Possibilité de sauvegarder un profil de configuration.

---

## Moyen terme
### Tests e2e frontend ↔ backend
- Automatiser les tests bout-en-bout entre Vue 3 (frontend) et Symfony (backend) via Playwright.
- Intégration des tests dans le pipeline CI.

### Mode staging
- Ajouter un fichier `docker-compose.override.yml` spécifique au staging.
- Configurations adaptées : variables d’environnement, logs, services tiers.

### Configuration Traefik
- Offrir une alternative de reverse proxy avec Traefik pour le routage dynamique.
- Inclure la configuration TLS/Let's Encrypt automatique.

---

## Long terme
### Internationalisation (i18n)
- Ajouter un système d’internationalisation pour le frontend Vue 3.
- Support multi-langues et gestion des traductions (ex: vue-i18n).
