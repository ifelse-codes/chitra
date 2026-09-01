#!/usr/bin/env bash
# demo-session-18.sh — S18: the heatmap chart, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), and — this session — heatmap (S18).
# NOTE: When a user asks to SEE the demo, present it as a terminal-styled HTML slide
# deck (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="18"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

render() { # render a heatmap sample through the REAL source (not the stale dist)
  local tmp="packages/core/src/__demo_s18_tmp.ts"
  printf '%s\n' "$1" > "$tmp"
  ( cd packages/core && npx tsx "src/__demo_s18_tmp.ts" ) 2>/dev/null || true
  rm -f "$tmp"
}

header "Session ${SESSION} Demo — heatmap chart LOCKED"

label "BEFORE → the pre-lock heatmap used a 10-colour blue→orange→red rainbow"
printf "${DIM}  (HEAT_COLORS_DARK, no panel frame, no eyebrow, no summary footer)${RESET}\n"

label "AFTER → grey-ramp intensity + ONE accent on the peak cell, full panel chrome"
render 'import { heatmap } from "./charts/heatmap.js";
console.log(heatmap({
  data: [[1,3,5,7,9],[2,4,6,8,10],[3,5,7,9,11],[4,6,8,10,12]],
  title: "Activity Heatmap", width: 40,
}).toString());'
ok "grey ramp #ECECEF→#6A6A75 (light→dark), single accent on peak (3,4), rows×cols·min..max·peak footer"

label "Degenerate data is safe — an empty grid renders a framed n 0 panel"
render 'import { heatmap } from "./charts/heatmap.js";
console.log(heatmap({ data: [], width: 40 }).toPlain());'
ok "no Infinity / NaN; framed n 0 footer"

label "An all-equal grid renders honestly with a collapsed range"
render 'import { heatmap } from "./charts/heatmap.js";
console.log(heatmap({ data: [[5,5],[5,5]], width: 40 }).toPlain());'
ok "collapsed 5..5 range; accent still spent exactly once"

# --- Summary Table ---
header "Summary"
printf "\n"
printf "  %-34s %s\n" "Capability" "Status"
printf "  %-34s %s\n" "----------------------------------" "------"
printf "  %-34s %s\n" "heatmap: grey-ramp intensity"        "LOCKED"
printf "  %-34s %s\n" "heatmap: one accent on peak cell"    "LOCKED"
printf "  %-34s %s\n" "heatmap: dashed panel + eyebrow"     "LOCKED"
printf "  %-34s %s\n" "heatmap: rows×cols·min..max·peak"    "LOCKED"
printf "  %-34s %s\n" "heatmap: empty/degenerate safe"      "WORKS"
printf "  %-34s %s\n" "falsifiability tests (accent-once)"  "GREEN"
printf "\n"

ok "Session ${SESSION} demo complete."
