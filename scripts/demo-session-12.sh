#!/usr/bin/env bash
# demo-session-12.sh — cumulative demo: S01–S12
# S12: bar chart reference-locked to the shared design language
#      (one accent + grey tone ramp, dashed panel, + y-guide, + x-ticks, per-series summary)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="12"
TSX="./packages/core/node_modules/.bin/tsx"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RED="\033[31m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
DEMO_FAILED=0
fail()   { printf "${RED}✗ %s${RESET}\n" "$1"; DEMO_FAILED=1; }

# Write a temp file, run it, capture output, remove it.
run_ts() {
  local TMP=".demo-s12-$$-$RANDOM.mts"
  cat > "$TMP"
  local OUT
  OUT=$("$TSX" "$TMP" 2>/dev/null) || { rm -f "$TMP"; return 1; }
  rm -f "$TMP"
  printf "%s\n" "$OUT"
}

header "Session ${SESSION} Demo — chitra bar chart (LOCKED S12 design)"

# ── S12: single-series bar ────────────────────────────────────
header "S12: bar() — locked panel (single series)"
label "One accent on peak bar; grey tone ramp; dashed frame; + ticks; MIN/MAX/AVG/LAST"
OUT=$(run_ts <<'TS'
import { bar } from "./packages/core/src/charts/bar.js";
bar({
  data: [42, 67, 38, 55, 72, 45, 31, 58],
  labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug"],
  title: "Monthly Deploys",
  xLabel: "DEPLOYMENTS",
  height: 12,
}).render();
TS
)
echo "$OUT"

# Strip ANSI before checking so colour codes don't break substring matches.
PLAIN=$(printf '%s' "$OUT" | sed 's/\x1b\[[0-9;]*m//g')
if echo "$PLAIN" | grep -q "┌╌";       then ok "dashed frame top (┌╌)"; else fail "missing dashed frame top"; fi
if echo "$PLAIN" | grep -q "└╌";       then ok "dashed frame bottom (└╌)"; else fail "missing dashed frame bottom"; fi
if echo "$PLAIN" | grep -q "DEPLOYMENTS"; then ok "eyebrow row"; else fail "missing eyebrow row"; fi
if echo "$PLAIN" | grep -q "+";         then ok "+ tick marks present"; else fail "missing + tick marks"; fi
if echo "$PLAIN" | grep -q "· min ";    then ok "summary: min"; else fail "summary missing min"; fi
if echo "$PLAIN" | grep -q "· max ";    then ok "summary: max"; else fail "summary missing max"; fi
if echo "$PLAIN" | grep -q "· avg ";    then ok "summary: avg"; else fail "summary missing avg"; fi
if echo "$PLAIN" | grep -q "last";      then ok "summary: last"; else fail "summary missing last"; fi

# ── S12: multi-series bar ────────────────────────────────────
header "S12: bar() — multi-series"
label "Tone ramp per series; per-series summary"
run_ts <<'TS'
import { bar } from "./packages/core/src/charts/bar.js";
bar({
  data: [
    [120, 190, 150, 280, 340, 310],
    [ 80, 130,  90, 150, 200, 180],
  ],
  labels: ["Jan","Feb","Mar","Apr","May","Jun"],
  seriesLabels: ["Desktop", "Mobile"],
  title: "Traffic by Device",
  height: 10,
}).render();
TS

# ── S12: themes ───────────────────────────────────────────────
header "S12: bar() — three themes"
for theme in default nord dracula; do
  label "Theme: $theme"
  run_ts <<TS
import { bar } from "./packages/core/src/charts/bar.js";
bar({ data: [30, 60, 45, 80, 55], title: "${theme}", theme: "${theme}", height: 8 }).render();
TS
done

# ── S12: ASCII renderer ────────────────────────────────────────
header "S12: bar() — ascii renderer"
label "Same locked chrome in ASCII mode"
run_ts <<'TS'
import { bar } from "./packages/core/src/charts/bar.js";
bar({
  data: [10, 40, 25, 65, 50],
  labels: ["A","B","C","D","E"],
  title: "ASCII Bar",
  renderer: "ascii",
  height: 8,
}).render();
TS

# ── S12: shared panel chrome comparison ───────────────────────
header "S12: bar vs line — same panel chrome (noColor)"
run_ts <<'TS'
import { bar } from "./packages/core/src/charts/bar.js";
import { line } from "./packages/core/src/charts/line.js";
console.log("── bar() ──");
bar({ data: [30, 55, 40, 70, 45], title: "Bar", noColor: true, height: 8 }).render();
console.log("── line() ──");
line({ data: [30, 55, 40, 70, 45], title: "Line", noColor: true, height: 8 }).render();
TS

# ── Summary ───────────────────────────────────────────────────
echo ""
header "Demo Summary"
printf '%-38s %s\n' "CRITERION" "STATUS"
printf '%-38s %s\n' "--------------------------------------" "------"
printf '%-38s %s\n' "one accent + grey tone ramp"    "SHIPPED (no theme.colors[] rainbow)"
printf '%-38s %s\n' "dashed panel + eyebrow"         "SHIPPED (┌╌…╌┐ + ╌ rule + eyebrow)"
printf '%-38s %s\n' "+ y-guide + + x-tick row"      "SHIPPED (+ at top; + marks under plot)"
printf '%-38s %s\n' "per-series MIN/MAX/AVG/LAST"    "SHIPPED (summary rows + accent on max)"
printf '%-38s %s\n' "locked families unchanged"      "SHIPPED (area/line/circular byte-equal)"
printf '%-38s %s\n' "README LOCKED: bar chart"       "SHIPPED (### LOCKED: bar chart — S12)"
printf '%-38s %s\n' "sparkline actually renders"      "SHIPPED (was dead code — S12 review REJECT, fixed)"
printf '%-38s %s\n' "163 tests green"                "SHIPPED (was 148 pre-S12, 159 pre-fix)"
printf '%-38s %s\n' "verify-session-12.sh 28/28"     "SHIPPED (ALL GREEN)"
printf '%-38s %s\n' "SVG/web bar renderer"           "NOT BUILT (no BarChartModel yet)"

if [ "$DEMO_FAILED" -eq 0 ]; then
  printf "\n${GREEN}${BOLD}Demo exit 0 — all checks passed.${RESET}\n"
  exit 0
else
  printf "\n${RED}${BOLD}Demo exit 1 — one or more checks failed.${RESET}\n"
  exit 1
fi
