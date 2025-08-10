# shellcheck shell=sh
vite_patch_from_modules() {
  _vite="$1"; _mode="$2"
  _base="$SCRIPT_DIR/templates/modules/frontend/patches/vite"
  case "$_mode" in
    backend) _script="$_base/backend.ed" ;;
    clear)   _script="$_base/clear.ed" ;;
    *)       err "Mode vite inconnu: $_mode"; return 1 ;;
  esac
  [ -f "$_script" ] || { err "Patch Vite manquant: $_script"; return 1; }

  if command -v ed >/dev/null 2>&1; then
    ed -s "$_vite" < "$_script" && { ok "Vite patché (${_mode}) via modules"; return 0; }
    warn "ed a échoué — fallback sed"
  else
    warn "ed introuvable — fallback sed (brew install ed / apt-get install ed)"
  fi

  if [ "$_mode" = "backend" ]; then
    if command -v gsed >/dev/null 2>&1; then SED=gsed; else SED=sed; fi
    if "$SED" --version >/dev/null 2>&1; then
      "$SED" -i 's|__VITE_PROXY__|proxy: { "/api": { target: "http://nginx", changeOrigin: true } },|g' "$_vite"
      "$SED" -i 's|__VITE_BUILD__|build: { outDir: "../backend/public/build", emptyOutDir: false },|g' "$_vite"
    else
      "$SED" -i '' 's|__VITE_PROXY__|proxy: { "/api": { target: "http://nginx", changeOrigin: true } },|g' "$_vite"
      "$SED" -i '' 's|__VITE_BUILD__|build: { outDir: "../backend/public/build", emptyOutDir: false },|g' "$_vite"
    fi
  else
    if command -v gsed >/dev/null 2>&1; then SED=gsed; else SED=sed; fi
    if "$SED" --version >/dev/null 2>&1; then
      "$SED" -i 's|__VITE_PROXY__||g' "$_vite"
      "$SED" -i 's|__VITE_BUILD__||g' "$_vite"
    else
      "$SED" -i '' 's|__VITE_PROXY__||g' "$_vite"
      "$SED" -i '' 's|__VITE_BUILD__||g' "$_vite"
    fi
  fi
  ok "Vite patché (${_mode}) via sed (fallback)"
}
