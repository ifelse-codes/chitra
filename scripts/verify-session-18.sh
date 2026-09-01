#!/usr/bin/env bash
# verify-session-18.sh — S18: lock the heatmap chart to the reference/panel language.
# Proves: the heatmap now renders the locked panel (grey-ramp intensity, one accent on
# the peak cell, dashed frame/eyebrow/guides/rules, rows×cols·min..max·peak footer),
# the falsifiability tests pass, the full core suite + typecheck stay green, and the
# regenerated docs previews are in sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="18"
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

# ── Criterion 1: the core library is green ──────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck

# ── Criterion 2: the heatmap lock specifically holds ────────────
run_check "heatmap-tests-green"    pnpm --filter @chitra/core run test -- heatmap

# The rainbow is gone from the source (only the README's "is gone" note may mention it).
run_check "no-rainbow-in-source"   bash -c '
  if grep -q "HEAT_COLORS_DARK" packages/core/src/charts/heatmap.ts; then
    echo "HEAT_COLORS_DARK still present in heatmap.ts"; exit 1
  fi
  grep -q "frameTop" packages/core/src/charts/heatmap.ts || { echo "no panel frame in heatmap.ts"; exit 1; }
'

# The README carries the LOCKED contract block.
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: heatmap chart — session 18 design" packages/core/README.md
'

# ── Criterion 3: docs previews regenerated + in sync ────────────
run_check "docs-typecheck"         pnpm --filter @workspace/chitra-docs run typecheck
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 4: branch is s18 ──────────────────────────────────
run_check "branch-is-s18"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-18-* ]] || { echo "branch=$branch, expected session-18-*"; exit 1; }
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
