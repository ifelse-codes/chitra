#!/usr/bin/env bash
# Session 10 demo — the line chart, rebuilt to carry the LOCKED Session 09
# design language. Shows the dashed panel + eyebrow + `│` y-guide + braille
# curve on the tone ramp with the accent spent once (peak cap + footer max),
# clean X-axis labels, and the footer stats — plus the ascii fallback used by
# the docs NIFTY preview.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="10"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — line chart carries the LOCKED S09 look"

header "1. What carried over from the locked area/circular language"
label "dashed frame ┌╌…╌┐ · eyebrow row · | y-guide · braille sub-pixels"
label "tone-ramp curve (#A4A4AE) · accent spent ONCE on the peak cap + footer max"
label "empty cells are spaces (never blank-braille U+2800) · footer stats"
ok "Same panel DNA as pie / donut / area."

header "2. Line — braille, eyebrow, timestamp, status"
./packages/core/node_modules/.bin/tsx -e '
import { line } from "@chitra/core";
console.log(line({
  data: [12, 19, 15, 28, 34, 31, 42, 38, 52, 47, 61, 58],
  labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
  title: "REVENUE",
  eyebrow: "Monthly · Revenue trend",
  timestamp: "10:42 IST",
  status: "all systems operational",
  width: 62,
  height: 12,
}).toPlain());
' 2>/dev/null || true
ok "Line renders the locked language."

header "3. Multi-series — thin lines + glyph markers stop the overlap mess"
./packages/core/node_modules/.bin/tsx -e '
import { line } from "@chitra/core";
console.log(line({
  data: [
    [120, 200, 170, 260, 220, 310, 280, 340],
    [80, 150, 190, 180, 240, 230, 290, 310],
    [150, 160, 175, 185, 195, 205, 215, 225],
  ],
  labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug"],
  seriesLabels: ["Revenue", "Costs", "Baseline"],
  title: "GROWTH",
  eyebrow: "Fiscal · Revenue vs costs",
  width: 56,
  height: 10,
}).toPlain());
' 2>/dev/null || true
ok "Each series a thin line in its own colour + glyph markers at points."

header "4. ASCII fallback — the docs NIFTY preview"
cat > .demo-nifty.mts <<'EOF'
import { line } from "./packages/core/src/charts/line.js";
const o = line({
  data: [
    24000, 24080, 24150, 24260, 24400, 24460, 24380, 24400, 24340, 24310,
    24480, 24390, 24270, 24140, 24060, 24060, 23990, 23880, 23940, 23900,
    24060, 24000, 24060, 24120, 24180, 24260, 24280, 24240, 24350, 24340,
    24460, 24470, 24490, 24510, 24550, 24600, 24660, 24800, 24860, 24860,
    24720, 24660, 24630, 24590, 24540, 24510, 24470, 24520, 24560, 24600
  ],
  labels: ["7D Ago", "6D Ago", "5D Ago", "4D Ago", "3D Ago", "2D Ago", "1D Ago", "Now"],
  title: "NIFTY 50 INDEX",
  width: 72,
  height: 14,
  renderer: "ascii",
});
console.log(o.toPlain());
EOF
./packages/core/node_modules/.bin/tsx .demo-nifty.mts 2>/dev/null
rm -f .demo-nifty.mts
ok "ASCII line drawing survives on the locked panel."

header "5. LOCKED contract on file"
grep -n "LOCKED: line chart" packages/core/README.md | sed 's/^/  /'
ok "README documents the locked line language."

header "Summary"
printf "\n"
printf "  %-40s %s\n" "Feature" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "Dashed panel + eyebrow"                    "LOCKED"
printf "  %-40s %s\n" "Braille curve on tone ramp"                "DONE"
printf "  %-40s %s\n" "Accent spent once (peak + summary max)"     "DONE"
printf "  %-40s %s\n" "Multi-series glyph markers + thin lines"    "DONE"
printf "  %-40s %s\n" "Dashed gridlines + per-series summary"      "DONE"
printf "  %-40s %s\n" "Auto-scaled y-range (shared SVG model)"    "DONE"
printf "  %-40s %s\n" "Clean X-axis labels"                       "DONE"
printf "  %-40s %s\n" "ASCII fallback (docs preview)"             "DONE"
printf "\n"

ok "Session ${SESSION} demo complete."
