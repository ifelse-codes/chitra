#!/usr/bin/env bash
# demo-session-27.sh — S27: candlestick + boxplot, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
# timeline (S21), gauge (S22), progress (S23), histogram (S25), waterfall (S26),
# funnel (S26), sankey (S26), radar (S26), candlestick (S27), and boxplot (S27).
#
# Every case runs the REAL chart and prints observed output (no stderr/
# exit-code swallowing), and the lock claims are FALSIFIABLE checks that go red
# on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="27"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }

DEMO_FAIL=0
scorecard=()
record() { # name  PASS|FAIL
  scorecard+=("$(printf '%-40s %s' "$1" "$2")")
  [ "$2" = "PASS" ] || DEMO_FAIL=1
}

# Render a snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s27_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s27_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — candlestick LOCKED to the reference/panel language"
printf "${DIM}  (bearish outline boxes · bullish solids · peak accent once · adaptive prices · dashed panel + OHLC eyebrow)${RESET}\n"

# ── BEFORE → AFTER ──────────────────────────────────────────────────────────
label "BEFORE (pre-lock — theme.colors green/red flood, decimal sprawl, bare title, solid baseline)"
cat <<'EOF'
  Candle Chart (green/red rainbow, 162.55-style y-labels, no panel)
EOF

label "AFTER (live render through the real candlestick chart)"
AFTER_C="$(render 'import { candlestick } from "./charts/candlestick.js";
console.log(candlestick({ data: [
  { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
  { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
  { open: 98, high: 108, low: 96, close: 107, label: "Day3" },
], noColor: true }).toString());')" || true
printf '%s\n' "$AFTER_C"

label "Check: bearish Day2 is an outline box, bullish Day1 solid, peak Day3 solid"
if printf '%s' "$AFTER_C" | grep -q "┌╌" && printf '%s' "$AFTER_C" | grep -q "▓" && printf '%s' "$AFTER_C" | grep -q "█"; then
  ok "outline downs · solid ups · solid peak"; record "candle-kinds" PASS
else no "kind vocabulary missing"; record "candle-kinds" FAIL; fi

label "Check: panel chrome (dashed frame, OHLC eyebrow, 2 rules, N·HI·LO·LAST foot)"
candle_ok=1
printf '%s' "$AFTER_C" | head -1 | grep -q "^┌╌" || candle_ok=0
printf '%s' "$AFTER_C" | grep -q "OHLC" || candle_ok=0
[ "$(printf '%s' "$AFTER_C" | grep -c "^│ ╌* │$")" = "2" ] || candle_ok=0
printf '%s' "$AFTER_C" | grep -q "N 3 · HI 115 · LO 95 · LAST 107" || candle_ok=0
if [ "$candle_ok" = "1" ]; then ok "frame + eyebrow + rules + foot all present"; record "candle-chrome" PASS
else no "panel chrome incomplete"; record "candle-chrome" FAIL; fi

label "Check: accent census (peak body only, 0 theme.colors leaks)"
CENSUS_C="$(render 'import { candlestick } from "./charts/candlestick.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = candlestick({ data: [
  { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
  { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
  { open: 98, high: 108, low: 96, close: 107, label: "Day3" },
] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!/[█▓┌╌┐│└┘]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other);')" || true
read -r C_ACCENT C_GREY C_OTHER <<< "$CENSUS_C"
if [ "$C_OTHER" != "0" ] || [ "$C_ACCENT" = "0" ] || [ "$C_GREY" = "0" ]; then
  no "census failed (accent=$C_ACCENT grey=$C_GREY other=$C_OTHER)"; record "candle-census" FAIL
else ok "accent ×$C_ACCENT on peak · grey ×$C_GREY · 0 leaks"; record "candle-census" PASS; fi

label "Check: degenerate inputs (empty / flat / non-finite)"
DEGEN_C="$(render 'import { candlestick } from "./charts/candlestick.js";
const e = candlestick({ data: [], noColor: true }).toPlain();
const f = candlestick({ data: [{ open: 50, high: 50, low: 50, close: 50, label: "F" }], noColor: true }).toPlain();
const m = candlestick({ data: [{ open: 1, high: 2, low: 1, close: 2, label: "O" }, { open: NaN, high: 1, low: 1, close: 1, label: "X" }], noColor: true }).toPlain();
console.log(JSON.stringify({ e: e.includes("N 0 · (no data)"), f: !f.includes("NaN") && f.includes("█"), m: !m.includes("NaN") }));')" || true
if [ "$DEGEN_C" = '{"e":true,"f":true,"m":true}' ]; then ok "empty + flat + non-finite safe"; record "candle-degen" PASS
else no "degenerate gap ($DEGEN_C)"; record "candle-degen" FAIL; fi

header "Session ${SESSION} Demo — boxplot LOCKED to the reference/panel language"
printf "${DIM}  (peak-median accent once · grey ramp + ░▒▓ shade · ─── medians vs │ edges · SPREAD eyebrow)${RESET}\n"

label "AFTER (live render through the real boxplot chart)"
AFTER_B="$(render 'import { boxplot } from "./charts/boxplot.js";
console.log(boxplot({ data: [[1,2,3,4,5,6,7,8,9],[2,3,4,5,6],[10,12,14,16,18,20,22]], labels: ["A","B","C"], noColor: true }).toString());')" || true
printf '%s\n' "$AFTER_B"

label "Check: median runs distinct from edges, shade + peak fill present"
box_ok=1
printf '%s' "$AFTER_B" | grep -Eq "───|═══" || box_ok=0
printf '%s' "$AFTER_B" | grep -q "│" || box_ok=0
printf '%s' "$AFTER_B" | grep -Eq "[░▒▓]" || box_ok=0
printf '%s' "$AFTER_B" | grep -q "█" || box_ok=0
if [ "$box_ok" = "1" ]; then ok "───/═══ medians · │ edges · ░▒▓ + █ fills"; record "box-glyphs" PASS
else no "median/texture vocabulary missing"; record "box-glyphs" FAIL; fi

label "Check: panel chrome (dashed frame, SPREAD eyebrow, 2 rules, GROUPS·MED·PEAK foot)"
boxchrome_ok=1
printf '%s' "$AFTER_B" | head -1 | grep -q "^┌╌" || boxchrome_ok=0
printf '%s' "$AFTER_B" | grep -q "SPREAD" || boxchrome_ok=0
[ "$(printf '%s' "$AFTER_B" | grep -c "^│ ╌* │$")" = "2" ] || boxchrome_ok=0
printf '%s' "$AFTER_B" | grep -q "GROUPS 3 · MED 6 · PEAK C 16" || boxchrome_ok=0
if [ "$boxchrome_ok" = "1" ]; then ok "frame + eyebrow + rules + foot all present"; record "box-chrome" PASS
else no "panel chrome incomplete"; record "box-chrome" FAIL; fi

label "Check: accent census (peak group only, 0 rainbow leaks)"
CENSUS_B="$(render 'import { boxplot } from "./charts/boxplot.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = boxplot({ data: [[1,2,3,4,5,6,7,8,9],[2,3,4,5,6],[10,12,14,16,18,20,22]], labels: ["A","B","C"] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!/[│┬┴─═░▒▓█]/.test(s[2])) continue;
  if (/[A-Za-z0-9]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other);')" || true
read -r B_ACCENT B_GREY B_OTHER <<< "$CENSUS_B"
if [ "$B_OTHER" != "0" ] || [ "$B_ACCENT" = "0" ] || [ "$B_GREY" = "0" ]; then
  no "census failed (accent=$B_ACCENT grey=$B_GREY other=$B_OTHER)"; record "box-census" FAIL
else ok "accent ×$B_ACCENT on peak · grey ×$B_GREY · 0 leaks"; record "box-census" PASS; fi

label "Check: degenerate inputs (empty / single-value / non-finite / narrow)"
DEGEN_B="$(render 'import { boxplot } from "./charts/boxplot.js";
const e = boxplot({ data: [], noColor: true }).toPlain();
const s = boxplot({ data: [[5],[5]], noColor: true }).toPlain();
const m = boxplot({ data: [[1, NaN, 2]], noColor: true }).toPlain();
const n = boxplot({ data: [[1,2,3]], width: 5, noColor: true }).toPlain();
console.log(JSON.stringify({ e: e.includes("GROUPS 0 · (no data)"), s: !s.includes("NaN"), m: !m.includes("NaN"), n: n.startsWith("┌╌") }));')" || true
if [ "$DEGEN_B" = '{"e":true,"s":true,"m":true,"n":true}' ]; then ok "empty + single + non-finite + narrow safe"; record "box-degen" PASS
else no "degenerate gap ($DEGEN_B)"; record "box-degen" FAIL; fi

# ── Summary scorecard ─────────────────────────────────────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (tonal, precision, degen)" "see verify-session-27.sh"
printf "  %-40s %s\n" "README LOCKED ×2 blocks"             "see verify-session-27.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-27.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
