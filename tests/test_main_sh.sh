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

echo "[7] catalog prereq check does not require yq before prereqs"
HAS_COMMAND_ORIG="$(declare -f has_command)"
has_command() { return 1; }
if ensure_catalog_prereqs; then
  pass "ensure_catalog_prereqs only validates catalog presence"
else
  fail "ensure_catalog_prereqs should not fail when yq is missing"
fi
if ( ensure_catalog_parser ); then
  fail "ensure_catalog_parser should fail when yq is missing"
else
  pass "ensure_catalog_parser fails without yq"
fi
eval "${HAS_COMMAND_ORIG}"

echo "[8] dry-run homebrew path update is non-mutating; normal mode is idempotent"
DRY_RUN=true
rm -f "${HOME}/.zprofile"
update_homebrew_paths
if [[ -f "${HOME}/.zprofile" ]]; then
  fail "dry-run should not create ~/.zprofile"
else
  pass "dry-run does not modify ~/.zprofile"
fi

DRY_RUN=false
update_homebrew_paths
update_homebrew_paths
if [[ -f "${HOME}/.zprofile" ]]; then
  pass "normal mode creates ~/.zprofile when needed"
else
  fail "normal mode should create ~/.zprofile"
fi
line_count="$(grep -c 'shellenv' "${HOME}/.zprofile" || true)"
if [[ "${line_count}" -eq 1 ]]; then
  pass "update_homebrew_paths is idempotent"
else
  fail "expected one shellenv line, found ${line_count}"
fi

echo "[9] catalog checks run after prereqs in main flow"
CALL_ORDER=()
parse_args() { :; }
ensure_state_dirs() { :; }
preflight_checks() { CALL_ORDER+=("preflight"); }
run_prerequisites() { CALL_ORDER+=("prereqs"); }
ensure_catalog_prereqs() { CALL_ORDER+=("catalog"); }
should_skip_step() { return 1; }
write_checkpoint() { :; }
resolve_selection_from_flags() { SELECTED_GROUPS=(); SELECTED_PACKAGE_IDS=("git"); }
ensure_rosetta_if_needed() { :; }
record_preinstalled() { :; }
run_ansible_pull() { :; }
write_report() { :; }
main
if [[ "${CALL_ORDER[*]}" == "preflight prereqs catalog" ]]; then
  pass "main runs catalog checks after prerequisites"
else
  fail "unexpected main call order: ${CALL_ORDER[*]}"
fi

echo "[10] parse_args rejects deprecated mac settings import flags"
source main.sh
if ( parse_args --import-mac-settings >/dev/null 2>&1 ); then
  fail "deprecated --import-mac-settings should fail"
else
  pass "deprecated --import-mac-settings is rejected"
fi

echo "[11] main flow no longer calls mac settings import step"
CALL_ORDER=()
parse_args() { :; }
ensure_state_dirs() { :; }
preflight_checks() { CALL_ORDER+=("preflight"); }
should_skip_step() { return 1; }
write_checkpoint() { :; }
apply_mac_settings_import() { CALL_ORDER+=("import"); }
run_prerequisites() { CALL_ORDER+=("prereqs"); }
ensure_catalog_prereqs() { CALL_ORDER+=("catalog"); }
load_profile() { :; }
ensure_catalog_parser() { CALL_ORDER+=("parser"); }
resolve_selection_from_flags() { :; }
run_wizard() { :; }
ensure_rosetta_if_needed() { :; }
record_preinstalled() { :; }
run_ansible_pull() { CALL_ORDER+=("ansible"); }
write_report() { :; }
main
if [[ " ${CALL_ORDER[*]} " != *" import "* ]]; then
  pass "main flow skips mac settings import"
else
  fail "main should not call mac settings import: ${CALL_ORDER[*]}"
fi

print_results_and_exit
