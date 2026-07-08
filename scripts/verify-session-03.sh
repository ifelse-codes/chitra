#!/usr/bin/env bash
# Session 03 verify — Polished docs site.
# Proves: generated previews still match, docs typecheck/build, core stays green,
# and the docs no longer advertise invalid theme names.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="03"

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

APP="artifacts/chitra-docs/src/App.tsx"

run_check "core-tests"        pnpm --filter @chitra/core run test
run_check "core-typecheck"    pnpm --filter @chitra/core run typecheck
run_check "docs-gen-check"    pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "docs-typecheck"    pnpm --filter @workspace/chitra-docs run typecheck
run_check "docs-build"        env PORT=5000 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build
run_check "docs-no-neon"      bash -c "! grep -q 'neon' '$APP'"
run_check "docs-route-cards"  grep -q "route-grid" "$APP"
run_check "docs-ai-output"    grep -q "MCP-style tool results" "$APP"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
