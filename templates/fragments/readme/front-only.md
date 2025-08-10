# $_app

Généré par **blueprint** (module frontend uniquement).

## 📦 Stack
- **Backend** : Vue 3 + Vite + TypeScript
- **Tests* : Vitest + Playwright (e2e)
- **Makefile** : commandes utilitaires (`make help` pour la liste)

---

## 🚀 Démarrer le projet

```bash
docker compose up -d
```

## 🌐 Points d’accès
- **App** : [http://localhost:5173](http://localhost:5173)

---

## 🛠 Commandes utiles

```bash
# Lister toutes les commandes make disponibles
make help

# Build de production
make build

# Tests unitaires (Vitest)
make test

# Tests end-to-end (Playwright)
make e2e
```

## 📁 Structure générée

**frontend/**
- **index.html**
- **src/** : Code applicatif (Vue 3 + TS)
- **src/router/** : Router
- **src/stores/** : State (Pinia)
- **src/views/** : Pages
- **tests/** : Tests unitaires (Vitest)
- **e2e/** : Tests e2e (Playwright)
- **tsconfig.json**
- **vite.config.ts**
- **package.json**

## ⚙️ Env & config

- Vite est préconfiguré pour le mode standalone (sans backend).
- Pour un futur backend : un patch automatique ajoutera le proxy API (```/api```) et la sortie build vers le dossier backend.

## 📑 Notes

- Si node_modules a été nettoyé pendant que Vite tournait, relancez ```npm install``` ou ```make dev```.
- Le build de prod génère les assets dans ```frontend/dist/```.