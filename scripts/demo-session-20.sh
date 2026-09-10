#!/usr/bin/env bash
# demo-session-20.sh — S20: the treemap chart, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19), and — this session —
# treemap (S20), the first hierarchical chart in the locked language.
#
# Every case runs the REAL treemap and prints observed output (no stderr/exit-code
# swallowing), and the accent-on-peak + no-rainbow claims are FALSIFIABLE checks that
# go red on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="20"
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

# Render a treemap snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s20_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s20_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — treemap LOCKED to the S18 heatmap reference language"
printf "${DIM}  (accent once on the peak node · grey tone ramp · dashed panel chrome · no rainbow)${RESET}\n"

# ── BEFORE → AFTER on one dataset ───────────────────────────────────────────────
label "BEFORE (pre-lock, reconstructed from git — NOT a live render)"
printf "${DIM}  Each node a different theme.colors[i%%n] rainbow hue · no frame · no footer:${RESET}\n"
cat <<'EOF'
  ██████████████ TS      ██████████ Python
  ██████ Rust    ███ Go  ██ Ruby
EOF

label "AFTER (live render of the identical data through the real treemap)"
AFTER="$(render 'import { treemap } from "./charts/treemap.js";
console.log(treemap({
  data: [
    { label: "TS", value: 45 },
    { label: "Python", value: 30 },
    { label: "Rust", value: 15 },
    { label: "Go", value: 7 },
    { label: "Ruby", value: 3 },
  ],
  title: "Codebase", width: 50, height: 10,
}).toString());')"
printf '%s\n' "$AFTER"

# ── Falsifiable check: accent spent on the peak node, zero rainbow leaks ────────
label "Check: accent on the peak node only, every other cell a grey tone (raw-RGB census)"
CENSUS="$(render 'import { treemap } from "./charts/treemap.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = treemap({ data:[
  { label: "TS", value: 45 }, { label: "Python", value: 30 },
  { label: "Rust", value: 15 }, { label: "Go", value: 7 }, { label: "Ruby", value: 3 },
], width: 50, height: 10 }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const CELL = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (!CELL.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (theme.tones.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other);')"
read -r ACCENT_N GREY_N OTHER_N <<< "$CENSUS"
if [ "$ACCENT_N" -gt 0 ] && [ "$OTHER_N" = "0" ] && [ "$GREY_N" -gt 0 ]; then
  ok "accent on peak ($ACCENT_N segs) · $GREY_N grey-ramp segs · 0 rainbow leaks"; record "accent-on-peak (raw-RGB)" PASS
else no "accent=$ACCENT_N grey=$GREY_N other=$OTHER_N"; record "accent-on-peak (raw-RGB)" FAIL; fi

# ── Falsifiable check: NO theme.colors rainbow in the source ────────────────────
label "Check: no live theme.colors[i % n] rainbow assignment in treemap.ts"
if sed -e '/\/\*/,/\*\//d' -e 's://.*$::' packages/core/src/charts/treemap.ts | grep -q "theme\.colors\["; then
  no "theme.colors[] rainbow still present"; record "no-rainbow source" FAIL
else ok "rainbow assignment gone (only a comment references it)"; record "no-rainbow source" PASS; fi

# ── Panel chrome present in real output ─────────────────────────────────────────
label "Check: locked panel chrome present (dashed frame · AREA eyebrow · +/│ guide · rules · footer)"
chrome_ok=1
printf '%s' "$AFTER" | grep -q "┌╌"      || chrome_ok=0  # dashed frame top
printf '%s' "$AFTER" | grep -q "AREA"     || chrome_ok=0  # uppercase eyebrow
printf '%s' "$AFTER" | grep -q "│ ╌"      || chrome_ok=0  # rule separator
printf '%s' "$AFTER" | grep -q "peak TS"  || chrome_ok=0  # summary names the peak
if [ "$chrome_ok" = "1" ]; then ok "dashed frame + AREA eyebrow + rules + peak footer"; record "panel language" PASS
else no "a chrome element was missing"; record "panel language" FAIL; fi

# ── Degenerate cases: must not crash / no NaN ───────────────────────────────────
header "Degenerate input renders safely"
deg_ok=1
label "empty data → framed n 0 panel"
E="$(render 'import { treemap } from "./charts/treemap.js";
console.log(treemap({ data: [] }).toPlain());')" || deg_ok=0
printf '%s\n' "$E"
printf '%s' "$E" | grep -q "n 0" || deg_ok=0
printf '%s' "$E" | grep -q "NaN" && deg_ok=0

label "all-equal values → honest render, accent still spent (first max)"
A="$(render 'import { treemap } from "./charts/treemap.js";
console.log(treemap({ data: [{label:"a",value:5},{label:"b",value:5}] }).toPlain());')" || deg_ok=0
printf '%s\n' "$A"
printf '%s' "$A" | grep -q "peak a" || deg_ok=0
printf '%s' "$A" | grep -q "NaN" && deg_ok=0

label "single node → safe"
S="$(render 'import { treemap } from "./charts/treemap.js";
console.log(treemap({ data: [{label:"solo",value:42}] }).toPlain());')" || deg_ok=0
printf '%s\n' "$S"
printf '%s' "$S" | grep -q "peak solo" || deg_ok=0
if [ "$deg_ok" = "1" ]; then ok "empty / all-equal / single all safe (no crash, no NaN)"; record "degenerate-safe" PASS
else no "a degenerate case failed"; record "degenerate-safe" FAIL; fi

# ── Hierarchy flattens honestly ─────────────────────────────────────────────────
header "Hierarchy flattens honestly (peak is the max leaf)"
N="$(render 'import { treemap } from "./charts/treemap.js";
console.log(treemap({ data: [
  { label: "Lang", value: 10, children: [ { label: "TS", value: 8 }, { label: "Go", value: 2 } ] },
  { label: "Docs", value: 5 },
] }).toPlain());')" || true
printf '%s\n' "$N"
if printf '%s' "$N" | grep -q "n 3 · 2..8 · peak TS"; then ok "children flatten; peak is the max leaf (TS)"; record "hierarchy-flatten" PASS
else no "flattened footer wrong"; record "hierarchy-flatten" FAIL; fi

# ── Summary scorecard (fed by the real checks above) ───────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (accent, chrome, degen)"     "see verify-session-20.sh"
printf "  %-40s %s\n" "README LOCKED treemap block"            "see verify-session-20.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-20.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
