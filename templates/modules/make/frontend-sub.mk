SHELL := /bin/sh
.DEFAULT_GOAL := help

ROOT    := $(abspath $(CURDIR)/..)
COMPOSE ?= docker compose -f $(ROOT)/docker-compose.yml

.PHONY: help dev test e2e front-sync front-quality-sync lint lint-fix format format-fix typecheck check

help: ## 📖 Aide frontend (Vite/Tests/Lint/Format/Types)
	@printf "\n\033[1m🎨 Frontend\033[0m  (dir: %s)\n" "$(notdir $(CURDIR))"
	@awk -F':.*## ' '/^[a-zA-Z0-9_.-]+:.*## /{printf "  \033[35m%-28s\033[0m %s\n", $$1, $$2}' $(firstword $(MAKEFILE_LIST))
	@printf "\n"

front-sync: ## 📦 Copie le blueprint front → ./ (structure app/ ou racine)
	@test -d $(ROOT)/.blueprint/frontend || { echo ".blueprint/frontend manquant"; exit 1; }
	@mkdir -p .
	@if [ -d $(ROOT)/.blueprint/frontend/app ]; then \
	  (cd $(ROOT)/.blueprint/frontend/app && tar cf - .) | (cd . && tar xpf -); \
	else \
	  (cd $(ROOT)/.blueprint/frontend && tar cf - .) | (cd . && tar xpf -); \
	fi
	@echo "Frontend synchronisé."

front-quality-sync: ## 🧰 Recopie aussi ESLint/Prettier/etc.
	@$(MAKE) front-sync

dev:        ## 🚀 Vite dev server (port 5173)
	$(COMPOSE) exec -it frontend sh -lc "npm run dev -- --host 0.0.0.0"
test:       ## 🧪 Tests unitaires (vitest)
	$(COMPOSE) exec -it frontend sh -lc "npm test"
e2e:        ## 🧭 Tests e2e (Playwright)
	$(COMPOSE) exec -it frontend sh -lc "npm run e2e"
lint:       ## 🔎 ESLint
	$(COMPOSE) exec -it frontend sh -lc "npm run lint"
lint-fix:   ## 🧹 ESLint --fix
	$(COMPOSE) exec -it frontend sh -lc "npm run lint:fix"
format:     ## 🖋️  Prettier --check
	$(COMPOSE) exec -it frontend sh -lc "npm run format"
format-fix: ## ✍️  Prettier --write
	$(COMPOSE) exec -it frontend sh -lc "npm run format:fix"
typecheck:  ## ⛑️  TypeScript --noEmit
	$(COMPOSE) exec -it frontend sh -lc "npm run typecheck"
check:      ## ✅ Typecheck + Lint + Tests
	$(COMPOSE) exec -it frontend sh -lc "npm run check"
