#!/usr/bin/env bash
# S33 — release readiness: CI browser QA, candle exclusivity, SVG parity, AI-data manual.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-33/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

APP=artifacts/chitra-docs/src/App.tsx
CI=.github/workflows/ci.yml

# ── Story 1: CI browser QA ──────────────────────────────────────
run_check "ci-browser-qa-job"   bash -c "grep -q 'browser-qa' $CI && grep -q 'qa-catalog.mjs' $CI"
run_check "ci-playwright-install" bash -c "grep -q 'playwright install' $CI"

# ── Story 2: candle ties-first exclusivity ──────────────────────
run_check "candle-exclusivity-test" bash -c "grep -q 'SECOND tied candle is never accented' packages/core/tests/candlestick.test.ts"

# ── Story 3: SVG parity ─────────────────────────────────────────
run_check "model-canonical-colors" bash -c "grep -q 'seriesColors' packages/core/src/charts/line-model.ts"
run_check "svg-theme-aware"        bash -c "grep -q 'ansiToCss' packages/core/src/charts/line-model.ts && ! grep -q '#8ae234' packages/core/src/charts/line-model.ts"
run_check "svg-grid-option"        bash -c "grep -q 'model.grid' packages/core/src/charts/line-model.ts"
run_check "line-svg-drift-test"    test -f packages/core/tests/line-svg.test.ts
run_check "core-tests"             pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "drift-gate"             pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Story 4: AI-data manual ─────────────────────────────────────
run_check "ai-data-page"           bash -c "grep -q 'function AiDataPage' $APP && grep -q 'AI Data Reference' $APP"
run_check "ai-data-nav"            bash -c "grep -q 'ai-data' $APP"
run_check "ai-data-qa-list"        bash -c "grep -q 'ai-data' scripts/qa-catalog.mjs"
run_check "readme-links-manual"    bash -c "grep -q 'chitra.iifelse.com/ai-data' packages/core/README.md"

# ── Standing docs gates ─────────────────────────────────────────
run_check "docs-typecheck"         pnpm --filter @workspace/chitra-docs run typecheck
run_check "docs-build"             bash -c 'PORT=5174 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build'

# ── Branch discipline ───────────────────────────────────────────
run_check "branch-is-s33"          bash -c '[[ "$(git rev-parse --abbrev-ref HEAD)" == session-33-* ]]'

( cd ".ai/verify/session-33" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 33 Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
