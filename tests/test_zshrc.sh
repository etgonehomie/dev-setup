#!/bin/bash
# Tests for .zshrc safety and correctness
# Run with: bash tests/test_zshrc.sh

ZSHRC="dotfiles/terminal/.zshrc"
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL+1)); }

echo ""
echo "=== .zshrc Tests ==="
echo ""

# 1. File exists
echo "[1] File existence"
[[ -f "$ZSHRC" ]] && pass "$ZSHRC exists" || fail "$ZSHRC not found"

# 2. ZSH shebang present
echo "[2] ZSH shebang"
head -1 "$ZSHRC" | grep -q "#!/bin/zsh" && pass "shebang is #!/bin/zsh" || fail "missing #!/bin/zsh shebang"

# 3. ZSH version guard present (prevents bash from sourcing zsh-only plugins)
echo "[3] ZSH version guard"
grep -q '\[\[ -n "\$ZSH_VERSION" \]\] || return' "$ZSHRC" \
  && pass "ZSH_VERSION guard present" \
  || fail "missing ZSH_VERSION guard — zsh plugins will crash if sourced from bash"

# 4. Plugin sources are guarded with file existence checks
echo "[4] Plugin source guards"
if grep -q 'source.*zsh-fast-syntax-highlighting' "$ZSHRC"; then
  grep -B1 'source.*zsh-fast-syntax-highlighting' "$ZSHRC" | grep -q '\[\[ -f' \
    && pass "zsh-fast-syntax-highlighting source is guarded" \
    || fail "zsh-fast-syntax-highlighting sourced without file existence check"
fi
if grep -q 'source.*zsh-autosuggestions' "$ZSHRC"; then
  grep -B1 'source.*zsh-autosuggestions' "$ZSHRC" | grep -q '\[\[ -f' \
    && pass "zsh-autosuggestions source is guarded" \
    || fail "zsh-autosuggestions sourced without file existence check"
fi
if grep -q 'source.*zsh-autocomplete' "$ZSHRC"; then
  grep -B1 'source.*zsh-autocomplete' "$ZSHRC" | grep -q '\[\[ -f' \
    && pass "zsh-autocomplete source is guarded" \
    || fail "zsh-autocomplete sourced without file existence check"
fi

# 5. ZSH syntax check (requires zsh installed)
echo "[5] ZSH syntax"
if command -v zsh &>/dev/null; then
  zsh -n "$ZSHRC" 2>/dev/null \
    && pass "zsh -n reports no syntax errors" \
    || fail "zsh -n found syntax errors in $ZSHRC"
else
  echo "  ⚠️  SKIP: zsh not installed, skipping syntax check"
fi

# 6. No bare `source` of zsh plugins (must be guarded)
echo "[6] No unguarded plugin sources"
UNGUARDED=$(grep -n '^source.*zsh-' "$ZSHRC" 2>/dev/null)
[[ -z "$UNGUARDED" ]] \
  && pass "no unguarded bare source calls for zsh plugins" \
  || fail "found unguarded source calls:\n$UNGUARDED"

# 7. Does NOT contain 'ansible_env' (deprecated, should use ansible_facts)
echo "[7] Deprecated ansible_env not in dotfiles"
grep -rq 'ansible_env' dotfiles/ 2>/dev/null \
  && fail "dotfiles contain deprecated 'ansible_env' references" \
  || pass "no deprecated 'ansible_env' in dotfiles"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
