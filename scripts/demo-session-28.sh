#!/usr/bin/env bash
# demo-session-28.sh — S28: sparkline LOCKED to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line
# (S10), bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19),
# treemap (S20), timeline (S21), gauge (S22), progress (S23), histogram
# (S25), waterfall (S26), funnel (S26), sankey (S26), radar (S26),
# candlestick (S27), boxplot (S27), and sparkline (S28).
#
# Every case runs the REAL chart and prints observed output (no stderr/
# exit-code swallowing), and the lock claims are FALSIFIABLE checks that go red
# on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="28"
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
  local tmp="packages/core/src/__demo_s28_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s28_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — sparkline LOCKED to the reference/panel language"
printf "${DIM}  (shape+shade columns · peak accent once · dashed panel + SPARKLINE eyebrow · n·min·max·last·peak foot)${RESET}\n"

# ── BEFORE → AFTER ──────────────────────────────────────────────────────────
label "BEFORE (pre-lock — bare single-teal strip, no frame, no facts)"
cat <<'EOF'
  CPU  ▂▃▃▅▄▇▆██ 82   (one teal flood, label + last only)
EOF

label "AFTER (live render through the real sparkline chart)"
AFTER_S="$(render 'import { sparkline } from "./charts/sparkline.js";
console.log(sparkline({ data: [45, 60, 75, 88, 95, 88, 75, 60, 48, 55, 70, 85, 96, 102, 90, 76, 62, 50, 58, 72, 86, 94, 87, 74, 61, 52, 66, 80], label: "CPU", showValue: true, noColor: true }).toString());')" || true
printf '%s\n' "$AFTER_S"

label "Check: shape+shade vocabulary (4 strip rows, ramp glyphs, solid peak, no sub-blocks)"
if [ "$(printf '%s' "$AFTER_S" | grep -c "[░▒▓█]")" = "4" ] && printf '%s' "$AFTER_S" | grep -Eq "[░▒▓]" \
  && printf '%s' "$AFTER_S" | grep -q "█" && ! printf '%s' "$AFTER_S" | grep -Eq "[▁▂▃▄▅▆▇]"; then
  ok "4-row strip · ░▒▓ ramp · █ peak · no sub-blocks"; record "spark-vocab" PASS
else no "shape+shade vocabulary missing"; record "spark-vocab" FAIL; fi

label "Check: panel chrome (dashed frame, CPU on top, SPARKLINE eyebrow, 2 rules, facts foot)"
spark_ok=1
printf '%s' "$AFTER_S" | head -1 | grep -q "^┌╌.*CPU" || spark_ok=0
printf '%s' "$AFTER_S" | grep -q "SPARKLINE" || spark_ok=0
[ "$(printf '%s' "$AFTER_S" | grep -c "^│ ╌* │$")" = "2" ] || spark_ok=0
printf '%s' "$AFTER_S" | grep -q "n 28 · min 45 · max 102 · last 80 · peak 102" || spark_ok=0
if [ "$spark_ok" = "1" ]; then ok "frame + label + eyebrow + rules + foot all present"; record "spark-chrome" PASS
else no "panel chrome incomplete"; record "spark-chrome" FAIL; fi

label "Check: accent census (peak column only, 0 teal leaks)"
CENSUS_S="$(render 'import { sparkline } from "./charts/sparkline.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = sparkline({ data: [45, 60, 75, 88, 95, 88, 75, 60, 48, 55, 70, 85, 96, 102, 90, 76, 62, 50, 58, 72, 86, 94, 87, 74, 61, 52, 66, 80] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!/[░▒▓█]/.test(s[2])) continue;
  if (/[A-Za-z0-9]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other);')" || true
read -r S_ACCENT S_GREY S_OTHER <<< "$CENSUS_S"
if [ "$S_OTHER" != "0" ] || [ "$S_ACCENT" = "0" ] || [ "$S_GREY" = "0" ]; then
  no "census failed (accent=$S_ACCENT grey=$S_GREY other=$S_OTHER)"; record "spark-census" FAIL
else ok "accent ×$S_ACCENT on peak · grey ×$S_GREY · 0 leaks"; record "spark-census" PASS; fi

label "Check: degenerate inputs (empty / flat / non-finite / narrow)"
DEGEN_S="$(render 'import { sparkline } from "./charts/sparkline.js";
const e = sparkline({ data: [], noColor: true }).toPlain();
const f = sparkline({ data: [7, 7, 7], noColor: true }).toPlain();
const m = sparkline({ data: [1, NaN, 2], noColor: true }).toPlain();
const n = sparkline({ data: [1, 2, 3], width: 1, noColor: true }).toPlain();
console.log(JSON.stringify({ e: e.includes("n 0 · (no data)"), f: !f.includes("NaN") && f.includes("█"), m: !m.includes("NaN"), n: n.startsWith("┌╌") }));')" || true
if [ "$DEGEN_S" = '{"e":true,"f":true,"m":true,"n":true}' ]; then ok "empty + flat + non-finite + narrow safe"; record "spark-degen" PASS
else no "degenerate gap ($DEGEN_S)"; record "spark-degen" FAIL; fi

# ── Summary scorecard ─────────────────────────────────────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests + typecheck" "see verify-session-28.sh"
printf "  %-40s %s\n" "README LOCKED block"   "see verify-session-28.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-28.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
