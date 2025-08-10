# shellcheck shell=sh
app_main() {
  [ $# -lt 1 ] && die "Veuillez fournir un répertoire cible. Ex: blueprint app my-app"
  target="$1"; shift || true

  WITH_FRONTEND=""; WITH_BACKEND=""; WITH_AUTH=""; DB=""; NO_DB=""; AUTO_RUN=1; FORCE=""; MERGE=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --with-frontend) WITH_FRONTEND=1 ;;
      --with-backend)  WITH_BACKEND=1  ;;
      --with-auth)     WITH_AUTH=1     ;;
      --db=*)          DB="${1#--db=}" ;;
      --no-db)         NO_DB=1         ;;
      --no-run)        AUTO_RUN=""     ;;
      --force|-f)      FORCE=1         ;;
      --merge|-m)      MERGE=1         ;;
      *) die "Option inconnue: $1"     ;;
    esac; shift || true
  done

  # Règles
  [ -z "${WITH_FRONTEND}${WITH_BACKEND}" ] && die "Vous devez préciser au moins --with-frontend ou --with-backend"
  [ -n "${WITH_AUTH}" ] && [ -z "${WITH_BACKEND}" ] && die "--with-auth requiert --with-backend"
  [ -n "${WITH_AUTH}" ] && [ -n "${NO_DB}" ] && die "--with-auth nécessite une base (retirez --no-db)"
  [ -n "${DB}" ] && [ -z "${WITH_BACKEND}" ] && die "--db requiert --with-backend"
  [ -n "${DB}" ] && [ "$DB" != "mysql" ] && die "Seul --db=mysql est supporté (pour l'instant)"

  dest="$(pwd)/$target"
  ensure_target_dir "$dest" "$FORCE" "$MERGE"

  banner
  say "📁 Création du projet: ${BOLD}$dest${RESET}"

  # Base
  copy_tree "$SCRIPT_DIR/templates/base" "$dest"

  # Frontend
  if [ -n "${WITH_FRONTEND}" ]; then
    copy_tree "$SCRIPT_DIR/templates/modules/frontend/blueprints" "$dest/.blueprint/frontend"
    mkdir -p "$dest/frontend"
    if [ -d "$dest/.blueprint/frontend/app" ]; then
      (cd "$dest/.blueprint/frontend/app" && tar cf - .) | (cd "$dest/frontend" && tar xpf -)
    else
      (cd "$dest/.blueprint/frontend" && tar cf - .) | (cd "$dest/frontend" && tar xpf -)
    fi
    ok "Frontend matérialisé → frontend/"
  fi

  # Backend
  if [ -n "${WITH_BACKEND}" ]; then
    copy_tree "$SCRIPT_DIR/templates/modules/backend" "$dest"
    copy_tree "$SCRIPT_DIR/templates/modules/backend/blueprints" "$dest/.blueprint/backend"
    ok "Backend préparé (nginx/php + blueprints)"
  fi

  # CI
  if [ -d "$SCRIPT_DIR/templates/modules/ci/blueprints" ]; then
    copy_tree "$SCRIPT_DIR/templates/modules/ci/blueprints" "$dest/.blueprint/ci"
    mkdir -p "$dest/.github/workflows"
    if [ -d "$dest/.blueprint/ci/github/workflows" ]; then
      (cd "$dest/.blueprint/ci/github/workflows" && tar cf - .) | (cd "$dest/.github/workflows" && tar xpf -)
    fi
  fi

  # Compose
  WITH_MYSQL="0"
  if [ -n "${WITH_BACKEND}" ]; then
    if   [ -n "${NO_DB}" ]; then WITH_MYSQL="0"
    elif [ -n "${DB}"    ]; then WITH_MYSQL="1"
    else                          WITH_MYSQL="1"
    fi
  fi
  gen_compose "$dest" "${WITH_FRONTEND:+1}" "${WITH_BACKEND:+1}" "$WITH_MYSQL"
  ok "docker-compose.yml généré"

  # Makefiles
  place_makefiles "$dest" "${WITH_FRONTEND:+1}" "${WITH_BACKEND:+1}"

  # README
  gen_readme_from_fragments "$dest" "$(basename -- "$dest")" "${WITH_FRONTEND:+1}" "${WITH_BACKEND:+1}"

  # Vite patch
  if [ -n "${WITH_FRONTEND}" ]; then
    vite="$dest/frontend/vite.config.ts"
    if [ -f "$vite" ]; then
      if [ -n "${WITH_BACKEND}" ]; then vite_patch_from_modules "$vite" backend; else vite_patch_from_modules "$vite" clear; fi
    else
      warn "vite.config.ts introuvable à $vite — patch ignoré"
    fi
  fi

  # Tokens
  render_tokens "$dest" "$(basename -- "$dest")"

  # Notes
  if [ -n "${WITH_BACKEND}" ]; then
    [ "$WITH_MYSQL" = "1" ] && say "🗄️  MySQL activé par défaut (désactivez via --no-db)."
    [ -n "${WITH_AUTH}" ] && say "🔐 JWT/refresh: utilisez ${BOLD}make jwt${RESET} après ${BOLD}make init-backend${RESET}."
  fi

  ok "Projet créé: $dest"

  # Clean
  cleanup_blueprint_dirs "$dest"

  # Auto-run
  if [ -n "${AUTO_RUN}" ]; then
    (
      cd "$dest"
      dc up -d
      if [ -n "${WITH_BACKEND}" ]; then
        backend_init_skeleton "$dest"
        make -C backend -s db-url >/dev/null 2>&1 || true
      fi
    )
    [ -n "${WITH_FRONTEND}" ] && say "→ Front: Vite en route (5173) via Docker."
    [ -n "${WITH_BACKEND}" ] && say "→ Back: Nginx 8080, Symfony initialisé. (/api/ping après 'make ping')"
  fi
}
