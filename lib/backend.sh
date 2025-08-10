# shellcheck shell=sh
backend_init_skeleton() {
  _root="$1"
  _appdir="$_root/backend"

  mkdir -p "$_appdir"

  if [ -f "$_appdir/composer.json" ]; then
    warn "backend/composer.json existe déjà — création du skeleton ignorée."
    return 0
  fi

  say "🏗️  Création du skeleton Symfony 7.3 (composer:2 via docker run)…"
  run_composer_container "$_appdir" '\
    set -eu; \
    tmp="$(mktemp -d)"; \
    composer create-project symfony/skeleton:"^7.3" "$tmp" >/dev/null 2>&1; \
    find /app -mindepth 1 -maxdepth 1 \
      ! -name Makefile \
      ! -name .git \
      ! -name .env.local \
      -exec rm -rf {} +; \
    cp -a "$tmp/." /app/; \
  ' || die "Échec de création du skeleton Symfony."

  ok "Symfony créé dans backend/. Pensez à: make db-url"
}
