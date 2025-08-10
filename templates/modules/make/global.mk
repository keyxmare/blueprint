SHELL := /bin/sh
.DEFAULT_GOAL := help

FRONT_DIR ?= frontend
BACK_DIR  ?= backend
COMPOSE   ?= docker compose

DISPATCH_TARGETS := dev test e2e lint lint-fix format format-fix typecheck check init-backend db-url ping doctrine-install db-create db-diff db-migrate db-reset fixtures auth auth-migrate quality-backend-setup phpstan cs cs-fix phpunit jwt maker-install xdebug-on xdebug-off

.PHONY: help up down $(DISPATCH_TARGETS)

help: ## 📖 Affiche l'aide globale + sous-projets
	@printf "\n\033[1m🌐 Blueprint — commandes globales\033[0m\n"
	@awk -F':.*## ' '/^[a-zA-Z0-9_.-]+:.*## /{printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}' $(firstword $(MAKEFILE_LIST))
	for dir in "$(BACK_DIR)" "$(FRONT_DIR)"; do \
	  if [ -f "$$dir/Makefile" ] && grep -qE "^[[:space:]]*help:" "$$dir/Makefile"; then \
		$(MAKE) -C "$$dir" help; \
	  fi; \
	done
	@printf "\n"

up: ## 🚀 Démarre les services Docker (dev)
	$(COMPOSE) up -d

down: ## 🛑 Stoppe et supprime les services Docker
	$(COMPOSE) down

$(DISPATCH_TARGETS): ## ✨ Dispatche la cible du même nom vers back/front si disponible
	@t="$@"; \
	for dir in "$(BACK_DIR)" "$(FRONT_DIR)"; do \
	  if [ -f "$$dir/Makefile" ] && grep -qE "^[[:space:]]*$$t:" "$$dir/Makefile"; then \
	    echo "→ $$dir: make $$t"; \
	    $(MAKE) -C "$$dir" $$t || exit $$?; \
	  fi; \
	done
