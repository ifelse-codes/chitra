#!/usr/bin/env bash
# demo-session-25.sh — S25: the histogram chart, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
# timeline (S21), gauge (S22), progress (S23), and — this session — histogram (S25).
#
# Every case runs the REAL histogram chart and prints observed output (no stderr/
# exit-code swallowing), and the accent-on-mode + integer-label claims are
# FALSIFIABLE checks that go red on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="25"
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

# Render a histogram snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s25_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s25_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — histogram LOCKED to the reference/panel language"
printf "${DIM}  (accent once on the mode bin · grey ramp + ░▒▓ shade texture · integer count labels · dashed panel chrome · no theme.colors flood)${RESET}\n"

# ── BEFORE → AFTER on one sample ────────────────────────────────────────────────
label "BEFORE (pre-lock, captured in design-reference/mudra-audit.md — NOT a live render)"
printf "${DIM}  theme.colors[0] cyan flood · decimal count labels · no frame · no summary:${RESET}\n"
cat <<'EOF'
LATENCY MS
 47│                        █████
   │                  █████ █████ █████
36.56│                  █████ █████ █████
   │                  █████ █████ █████ █████
26.11│            █████ █████ █████ █████ █████
   │            █████ █████ █████ █████ █████ █████
15.67│            █████ █████ █████ █████ █████ █████ █████
 5.22│      █████ █████ █████ █████ █████ █████ █████ █████
  0│█████ █████ █████ █████ █████ █████ █████ █████ █████ █████
   └───────────────────────────────────────────────────────────
    20    35    51    66    81    96    112   127   142   158
EOF

label "AFTER (live render of the same distribution through the real histogram chart)"
AFTER="$(render 'import { histogram } from "./charts/histogram.js";
const data = Array.from({ length: 240 }, (_, i) => 20 + Math.abs(Math.sin(i / 13)) * 140);
console.log(histogram({ data, title: "Latency ms", xLabel: "Latency", noColor: true }).toString());')" || true
printf '%s\n' "$AFTER"
PLAIN="$(render 'import { histogram } from "./charts/histogram.js";
const data = Array.from({ length: 240 }, (_, i) => 20 + Math.abs(Math.sin(i / 13)) * 140);
console.log(histogram({ data, title: "Latency ms", xLabel: "Latency", noColor: true }).toPlain());')" || true

