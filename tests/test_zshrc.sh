#!/bin/bash
# Focused safety tests for zshrc dotfile.
# Run with: bash tests/test_zshrc.sh

set -euo pipefail
source tests/test_lib.sh

ZSHRC="dotfiles/terminal/.zshrc"

echo ""
echo "=== zshrc Safety Tests ==="
echo ""

echo "[1] zshrc exists and is valid zsh syntax"
assert_true "dotfiles/terminal/.zshrc exists" test -f "${ZSHRC}"
if command -v zsh >/dev/null 2>&1; then
  assert_true "zsh -n passes" zsh -n "${ZSHRC}"
else
  pass "zsh not installed; syntax check skipped"
fi

echo "[2] zsh version guard exists"
assert_grep "ZSH guard is present" '\[\[ -n "\$ZSH_VERSION" \]\] || return' "${ZSHRC}"

echo "[3] no deprecated ansible_env in dotfiles"
assert_true "dotfiles contain no ansible_env references" bash -lc "! grep -rq 'ansible_env' dotfiles/"

print_results_and_exit
