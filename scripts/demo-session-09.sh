#!/usr/bin/env bash
# Session 09 demo — design-reference language, proven on the donut chart.
# Shows the CURRENT bare donut vs the TARGET mudra one-hue look
# (dashed frame, eyebrow caption, tone ramp + glyph legend, metric cells,
# status footer) rendered with chitra's own ansi/panel primitives.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="09"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — design-reference donut"

header "1. The design language (from design-reference/)"
label "tui-chart  → terminal-native look: dashed frame, glyphs, metric stats"
label "mudra-chart → ONE hue + tone ramp + dash + glyph; accent spent once"
label "mudra-dashboard → terminal translation: mono, sharp corners, dashed borders"
ok "Design language learned and codified in the README."

header "2. Current donut (today)"
label "Bare — no panel, rainbow slices, plain text legend:"
./packages/core/node_modules/.bin/tsx scripts/src/demo09-donut.ts 2>/dev/null \
  | sed -n '/CURRENT/,/^$/p'
ok "Baseline captured."

header "3. Target donut (mudra one-hue language)"
label "Dashed ╌ panel · eyebrow caption · tone ramp + glyph legend · metric cells · status:"
./packages/core/node_modules/.bin/tsx scripts/src/demo09-donut.ts 2>/dev/null \
  | sed -n '/TARGET A/,/^$/p'
ok "Target look rendered with chitra's own primitives — no lib changes."

header "4. README design contract"
grep -n "Design Style" packages/core/README.md | sed 's/^/  /'
ok "Design Style section present."

header "Summary"
printf "\n"
printf "  %-40s %s\n" "Feature" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "Design reference analysis"              "DONE"
printf "  %-40s %s\n" "README Design Style section"            "ADDED"
printf "  %-40s %s\n" "Direction: mudra one-hue"               "LOCKED"
printf "  %-40s %s\n" "Donut design-language demo"             "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
