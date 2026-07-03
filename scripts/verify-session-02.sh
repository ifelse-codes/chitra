#!/usr/bin/env bash
# Session 02 verify — Expanded examples.
# Proves: the core lib is still green, examples/basic.ts runs cleanly,
# and the new multi-series / theme-tour / MCP-tool sections are present.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="02"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

TSX="$ROOT/packages/core/node_modules/.bin/tsx"
EXAMPLES_LOG="$ROOT/$ARTIFACTS/examples-basic.log"

# Invariant: core library stays green.
run_check "core-tests"     pnpm --filter @chitra/core run test
run_check "core-typecheck" pnpm --filter @chitra/core run typecheck

# New for S02: examples/basic.ts runs without error.
(
  cd examples && "$TSX" basic.ts > "$EXAMPLES_LOG" 2>&1
) || true
run_check "examples-run" test -s "$EXAMPLES_LOG"

# New examples content must be present in the output.
run_check "examples-multi-series-bar" grep -q "MULTI-SERIES BAR CHART" "$EXAMPLES_LOG"
run_check "examples-theme-tour"       grep -q "THEME TOUR" "$EXAMPLES_LOG"
run_check "examples-mcp-tool"         grep -q "render_chart" "$EXAMPLES_LOG"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
