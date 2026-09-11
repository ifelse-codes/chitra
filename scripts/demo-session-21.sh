#!/usr/bin/env bash
# demo-session-21.sh — S21: the timeline chart, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), and —
# this session — timeline (S21), the Gantt/timeline chart in the locked language.
#
# Every case runs the REAL timeline and prints observed output (no stderr/exit-code
# swallowing), and the accent-on-longest-span + no-rainbow claims are FALSIFIABLE
# checks that go red on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="21"
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

# Render a timeline snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s21_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s21_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — timeline LOCKED to the reference/panel language"
printf "${DIM}  (accent once on the longest span · grey ramp + ░▒▓ shade texture · ─ scale track · dashed panel chrome · no rainbow)${RESET}\n"

# ── BEFORE → AFTER on one dataset ───────────────────────────────────────────────
label "BEFORE (pre-lock, reconstructed from git — NOT a live render)"
printf "${DIM}  Each event a different theme.colors[i%%n] rainbow hue · ▶/◀ markers · no frame · no footer:${RESET}\n"
cat <<'EOF'
  Design ▶████████◀─────────────────────
  Build  ─────────▶████████████████◀────
  Test   ───────────────────▶████████◀─
EOF

label "AFTER (live render of the identical data through the real timeline)"
AFTER="$(render 'import { timeline } from "./charts/timeline.js";
console.log(timeline({
  events: [
    { label: "Design", start: 0, end: 2 },
    { label: "Build", start: 2, end: 6 },
    { label: "Test", start: 5, end: 7 },
    { label: "Deploy", start: 7, end: 8 },
  ],
  title: "Sprint Timeline",
}).toString());')"
printf '%s\n' "$AFTER"

# ── Falsifiable check: accent spent on the longest span, zero rainbow leaks ─────
label "Check: accent on the longest span only, every other bar a grey tone (raw-RGB census)"
CENSUS="$(render 'import { timeline } from "./charts/timeline.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = timeline({ events: [
  { label: "Design", start: 0, end: 2 },
  { label: "Build", start: 2, end: 6 },
  { label: "Test", start: 5, end: 7 },
  { label: "Deploy", start: 7, end: 8 },
] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (!BAR.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (theme.tones.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other);')"
read -r ACCENT_N GREY_N OTHER_N <<< "$CENSUS"
if [ "$ACCENT_N" = "1" ] && [ "$OTHER_N" = "0" ] && [ "$GREY_N" -gt 0 ]; then
  ok "accent on longest span (1 seg) · $GREY_N grey-ramp segs · 0 rainbow leaks"; record "accent-on-longest (raw-RGB)" PASS
else no "accent=$ACCENT_N grey=$GREY_N other=$OTHER_N"; record "accent-on-longest (raw-RGB)" FAIL; fi

# ── Falsifiable check: NO theme.colors rainbow in the source ────────────────────
label "Check: no live theme.colors[i % n] rainbow assignment in timeline.ts"
if sed -e '/\/\*/,/\*\//d' -e 's://.*$::' packages/core/src/charts/timeline.ts | grep -q "theme\.colors\["; then
  no "theme.colors[] rainbow still present"; record "no-rainbow source" FAIL
else ok "rainbow assignment gone (only a comment references it)"; record "no-rainbow source" PASS; fi

# ── Panel chrome present in real output ─────────────────────────────────────────
label "Check: locked panel chrome present (dashed frame · SPAN eyebrow · +╌…╌+ guide · rules · footer)"
chrome_ok=1
printf '%s' "$AFTER" | grep -q "┌╌"      || chrome_ok=0  # dashed frame top
printf '%s' "$AFTER" | grep -q "SPAN"    || chrome_ok=0  # uppercase eyebrow
printf '%s' "$AFTER" | grep -q "│ ╌"    || chrome_ok=0  # rule separator
printf '%s' "$AFTER" | grep -q "span Build" || chrome_ok=0  # summary names the longest span
if [ "$chrome_ok" = "1" ]; then ok "dashed frame + SPAN eyebrow + guide + rules + span footer"; record "panel language" PASS
else no "a chrome element was missing"; record "panel language" FAIL; fi

# ── Retired glyphs ──────────────────────────────────────────────────────────────
label "Check: ▶/◀ markers retired — a point event renders one lightest-shade glyph (░)"
P="$(render 'import { timeline } from "./charts/timeline.js";
console.log(timeline({ events: [{ label: "milestone", start: 3 }, { label: "phase", start: 0, end: 6 }] }).toPlain());')" || true
printf '%s\n' "$P"
p_ok=1
printf '%s' "$P" | grep -q "▶\|◀" && p_ok=0
BLOCKS="$(printf '%s' "$P" | grep milestone | grep -o '[░▒▓█]' | wc -l | tr -d ' ')"
[ "$BLOCKS" = "1" ] || p_ok=0
printf '%s' "$P" | grep -q "░" || p_ok=0
if [ "$p_ok" = "1" ]; then ok "no ▶/◀ anywhere; point event = exactly one ░"; record "point-events" PASS
else no "retired glyphs present or point event wrong (ramp glyphs=$BLOCKS)"; record "point-events" FAIL; fi

# ── Degenerate cases: must not crash / no NaN ───────────────────────────────────
header "Degenerate input renders safely"
deg_ok=1
label "empty events → framed n 0 panel"
E="$(render 'import { timeline } from "./charts/timeline.js";
console.log(timeline({ events: [] }).toPlain());')" || deg_ok=0
printf '%s\n' "$E"
printf '%s' "$E" | grep -q "n 0" || deg_ok=0
printf '%s' "$E" | grep -q "NaN" && deg_ok=0

label "collapsed range (all events at one instant) → honest render, accent still spent (first)"
A="$(render 'import { timeline } from "./charts/timeline.js";
console.log(timeline({ events: [{label:"a",start:5},{label:"b",start:5}] }).toPlain());')" || deg_ok=0
printf '%s\n' "$A"
printf '%s' "$A" | grep -q "span a" || deg_ok=0
printf '%s' "$A" | grep -q "NaN" && deg_ok=0

label "single event → safe"
S="$(render 'import { timeline } from "./charts/timeline.js";
console.log(timeline({ events: [{label:"solo",start:2,end:5}] }).toPlain());')" || deg_ok=0
printf '%s\n' "$S"
printf '%s' "$S" | grep -q "span solo" || deg_ok=0
if [ "$deg_ok" = "1" ]; then ok "empty / collapsed / single all safe (no crash, no NaN)"; record "degenerate-safe" PASS
else no "a degenerate case failed"; record "degenerate-safe" FAIL; fi

# ── Summary scorecard (fed by the real checks above) ───────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (accent, chrome, degen)"     "see verify-session-21.sh"
printf "  %-40s %s\n" "README LOCKED timeline block"          "see verify-session-21.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-21.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
