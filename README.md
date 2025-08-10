# 🧩 Blueprint

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Blueprint** est un générateur de projets **mono-repo** modulaires (frontend + backend) avec Docker, Makefile et CI intégrés.  
Il permet de créer rapidement des stacks prêtes à l’emploi basées sur **Vue 3** et **Symfony**, avec une configuration simplifiée pour démarrer immédiatement.

---

## ✨ Fonctionnalités
- **Frontend** : Vue 3 + Vite + TypeScript
- **Backend** : Symfony 7.3 + PHP 8.4 (nginx/php-fpm)
- **Base de données** : MySQL (PostgreSQL prévu)
- **CI/CD** : GitHub Actions
- **Outils développeur** : Makefiles, fragments Docker Compose, scripts d’initialisation

---

## 🚀 Installation

Cloner le dépôt :
```bash
git clone https://github.com/<user>/blueprint.git
cd blueprint
```

Rendre le script exécutable :
```bash
chmod +x bin/blueprint
```

---

## 📦 Commande principale

```bash
./blueprint app <directory> [options]
```

### Options
| Option               | Description |
|----------------------|-------------|
| `--with-frontend`    | Ajoute le module frontend (Vue 3 + Vite) |
| `--with-backend`     | Ajoute le module backend (Symfony + nginx/php-fpm) |
| `--with-auth`        | Ajoute un module d’authentification JWT (backend requis) |
| `--db=mysql`         | Active MySQL (par défaut si backend présent) |
| `--no-db`            | Désactive la base de données |
| `--force` / `-f`     | Écrase le dossier cible (préserve `.git`) |
| `--merge` / `-m`     | Fusionne avec le dossier existant |
| `--no-run`           | Génère le projet sans lancer `docker compose up` |

---

## 📋 Exemples d’utilisation

**Frontend seul** :
```bash
./blueprint app my-front --with-frontend
```

**Backend seul avec MySQL** :
```bash
./blueprint app my-back --with-backend --db=mysql
```

**Stack complète** :
```bash
./blueprint app my-full --with-frontend --with-backend --db=mysql --with-auth
```

---

## 📂 Structure des templates

```
templates/
├── base/              # Fichiers communs (.gitignore, .editorconfig, etc.)
├── modules/
│   ├── frontend/      # Vue 3 + Vite + TS
│   ├── backend/       # Symfony + nginx/php-fpm
│   ├── compose/       # Fragments docker-compose
│   ├── make/          # Fragments Makefile
│   └── ci/            # Fragments CI/CD
└── fragments/         # README pré-formatés
```

---

## 🤝 Contribution
Les PR sont les bienvenues !  
Merci de respecter les conventions de commit ([Conventional Commits](https://www.conventionalcommits.org/)) et d’ajouter des tests si nécessaire.

---

## 📜 Licence
Ce projet est sous licence **MIT**. Voir [LICENSE](LICENSE) pour plus d’informations.
