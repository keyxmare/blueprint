# shellcheck shell=sh
say()   { printf "%s\n" "$*"; }
ok()    { printf "%s✅ %s%s\n" "$C_GRN" "$*" "$RESET"; }
warn()  { printf "%s⚠️  %s%s\n" "$C_YEL" "$*" "$RESET" >&2; }
err()   { printf "%s❌ %s%s\n" "$C_RED" "$*" "$RESET" >&2; }
die()   { err "$*"; exit 1; }

banner() {
  printf "\n%s🧩  %sblueprint%s — générateur mono-repo modulaire%s  v%s\n\n" \
    "$BOLD" "$C_CYAN" "$RESET" "$BOLD" "$VERSION"
}

usage() {
  banner
  cat <<'EOF'
Usage:
  blueprint app <directory> [--with-frontend] [--with-backend] [--with-auth] [--db=mysql] [--no-db] [--no-run] [--force] [--merge]

Options:
  --force    : écrase le dossier cible (préserve .git) sans poser de question
  --merge    : fusionne dans le dossier existant (écrase les fichiers en conflit)

Règles:
  • Au moins l'un de --with-frontend ou --with-backend est requis.
  • --with-auth et --db=* seulement si --with-backend est présent.
  • DB: MySQL par défaut si backend présent (désactive avec --no-db).

Exemples:
  blueprint app my-front  --with-frontend
  blueprint app my-back   --with-backend
  blueprint app my-full   --with-frontend --with-backend --db=mysql --with-auth
EOF
}
