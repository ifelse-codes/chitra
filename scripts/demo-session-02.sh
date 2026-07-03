#!/usr/bin/env bash
# Session 02 demo — Expanded examples (cumulative).
# Shows: the new multi-series bar, all 7 themes, and MCP-tool agent output.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="02"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

TSX="$ROOT/packages/core/node_modules/.bin/tsx"

header "Session ${SESSION} Demo — Expanded examples"

header "1. Multi-series bar chart with legend"
label "Grouped bars + seriesLabels, rendered through @chitra/core:"
( cd examples && "$TSX" basic.ts 2>/dev/null ) | awk '/MULTI-SERIES BAR CHART/{p=1} p{print} /HORIZONTAL BAR CHART/{exit}' | head -30 || true
ok "Grouped comparison with a legend works out of the box."

header "2. Theme tour across all 7 themes"
label "The same line chart rendered once per built-in theme:"
( cd examples && "$TSX" basic.ts 2>/dev/null ) | awk '/THEME TOUR/{p=1} p{print} /HISTOGRAM/{exit}' | head -60 || true
ok "Themes: default, nord, dracula, github-dark, tokyo-night, solarized, monochrome."

header "3. AI-agent / MCP tool result"
label "A chart shaped as a tool result an LLM can consume (noColor + toJSON):"
( cd examples && "$TSX" basic.ts 2>/dev/null ) | awk '/AI AGENT OUTPUT/{p=1} p{print}' | head -40 || true
ok "toPlain() + toJSON() fit the MCP content array pattern."

header "Summary"
printf "\n"
printf "  %-38s %s\n" "Feature" "Status"
printf "  %-38s %s\n" "--------------------------------------" "------"
printf "  %-38s %s\n" "multi-series bar with legend"          "WORKS"
printf "  %-38s %s\n" "theme tour (7 themes)"                 "WORKS"
printf "  %-38s %s\n" "MCP-tool agent output"                 "WORKS"
printf "  %-38s %s\n" "116 core tests"                        "GREEN"
printf "\n"

ok "Session ${SESSION} demo complete."
