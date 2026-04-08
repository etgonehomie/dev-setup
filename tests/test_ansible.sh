#!/bin/bash
# Tests for Ansible playbook correctness
# Run with: bash tests/test_ansible.sh

PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL+1)); }

echo ""
echo "=== Ansible Playbook Tests ==="
echo ""

# 1. No deprecated ansible_env references
echo "[1] No deprecated ansible_env usage"
HITS=$(grep -rn 'ansible_env' ansible/ 2>/dev/null)
[[ -z "$HITS" ]] \
  && pass "no 'ansible_env' found (using ansible_facts['env'] correctly)" \
  || fail "deprecated 'ansible_env' still present:\n$HITS"

# 2. themes_local_dir uses absolute brew_prefix (not ~/brew_prefix)
echo "[2] themes_local_dir path is not prefixed with ~/"
grep -q '"~/{{ brew_prefix }}' ansible/terminal-config.yml 2>/dev/null \
  && fail "themes_local_dir still has ~/{{ brew_prefix }} (double-slash bug)" \
  || pass "themes_local_dir uses absolute brew_prefix path"

# 3. font-hack-nerd-font is NOT in cli_extensions (must be a cask)
echo "[3] font-hack-nerd-font is not in cli_extensions (brew formula list)"
if grep -A2 'cli_extensions' ansible/homebrew_vars.yml | grep -q 'font-hack-nerd-font'; then
  fail "font-hack-nerd-font is in cli_extensions — it must be installed as a cask"
else
  pass "font-hack-nerd-font not in cli_extensions"
fi

# 4. font-hack-nerd-font IS in cask_dev_apps
echo "[4] font-hack-nerd-font is in cask_dev_apps"
grep -A50 '^cask_dev_apps:' ansible/homebrew_vars.yml | grep -q 'font-hack-nerd-font' \
  && pass "font-hack-nerd-font found in cask_dev_apps" \
  || fail "font-hack-nerd-font missing from cask_dev_apps"

# 5. homebrew-config.yml uses install_options: overwrite
echo "[5] homebrew install tasks use install_options: overwrite"
COUNT=$(grep -c 'install_options: overwrite' ansible/homebrew-config.yml 2>/dev/null)
[[ "$COUNT" -ge 2 ]] \
  && pass "install_options: overwrite present in $COUNT homebrew tasks" \
  || fail "install_options: overwrite missing from homebrew tasks (found $COUNT, expected 2+)"

# 6. Symlink parent dir task exists in terminal-config.yml
echo "[6] Symlink parent dir is created before symlink task"
grep -q 'themes_symlink_dir | dirname' ansible/terminal-config.yml 2>/dev/null \
  && pass "parent dir creation task present before symlink" \
  || fail "no task to create parent dir of themes_symlink_dir"

# 7. YAML syntax check (requires python3 + PyYAML)
echo "[7] YAML syntax"
if command -v python3 &>/dev/null && python3 -c "import yaml" 2>/dev/null; then
  for f in ansible/*.yml; do
    python3 -c "import sys,yaml; yaml.safe_load(open(sys.argv[1]))" "$f" 2>/dev/null \
      && pass "$f is valid YAML" \
      || fail "$f has invalid YAML syntax"
  done
else
  echo "  ⚠️  SKIP: PyYAML not installed (pip install pyyaml to enable)"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
