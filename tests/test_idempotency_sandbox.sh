#!/bin/bash
# End-to-end idempotency simulation in an isolated sandbox.
# Run with: bash tests/test_idempotency_sandbox.sh

set -euo pipefail
source tests/test_lib.sh

echo ""
echo "=== Sandbox Idempotency Tests ==="
echo ""

if [[ "$(uname -s)" != "Darwin" ]]; then
  pass "non-macOS host; sandbox test skipped"
  print_results_and_exit
fi

ROOT_TMP="$(mktemp -d)"
SANDBOX_HOME="${ROOT_TMP}/home"
MOCK_BIN="${ROOT_TMP}/bin"
MOCK_STATE="${ROOT_TMP}/state"
mkdir -p "${SANDBOX_HOME}" "${MOCK_BIN}" "${MOCK_STATE}"
trap 'rm -rf "${ROOT_TMP}"' EXIT

cat > "${MOCK_BIN}/curl" <<'EOF'
#!/bin/bash
exit 0
EOF

cat > "${MOCK_BIN}/sudo" <<'EOF'
#!/bin/bash
exit 0
EOF

cat > "${MOCK_BIN}/yq" <<'EOF'
#!/bin/bash
query="$2"
if [[ "${query}" == *'select(.id == "git")'* && "${query}" == *'.type'* ]]; then
  echo "formula"
  exit 0
fi
if [[ "${query}" == *'select(.id == "raycast")'* && "${query}" == *'.type'* ]]; then
  echo "cask"
  exit 0
fi
exit 0
EOF

cat > "${MOCK_BIN}/brew" <<'EOF'
#!/bin/bash
set -euo pipefail
STATE_DIR="${MOCK_STATE_DIR:?MOCK_STATE_DIR is required}"
FORMULAE_FILE="${STATE_DIR}/formulae.txt"
CASKS_FILE="${STATE_DIR}/casks.txt"

touch "${FORMULAE_FILE}" "${CASKS_FILE}"

has_item() {
  local file="$1" item="$2"
  grep -qx "${item}" "${file}"
}

add_item() {
  local file="$1" item="$2"
  if ! has_item "${file}" "${item}"; then
    echo "${item}" >> "${file}"
  fi
}

cmd="${1:-}"
case "${cmd}" in
  list)
    if [[ "${2:-}" == "--formula" ]]; then
      has_item "${FORMULAE_FILE}" "${3:-}" && exit 0 || exit 1
    elif [[ "${2:-}" == "--cask" ]]; then
      has_item "${CASKS_FILE}" "${3:-}" && exit 0 || exit 1
    else
      has_item "${FORMULAE_FILE}" "${2:-}" && exit 0 || has_item "${CASKS_FILE}" "${2:-}" && exit 0 || exit 1
    fi
    ;;
  install)
    add_item "${FORMULAE_FILE}" "${2:-}"
    exit 0
    ;;
  update|upgrade)
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF

cat > "${MOCK_BIN}/ansible-pull" <<'EOF'
#!/bin/bash
set -euo pipefail
STATE_DIR="${MOCK_STATE_DIR:?MOCK_STATE_DIR is required}"
FORMULAE_FILE="${STATE_DIR}/formulae.txt"
CASKS_FILE="${STATE_DIR}/casks.txt"
RUN_LOG="${STATE_DIR}/ansible-pull.log"

touch "${FORMULAE_FILE}" "${CASKS_FILE}" "${RUN_LOG}"
echo "ansible-pull $*" >> "${RUN_LOG}"

check_mode=false
extra_file=""
for arg in "$@"; do
  if [[ "${arg}" == "--check" ]]; then
    check_mode=true
  fi
  if [[ "${arg}" == @* ]]; then
    extra_file="${arg#@}"
  fi
done

extract_csv() {
  local key="$1"
  awk -F'"' -v k="${key}" '$1 ~ k ":" { print $2 }' "${extra_file}"
}

if [[ "${check_mode}" != "true" && -n "${extra_file}" && -f "${extra_file}" ]]; then
  formula_csv="$(extract_csv selected_formulae_csv)"
  cask_csv="$(extract_csv selected_casks_csv)"
  IFS=',' read -r -a formulae <<< "${formula_csv}"
  IFS=',' read -r -a casks <<< "${cask_csv}"
  for pkg in "${formulae[@]}"; do
    pkg="$(echo "${pkg}" | xargs)"
    [[ -z "${pkg}" ]] && continue
    grep -qx "${pkg}" "${FORMULAE_FILE}" || echo "${pkg}" >> "${FORMULAE_FILE}"
  done
  for pkg in "${casks[@]}"; do
    pkg="$(echo "${pkg}" | xargs)"
    [[ -z "${pkg}" ]] && continue
    grep -qx "${pkg}" "${CASKS_FILE}" || echo "${pkg}" >> "${CASKS_FILE}"
  done
fi
EOF

chmod +x "${MOCK_BIN}/curl" "${MOCK_BIN}/sudo" "${MOCK_BIN}/yq" "${MOCK_BIN}/brew" "${MOCK_BIN}/ansible-pull"

export HOME="${SANDBOX_HOME}"
export PATH="${MOCK_BIN}:$PATH"
export MOCK_STATE_DIR="${MOCK_STATE}"

echo "[1] first non-dry run installs selected packages in sandbox"
bash ./main.sh --packages git,raycast --yes
REPORT_PATH="${HOME}/.local/state/dev-setup/last-report.txt"
assert_grep "git marked installed on first run" 'git: installed' "${REPORT_PATH}"
assert_grep "raycast marked installed on first run" 'raycast: installed' "${REPORT_PATH}"

echo "[2] second run is idempotent for package state"
bash ./main.sh --packages git,raycast --yes
assert_grep "git marked already_present on second run" 'git: already_present' "${REPORT_PATH}"
assert_grep "raycast marked already_present on second run" 'raycast: already_present' "${REPORT_PATH}"

echo "[3] shell profile update is not duplicated"
ZPROFILE_PATH="${HOME}/.zprofile"
assert_true "sandbox zprofile created in non-dry mode" test -f "${ZPROFILE_PATH}"
SHELLENV_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
count="$(grep -cF "${SHELLENV_LINE}" "${ZPROFILE_PATH}" || true)"
if [[ "${count}" -eq 1 ]]; then
  pass "homebrew shellenv line appears once"
else
  fail "homebrew shellenv line expected once, found ${count}"
fi

echo "[4] dry-run does not modify shell profile"
DRY_HOME="${ROOT_TMP}/home-dry"
mkdir -p "${DRY_HOME}"
export HOME="${DRY_HOME}"
bash ./main.sh --packages git --yes --dry-run
if [[ -f "${HOME}/.zprofile" ]]; then
  fail "dry-run should not create ~/.zprofile in sandbox"
else
  pass "dry-run leaves ~/.zprofile untouched in sandbox"
fi

echo "[5] ansible-pull invoked in both real and check modes"
assert_grep "non-dry run logged" 'ansible-pull' "${MOCK_STATE}/ansible-pull.log"
assert_grep "dry-run uses --check" '--check' "${MOCK_STATE}/ansible-pull.log"

print_results_and_exit
