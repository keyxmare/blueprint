# shellcheck shell=sh
VERSION="1.1.0"
# Si bin/blueprint est appelé via PATH, re-résoudre la racine repo:
[ -n "${SCRIPT_DIR:-}" ] || SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"

# Style/couleurs
BOLD="$(printf '\033[1m')"; DIM="$(printf '\033[2m')"; RESET="$(printf '\033[0m')"
C_CYAN="$(printf '\033[36m')"; C_YEL="$(printf '\033[33m')"; C_MAG="$(printf '\033[35m')"; C_RED="$(printf '\033[31m')"; C_GRN="$(printf '\033[32m')"
