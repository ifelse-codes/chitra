#!/usr/bin/env bash
# verify-session-11.sh — S11: catalog two-panel page

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="11"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
    echo "  ↳ FAIL log: $LOG"
  fi
}

# ── Core: tests, typecheck ─────────────────────────────────────
run_check "core-tests"          pnpm --filter @chitra/core run test
run_check "core-typecheck"      pnpm --filter @chitra/core run typecheck

# ── The one check that is not a grep ──────────────────────────
# Every other catalog check below greps the source for a string. That is how this
# script reported 14/14 ALL GREEN while 19 of 20 chart pages failed to render in a
# real browser. This one EXECUTES the shipped evaluator against all 20 examples,
# every renderer, and a deliberately broken buffer.
run_check "catalog-examples-execute" pnpm --filter @workspace/chitra-docs run check:catalog

# ── Docs: typecheck, chart drift gate ─────────────────────────
run_check "docs-typecheck"      pnpm --filter @workspace/chitra-docs run typecheck
run_check "docs-gen-charts-check" pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── S11 branch structure ───────────────────────────────────────
run_check "branch-is-s11"       bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-11-* ]] || { echo "branch=$branch, expected session-11-*"; exit 1; }
'

# ── CatalogPage component exists ──────────────────────────────
run_check "catalog-component-exists-SOURCE-GREP" bash -c '
  [ -f "artifacts/chitra-docs/src/components/CatalogPage.tsx" ] || exit 1
  grep -q "PanelGroup" artifacts/chitra-docs/src/components/CatalogPage.tsx || exit 1
  grep -q "vim-editor" artifacts/chitra-docs/src/components/CatalogPage.tsx || exit 1
  grep -q "term-preview" artifacts/chitra-docs/src/components/CatalogPage.tsx || exit 1
'

# ── CatalogPage: key features present ─────────────────────────
# The three repairs that answered a cold REJECT on criterion 2 (real block cursor,
# padding-corrected current-line stripe, gutter scroll-sync) were guarded by NOTHING:
# the feature grep below matches strings that were all present in the rejected state.
# These are still source greps — say so — but they now name the repairs specifically,
# so reverting one is at least visible at close.
run_check "catalog-repairs-present-SOURCE-GREP" bash -c '
  f=artifacts/chitra-docs/src/components/CatalogPage.tsx
  grep -q "vim-block-cursor"            "$f" || { echo "block cursor overlay missing"; exit 1; }
  grep -q "VIM_PAD + (curLine - 1)"     "$f" || { echo "current-line stripe padding correction missing"; exit 1; }
  grep -q "gutterRef.current.scrollTop" "$f" || { echo "gutter scroll-sync missing"; exit 1; }
  grep -q "caret-color: transparent"    artifacts/chitra-docs/src/index.css || { echo "native caret not suppressed"; exit 1; }
'

run_check "catalog-vim-features-SOURCE-GREP" bash -c '
  f="artifacts/chitra-docs/src/components/CatalogPage.tsx"
  grep -q "vim-gutter"     "$f" || exit 1
  grep -q "vim-curline-hl" "$f" || exit 1
  grep -q "vim-tilde"      "$f" || exit 1
  grep -q "vim-modeline"   "$f" || exit 1
  grep -q "vim-mode-badge" "$f" || exit 1
  grep -q "vim-ta"         "$f" || exit 1
'

run_check "catalog-terminal-features-SOURCE-GREP" bash -c '
  f="artifacts/chitra-docs/src/components/CatalogPage.tsx"
  grep -q "term-titlebar"  "$f" || exit 1
  grep -q "term-pill"      "$f" || exit 1
  grep -q "term-prompt"    "$f" || exit 1
  grep -q "ansiToHtml"     "$f" || exit 1
  grep -q "term-footer"    "$f" || exit 1
'

run_check "catalog-toolbar-features-SOURCE-GREP" bash -c '
  f="artifacts/chitra-docs/src/components/CatalogPage.tsx"
  grep -q "ct-run"         "$f" || exit 1
  grep -q "ct-select"      "$f" || exit 1
  grep -q "RENDERERS"      "$f" || exit 1
  grep -q "THEMES"         "$f" || exit 1
  grep -q "ct-reset"       "$f" || exit 1
'

# ── Live execution: evaluator present ─────────────────────────
run_check "catalog-evaluator-SOURCE-GREP" bash -c '
  f="artifacts/chitra-docs/src/components/CatalogPage.tsx"
  grep -q "new Function"   "$f" || exit 1
  grep -q "chitraCore"     "$f" || exit 1
  grep -q "globalThis"     "$f" || exit 1
  grep -q "evalCode"       "$f" || exit 1
'

# ── @chitra/core in docs deps ─────────────────────────────────
run_check "core-dep-in-docs-SOURCE-GREP" bash -c '
  grep -q "@chitra/core" artifacts/chitra-docs/package.json || exit 1
  [ -d "artifacts/chitra-docs/node_modules/@chitra/core" ] || exit 1
'

# ── App.tsx uses CatalogPage ───────────────────────────────────
run_check "app-uses-catalog-page-SOURCE-GREP" bash -c '
  grep -q "CatalogPage" artifacts/chitra-docs/src/App.tsx || exit 1
  grep -q "content-catalog" artifacts/chitra-docs/src/App.tsx || exit 1
'

# ── CSS has catalog and vim styles ────────────────────────────
run_check "css-has-catalog-styles-SOURCE-GREP" bash -c '
  f="artifacts/chitra-docs/src/index.css"
  grep -q "catalog-page"   "$f" || exit 1
  grep -q "vim-editor"     "$f" || exit 1
  grep -q "term-preview"   "$f" || exit 1
  grep -q "tok-kw"         "$f" || exit 1
'

# ── No changes to packages/core ───────────────────────────────
run_check "core-output-locked" bash -c '
  changed=$(git diff main -- packages/core/src/ 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "packages/core/src changed: $changed lines"; exit 1; }
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-38s %s\n' "STEP" "RESULT"
printf '%-38s %s\n' "--------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
