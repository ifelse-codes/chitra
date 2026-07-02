#!/usr/bin/env bash
# Template — copy to scripts/demo-session-NN.sh and customize per session.
# Demo scripts are narrative — they show what was built with real/mock data.
# Demos are cumulative: each session's demo includes prior session capabilities.
# NOTE: This bash script is for CI/verify. When a user asks to see the demo,
# the agent should present results as an interactive HTML slide deck
# (terminal-styled, auto-play, PASS/FAIL coloring, scorecard summary).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# === EDIT PER SESSION ===
SESSION="NN"
# ========================

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo"

# === EDIT PER SESSION ===
# header "Feature Name"
# label "Description of what this demonstrates"
# Run commands, show output, display results
# ok "What this proves"
# ========================

# --- Summary Table ---
header "Summary"
printf "\n"
printf "  %-30s %s\n" "Feature" "Status"
printf "  %-30s %s\n" "------------------------------" "------"
# printf "  %-30s %s\n" "Feature name"                  "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
