#!/usr/bin/env bash
# verify-session-15.sh — S15: Scripted browser QA of all 20 catalog pages.
# Proves: every catalog page renders in a real browser with zero console/page
# errors, the Run shortcut re-renders, and boot-scoped persistence survives
# navigation. Core and standing gates stay green.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="15"
HEADED=0
for arg in "$@"; do
  [ "$arg" = "--headed" ] && HEADED=1 && shift
done
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-44s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-44s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
    echo "  ↳ FAIL log: $LOG" >&2
  fi
}

# ── Criterion 1: QA suite runs and passes ───────────────────────
export QA_ARTIFACTS="$ARTIFACTS"
QA_ARGS=()
if [ "${HEADED:-0}" = "1" ]; then QA_ARGS+=("--headed"); fi
run_check "qa-catalog-runs" node scripts/qa-catalog.mjs "${QA_ARGS[@]+"${QA_ARGS[@]}"}"

# ── Criterion 2: Standing gates ─────────────────────────────────
run_check "docs-typecheck"         pnpm --filter @workspace/chitra-docs run typecheck
run_check "catalog-examples-execute" pnpm --filter @workspace/chitra-docs run check:catalog
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 3: Core untouched ─────────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "core-unchanged"         bash -c '
  changed=$(git diff main -- packages/core 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "packages/core changed: $changed lines"; exit 1; }
'

# ── Criterion 4: Branch is s15 ──────────────────────────────────
run_check "branch-is-s15"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-15-* ]] || { echo "branch=$branch, expected session-15-*"; exit 1; }
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-44s %s\n' "STEP" "RESULT"
printf '%-44s %s\n' "--------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi