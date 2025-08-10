# $_app

Généré par **blueprint** (module backend uniquement).

## 📦 Stack
- **Backend** : Symfony 7.3, PHP 8.4 (nginx + php-fpm)
- **Base de données** : MySQL (activée par défaut, désactivable via `--no-db`)
- **Qualité** :
    - PHPUnit (tests unitaires)
    - PHPStan (analyse statique)
- **Makefile** : commandes utilitaires (`make help` pour la liste)

---

## 🚀 Démarrer le projet

```bash
docker compose up -d
```

## 🌐 Points d’accès
- **API** : [http://localhost:8080](http://localhost:8080)
- **Ping de test** : [http://localhost:8080/api/ping](http://localhost:8080/api/ping)

---

## 🛠 Commandes utiles

```bash
# Lister toutes les commandes make disponibles
make help

# Lancer les tests PHPUnit
make test

# Analyse statique PHPStan
make phpstan
```

## 📁 Structure générée

**backend/**
- **config/** : Configuration Symfony
- **public/** : Point d'entrée public (index.php)
- **src/** : Code applicatif
- **tests/** : Tests unitaires
- **vendor/** : Dépendances PHP (générées par Composer)
- **Makefile** : Commandes backend

## ⚙️ Variables d’environnement

- **.env.local** : fichier local pour surcharger la configuration Symfony.  
  Exemple pour MySQL par défaut :
  ```dotenv
  DATABASE_URL="mysql://app:app@mysql:3306/app?serverVersion=8.4"
  
## 📑 Notes

- MySQL est lancé automatiquement si activé.
- Si vous utilisez un autre SGBD, adaptez la variable DATABASE_URL.
- Après modification des dépendances PHP, reconstruisez le service :
```bash
docker compose build php
```
