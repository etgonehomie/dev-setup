#!/bin/bash

PASS=0
FAIL=0

pass() {
  echo "  ✅ PASS: $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  ❌ FAIL: $1"
  FAIL=$((FAIL + 1))
}

assert_true() {
  local description="$1"
  shift
  if "$@"; then
    pass "${description}"
  else
    fail "${description}"
  fi
}

assert_grep() {
  local description="$1"
  local pattern="$2"
  local file="$3"
  if grep -q -- "${pattern}" "${file}"; then
    pass "${description}"
  else
    fail "${description}"
  fi
}

assert_not_grep() {
  local description="$1"
  local pattern="$2"
  local file="$3"
  if grep -q -- "${pattern}" "${file}"; then
    fail "${description}"
  else
    pass "${description}"
  fi
}

print_results_and_exit() {
  echo ""
  echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
  echo ""
  [[ ${FAIL} -eq 0 ]]
}
