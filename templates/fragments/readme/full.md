# $_app

Généré par **blueprint** (modules frontend + backend).

## 📦 Stack
- **Frontend** : Vue 3 + Vite + TypeScript
- **Backend** : Symfony 7.3, PHP 8.4 (nginx + php-fpm)
- **Base de données** : MySQL (activée par défaut, désactivable via `--no-db`)
- **Qualité** :
  - PHPUnit / PHPStan
  - Vitest / Playwright
- **Makefile** : commandes globales et par sous-projet

---

## 🚀 Démarrer le projet

```bash
docker compose up -d
make init-backend
make dev
```

## 🌐 Points d’accès
- **Frontend** : [http://localhost:5173](http://localhost:5173)
- **API** : [http://localhost:8080](http://localhost:8080)
- **Ping de test** : [http://localhost:8080/api/ping](http://localhost:8080/api/ping)

## 🔧 Intégration Front ↔ Back
- ```vite.config.ts``` est patché automatiquement :
   - **Proxy API** : requêtes ```/api``` redirigées vers nginx (backend)
   - **Build** : assets sortis dans ```backend/public/build``` (sans vider le répertoire)
- Côté backend, nginx sert ```/var/www/public``` et le front sert en dev depuis Vite.

## 🛠 Commandes utiles
```bash
# Global
make help
make up           # démarre les services
make down         # arrête les services

# Frontend
make dev          # Vite dev server
make build        # build de production
make test         # tests unitaires (Vitest)
make e2e          # tests end-to-end (Playwright)

# Backend
make init-backend # skeleton Symfony + deps
make test         # PHPUnit
make phpstan      # analyse statique
```

## 📁 Structure générée

**frontend/**
- **index.html**
- **src/**
- **tests/** : Vitest
- **e2e/** : Playwright
- **tsconfig.json**
- **vite.config.ts**

**backend/**
- **config/**
- **public/** : Point d'entrée public (index.php) + /build (assets)
- **src/**
- **tests/** : PHPUnit
- **vendor/**
- **Makefile**

## ⚙️ Variables d’environnement (backend)
```dotenv
DATABASE_URL="mysql://app:app@mysql:3306/app?serverVersion=8.4"
```

## 🧱 Build & déploiement
- **Dev** : Vite en mode dev **(port 5173)**, API sur **8080**.
- **Prod build** :

```bash
make build            # génère frontend/public/build
```
Les assets sont copiés dans ```backend/public/build``` (via patch Vite), et servis par nginx.

## 📑 Notes
- Si vous utilisez ```--force``` avec des conteneurs en cours d’exécution, évitez de supprimer les dossiers montés (```frontend/```, ```backend/```).
- En cas de nettoyage agressif, arrêtez d’abord : ```docker compose down -v```.

Si ```node_modules``` disparaît pendant que Vite tourne, relancez ```npm install``` / ```make dev```.