#!/bin/bash
# TDD-style unit tests for main.sh helpers and CLI parsing.
# Run with: bash tests/test_main_sh.sh

set -euo pipefail
source tests/test_lib.sh

echo ""
echo "=== main.sh Unit Tests ==="
echo ""

TMP_HOME="$(mktemp -d)"
trap 'rm -rf "${TMP_HOME}"' EXIT
export HOME="${TMP_HOME}"
export DEV_SETUP_SOURCE_ONLY=true

source main.sh

echo "[1] script is sourceable and has no syntax errors"
assert_true "bash syntax passes" bash -n main.sh

echo "[2] append_unique dedupes correctly"
ARR=("a" "b")
if append_unique "c" "${ARR[@]}"; then
  pass "append_unique allows new value"
else
  fail "append_unique should allow new value"
fi
if append_unique "a" "${ARR[@]}"; then
  fail "append_unique should reject duplicate value"
else
  pass "append_unique rejects duplicate value"
fi

echo "[3] parse_csv_into_array trims values"
OUT=()
parse_csv_into_array " core,dev , productivity " OUT
if [[ "${#OUT[@]}" -eq 3 && "${OUT[0]}" == "core" && "${OUT[1]}" == "dev" && "${OUT[2]}" == "productivity" ]]; then
  pass "csv parsing trims values and preserves order"
else
  fail "csv parsing failed"
fi

echo "[4] group selection expands to package selection"
SELECTED_GROUPS=()
SELECTED_PACKAGE_IDS=()
GROUPS_CSV="core,local-ai"
PACKAGES_CSV=""
resolve_selection_from_flags
if [[ " ${SELECTED_PACKAGE_IDS[*]} " == *" curl "* && " ${SELECTED_PACKAGE_IDS[*]} " == *" ollama "* ]]; then
  pass "group expansion includes expected package IDs"
else
  fail "group expansion missing expected package IDs"
fi

echo "[5] profile write/read roundtrip"
SELECTED_GROUPS=("core" "security")
SELECTED_PACKAGE_IDS=("curl" "tailscale")
APPLY_RAYCAST_CONFIG=true
DOTFILES_OVERWRITE_MODE="always"
save_profile "${HOME}/profile.yml"

GROUPS_CSV=""
PACKAGES_CSV=""
APPLY_RAYCAST_CONFIG=false
DOTFILES_OVERWRITE_MODE="never"
load_profile "${HOME}/profile.yml"

if [[ "${GROUPS_CSV}" == "core,security" && "${PACKAGES_CSV}" == "curl,tailscale" && "${APPLY_RAYCAST_CONFIG}" == "true" && "${DOTFILES_OVERWRITE_MODE}" == "always" ]]; then
  pass "profile roundtrip persists expected settings"
else
  fail "profile roundtrip mismatch"
fi

echo "[6] ansible vars file includes selection + modes"
SELECTED_GROUPS=("productivity")
SELECTED_PACKAGE_IDS=("raycast" "git")
APPLY_RAYCAST_CONFIG=true
DOTFILES_OVERWRITE_MODE="always"
DO_CLEANUP=true
DRY_RUN=true
VARS_FILE="$(mktemp)"
build_ansible_vars_file "${VARS_FILE}"
assert_grep "groups csv persisted" 'selected_groups_csv: "productivity"' "${VARS_FILE}"
assert_grep "formulae csv persisted" 'selected_formulae_csv: "git"' "${VARS_FILE}"
assert_grep "casks csv persisted" 'selected_casks_csv: "raycast"' "${VARS_FILE}"
assert_grep "raycast mode persisted" 'apply_raycast_config: true' "${VARS_FILE}"
rm -f "${VARS_FILE}"

print_results_and_exit
