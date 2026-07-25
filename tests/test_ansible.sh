#!/bin/bash
# TDD-style structural tests for Ansible wiring.
# Run with: bash tests/test_ansible.sh

set -euo pipefail
source tests/test_lib.sh

echo ""
echo "=== Ansible Wiring Tests ==="
echo ""

echo "[1] main playbook includes expected child playbooks"
assert_grep "imports homebrew-config" 'ansible/homebrew-config.yml' main.yml
assert_grep "imports raycast-config" 'ansible/raycast-config.yml' main.yml
assert_grep "imports cleanup" 'ansible/cleanup.yml' main.yml

echo "[2] homebrew config is selection-driven"
assert_grep "uses selected formula csv" 'selected_formulae_csv' ansible/homebrew-config.yml
assert_grep "uses selected cask csv" 'selected_casks_csv' ansible/homebrew-config.yml
assert_grep "cask failures are non-blocking" 'ignore_errors: true' ansible/homebrew-config.yml

echo "[3] dotfile overwrite strategy exists"
assert_grep "terminal config has overwrite mode" 'dotfiles_overwrite_mode' ansible/terminal-config.yml
assert_grep "terminal config has backups" 'dotfiles_backup_dir' ansible/terminal-config.yml
assert_grep "git config has overwrite mode" 'dotfiles_overwrite_mode' ansible/git-config.yml
assert_grep "git config has backups" 'dotfiles_backup_dir' ansible/git-config.yml

echo "[4] raycast config is optional and secret-safe"
assert_grep "raycast gated by apply flag" 'apply_raycast_config' ansible/raycast-config.yml
assert_grep "raycast password loaded from env" "lookup('env', 'RAYCAST_PASSWORD')" ansible/raycast-config.yml
assert_not_grep "vault file removed" 'vault_password.yml' ansible/raycast-config.yml

echo "[5] cleanup is opt-in"
assert_grep "cleanup_cache guard exists" 'cleanup_cache' ansible/cleanup.yml

echo "[6] YAML syntax validation"
if command -v python3 >/dev/null 2>&1 && python3 -c "import yaml" >/dev/null 2>&1; then
  for f in main.yml ansible/*.yml; do
    if python3 -c "import sys,yaml; yaml.safe_load(open(sys.argv[1]))" "$f" >/dev/null 2>&1; then
      pass "${f} is valid YAML"
    else
      fail "${f} is invalid YAML"
    fi
  done
else
  pass "PyYAML not installed; YAML syntax test skipped"
fi

print_results_and_exit
