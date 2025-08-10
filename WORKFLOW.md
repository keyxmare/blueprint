# Workflow (modulaire)

- **bin/** : scripts exécutables (point d’entrée CLI)
- **commands/** : commandes utilisateurs (logique haut-niveau, ex: app.sh)
- **lib/** : fonctions utilitaires réutilisables (fs, docker, ui, vite…)
- **templates/ : contenu statique servant à générer les projets

### `bin/`
- **`blueprint`** : script principal appelé par l’utilisateur.  
  Charge les librairies (`lib/*.sh`) et exécute la commande demandée (`commands/*.sh`).

### `commands/`
- **`app.sh`** : implémentation de la commande `blueprint app ...`.  
  C’est ici que sont :
    - Analysés les arguments/flags (`--with-frontend`, `--force`…)
    - Déterminées les étapes à exécuter
    - Appelées les fonctions utilitaires de `lib/`

### `lib/`
Bibliothèques organisées par domaine :
- **`backend.sh`** : fonctions liées à l’initialisation du backend (skeleton Symfony…)
- **`constants.sh`** : variables globales (chemins, version…)
- **`docker.sh`** : wrapper Docker/Docker Compose
- **`fragments.sh`** : assemblage de fragments (`docker-compose.yml`, README…)
- **`fs.sh`** : gestion des fichiers/dossiers (nettoyage, copie, merge…)
- **`ui.sh`** : fonctions d’affichage (bannières, couleurs, messages…)
- **`vite.sh`** : patch de `vite.config.ts` selon les modules

---

## 📂 Templates

### `templates/base/`
Fichiers communs à **tous** les projets (ex: `.editorconfig`, `.gitignore`).

### `templates/fragments/`
Fragments de README (`front-only.md`, `back-only.md`, `full.md`) utilisés pour générer la documentation initiale du projet selon les modules sélectionnés.

### `templates/modules/`
Chaque sous-dossier est un *module* :
- **`backend/`** : config nginx, PHP, qualité (phpstan/phpunit), blueprints de fonctionnalités (`ping`, `auth`…)
- **`frontend/`** : blueprint Vue 3 + Vite + TS, patchs de config Vite
- **`compose/`** : fragments `docker-compose.yml` pour chaque service
- **`make/`** : fragments Makefile (`global.mk`, `backend-sub.mk`, `frontend-sub.mk`)
- **`ci/`** : workflows CI/CD (GitHub Actions)

---

## ⚙️ Commande principale

```bash
./blueprint app <dir> [--with-frontend] [--with-backend] [--with-auth] [--db=mysql] [--no-db] [--force] [--merge] [--no-run]
```

### Règles
- Au moins **un** de `--with-frontend` ou `--with-backend` est requis.
- `--with-auth` et `--db=*` → uniquement avec backend.
- Si backend → MySQL par défaut (désactivable avec `--no-db`).
- `--db` supporte uniquement `mysql` pour l’instant.

---

## 🔄 Cycle de génération

1. **Préparation du dossier cible**
    - Création si inexistant.
    - `--force` → nettoyage préservant `.git` et dépendances actives (`node_modules`, `vendor`).
    - `--merge` → fusion (écrasement fichiers en conflit).
    - Sinon → prompt interactif.

2. **Copie des bases** (`templates/base/` → projet)

3. **Ajout des modules sélectionnés**
    - Frontend : blueprint Vue 3/Vite, patch Vite, Makefile.
    - Backend : config nginx/PHP, blueprints backend, Makefile.

4. **Ajout éventuel de CI/CD**
    - Copie des workflows GitHub Actions si présents.

5. **Assemblage `docker-compose.yml`**
    - Concatène les fragments nécessaires (`compose/*.yml`).

6. **Génération des Makefiles**
    - Global + spécifiques au frontend/backend.

7. **README**
    - Généré à partir des fragments (`fragments/readme/*.md`).

8. **Patch Vite**
    - Applique ou retire le proxy/API et la config build selon présence du backend.

9. **Remplacement des tokens**
    - Remplace `__APP_NAME__` et autres placeholders dans tous les fichiers texte.

10. **Lancement automatique** *(sauf `--no-run`)*
    - `docker compose up -d`
    - Backend présent → création du skeleton Symfony (`make init-backend`).

---

## 🚀 Exemples

```bash
# Frontend seul
./blueprint app my-front --with-frontend

# Backend seul
./blueprint app my-back --with-backend

# Full-stack avec auth et MySQL
./blueprint app my-full --with-frontend --with-backend --db=mysql --with-auth
```
