# shellcheck shell=sh
dc() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@" || true
  else
    docker-compose "$@" || true
  fi
}

maybe_down_compose() {
  _root="$1"
  command -v docker >/dev/null 2>&1 || return 0
  [ -f "$_root/docker-compose.yml" ] || return 0
  if (cd "$_root" && docker compose ps -q | grep -q .); then
    warn "Conteneurs actifs détectés — arrêt avant --force."
    (cd "$_root" && docker compose down) || true
  fi
}

run_composer_container() {
  _workdir="$1"; shift || true
  _cmd="$*"
  if command -v docker >/dev/null 2>&1; then
    uid="$(id -u 2>/dev/null || echo 1000)"
    gid="$(id -g 2>/dev/null || echo 1000)"
    cache_dir="${COMPOSER_CACHE_DIR:-$HOME/.composer/cache}"
    docker run --rm \
      -u "$uid:$gid" \
      -v "$_workdir":/app \
      -v "$cache_dir":/tmp/composer-cache \
      -e COMPOSER_CACHE_DIR=/tmp/composer-cache \
      -w /app \
      composer:2 sh -lc "$_cmd"
  else
    die "Docker indisponible — exécution impossible."
  fi
}

run_backend_command() {
  _cmd="$*"
  if command -v docker >/dev/null 2>&1; then
	dc exec -T -w "/var/www/html" php sh -lc "$_cmd"
  else
	die "Docker indisponible — exécution impossible."
  fi
}