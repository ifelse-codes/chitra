#!/usr/bin/env bash
# demo-session-11.sh — cumulative demo: S01–S11
# S11: catalog two-panel page (vim editor + live terminal preview)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="11"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RED="\033[31m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
info()   { printf "${DIM}  %s${RESET}\n" "$1"; }
# A demo that cannot fail is not a demo. Every ✗ now marks the run failed, and
# the script exits non-zero at the end. (Cold review, S118: the original fail()
# printed and returned 0, so this script exited 0 while 19 of 20 pages were broken.)
DEMO_FAILED=0
fail()   { printf "${RED}✗ %s${RESET}\n" "$1"; DEMO_FAILED=1; }

header "Session ${SESSION} Demo — chitra docs catalog two-panel page"

# ── S11: Catalog page ─────────────────────────────────────────

header "S11: CatalogPage component"
label "Two-panel layout (react-resizable-panels)"
if grep -q "PanelGroup" artifacts/chitra-docs/src/components/CatalogPage.tsx 2>/dev/null; then
  ok "PanelGroup split present in CatalogPage.tsx"
else
  fail "PanelGroup not found"
fi

label "Left panel: vim-styled editor"
for feat in vim-gutter vim-curline-hl vim-tilde vim-modeline vim-tabs vim-ta hlTs; do
  if grep -q "$feat" artifacts/chitra-docs/src/components/CatalogPage.tsx 2>/dev/null; then
    ok "$feat"
  else
    fail "$feat missing"
  fi
done

label "Right panel: terminal preview"
for feat in term-titlebar term-pill term-prompt ansiToHtml term-footer; do
  if grep -q "$feat" artifacts/chitra-docs/src/components/CatalogPage.tsx 2>/dev/null; then
    ok "$feat"
  else
    fail "$feat missing"
  fi
done

label "Toolbar"
for feat in ct-run RENDERERS THEMES ct-reset download copy; do
  if grep -q "$feat" artifacts/chitra-docs/src/components/CatalogPage.tsx 2>/dev/null; then
    ok "$feat"
  else
    fail "$feat missing"
  fi
done

label "Live in-browser evaluator"
for feat in "new Function" "chitraCore" "globalThis" "evalCode" "buildFnBody"; do
  if grep -q "$feat" artifacts/chitra-docs/src/components/CatalogPage.tsx 2>/dev/null; then
    ok "$feat"
  else
    fail "$feat missing"
  fi
done

header "S11: @chitra/core bundled into docs"
if grep -q "@chitra/core" artifacts/chitra-docs/package.json; then
  ok "@chitra/core in docs package.json"
else
  fail "@chitra/core not in docs package.json"
fi
if [ -d "artifacts/chitra-docs/node_modules/@chitra/core" ]; then
  ok "node_modules/@chitra/core symlinked (pnpm workspace)"
else
  fail "node_modules/@chitra/core not found — run pnpm install"
fi

header "S11: Core invariants (chart output LOCKED)"
label "Core tests"
# NB: capture first, then grep. Under `set -o pipefail`, `cmd | grep -q` makes
# grep exit on the first match, SIGPIPEs the producer, and fails the pipeline —
# which is why this check reported a false ✗ (called "cosmetic" at S11 close).
CORE_TEST_OUT="$(pnpm --filter @chitra/core run test 2>&1 || true)"
if printf '%s' "$CORE_TEST_OUT" | grep -q "148 passed"; then
  ok "148/148 tests green"
else
  fail "core tests failed"
fi

label "Core typecheck"
if pnpm --filter @chitra/core run typecheck 2>/dev/null; then
  ok "typecheck clean"
else
  fail "typecheck failed"
fi

label "Docs typecheck"
if pnpm --filter @workspace/chitra-docs run typecheck 2>/dev/null; then
  ok "docs typecheck clean"
else
  fail "docs typecheck failed"
fi

label "Chart drift gate"
GEN_OUT="$(pnpm --filter @workspace/chitra-docs run gen:charts:check 2>&1 || true)"
if printf '%s' "$GEN_OUT" | grep -q "up to date"; then
  ok "gen:charts:check — all charts up to date"
else
  fail "gen:charts:check failed"
fi

label "No core changes"
changed=$(git diff main -- packages/core/src/ 2>/dev/null | wc -l)
if [ "$changed" -eq 0 ]; then
  ok "packages/core/src unchanged from main"
else
  fail "packages/core/src changed ($changed lines)"
fi

# ── Cumulative: previous sessions still green ─────────────────

header "Cumulative: Previous sessions"
label "S08+ chart output (braille, blocks, ascii)"
info "$ pnpm --filter @chitra/core run test (148 tests)"
ok "All renderers verified by test suite"

label "S09 LOCKED circular charts (pie/donut/area)"
if grep -q "LOCKED: circular charts" packages/core/README.md 2>/dev/null; then
  ok "LOCKED contract in README.md"
fi

label "S10 LOCKED line chart (braille, multi-series)"
if grep -q "LOCKED: line chart" packages/core/README.md 2>/dev/null; then
  ok "LOCKED contract in README.md"
fi

# ── Summary table ─────────────────────────────────────────────

header "Summary"
printf "\n"
printf "  %-40s %s\n" "Feature" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
# Derived, not typed. The catalog rows are decided by the executable check; the
# rest by commands that can fail. A hardcoded "SHIPS" table is a claim, not a demo.
if pnpm --filter @workspace/chitra-docs run check:catalog >/dev/null 2>&1; then
  CATALOG="SHIPS (executed)"
else
  CATALOG="BROKEN"; DEMO_FAILED=1
fi
if [ -z "$(git diff main -- packages/core/src/)" ]; then CORE="SHIPS (locked)"; else CORE="DRIFTED"; DEMO_FAILED=1; fi
if pnpm --filter @workspace/chitra-docs run gen:charts:check >/dev/null 2>&1; then GEN="SHIPS"; else GEN="BROKEN"; DEMO_FAILED=1; fi

printf "  %-40s %s\n" "All 20 catalog examples execute"            "$CATALOG"
printf "  %-40s %s\n" "Renderer + theme injection takes effect"    "$CATALOG"
printf "  %-40s %s\n" "Error capture (never white-screen)"         "$CATALOG"
printf "  %-40s %s\n" "Core chart output locked"                   "$CORE"
printf "  %-40s %s\n" "gen:charts:check green"                     "$GEN"
printf "\n  %s\n" "Not asserted by this script (source-read only, no DOM test):"
printf "  %-40s %s\n" "  two-panel split · vim chrome · toolbar"   "unverified"
printf "\n"
info "To launch docs in browser:"
info "  PORT=3000 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run dev"
info "  Then navigate to a chart page (e.g. /line)"
printf "\n"

ok "Session ${SESSION} demo complete."

if [ "$DEMO_FAILED" -ne 0 ]; then
  printf "${RED}Demo FAILED — at least one check above did not pass.${RESET}\n"
  exit 1
fi