# ── Falsifiable check: accent only on solid █ mode segments, zero theme.colors leaks
label "Check: accent on the mode bin only (solid █), bins on the grey ramp (raw-ANSI census)"
CENSUS="$(render 'import { histogram } from "./charts/histogram.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = histogram({ data: [1,2,2,3,3,3,4,4,5,6,7,8,8,9], bins: 5 }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0, badAccent = "";
for (const s of segs) {
  if (!BAR.test(s[2])) continue;
  if (s[1] === theme.accent) { accent++; if (!/^█+$/.test(s[2])) badAccent = s[2]; }
  else if (theme.tones.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other + " " + JSON.stringify(badAccent));')" || true
read -r ACCENT_N GREY_N OTHER_N BAD_ACCENT <<< "$CENSUS"
if [ "$OTHER_N" = "0" ] && [ "$GREY_N" -gt 0 ] && [ "$ACCENT_N" -gt 0 ] && [ "$BAD_ACCENT" = "\"\"" ]; then
  ok "accent only on solid █ mode rows · $GREY_N grey-ramp segs · 0 theme.colors leaks"; record "accent-on-mode (raw-ANSI)" PASS
else no "accent=$ACCENT_N grey=$GREY_N other=$OTHER_N bad=$BAD_ACCENT"; record "accent-on-mode (raw-ANSI)" FAIL; fi

# ── Falsifiable check: NO theme.colors flood in the source ──────────────────────
label "Check: no live theme.colors[i] flood and the panel language is in histogram.ts"
src_ok=1
if sed -e '/\/\*/,/\*\//d' -e 's://.*$::' packages/core/src/charts/histogram.ts | grep -q "theme\.colors\["; then
  no "theme.colors[] flood still present"; src_ok=0
fi
for needle in frameTop theme.accent COUNT_SHADES; do
  sed -e '/\/\*/,/\*\//d' -e 's://.*$::' packages/core/src/charts/histogram.ts | grep -q "$needle" \
    || { no "missing $needle in histogram.ts"; src_ok=0; }
done
if [ "$src_ok" = "1" ]; then ok "flood assignment gone · panel + accent + shade ramp present (only comments reference the past)"; record "source-locked" PASS
else record "source-locked" FAIL; fi

# ── Panel chrome present in real output ─────────────────────────────────────────
label "Check: locked panel chrome present (dashed frame · eyebrow · baseline · rules · footer)"
chrome_ok=1
printf '%s' "$AFTER" | grep -q "┌╌"       || chrome_ok=0  # dashed frame top
printf '%s' "$PLAIN" | grep -q "LATENCY" || chrome_ok=0  # uppercased opts.xLabel eyebrow
printf '%s' "$AFTER" | grep -q "└╌"      || chrome_ok=0  # dashed baseline + frame bottom
printf '%s' "$AFTER" | grep -q "│ ╌"     || chrome_ok=0  # rule separator
printf '%s' "$PLAIN" | grep -q "n 240 · mode " || chrome_ok=0  # footer facts
if [ "$chrome_ok" = "1" ]; then ok "dashed frame + LATENCY eyebrow + dashed baseline + rules + n/mode footer"; record "panel language" PASS
else no "a chrome element was missing"; record "panel language" FAIL; fi

# ── Integer y labels: the decimal-count bug is dead ─────────────────────────────
label "Check: y-axis labels are INTEGER counts (36.56-style decimals retired)"
INTS="$(render 'import { histogram } from "./charts/histogram.js";
const data = Array.from({ length: 240 }, (_, i) => 20 + Math.abs(Math.sin(i / 13)) * 140);
const lines = histogram({ data, noColor: true }).toPlain().split("\n");
let labels = 0, decimals = 0;
for (const line of lines) {
  const m = line.match(/^│ (\s*\d*)([+│])/);
  if (!m) continue;
  labels++;
  if (m[1]!.includes(".")) decimals++;
}
console.log(labels + " " + decimals);')" || true
read -r LABELS_N DECIMALS_N <<< "$INTS"
if [ "$DECIMALS_N" = "0" ] && [ "$LABELS_N" -ge 3 ]; then
  ok "$LABELS_N integer y labels · 0 decimal labels"; record "integer-y-labels" PASS
else no "labels=$LABELS_N decimals=$DECIMALS_N"; record "integer-y-labels" FAIL; fi

# ── Shade texture: the density reads through noColor ────────────────────────────
label "Check: ░▒▓█ shade texture carries the density through noColor (light → dark)"
P="$(render 'import { histogram } from "./charts/histogram.js";
const data = [0, 2, 2.5, 3, 4, 4.2, 4.4, 4.6, 4.8, 5, 6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9];
const plain = histogram({ data, bins: 4, noColor: true }).toPlain();
for (const g of ["░", "▒", "▓", "█"]) console.log(g + " " + (plain.includes(g) ? "present" : "MISSING"));')" || true
printf '%s\n' "$P"
ramp_ok=1
printf '%s' "$P" | grep -q "░ present" || ramp_ok=0
printf '%s' "$P" | grep -q "▒ present" || ramp_ok=0
printf '%s' "$P" | grep -q "▓ present" || ramp_ok=0
printf '%s' "$P" | grep -q "█ present" || ramp_ok=0
if [ "$ramp_ok" = "1" ]; then ok "░ → ▒ → ▓ → █ progression survives stripAnsi"; record "shade-texture" PASS
else no "the ramp did not read through noColor"; record "shade-texture" FAIL; fi

# ── Degenerate cases: must not crash / no NaN / honest footers ──────────────────
header "Degenerate input renders safely"
deg_ok=1
label "empty data → framed `n 0 · (no data)` panel, null JSON facts"
E="$(render 'import { histogram } from "./charts/histogram.js";
const h = histogram({ data: [] });
console.log(h.toPlain());
console.log(JSON.stringify({ mode: h.toJSON().mode, p50: h.toJSON().p50, p99: h.toJSON().p99 }));')" || deg_ok=0
printf '%s\n' "$E"
printf '%s' "$E" | grep -q "n 0 · (no data)" || deg_ok=0
printf '%s' "$E" | grep -q '"mode":null' || deg_ok=0

label "collapsed range (all values equal) → lands in bin 0, no NaN"
C="$(render 'import { histogram } from "./charts/histogram.js";
const h = histogram({ data: [7,7,7,7] });
console.log(h.toPlain().includes("NaN") ? "NaN LEAK" : "no NaN");
console.log("bin0=" + h.toJSON().binCounts[0]);')" || deg_ok=0
printf '%s\n' "$C"
printf '%s' "$C" | grep -q "no NaN" || deg_ok=0
printf '%s' "$C" | grep -q "bin0=4" || deg_ok=0

label "non-finite samples (NaN/Infinity) → excluded, never binned"
M="$(render 'import { histogram } from "./charts/histogram.js";
const h = histogram({ data: [1, 2, 3, NaN, Infinity] });
console.log(h.toPlain().includes("NaN") ? "NaN LEAK" : "no NaN");
console.log("count=" + h.toJSON().count);')" || deg_ok=0
printf '%s\n' "$M"
printf '%s' "$M" | grep -q "no NaN" || deg_ok=0
printf '%s' "$M" | grep -q "count=3" || deg_ok=0
if [ "$deg_ok" = "1" ]; then ok "empty / collapsed / non-finite all safe (no crash, no NaN, honest footers)"; record "degenerate-safe" PASS
else no "a degenerate case failed"; record "degenerate-safe" FAIL; fi

# ── Agent surface ───────────────────────────────────────────────────────────────
label "Agent surface: toJSON() carries the additive facts (mode · p50 · p99 · count)"
J="$(render 'import { histogram } from "./charts/histogram.js";
const json = histogram({ data: [1,2,2,3,3,3,4,4,5,6,7,8,8,9] }).toJSON();
console.log(JSON.stringify({ type: json.type, mode: json.mode, p50: json.p50, p99: json.p99, count: json.count }));')" || true
printf '%s\n' "$J"
printf '%s' "$J" | grep -q '"type":"histogram"' && printf '%s' "$J" | grep -q '"p50":4' && printf '%s' "$J" | grep -q '"p99":9' && printf '%s' "$J" | grep -q '"count":14' \
  && { ok "additive agent facts present (type/mode/p50/p99/count)"; record "tojson-agent-surface" PASS; } \
  || { no "agent surface incomplete"; record "tojson-agent-surface" FAIL; }

# ── Summary scorecard (fed by the real checks above) ───────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (accent, chrome, degen)"     "see verify-session-25.sh"
printf "  %-40s %s\n" "README LOCKED histogram block"          "see verify-session-25.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-25.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
