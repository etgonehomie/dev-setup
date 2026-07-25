#!/bin/bash
set -euo pipefail

GIT_REPO="https://github.com/etgonehomie/dev-setup.git"
PLAYBOOK_FILENAME="main.yml"
STATE_DIR="${HOME}/.local/state/dev-setup"
STATE_FILE="${STATE_DIR}/checkpoint.env"
REPORT_FILE="${STATE_DIR}/last-report.txt"
PROFILE_PATH="${HOME}/.config/dev-setup/profile.yml"

WIZARD_MODE=false
AUTO_CONFIRM=false
DRY_RUN=false
DO_UPGRADE=false
DO_CLEANUP=false
RESUME=false
APPLY_RAYCAST_CONFIG=false
DOTFILES_OVERWRITE_MODE="prompt"
GROUPS_CSV=""
PACKAGES_CSV=""

declare -a SELECTED_GROUPS=()
declare -a SELECTED_PACKAGE_IDS=()
declare -a PREINSTALLED_IDS=()

CATEGORY_ORDER=("core" "dev" "browsers" "productivity" "local-ai" "security" "data" "media-creator")

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

usage() {
  cat <<'EOF'
Usage: main.sh [options]

Options:
  --wizard                 Run interactive category/package wizard
  --yes                    Non-interactive mode; auto-confirm prompts
  --profile <path>         Load selections from profile YAML
  --groups <csv>           Category list (e.g., core,dev,productivity)
  --packages <csv>         Package IDs override (e.g., git,raycast,ollama)
  --raycast-config         Apply Raycast config import step
  --upgrade                Run brew upgrade before provisioning
  --cleanup                Cleanup ansible-pull cache after success
  --dry-run                Preview actions without mutating system
  --resume                 Resume from checkpoint file
  --help                   Show this help
EOF
}

category_label() {
  case "$1" in
    core) echo "Core CLI" ;;
    dev) echo "Developer Tools" ;;
    browsers) echo "Browsers" ;;
    productivity) echo "Productivity" ;;
    local-ai) echo "Local AI" ;;
    security) echo "Security" ;;
    data) echo "Data" ;;
    media-creator) echo "Media / Creator" ;;
    *) echo "$1" ;;
  esac
}

category_items() {
  case "$1" in
    core) echo "curl eza fzf bat zsh-autosuggestions zsh-autocomplete zsh-fast-syntax-highlighting neovim oh-my-posh git python" ;;
    dev) echo "iterm2 font-hack-nerd-font docker postman" ;;
    browsers) echo "google-chrome firefox vivaldi" ;;
    productivity) echo "raycast discord chatgpt obsidian" ;;
    local-ai) echo "ollama" ;;
    security) echo "tailscale 1password" ;;
    data) echo "tableplus dbeaver-community" ;;
    media-creator) echo "shottr 4k-video-downloader-plus" ;;
    *) echo "" ;;
  esac
}

package_kind() {
  case "$1" in
    curl|eza|fzf|bat|zsh-autosuggestions|zsh-autocomplete|zsh-fast-syntax-highlighting|neovim|oh-my-posh|git|python|ollama)
      echo "formula"
      ;;
    iterm2|font-hack-nerd-font|docker|postman|google-chrome|firefox|vivaldi|raycast|discord|chatgpt|obsidian|tailscale|1password|tableplus|dbeaver-community|shottr|4k-video-downloader-plus)
      echo "cask"
      ;;
    *)
      echo ""
      ;;
  esac
}

package_desc() {
  case "$1" in
    curl) echo "Download tooling" ;;
    eza) echo "Modern ls replacement" ;;
    fzf) echo "Fuzzy finder" ;;
    bat) echo "cat with syntax highlighting" ;;
    zsh-autosuggestions) echo "Shell suggestions" ;;
    zsh-autocomplete) echo "Shell autocomplete" ;;
    zsh-fast-syntax-highlighting) echo "Shell syntax highlighting" ;;
    neovim) echo "Editor" ;;
    oh-my-posh) echo "Prompt theming" ;;
    git) echo "Source control" ;;
    python) echo "Python runtime" ;;
    ollama) echo "Local LLM runtime" ;;
    iterm2) echo "Terminal app" ;;
    font-hack-nerd-font) echo "Nerd font" ;;
    docker) echo "Container runtime" ;;
    postman) echo "API client" ;;
    google-chrome|firefox|vivaldi) echo "Browser" ;;
    raycast) echo "Launcher and workflow app" ;;
    discord) echo "Messaging" ;;
    chatgpt) echo "Desktop AI app" ;;
    obsidian) echo "Notes" ;;
    tailscale) echo "Mesh VPN" ;;
    1password) echo "Password manager" ;;
    tableplus|dbeaver-community) echo "Database client" ;;
    shottr) echo "Screenshot utility" ;;
    4k-video-downloader-plus) echo "Media downloader" ;;
    *) echo "" ;;
  esac
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

