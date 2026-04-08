#!/bin/bash
# Tests for main.sh correctness
# Run with: bash tests/test_main_sh.sh

MAIN_SH="main.sh"
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL+1)); }

echo ""
echo "=== main.sh Tests ==="
echo ""

# 1. File exists
echo "[1] File existence"
[[ -f "$MAIN_SH" ]] && pass "$MAIN_SH exists" || fail "$MAIN_SH not found"

# 2. Bash shebang (it's the bootstrap script, must be bash)
echo "[2] Bash shebang"
head -1 "$MAIN_SH" | grep -q "#!/bin/bash" \
  && pass "shebang is #!/bin/bash" \
  || fail "expected #!/bin/bash shebang in main.sh"

# 3. Does NOT source .zshrc from bash (root cause of the plugin crash bug)
echo "[3] Does not source .zshrc from bash"
grep -q 'source.*\.zshrc\|source.*ZSHRC' "$MAIN_SH" \
  && fail "main.sh sources .zshrc from bash — this crashes zsh-only plugins" \
  || pass "main.sh does not source .zshrc from bash"

# 4. Bash syntax check
echo "[4] Bash syntax"
bash -n "$MAIN_SH" 2>/dev/null \
  && pass "bash -n reports no syntax errors" \
  || fail "bash -n found syntax errors in $MAIN_SH"

# 5. ansible-pull is invoked (core purpose)
echo "[5] ansible-pull invoked"
grep -q 'ansible-pull' "$MAIN_SH" \
  && pass "ansible-pull command present" \
  || fail "ansible-pull not found in main.sh"

# 6. Homebrew install step present
echo "[6] Homebrew bootstrap present"
grep -q 'install_homebrew\|brew' "$MAIN_SH" \
  && pass "Homebrew install step present" \
  || fail "Homebrew install step missing"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
