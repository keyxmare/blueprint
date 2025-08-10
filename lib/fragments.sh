# shellcheck shell=sh
gen_compose() {
  _proj="$1"; _with_front="$2"; _with_back="$3"; _with_mysql="$4"
  _out="$_proj/docker-compose.yml"
  mkfile "$_out" <<'YAML'
services:
YAML
  if [ "$_with_front" = "1" ]; then
    { cat "$SCRIPT_DIR/templates/modules/compose/frontend.yml"; printf "\n"; } >>"$_out"
  fi
  if [ "$_with_back" = "1" ]; then
    { cat "$SCRIPT_DIR/templates/modules/compose/php.yml";      printf "\n"; } >>"$_out"
    { cat "$SCRIPT_DIR/templates/modules/compose/nginx.yml";    printf "\n"; } >>"$_out"
    if [ "$_with_mysql" = "1" ]; then
      { cat "$SCRIPT_DIR/templates/modules/compose/mysql.yml";  printf "\n"; } >>"$_out"
      printf "volumes:\n  dbdata:\n" >>"$_out"
    fi
  fi
}

gen_readme_from_fragments() {
  _proj="$1"; _app="$2"; _with_front="$3"; _with_back="$4"
  _out="$_proj/README.md"
  if [ "$_with_front" = "1" ] && [ "$_with_back" = "1" ]; then
    _frag="$SCRIPT_DIR/templates/fragments/readme/full.md"
  elif [ "$_with_front" = "1" ]; then
    _frag="$SCRIPT_DIR/templates/fragments/readme/front-only.md"
  else
    _frag="$SCRIPT_DIR/templates/fragments/readme/back-only.md"
  fi
  [ -f "$_frag" ] || die "Fragment README manquant: $_frag"
  mkdir -p "$_proj"
  cp "$_frag" "$_out"
  sedi "s|__APP_NAME__|$_app|g" "$_out"
}

place_makefiles() {
  _proj="$1"; _with_front="$2"; _with_back="$3"
  cp "$SCRIPT_DIR/templates/modules/make/global.mk" "$_proj/Makefile"
  if [ "$_with_back" = "1" ]; then mkdir -p "$_proj/backend";  cp "$SCRIPT_DIR/templates/modules/make/backend-sub.mk"  "$_proj/backend/Makefile"; fi
  if [ "$_with_front" = "1" ]; then mkdir -p "$_proj/frontend"; cp "$SCRIPT_DIR/templates/modules/make/frontend-sub.mk" "$_proj/frontend/Makefile"; fi
}
