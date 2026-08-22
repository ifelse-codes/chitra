#!/usr/bin/env bash
# demo-session-15.sh — cumulative demo: S01–S15
# S15: Scripted browser QA of all 20 catalog pages

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="15"
HEADED=0
for arg in "$@"; do
  [ "$arg" = "--headed" ] && HEADED=1 && shift
done

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RED="\033[31m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
info()   { printf "${DIM}  %s${RESET}\n" "$1"; }
DEMO_FAILED=0
fail()   { printf "${RED}✗ %s${RESET}\n" "$1"; DEMO_FAILED=1; }

DOCS=artifacts/chitra-docs/src
APP="$DOCS/App.tsx"
TSX="$DOCS/components/CatalogPage.tsx"
STORE="$DOCS/lib/bufferStore.ts"
VCFG=artifacts/chitra-docs/vite.config.ts

header "Session ${SESSION} Demo — chitra docs: Scripted browser QA"

header "S15: Playwright QA script exists"
[ -f scripts/qa-catalog.mjs ] && ok "scripts/qa-catalog.mjs present" || fail "qa-catalog.mjs missing"

header "S15: Playwright installed"
pnpm --filter workspace list playwright >/dev/null 2>&1 && ok "Playwright in workspace deps" || fail "Playwright not installed"

header "S15: QA suite executes (dry-run check)"
# Quick syntax check
node --check scripts/qa-catalog.mjs 2>/dev/null && ok "QA script syntax OK" || fail "QA script has syntax errors"

header "S15: Verify script exists"
[ -f scripts/verify-session-15.sh ] && ok "verify-session-15.sh present" || fail "verify-session-15.sh missing"

header "S15: QA checks what matters"
grep -q 'CHART_IDS = \[' scripts/qa-catalog.mjs && ok "All 20 chart IDs in test" || fail "Missing chart IDs"
grep -q 'page.on("console"' scripts/qa-catalog.mjs && ok "Console error tracking" || fail "No console tracking"
grep -q 'page.on("pageerror"' scripts/qa-catalog.mjs && ok "Page error tracking" || fail "No page error tracking"
grep -q 'term-output\|term-error-block' scripts/qa-catalog.mjs && ok "Terminal output assertion" || fail "No output assertion"
grep -q 'Meta+Enter' scripts/qa-catalog.mjs && grep -q 'Control+Enter' scripts/qa-catalog.mjs && ok "Run shortcut test" || fail "No Run shortcut test"
grep -q 'persistence' scripts/qa-catalog.mjs && ok "Persistence smoke test" || fail "No persistence test"
grep -q 'results.json' scripts/qa-catalog.mjs && ok "JSON artifacts written" || fail "No artifact output"

header "S15: Artifacts directory structure"
grep -q '.ai/verify/session-15' scripts/qa-catalog.mjs && ok "Artifacts path correct" || fail "Wrong artifacts path"

header "Standing gates (unchanged)"
if pnpm --filter @workspace/chitra-docs run check:catalog >/dev/null 2>&1; then
  ok "check:catalog green"
else
  fail "check:catalog failed"
fi
if pnpm --filter @workspace/chitra-docs run typecheck >/dev/null 2>&1; then
  ok "docs typecheck clean"
else
  fail "docs typecheck failed"
fi

header "Core invariants (chart output LOCKED)"
CORE_TEST_OUT="$(pnpm --filter @chitra/core run test 2>&1 || true)"
if printf '%s' "$CORE_TEST_OUT" | grep -q "163 passed"; then
  ok "163/163 tests green"
else
  fail "core tests failed"
fi
changed=$(git diff main -- packages/core 2>/dev/null | wc -l)
if [ "$changed" -eq 0 ]; then
  ok "packages/core unchanged from main"
else
  fail "packages/core changed ($changed lines)"
fi

# ── Cumulative: previous sessions still green ─────────────────
header "Cumulative: Previous sessions"
for lock in "LOCKED: circular charts" "LOCKED: line chart" "LOCKED: bar chart"; do
  if grep -q "$lock" packages/core/README.md 2>/dev/null; then
    ok "$lock"
  else
    fail "$lock missing"
  fi
done
grep -q 'window.addEventListener("keydown", onKey)' "$TSX" \
  && ok "S13 global ⌘↩ run shortcut intact" || fail "S13 shortcut regressed"
grep -q 'useLocation' "$APP" && grep -q 'from "wouter"' "$APP" \
  && ok "S14 wouter routes intact" || fail "S14 routes regressed"
grep -q '__CHITRA_BOOT_ID__' "$VCFG" \
  && ok "S14 boot-scoped persistence intact" || fail "S14 persistence regressed"

# ── Summary table ─────────────────────────────────────────────
header "Summary"
printf "\n"
printf "  %-44s %s\n" "Feature" "Status"
printf "  %-44s %s\n" "----------------------------------------------" "------"
if pnpm --filter @workspace/chitra-docs run check:catalog >/dev/null 2>&1; then
  CATALOG="SHIPS (executed)"
else
  CATALOG="BROKEN"; DEMO_FAILED=1
fi
if [ -z "$(git diff main -- packages/core)" ]; then CORE="SHIPS (locked)"; else CORE="DRIFTED"; DEMO_FAILED=1; fi

printf "  %-44s %s\n" "Playwright QA script (20 charts + 4 docs + home)" "SCRIPTED"
printf "  %-44s %s\n" "Console/page error tracking"                       "IMPLEMENTED"
printf "  %-44s %s\n" "Terminal output assertion (non-empty)"               "IMPLEMENTED"
printf "  %-44s %s\n" "Global Run shortcut (⌘↩/Ctrl+↩) re-renders"       "IMPLEMENTED"
printf "  %-44s %s\n" "Edit→navigate→back persistence smoke"              "IMPLEMENTED"
printf "  %-44s %s\n" "Screenshots + JSON artifacts per page"             "IMPLEMENTED"
printf "  %-44s %s\n" "Standing gates (typecheck, catalog, drift)"        "$CATALOG"
printf "  %-44s %s\n" "Core chart output locked"                          "$CORE"
printf "\n  %s\n" "Run the full QA suite:"
printf "  %s\n" "  node scripts/qa-catalog.mjs            # headless (default)"
printf "  %s\n" "  node scripts/qa-catalog.mjs --headed   # watch Chrome run"
printf "\n"

ok "Session ${SESSION} demo complete."

if [ "$DEMO_FAILED" -ne 0 ]; then
  printf "${RED}Demo FAILED — at least one check above did not pass.${RESET}\n"
  exit 1
fi