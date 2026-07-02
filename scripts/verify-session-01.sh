#!/usr/bin/env bash
# Session 01 verify — Docs-from-lib generator.
# Proves: the shipped docs gallery data is regenerable from @chitra/core and
# in sync with the single source of truth (no hand-pasted drift), the lib is
# green, and everything typechecks.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="01"

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

# Core library must stay green (invariant: 116 tests).
run_check "core-tests"        pnpm --filter @chitra/core run test
run_check "core-typecheck"    pnpm --filter @chitra/core run typecheck

# Docs gallery data must be GENERATED from the lib and up to date — this is the
# whole point of S01: no drift between chart-specs.ts and the shipped files.
run_check "docs-charts-insync" pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "docs-typecheck"     pnpm --filter @workspace/chitra-docs run typecheck

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
