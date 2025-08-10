# shellcheck shell=sh
mkfile() { _p="$1"; shift || true; mkdir -p "$(dirname -- "$_p")"; cat >"$_p"; }
copy_tree() { _src="$1"; _dst="$2"; [ -d "$_src" ] || return 0; mkdir -p "$_dst"; (cd "$_src" && tar cf - .) | (cd "$_dst" && tar xpf -); }

sedi() {
  if command -v gsed >/dev/null 2>&1; then gsed -i "$1" "$2"; else sed -i '' "$1" "$2"; fi
}

render_tokens() {
  base="$1"; app="$2"
  LC_ALL=C find "$base" \
    -type d \( -name .git -o -name vendor -o -name node_modules -o -name dist -o -name coverage -o -name .next -o -name build -o -name public -o -name .idea -o -name .vscode \) -prune -o \
    -type f ! -name "*.png" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.gif" ! -name "*.ico" ! -name "*.webp" ! -name "*.pdf" ! -name "*.woff" ! -name "*.woff2" ! -name "*.ttf" \
    -exec sh -c '
      for f do
        mime=$(file -b --mime-type "$f" 2>/dev/null || echo text/plain)
        case "$mime" in
          text/*|application/json|application/xml|application/javascript)
            # échappe / & |
            safe_app=$(printf %s "$app" | sed "s/[\/&|]/\\\\&/g")
            if sed --version >/dev/null 2>&1; then
              LC_ALL=C sed -i -e "s|__APP_NAME__|$safe_app|g" "$f"
            else
              LC_ALL=C sed -i "" -e "s|__APP_NAME__|$safe_app|g" "$f"
            fi
            ;;
        esac
      done
    ' sh {} +
}

is_dir_empty() {
  _d="$1"
  [ ! -d "$_d" ] && return 0
  [ -z "$(ls -A "$_d" 2>/dev/null)" ]
}

clean_dir_preserve_git() {
  _d="$1"
  find "$_d" -mindepth 1 -maxdepth 1 \
    ! -name '.git' \
    ! -name 'backend' \
    ! -name 'frontend' \
    -exec rm -rf {} + 2>/dev/null || true

  for sub in backend frontend; do
    [ -d "$_d/$sub" ] || continue
    find "$_d/$sub" -mindepth 1 -maxdepth 1 \
      -exec rm -rf {} + 2>/dev/null || true
  done
}

prompt_overwrite_decision() {
  _dest="$1"
  printf "📁 Le dossier %s existe et n'est pas vide.\n" "$_dest"
  printf "Que souhaitez-vous faire ? [o] Écraser  [m] Fusionner  [a] Annuler %s" "> "
  if [ -t 0 ]; then IFS= read -r ans; else ans="a"; fi
  case "$ans" in o|O) echo "overwrite";; m|M) echo "merge";; *) echo "cancel";; esac
}

ensure_target_dir() {
  _dest="$1"; _force="$2"; _merge="$3"
  mkdir -p "$_dest"
  if is_dir_empty "$_dest"; then return 0; fi

  if [ -n "$_force" ]; then
    maybe_down_compose "$_dest"
    clean_dir_preserve_git "$_dest"
    ok "Dossier nettoyé (préservation .git)."
    return 0
  fi
  if [ -n "$_merge" ]; then
    warn "Fusion vers dossier existant : les fichiers en conflit seront écrasés."
    return 0
  fi

  action="$(prompt_overwrite_decision "$_dest")"
  case "$action" in
    overwrite) clean_dir_preserve_git "$_dest"; ok "Dossier nettoyé (préservation .git)." ;;
    merge)     warn "Fusion vers dossier existant : les fichiers en conflit seront écrasés." ;;
    *)         die "Opération annulée." ;;
  esac
}

cleanup_blueprint_dirs() {
  _dest="$1"

  rm -rf "$_dest/.blueprint" 2>/dev/null || true
  find "$_dest" -type d -name "blueprints" -exec rm -rf {} + 2>/dev/null || true
  rm -rf "$_dest/quality" 2>/dev/null || true
}