ensure_state_dirs() {
  mkdir -p "${STATE_DIR}" "$(dirname "${PROFILE_PATH}")"
}

write_checkpoint() {
  local step="$1"
  mkdir -p "${STATE_DIR}"
  if [[ -f "${STATE_FILE}" ]] && grep -q "^${step}=done$" "${STATE_FILE}"; then
    return 0
  fi
  echo "${step}=done" >> "${STATE_FILE}"
}

step_done() {
  local step="$1"
  [[ -f "${STATE_FILE}" ]] && grep -q "^${step}=done$" "${STATE_FILE}"
}

should_skip_step() {
  local step="$1"
  [[ "${RESUME}" == "true" ]] && step_done "${step}"
}

append_unique() {
  local value="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "${item}" == "${value}" ]]; then
      return 1
    fi
  done
  return 0
}

array_contains() {
  local target="$1"
  shift
  local item
  for item in "$@"; do
    [[ "${item}" == "${target}" ]] && return 0
  done
  return 1
}

parse_csv_into_array() {
  local csv="$1"
  local out_name="$2"
  local raw token
  eval "${out_name}=()"
  [[ -z "${csv}" ]] && return 0
  IFS=',' read -r -a raw <<< "${csv}"
  for token in "${raw[@]}"; do
    token="$(echo "${token}" | xargs)"
    [[ -z "${token}" ]] && continue
    eval "${out_name}+=(\"\${token}\")"
  done
}

join_by_comma() {
  local IFS=','
  echo "$*"
}

confirm() {
  local prompt="$1"
  if [[ "${AUTO_CONFIRM}" == "true" ]]; then
    return 0
  fi
  if has_command gum; then
    gum confirm "${prompt}"
    return $?
  fi
  read -r -p "${prompt} [y/N] " choice
  [[ "${choice}" =~ ^[Yy]$ ]]
}

package_installed() {
  local package_id="$1"
  local kind
  kind="$(package_kind "${package_id}")"
  if ! has_command brew; then
    return 1
  fi
  if [[ "${kind}" == "formula" ]]; then
    brew list --formula "${package_id}" >/dev/null 2>&1
  else
    brew list --cask "${package_id}" >/dev/null 2>&1
  fi
}

record_preinstalled() {
  PREINSTALLED_IDS=()
  local package_id
  for package_id in "${SELECTED_PACKAGE_IDS[@]}"; do
    if package_installed "${package_id}"; then
      PREINSTALLED_IDS+=("${package_id}")
    fi
  done
}

is_preinstalled() {
  local package_id="$1"
  array_contains "${package_id}" "${PREINSTALLED_IDS[@]}"
}

is_mac() { [[ "$(uname -s)" == "Darwin" ]]; }
is_apple_silicon() { [[ "$(uname -m)" == "arm64" ]]; }

preflight_checks() {
  is_mac || { log "Error: macOS only."; exit 1; }
  has_command curl || { log "Error: curl is required."; exit 1; }
  curl -fsSI https://github.com >/dev/null || { log "Error: github.com unreachable."; exit 1; }
  curl -fsSI https://raw.githubusercontent.com >/dev/null || { log "Error: raw.githubusercontent.com unreachable."; exit 1; }

  if has_command sudo && ! sudo -n true >/dev/null 2>&1; then
    log "Sudo permission required. Prompting once..."
    sudo -v
  fi
}

detect_rosetta_requirement() {
  array_contains "4k-video-downloader-plus" "${SELECTED_PACKAGE_IDS[@]:-}"
}

