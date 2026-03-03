#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Test runner for scripts/bash/metrics.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
METRICS_SCRIPT="$REPO_ROOT/scripts/bash/metrics.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

# --- Helper functions ---

setup() {
  local fixture="$1"
  TEST_DIR="$FIXTURES_DIR/$fixture"
  if [ ! -d "$TEST_DIR" ]; then
    echo "FIXTURE NOT FOUND: $TEST_DIR" >&2
    return 1
  fi
}

run_metrics() {
  # Run metrics.sh from within the fixture directory
  local args="${1:-}"
  (cd "$TEST_DIR" && bash "$METRICS_SCRIPT" $args 2>/dev/null)
}

capture_metrics() {
  local args="${1:-}"
  OUTPUT="$(cd "$TEST_DIR" && bash "$METRICS_SCRIPT" $args 2>/dev/null)" || true
  EXIT_CODE=$?
}

assert_output_contains() {
  local expected="$1"
  if echo "$OUTPUT" | grep -qF "$expected"; then
    return 0
  else
    echo "  EXPECTED to find: '$expected'" >&2
    echo "  IN OUTPUT:" >&2
    echo "$OUTPUT" | sed 's/^/    /' >&2
    return 1
  fi
}

assert_output_not_contains() {
  local unexpected="$1"
  if echo "$OUTPUT" | grep -qF "$unexpected"; then
    echo "  EXPECTED NOT to find: '$unexpected'" >&2
    echo "  IN OUTPUT:" >&2
    echo "$OUTPUT" | sed 's/^/    /' >&2
    return 1
  else
    return 0
  fi
}

assert_exit_code() {
  local expected="$1"
  if [ "$EXIT_CODE" -eq "$expected" ]; then
    return 0
  else
    echo "  EXPECTED exit code: $expected, GOT: $EXIT_CODE" >&2
    return 1
  fi
}

run_test() {
  local test_name="$1"
  TOTAL_COUNT=$((TOTAL_COUNT + 1))
  echo -n "  $test_name ... "
  if "$test_name"; then
    echo "PASS"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# --- Summary mode tests (US1) ---

test_basic_repo() {
  setup "basic-repo"
  capture_metrics
  assert_output_contains "Spec lines:" &&
  assert_output_contains "Non-spec lines:" &&
  assert_output_contains "Spec chars:" &&
  assert_output_contains "Non-spec chars:" &&
  assert_output_contains "Spec %:" &&
  assert_output_contains "Lines:" &&
  assert_output_contains "Chars:"
}

test_empty_repo() {
  setup "empty-repo"
  capture_metrics
  assert_output_contains "N/A"
}

test_spec_only_repo() {
  setup "spec-only-repo"
  capture_metrics
  assert_output_contains "Lines: 100%" &&
  assert_output_contains "Chars: 100%"
}

test_no_spec_repo() {
  setup "no-spec-repo"
  capture_metrics
  assert_output_contains "Lines: 0%" &&
  assert_output_contains "Chars: 0%"
}

test_gitignore_repo() {
  setup "gitignore-repo"
  capture_metrics
  # build/ files should be excluded; only specs/doc.md (2 lines)
  # and src/app.sh (3 lines) should be counted
  assert_output_contains "Spec lines:" &&
  assert_output_contains "Non-spec lines:"
}

# --- Breakdown mode tests (US2) ---

test_breakdown_basic() {
  setup "basic-repo"
  capture_metrics "--breakdown"
  assert_output_contains "Breakdown by Directory" &&
  assert_output_contains "specs/" &&
  assert_output_contains "src/" &&
  assert_output_contains "spec" &&
  assert_output_contains "non-spec"
}

test_breakdown_root_files() {
  setup "gitignore-repo"
  capture_metrics "--breakdown"
  # .gitignore is a root file, should be grouped under "."
  assert_output_contains "."
}

test_breakdown_gitignore() {
  setup "gitignore-repo"
  capture_metrics "--breakdown"
  # build/ is in .gitignore so should NOT appear
  assert_output_not_contains "build/"
}

test_breakdown_sorting() {
  setup "basic-repo"
  capture_metrics "--breakdown"
  # Spec dirs (.specify/, specs/) should appear before non-spec dirs (src/)
  local specify_line spec_line src_line
  specify_line=$(echo "$OUTPUT" | grep -n '\.specify/' | head -1 | cut -d: -f1)
  spec_line=$(echo "$OUTPUT" | grep -n 'specs/' | head -1 | cut -d: -f1)
  src_line=$(echo "$OUTPUT" | grep -n 'src/' | head -1 | cut -d: -f1)
  [ "$specify_line" -lt "$src_line" ] && [ "$spec_line" -lt "$src_line" ]
}

# --- Main ---

run_tests() {
  echo "=== Owl Metrics Tests ==="
  echo ""
  echo "Summary mode (US1):"
  run_test test_basic_repo
  run_test test_empty_repo
  run_test test_spec_only_repo
  run_test test_no_spec_repo
  run_test test_gitignore_repo
  echo ""
  echo "Breakdown mode (US2):"
  run_test test_breakdown_basic
  run_test test_breakdown_root_files
  run_test test_breakdown_gitignore
  run_test test_breakdown_sorting
  echo ""
  echo "=== Results: $PASS_COUNT/$TOTAL_COUNT passed, $FAIL_COUNT failed ==="

  if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
  fi
}

run_tests
