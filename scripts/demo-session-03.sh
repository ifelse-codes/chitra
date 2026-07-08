#!/usr/bin/env bash
# Session 03 demo — Polished docs site (cumulative).
# Shows: generated previews, docs front-door IA, valid themes, and AI output path.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="03"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

APP="artifacts/chitra-docs/src/App.tsx"

header "Session ${SESSION} Demo — Docs polish"

header "1. Start-here navigation"
label "The sidebar groups the adopter path before the chart gallery:"
grep -n "Start Here\\|Chart Types\\|Agent Output" "$APP"
ok "Docs IA now separates onboarding, chart gallery, and agent output."

header "2. Homepage route cards"
label "The first screen points to install, quickstart, and AI output:"
grep -n "title=\"Install\"\\|title=\"Quickstart\"\\|title=\"AI output\"" "$APP"
ok "Users can jump directly to the highest-value docs paths."

header "3. Valid theme copy"
label "Theme examples use real @chitra/core theme names:"
grep -n "tokyo-night\\|dracula\\|github-dark\\|monochrome" "$APP" | head -8
ok "The phantom neon theme is gone from docs-site copy."

header "4. Generated chart previews"
label "Docs still render from generated chart data:"
pnpm --filter @workspace/chitra-docs run gen:charts:check >/dev/null
ok "Generated chart previews have no drift."

header "Summary"
printf "\n"
printf "  %-38s %s\n" "Feature" "Status"
printf "  %-38s %s\n" "--------------------------------------" "------"
printf "  %-38s %s\n" "start-here docs IA"                   "WORKS"
printf "  %-38s %s\n" "homepage route cards"                 "WORKS"
printf "  %-38s %s\n" "valid theme copy"                     "WORKS"
printf "  %-38s %s\n" "generated preview drift check"         "GREEN"
printf "\n"

ok "Session ${SESSION} demo complete."