ensure_rosetta_if_needed() {
  if ! is_apple_silicon || ! detect_rosetta_requirement; then
    return 0
  fi
  if /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
    log "Rosetta already installed."
    return 0
  fi
  if [[ "${DRY_RUN}" == "true" ]]; then
    log "Dry-run: would install Rosetta."
    return 0
  fi
  if confirm "Install Rosetta now?"; then
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
}

get_brew_prefix() {
  if is_apple_silicon; then echo "/opt/homebrew"; else echo "/usr/local"; fi
}

install_homebrew() {
  if has_command brew; then
    log "Homebrew already installed."
    return 0
  fi
  [[ "${DRY_RUN}" == "true" ]] && { log "Dry-run: would install Homebrew."; return 0; }
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

update_homebrew_paths() {
  local brew_prefix brew_path zprofile
  brew_prefix="$(get_brew_prefix)"
  brew_path="${brew_prefix}/bin/brew"
  zprofile="${HOME}/.zprofile"
  [[ -f "${zprofile}" ]] || touch "${zprofile}"
  if ! grep -q "eval \"\$(${brew_path} shellenv)\"" "${zprofile}" 2>/dev/null; then
    echo "eval \"\$(${brew_path} shellenv)\"" >> "${zprofile}"
  fi
  if [[ -x "${brew_path}" ]]; then
    eval "$("${brew_path}" shellenv)"
  fi
}

update_homebrew() { [[ "${DRY_RUN}" == "true" ]] || brew update; }
upgrade_homebrew() { [[ "${DO_UPGRADE}" == "true" && "${DRY_RUN}" != "true" ]] && brew upgrade || true; }

install_ansible() {
  if brew list ansible >/dev/null 2>&1; then
    return 0
  fi
  [[ "${DRY_RUN}" == "true" ]] && { log "Dry-run: would install ansible."; return 0; }
  brew install ansible
}

ensure_wizard_ui_deps() {
  [[ "${DRY_RUN}" == "true" ]] && { log "Dry-run: would install gum/fzf."; return 0; }
  if ! brew list gum >/dev/null 2>&1; then
    brew install gum || log "Warning: gum install failed; using plain prompts."
  fi
  if ! brew list fzf >/dev/null 2>&1; then
    brew install fzf || log "Warning: fzf install failed; using plain prompts."
  fi
}

select_packages_for_group() {
  local group="$1"
  local items item
  local missing_items=()
  items="$(category_items "${group}")"
  for item in ${items}; do
    if ! package_installed "${item}"; then
      missing_items+=("${item}")
    fi
  done
  [[ ${#missing_items[@]} -eq 0 ]] && { log "All ${group} items already installed."; return 0; }

  if confirm "Install all missing packages in '${group}'?"; then
    for item in "${missing_items[@]}"; do
      if append_unique "${item}" "${SELECTED_PACKAGE_IDS[@]:-}"; then
        SELECTED_PACKAGE_IDS+=("${item}")
      fi
    done
    return 0
  fi

  for item in "${missing_items[@]}"; do
    if confirm "Install ${item} ($(package_desc "${item}"))?"; then
      if append_unique "${item}" "${SELECTED_PACKAGE_IDS[@]:-}"; then
        SELECTED_PACKAGE_IDS+=("${item}")
      fi
    fi
  done
}

run_wizard() {
  SELECTED_GROUPS=()
  SELECTED_PACKAGE_IDS=()
  local group
  for group in "${CATEGORY_ORDER[@]}"; do
    if confirm "Enable $(category_label "${group}") (${group})?"; then
      SELECTED_GROUPS+=("${group}")
    fi
  done
  [[ ${#SELECTED_GROUPS[@]} -eq 0 ]] && { log "No categories selected."; exit 0; }

  for group in "${SELECTED_GROUPS[@]}"; do
    select_packages_for_group "${group}"
  done

  if array_contains "raycast" "${SELECTED_PACKAGE_IDS[@]:-}"; then
    if confirm "Apply Raycast settings import too?"; then
      APPLY_RAYCAST_CONFIG=true
    fi
  fi

  if confirm "Allow replacing existing dotfiles with timestamped backups?"; then
    DOTFILES_OVERWRITE_MODE="always"
  else
    DOTFILES_OVERWRITE_MODE="never"
  fi

  log "Groups: $(join_by_comma "${SELECTED_GROUPS[@]}")"
  log "Packages: $(join_by_comma "${SELECTED_PACKAGE_IDS[@]}")"
  confirm "Proceed with this plan?" || exit 1
  save_profile "${PROFILE_PATH}"
}

save_profile() {
  local profile_path="$1"
  mkdir -p "$(dirname "${profile_path}")"
  cat > "${profile_path}" <<EOF
groups: $(join_by_comma "${SELECTED_GROUPS[@]}")
packages: $(join_by_comma "${SELECTED_PACKAGE_IDS[@]}")
apply_raycast_config: ${APPLY_RAYCAST_CONFIG}
dotfiles_overwrite_mode: ${DOTFILES_OVERWRITE_MODE}
EOF
}

load_profile() {
  local profile_path="$1"
  [[ -f "${profile_path}" ]] || { log "Error: profile not found at ${profile_path}"; exit 1; }
  GROUPS_CSV="$(grep -E '^groups:' "${profile_path}" | head -1 | cut -d':' -f2- | xargs || true)"
  PACKAGES_CSV="$(grep -E '^packages:' "${profile_path}" | head -1 | cut -d':' -f2- | xargs || true)"
  local raycast_val dotfile_mode
  raycast_val="$(grep -E '^apply_raycast_config:' "${profile_path}" | head -1 | cut -d':' -f2- | xargs || true)"
  dotfile_mode="$(grep -E '^dotfiles_overwrite_mode:' "${profile_path}" | head -1 | cut -d':' -f2- | xargs || true)"
  [[ "${raycast_val}" == "true" ]] && APPLY_RAYCAST_CONFIG=true
  [[ -n "${dotfile_mode}" ]] && DOTFILES_OVERWRITE_MODE="${dotfile_mode}"
}

resolve_selection_from_flags() {
  if [[ -z "${SELECTED_GROUPS+_}" ]]; then SELECTED_GROUPS=(); fi
  if [[ -z "${SELECTED_PACKAGE_IDS+_}" ]]; then SELECTED_PACKAGE_IDS=(); fi
  if [[ -n "${GROUPS_CSV}" ]]; then
    parse_csv_into_array "${GROUPS_CSV}" SELECTED_GROUPS
  fi
  if [[ -n "${PACKAGES_CSV}" ]]; then
    parse_csv_into_array "${PACKAGES_CSV}" SELECTED_PACKAGE_IDS
  fi

  if [[ ${#SELECTED_GROUPS[@]} -gt 0 && ${#SELECTED_PACKAGE_IDS[@]} -eq 0 ]]; then
    local group item items
    for group in "${SELECTED_GROUPS[@]}"; do
      items="$(category_items "${group}")"
      for item in ${items}; do
        if append_unique "${item}" "${SELECTED_PACKAGE_IDS[@]:-}"; then
          SELECTED_PACKAGE_IDS+=("${item}")
        fi
      done
    done
  fi

  if [[ ${#SELECTED_GROUPS[@]} -eq 0 && ${#SELECTED_PACKAGE_IDS[@]} -eq 0 ]]; then
    if [[ -t 0 && "${AUTO_CONFIRM}" != "true" ]]; then
      WIZARD_MODE=true
    else
      log "No selections provided. Use --wizard, --profile, --groups, or --packages."
      exit 1
    fi
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --wizard) WIZARD_MODE=true; shift ;;
      --yes) AUTO_CONFIRM=true; shift ;;
      --profile) PROFILE_PATH="$2"; shift 2 ;;
      --groups) GROUPS_CSV="$2"; shift 2 ;;
      --packages) PACKAGES_CSV="$2"; shift 2 ;;
      --raycast-config) APPLY_RAYCAST_CONFIG=true; shift ;;
      --upgrade) DO_UPGRADE=true; shift ;;
      --cleanup) DO_CLEANUP=true; shift ;;
      --dry-run) DRY_RUN=true; shift ;;
      --resume) RESUME=true; shift ;;
      --help|-h) usage; exit 0 ;;
      *) log "Unknown option: $1"; usage; exit 1 ;;
    esac
  done
}

build_ansible_vars_file() {
  local file_path="$1"
  local formulae=()
  local casks=()
  local package_id kind
  for package_id in "${SELECTED_PACKAGE_IDS[@]}"; do
    kind="$(package_kind "${package_id}")"
    [[ -z "${kind}" ]] && continue
    if [[ "${kind}" == "formula" ]]; then
      formulae+=("${package_id}")
    else
      casks+=("${package_id}")
    fi
  done
  cat > "${file_path}" <<EOF
selected_groups_csv: "$(join_by_comma "${SELECTED_GROUPS[@]}")"
selected_formulae_csv: "$(join_by_comma "${formulae[@]}")"
selected_casks_csv: "$(join_by_comma "${casks[@]}")"
apply_raycast_config: ${APPLY_RAYCAST_CONFIG}
dotfiles_overwrite_mode: "${DOTFILES_OVERWRITE_MODE}"
cleanup_cache: ${DO_CLEANUP}
dry_run_mode: ${DRY_RUN}
EOF
}

run_ansible_pull() {
  local extra_vars_file cmd=()
  extra_vars_file="$(mktemp)"
  build_ansible_vars_file "${extra_vars_file}"
  cmd=(ansible-pull -U "${GIT_REPO}" "${PLAYBOOK_FILENAME}" -e "@${extra_vars_file}")
  [[ "${DRY_RUN}" == "true" ]] && cmd+=(--check)
  "${cmd[@]}"
  rm -f "${extra_vars_file}"
}

write_report() {
  mkdir -p "${STATE_DIR}"
  : > "${REPORT_FILE}"
  {
    echo "Dev Setup Report ($(date '+%Y-%m-%d %H:%M:%S'))"
    echo "Groups: $(join_by_comma "${SELECTED_GROUPS[@]}")"
    echo "Packages: $(join_by_comma "${SELECTED_PACKAGE_IDS[@]}")"
    echo
    echo "Results:"
  } >> "${REPORT_FILE}"

  local package_id
  for package_id in "${SELECTED_PACKAGE_IDS[@]}"; do
    if is_preinstalled "${package_id}"; then
      echo "  - ${package_id}: already_present" >> "${REPORT_FILE}"
    elif package_installed "${package_id}"; then
      echo "  - ${package_id}: installed" >> "${REPORT_FILE}"
    else
      echo "  - ${package_id}: failed" >> "${REPORT_FILE}"
    fi
  done

  if [[ "${APPLY_RAYCAST_CONFIG}" == "true" && -z "${RAYCAST_PASSWORD:-}" ]]; then
    echo "  - raycast-config: manual_action_required (set RAYCAST_PASSWORD and rerun with --raycast-config)" >> "${REPORT_FILE}"
  fi
  log "Report written to ${REPORT_FILE}"
}

run_prerequisites() {
  install_homebrew
  update_homebrew_paths
  if has_command brew; then
    update_homebrew
    upgrade_homebrew
    install_ansible
    ensure_wizard_ui_deps
  fi
}

main() {
  parse_args "$@"
  ensure_state_dirs

  if should_skip_step "preflight"; then log "Resume: skipping preflight."; else preflight_checks; write_checkpoint "preflight"; fi
  if should_skip_step "prereqs"; then log "Resume: skipping prereqs."; else run_prerequisites; write_checkpoint "prereqs"; fi

  if [[ -f "${PROFILE_PATH}" && "${WIZARD_MODE}" != "true" && -z "${GROUPS_CSV}" && -z "${PACKAGES_CSV}" ]]; then
    load_profile "${PROFILE_PATH}"
  fi

  resolve_selection_from_flags
  if should_skip_step "selection"; then
    log "Resume: using prior selection state."
  else
    [[ "${WIZARD_MODE}" == "true" ]] && run_wizard
    write_checkpoint "selection"
  fi

  ensure_rosetta_if_needed
  record_preinstalled

  if should_skip_step "ansible"; then log "Resume: skipping ansible."; else run_ansible_pull; write_checkpoint "ansible"; fi
  write_report
  log "Setup complete."
}

if [[ "${DEV_SETUP_SOURCE_ONLY:-false}" != "true" ]]; then
  main "$@"
fi
