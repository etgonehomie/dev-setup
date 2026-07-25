#!/bin/bash
set -euo pipefail

EXPORT_DIR="${HOME}/.config/dev-setup/mac-settings-export"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MAC_EXPORT_VARS_FILE="${SCRIPT_DIR}/mac-export-vars.yml"
FORCE=false

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

usage() {
  cat <<'EOF'
Usage: export-once.sh [options]

Options:
  --output-dir <path>  Export directory (default: ~/.config/dev-setup/mac-settings-export)
  --force              Overwrite existing export directory
  --help               Show this help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output-dir) EXPORT_DIR="$2"; shift 2 ;;
      --force) FORCE=true; shift ;;
      --help|-h) usage; exit 0 ;;
      *) log "Unknown option: $1"; usage; exit 1 ;;
    esac
  done
}

ensure_export_dir() {
  if [[ -e "${EXPORT_DIR}" && "${FORCE}" != "true" ]]; then
    log "Error: ${EXPORT_DIR} already exists. Re-run with --force to overwrite."
    exit 1
  fi
  if [[ -e "${EXPORT_DIR}" && "${FORCE}" == "true" ]]; then
    rm -rf "${EXPORT_DIR}"
  fi
  mkdir -p "${EXPORT_DIR}/domains"
}

export_domain_plists() {
  local domain
  local domains=()
  [[ -f "${MAC_EXPORT_VARS_FILE}" ]] || { log "Error: domain vars file not found at ${MAC_EXPORT_VARS_FILE}"; exit 1; }

  mapfile -t domains < <(sed -n 's/^[[:space:]]*-[[:space:]]*domain:[[:space:]]*"\([^"]\+\)".*/\1/p' "${MAC_EXPORT_VARS_FILE}")
  [[ ${#domains[@]} -gt 0 ]] || { log "Error: no domains found in ${MAC_EXPORT_VARS_FILE}"; exit 1; }

  for domain in "${domains[@]}"; do
    if defaults export "${domain}" "${EXPORT_DIR}/domains/${domain}.plist" >/dev/null 2>&1; then
      log "Exported ${domain}"
    else
      log "Skipped ${domain} (domain unavailable on this Mac)"
    fi
  done
}

write_metadata() {
  cat > "${EXPORT_DIR}/metadata.txt" <<EOF
created_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
source_hostname=$(scutil --get LocalHostName 2>/dev/null || hostname)
source_macos=$(sw_vers -productVersion)
EOF
}

write_apply_script() {
  cat > "${EXPORT_DIR}/exported-settings.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOMAINS_DIR="${SCRIPT_DIR}/domains"

if [[ ! -d "${DOMAINS_DIR}" ]]; then
  echo "Error: domains directory missing at ${DOMAINS_DIR}" >&2
  exit 1
fi

shopt -s nullglob
domain_files=("${DOMAINS_DIR}"/*.plist)
if [[ ${#domain_files[@]} -eq 0 ]]; then
  echo "Error: no domain plist files found in ${DOMAINS_DIR}" >&2
  exit 1
fi

for domain_file in "${domain_files[@]}"; do
  domain="$(basename "${domain_file}" .plist)"
  defaults import "${domain}" "${domain_file}"
  echo "Applied ${domain}"
done
EOF
  chmod +x "${EXPORT_DIR}/exported-settings.sh"
}

main() {
  [[ "$(uname -s)" == "Darwin" ]] || { log "Error: macOS only."; exit 1; }
  parse_args "$@"
  ensure_export_dir
  export_domain_plists
  write_metadata
  write_apply_script
  log "Export complete: ${EXPORT_DIR}"
  log "Import on a new Mac with: bash ${EXPORT_DIR}/exported-settings.sh"
}

main "$@"
