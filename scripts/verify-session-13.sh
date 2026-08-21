#!/usr/bin/env bash
# verify-session-13.sh — S13: docs catalog chrome at Darpan parity.
# Proves: the toolbar carries the Darpan primary/ghost/pill specs, the global
# cmd-enter shortcut is wired, the parity layer uses the shipped white-alpha
# fg tiers (verified against the live Darpan CSS), and core is untouched.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="13"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

DOCS=artifacts/chitra-docs/src
CSS="$DOCS/index.css"
TSX="$DOCS/components/CatalogPage.tsx"

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

# ── Criterion 1: Darpan canon tokens (white-alpha fg tiers) ───
run_check "fg-tiers-white-alpha"   grep -q "oklch(1 0 0 / 0.92)" "$CSS"
run_check "fg-tier-4-faintest"     grep -q "oklch(1 0 0 / 0.36)" "$CSS"
run_check "no-lightness-fg-legacy" bash -c '! grep -q "theater-fg: oklch(0.97" '"$CSS"

# ── Criterion 2: Run = Darpan .btnPrimary ─────────────────────
run_check "run-accent-border"      bash -c "grep -A6 '.ct-run {' '$CSS' | grep -q 'border: 1px solid var(--theater-accent)'"
run_check "run-warm-near-black"    grep -q "color: oklch(0.12 0.008 60)" "$CSS"
run_check "one-control-metric"     grep -q "ct-run, .ct-btn, .ct-select" "$CSS"

# ── Criterion 3: shortcut — label + global listener ───────────
run_check "kbd-chip-in-button"     grep -q 'ct-kbd' "$TSX"
run_check "kbd-style-present"      grep -q '\.ct-kbd' "$CSS"
run_check "platform-aware-label"   grep -q "Ctrl ↩" "$TSX"
run_check "global-keydown-listener" grep -q 'window.addEventListener("keydown", onKey)' "$TSX"
run_check "listener-removed"       grep -q 'removeEventListener("keydown", onKey)' "$TSX"

# ── Criterion 4: chrome details ───────────────────────────────
run_check "pills-uppercase"        bash -c "grep -A9 '^\.ct-pill {' '$CSS' | grep -q 'text-transform: uppercase'"
run_check "actions-uppercase"      bash -c "grep -A11 '^\.ct-btn {' '$CSS' | grep -q 'text-transform: uppercase'"
run_check "inspector-footer-kv"    test "$(grep -c 'tf-k' "$TSX")" -ge 3 && grep -q '\.tf-v' "$CSS"
run_check "dashed-empty-state"     bash -c "grep -A5 '.term-output-placeholder {' '$CSS' | grep -q 'dashed'"
run_check "error-banner-chip"      grep -q 'term-error-chip' "$TSX" && grep -q '\.term-error-chip' "$CSS"
run_check "jetbrains-mono-first"   bash -c "grep -- '--font-mono' '$CSS' | grep -q \"'JetBrains Mono', 'Cascadia Mono'\""
run_check "selection-accent"       grep -q "::selection { background: oklch(0.8 0.13 305 / 0.35)" "$CSS"
run_check "focus-ring-accent"      grep -q "outline: 2px solid oklch(0.8 0.13 305 / 0.45)" "$CSS"
run_check "scrollbar-line-tint"    grep -q "scrollbar-color: oklch(0.32 0.014 270 / 0.45)" "$CSS"

# ── Criterion 5: executable behavior ──────────────────────────
run_check "docs-typecheck"         pnpm --filter @workspace/chitra-docs run typecheck
run_check "catalog-examples-execute" pnpm --filter @workspace/chitra-docs run check:catalog
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 6: core untouched ───────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "core-unchanged"         bash -c '
  changed=$(git diff main -- packages/core 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "packages/core changed: $changed lines"; exit 1; }
'

# ── Criterion 7: branch is s13 ────────────────────────────────
run_check "branch-is-s13"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-13-* ]] || { echo "branch=$branch, expected session-13-*"; exit 1; }
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
