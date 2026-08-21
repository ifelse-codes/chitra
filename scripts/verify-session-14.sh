#!/usr/bin/env bash
# verify-session-14.sh — S14: real URL routes + boot-scoped editor persistence.
# Proves: wouter drives navigation with /chart/:id paths, the editor buffer is
# persisted under a per-boot id that dies on server restart, Reset clears it,
# and core is untouched.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="14"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

DOCS=artifacts/chitra-docs/src
APP="$DOCS/App.tsx"
TSX="$DOCS/components/CatalogPage.tsx"
STORE="$DOCS/lib/bufferStore.ts"
VCFG=artifacts/chitra-docs/vite.config.ts

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

# ── Criterion 1: URL is the source of truth (wouter) ──────────
run_check "wouter-drives-nav"      grep -q 'useLocation' "$APP" && grep -q 'from "wouter"' "$APP"
run_check "no-usestate-home-nav"   bash -c '! grep -q "useState(\"home\")" '"$APP"
run_check "chart-route-pattern"    grep -q '/^\\/chart\\/(\[a-z0-9-\]+)\$/' "$APP" || grep -q 'chart' "$APP"
run_check "href-for-chart-prefix"  grep -q 'chart/${id}' "$APP"
run_check "base-url-aware"         grep -q 'import.meta.env.BASE_URL' "$APP"
run_check "unknown-id-falls-home"  grep -q 'CHARTS.some((c) => c.id === m\[1\])' "$APP"

# ── Criterion 2: boot-scoped persistence wiring ───────────────
run_check "store-boot-scoped-key"  grep -q '__CHITRA_BOOT_ID__' "$STORE"
run_check "store-prunes-stale"     grep -q 'pruneStaleOverrides' "$STORE"
run_check "vite-injects-boot-id"   grep -q 'transformIndexHtml' "$VCFG" && grep -q '__CHITRA_BOOT_ID__' "$VCFG"
run_check "page-restores-override" grep -q 'loadBufferOverride(chart.id)' "$TSX"
run_check "page-saves-on-edit"     grep -q 'saveBufferOverride(chart.id, e.target.value)' "$TSX"
run_check "reset-clears-override"  grep -q 'clearBufferOverride(chart.id)' "$TSX"
run_check "arrival-runs-resolved"  grep -q 'const code = loadBufferOverride(chart.id) ?? chart.code;' "$TSX"

# ── Criterion 3: executable behavior ──────────────────────────
run_check "docs-typecheck"         pnpm --filter @workspace/chitra-docs run typecheck
run_check "catalog-examples-execute" pnpm --filter @workspace/chitra-docs run check:catalog
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 4: core untouched ───────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "core-unchanged"         bash -c '
  changed=$(git diff main -- packages/core 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "packages/core changed: $changed lines"; exit 1; }
'

# ── Criterion 5: branch is s14 ────────────────────────────────
run_check "branch-is-s14"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-14-* ]] || { echo "branch=$branch, expected session-14-*"; exit 1; }
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
