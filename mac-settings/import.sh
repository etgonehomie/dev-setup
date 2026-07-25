#!/bin/bash
set -euo pipefail

SOURCE_SCRIPT="${HOME}/.config/dev-setup/mac-settings-export/exported-settings.sh"
DRY_RUN=false

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

usage() {
  cat <<'EOF'
Usage: import.sh [options]

Options:
  --source <path>  Path to exported-settings.sh (default: ~/.config/dev-setup/mac-settings-export/exported-settings.sh)
  --dry-run        Show source file and exit without applying settings
  --help           Show this help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source) SOURCE_SCRIPT="$2"; shift 2 ;;
      --dry-run) DRY_RUN=true; shift ;;
      --help|-h) usage; exit 0 ;;
      *) log "Unknown option: $1"; usage; exit 1 ;;
    esac
  done
}

main() {
  [[ "$(uname -s)" == "Darwin" ]] || { log "Error: macOS only."; exit 1; }
  parse_args "$@"

  if [[ ! -f "${SOURCE_SCRIPT}" ]]; then
    log "Error: source settings script not found at ${SOURCE_SCRIPT}"
    exit 1
  fi

  if [[ "${DRY_RUN}" == "true" ]]; then
    log "Dry-run: would run ${SOURCE_SCRIPT}"
    exit 0
  fi

  bash "${SOURCE_SCRIPT}"
  log "Mac settings import complete."
}

main "$@"
