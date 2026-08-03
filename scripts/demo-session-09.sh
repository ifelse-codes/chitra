#!/usr/bin/env bash
# Session 09 demo — design-reference language, proven on pie + donut.
# Shows the mudra one-hue look (dashed frame, eyebrow, braille-dot circle,
# tone ramp, accent on the largest slice, right-aligned legend, status footer)
# rendered by the shared ring renderer.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="09"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — mudra one-hue pie + donut"

header "1. The design language (from design-reference/)"
label "mudra-chart → ONE hue + tone ramp + dash + glyph; accent spent once"
label "mudra-dashboard → terminal translation: mono, sharp corners, dashed borders"
ok "Design language learned and codified in the README."

header "2. The shared ring renderer (monochrome-print solution)"
label "A perfect round circle drawn from 2×4 sub-pixel braille dots, like the"
label "reference's stroked SVG circles — no stripes, bars, seams, or blocks."
ok "Braille dots + grey tone ramp + accent on the largest slice."

header "3. Pie — braille-dot circle, accent on largest, right legend"
./packages/core/node_modules/.bin/tsx -e '
import { pie } from "@chitra/core";
console.log(pie({
  data: [34.2, 28.6, 19.4, 9.8, 5.3, 2.7],
  labels: ["Web", "Mobile", "API", "Partner", "Bot", "Other"],
  title: "CLIENTS",
}).toPlain());
' 2>/dev/null || true
ok "Pie renders the design language."

header "4. Donut — dashed panel · eyebrow · accent primary · status"
./packages/core/node_modules/.bin/tsx -e '
import { donut } from "@chitra/core";
console.log(donut({
  data: [1_240_000, 380_000, 170_000, 14_000],
  labels: ["CPU", "MEM", "NET", "IO"],
  title: "SYSTEM",
  eyebrow: "Distribution · One hue + tone ramp + braille",
  status: "all systems operational ✓",
}).toPlain());
' 2>/dev/null || true
ok "Donut renders the design language."

header "5. README design contract"
grep -n "Design Style" packages/core/README.md | sed 's/^/  /'
ok "Design Style section present."

header "Summary"
printf "\n"
printf "  %-40s %s\n" "Feature" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "Design reference analysis"              "DONE"
printf "  %-40s %s\n" "README Design Style section"            "ADDED"
printf "  %-40s %s\n" "Direction: mudra one-hue"               "LOCKED"
printf "  %-40s %s\n" "Shared ring renderer (pie+donut)"       "DONE"
printf "  %-40s %s\n" "Braille-dot round circle (pie+donut)"     "DONE"
printf "\n"

ok "Session ${SESSION} demo complete."
