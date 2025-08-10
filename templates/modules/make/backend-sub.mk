SHELL := /bin/sh
.DEFAULT_GOAL := help

ROOT        := $(abspath $(CURDIR)/..)
COMPOSE     ?= docker compose --project-directory $(ROOT) -f $(ROOT)/docker-compose.yml
PHP_WD      ?= /var/www/html
COMPOSER_RUN = docker run --rm -u $$(id -u):$$(id -g) -v $(CURDIR):/app -w /app composer:2 sh -lc

.PHONY: help init-backend db-url ping jwt auth auth-migrate doctrine-install maker-install db-create db-diff db-migrate db-reset fixtures backend-quality-sync quality-backend-setup phpstan cs cs-fix phpunit xdebug-on xdebug-off xdebug-status doctor

help: ## 📖 Aide backend (Symfony/DB/JWT/Qualité/Xdebug)
	@printf "\n\033[1m🧱 Backend\033[0m  (dir: %s)\n" "$(notdir $(CURDIR))"
	@awk -F':.*## ' '/^[a-zA-Z0-9_.-]+:.*## /{printf "  \033[33m%-28s\033[0m %s\n", $$1, $$2}' $(firstword $(MAKEFILE_LIST))
	@printf "\n"

db-url: ## 🔗 Écrit DATABASE_URL MySQL dans .env.local
	@printf "DATABASE_URL=mysql://app:app@mysql:3306/app?serverVersion=8.4&charset=utf8mb4\n" > .env.local
	@echo "Écrit .env.local"

ping: ## 🧪 Ajoute /api/ping (depuis .blueprint)
	@test -d $(ROOT)/.blueprint/backend/ping || { echo ".blueprint/backend/ping manquant"; exit 1; }
	@mkdir -p src/Controller
	@(cd $(ROOT)/.blueprint/backend/ping && tar cf - .) | (cd . && tar xpf -)
	@echo "Ping OK: GET /api/ping"

jwt: ## 🔐 Installe JWT (+refresh) via composer:2 puis génère les clés avec PHP
	$(COMPOSER_RUN) 'composer require lexik/jwt-authentication-bundle gesdinet/jwt-refresh-token-bundle'
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc 'php bin/console lexik:jwt:generate-keypair --overwrite || true'

auth: ## 🔑 Copie templates Auth + installe bundles (composer:2) + clés
	@test -d $(ROOT)/.blueprint/backend/auth || { echo ".blueprint/backend/auth manquant"; exit 1; }
	@(cd $(ROOT)/.blueprint/backend/auth && tar cf - .) | (cd . && tar xpf -)
	$(COMPOSER_RUN) 'composer require symfony/security-bundle lexik/jwt-authentication-bundle gesdinet/jwt-refresh-token-bundle'
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc 'php bin/console lexik:jwt:generate-keypair --overwrite --no-interaction'
	@echo "Auth copiée et installée. → make auth-migrate"

auth-migrate: ## 🗃️  Diff + Migrate pour Auth (User/RefreshToken)
	$(COMPOSER_RUN) 'composer show symfony/orm-pack >/dev/null 2>&1 || composer require symfony/orm-pack doctrine/doctrine-migrations-bundle'
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc '\
	  php bin/console doctrine:migrations:diff; \
	  php bin/console doctrine:migrations:migrate -n \
	'

doctrine-install: ## 🧬 Installe Doctrine ORM + Migrations (composer:2)
	$(COMPOSER_RUN) 'composer require symfony/orm-pack doctrine/doctrine-migrations-bundle'

maker-install: ## 🛠️  Installe MakerBundle (dev) (composer:2)
	$(COMPOSER_RUN) 'composer require --dev symfony/maker-bundle'

db-create:   ## 🗄️  Crée la base si absente
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "php bin/console doctrine:database:create --if-not-exists"
db-diff:     ## 🧭 Génère une migration depuis les entités
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "php bin/console doctrine:migrations:diff"
db-migrate:  ## ⏩ Applique les migrations
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "php bin/console doctrine:migrations:migrate -n"
db-reset:    ## ♻️  Reset local (drop/create/migrate)
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc '\
	  php bin/console doctrine:database:drop --if-exists --force; \
	  php bin/console doctrine:database:create; \
	  php bin/console doctrine:migrations:migrate -n \
	'
fixtures:    ## 🌱 Indication pour fixtures
	@echo "composer require --dev doctrine/doctrine-fixtures-bundle && php bin/console doctrine:fixtures:load -n"

backend-quality-sync: ## 📦 Copie fichiers qualité depuis .blueprint → backend
	@test -d $(ROOT)/.blueprint/backend/quality || { echo ".blueprint/backend/quality manquant"; exit 1; }
	@(cd $(ROOT)/.blueprint/backend/quality && tar cf - .) | (cd . && tar xpf -)
	@mkdir -p tests var/phpstan

quality-backend-setup: backend-quality-sync ## 🧰 Installe php-cs-fixer/phpstan/phpunit (composer:2)
	$(COMPOSER_RUN) 'composer require --dev friendsofphp/php-cs-fixer phpstan/phpstan phpunit/phpunit'

phpstan:   ## 🔎 Analyse statique
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "vendor/bin/phpstan analyse --memory-limit=512M"
cs:        ## 🧼 Lint CS (dry-run)
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "vendor/bin/php-cs-fixer fix --dry-run --diff --using-cache=no"
cs-fix:    ## 🧽 Fix CS (write)
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "vendor/bin/php-cs-fixer fix --using-cache=no"
phpunit:   ## 🧪 Tests PHPUnit
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc "vendor/bin/phpunit"

xdebug-on: ## 🐞 Active Xdebug (port 9003) puis restart php-fpm
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc '\
	  cat > /usr/local/etc/php/conf.d/zz-xdebug.ini << "INI"\n\
zend_extension=xdebug\n\
xdebug.mode=debug,develop\n\
xdebug.start_with_request=trigger\n\
xdebug.client_port=9003\n\
xdebug.discover_client_host=1\n\
xdebug.client_host=host.docker.internal\n\
xdebug.idekey=PHPSTORM\n\
INI'
	$(COMPOSE) restart php
	@echo "Xdebug ON — ajoute ?XDEBUG_SESSION=1"

xdebug-off: ## 🚫 Désactive Xdebug (supprime ini) puis restart php-fpm
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc 'rm -f /usr/local/etc/php/conf.d/zz-xdebug.ini || true'
	$(COMPOSE) restart php
	@echo "Xdebug OFF."

xdebug-status: ## 📡 Affiche la présence de Xdebug
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc 'php -v && echo "---" && php -m | grep -i xdebug || true'

doctor: ## 🩺 Vérifie les montages et workdir
	@echo "== php =="; \
	$(COMPOSE) exec -T -w $(PHP_WD) php sh -lc 'echo "PWD=$$PWD"; ls -la . || true'
