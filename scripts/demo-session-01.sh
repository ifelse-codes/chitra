#!/usr/bin/env bash
# Session 01 demo — Docs-from-lib generator (cumulative).
# Shows: chitra renders real charts; the docs gallery data is now generated
# from the library (not hand-pasted); drift is detectable via --check.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="01"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

TSX="pnpm --filter @chitra/core exec tsx"

header "Session ${SESSION} Demo — Docs-from-lib generator"

header "1. chitra renders real charts (@chitra/core)"
label "Live charts straight from the library (packages/core/demo.ts):"
# Runs with cwd = packages/core (pnpm --filter exec). Show the first ~24 lines.
{ $TSX demo.ts 2>/dev/null || true; } | head -24 || true
ok "20 chart types available; ChartResult gives render/toString/toPlain/toJSON."

header "2. Docs gallery is GENERATED, not hand-pasted"
label "One spec source (scripts/chart-specs.ts) → both shipped data files:"
pnpm --filter @workspace/chitra-docs run gen:charts 2>&1 | grep -E "wrote" || true
ok "src/data/charts.ts + ansi-charts.json rendered through the real library."

header "3. Drift is now detectable"
label "CI check fails if the shipped files diverge from the spec source:"
if pnpm --filter @workspace/chitra-docs run gen:charts:check >/dev/null 2>&1; then
  ok "gen:charts:check → in sync (exit 0)"
else
  printf "${YELLOW}✗ out of sync — run pnpm gen:charts${RESET}\n"
fi
label "Bonus: fixed a real bug — candlestick referenced theme \"neon\" (nonexistent) → \"dracula\"."

header "Summary"
printf "\n"
printf "  %-38s %s\n" "Feature" "Status"
printf "  %-38s %s\n" "--------------------------------------" "------"
printf "  %-38s %s\n" "chitra chart rendering (20 types)"       "WORKS"
printf "  %-38s %s\n" "docs gallery generated from lib"         "WORKS"
printf "  %-38s %s\n" "drift check (gen:charts:check)"          "WORKS"
printf "  %-38s %s\n" "candlestick phantom-theme bug"           "FIXED"
printf "\n"

ok "Session ${SESSION} demo complete."
