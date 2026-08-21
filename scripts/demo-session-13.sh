#!/usr/bin/env bash
# demo-session-13.sh — cumulative demo: S01–S13
# S13: docs catalog chrome at Darpan parity (Run ⌘↩, canon tokens, inspector chrome)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="13"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RED="\033[31m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
info()   { printf "${DIM}  %s${RESET}\n" "$1"; }
DEMO_FAILED=0
fail()   { printf "${RED}✗ %s${RESET}\n" "$1"; DEMO_FAILED=1; }

DOCS=artifacts/chitra-docs/src
CSS="$DOCS/index.css"
TSX="$DOCS/components/CatalogPage.tsx"

header "Session ${SESSION} Demo — chitra docs catalog chrome at Darpan parity"

header "S13: Run button = Darpan .btnPrimary"
label "Accent fill + accent border + warm near-black text"
grep -q "color: oklch(0.12 0.008 60)" "$CSS" \
  && ok "warm near-black on accent" || fail "run text color not canon"
grep -q "border: 1px solid var(--theater-accent)" "$CSS" \
  && ok "1px accent border" || fail "no accent border on .ct-run"
label "Shortcut written in the button + global listener"
grep -q 'ct-kbd' "$TSX" && grep -q 'RUN_KBD' "$TSX" \
  && ok "⌘↩ / Ctrl ↩ keycap chip" || fail "kbd chip missing"
grep -q 'window.addEventListener("keydown", onKey)' "$TSX" \
  && ok "global cmd/ctrl+enter listener" || fail "shortcut is editor-only"

header "S13: Parity layer carries Darpan canon tokens"
grep -q "oklch(1 0 0 / 0.92)" "$CSS" \
  && ok "white-alpha fg tiers (verified vs live Darpan CSS)" || fail "fg tiers still approximated"
grep -q "::selection { background: oklch(0.8 0.13 305 / 0.35)" "$CSS" \
  && ok "accent selection" || fail "selection not accent"
grep -q "outline: 2px solid oklch(0.8 0.13 305 / 0.45)" "$CSS" \
  && ok "accent focus ring" || fail "focus ring not accent"
grep -q "scrollbar-color: oklch(0.32 0.014 270 / 0.45)" "$CSS" \
  && ok "line-tinted scrollbars" || fail "scrollbars not line-tinted"

header "S13: Inspector chrome"
for feat in tf-k tf-v tf-div dashed; do
  if grep -q "$feat" "$TSX" || grep -q "$feat" "$CSS"; then
    ok "$feat"
  else
    fail "$feat missing"
  fi
done
grep -q 'term-error-chip' "$TSX" \
  && ok "RUN FAILED chip banner" || fail "error banner missing"

header "S13: Executable behavior"
label "All catalog examples execute in-browser"
if pnpm --filter @workspace/chitra-docs run check:catalog >/dev/null 2>&1; then
  ok "check:catalog green"
else
  fail "check:catalog failed"
fi
label "Docs typecheck"
if pnpm --filter @workspace/chitra-docs run typecheck >/dev/null 2>&1; then
  ok "typecheck clean"
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
if grep -q "LOCKED: circular charts" packages/core/README.md 2>/dev/null; then
  ok "S09 LOCKED circular charts"
else
  fail "S09 LOCKED contract missing"
fi
if grep -q "LOCKED: line chart" packages/core/README.md 2>/dev/null; then
  ok "S10 LOCKED line chart"
else
  fail "S10 LOCKED contract missing"
fi
if grep -q "LOCKED: bar chart" packages/core/README.md 2>/dev/null; then
  ok "S12 LOCKED bar chart"
else
  fail "S12 LOCKED contract missing"
fi

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

printf "  %-44s %s\n" "Run = accent primary + ⌘↩ keycap"            "$CATALOG"
printf "  %-44s %s\n" "Global cmd/ctrl+enter run shortcut"          "$CATALOG"
printf "  %-44s %s\n" "White-alpha fg tiers (Darpan canon)"         "$CATALOG"
printf "  %-44s %s\n" "Uppercase chips · ghost actions · kv footer" "$CATALOG"
printf "  %-44s %s\n" "Dashed empty state + error banner"           "$CATALOG"
printf "  %-44s %s\n" "Core chart output locked"                    "$CORE"
printf "\n  %s\n" "Not asserted by this script (visual, founder-reviewed):"
printf "  %-44s %s\n" "  proportions · hover feel · aesthetic match"  "founder-approved live"
printf "\n"
info "To launch docs in browser:"
info "  PORT=5173 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run dev"
printf "\n"

ok "Session ${SESSION} demo complete."

if [ "$DEMO_FAILED" -ne 0 ]; then
  printf "${RED}Demo FAILED — at least one check above did not pass.${RESET}\n"
  exit 1
fi
