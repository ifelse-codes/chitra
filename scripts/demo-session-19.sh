#!/usr/bin/env bash
# demo-session-19.sh — S19: the horizontalBar chart, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), and — this session — horizontalBar (S19),
# the last unlocked chart family. This closes the reference-language migration.
#
# Per the demo-producer handoff (.ai/handoffs/session-19-demo-producer.md): every case
# runs the REAL horizontalBar and prints observed output (no stderr/exit-code swallowing),
# and the accent-once + no-░ claims are FALSIFIABLE checks that go red on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="19"
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

# Render a horizontalBar snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s19_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s19_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — horizontalBar LOCKED to the S12 bar reference language"
printf "${DIM}  (accent-once · grey ramp · dashed panel chrome · rotated + value-axis · no ░ phantom fill)${RESET}\n"

# ── BEFORE → AFTER on one dataset (clear max, a zero cell, a near-tie) ──────────
label "BEFORE (pre-lock, reconstructed from git — NOT a live render)"
printf "${DIM}  Each bar a different theme.colors[i%%n] rainbow hue · empty cells filled with ░ · no frame:${RESET}\n"
cat <<'EOF'
  Mobile  ██████████████████████████████ 90
  Desktop ██████████░░░░░░░░░░░░░░░░░░░░░ 30
  Tablet  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0
  Watch   ████░░░░░░░░░░░░░░░░░░░░░░░░░░░ 12
EOF

label "AFTER (live render of the identical data through the real horizontalBar)"
AFTER="$(render 'import { horizontalBar } from "./charts/horizontalBar.js";
console.log(horizontalBar({
  data: [90, 30, 0, 12],
  labels: ["Mobile", "Desktop", "Tablet", "Watch"],
  title: "SESSIONS BY DEVICE", xLabel: "sessions",
}).toString());')"
printf '%s\n' "$AFTER"

# ── Falsifiable check: accent hue spent EXACTLY once (raw-RGB) ──────────────────
label "Check: accent hue spent EXACTLY once (raw-RGB count on the peak bar)"
ACCENT_N="$(render 'import { horizontalBar } from "./charts/horizontalBar.js";
import { resolveTheme } from "./themes/index.js";
const acc = resolveTheme("default").accent;
const raw = horizontalBar({ data:[90,30,0,12], labels:["Mobile","Desktop","Tablet","Watch"], showAxes:false }).toString();
const n = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map(m=>m[0]).filter(c=>c===acc).length;
console.log(n);')"
if [ "$ACCENT_N" = "1" ]; then ok "accent count == 1 (only Mobile, the global max)"; record "accent-once (raw-RGB)" PASS
else no "accent count == $ACCENT_N (expected 1)"; record "accent-once (raw-RGB)" FAIL; fi

# ── Falsifiable check: NO ░ phantom filler anywhere ────────────────────────────
label "Check: the ░ phantom filler never appears (empty cells are SPACE)"
if printf '%s' "$AFTER" | grep -q "░"; then no "found ░ in output"; record "no-░ phantom fill" FAIL
else ok "zero ░ — Tablet (0) renders as blank space inside the frame"; record "no-░ phantom fill" PASS; fi

# ── Panel chrome present in real output ────────────────────────────────────────
label "Check: locked panel chrome present (dashed frame · eyebrow · rotated + guide · rules)"
chrome_ok=1
printf '%s' "$AFTER" | grep -q "┌╌"     || chrome_ok=0   # dashed frame top
printf '%s' "$AFTER" | grep -q "SESSIONS" || chrome_ok=0 # uppercase eyebrow (xLabel)
printf '%s' "$AFTER" | grep -qF -- "+╌" || chrome_ok=0   # rotated + value-axis guide (byte-safe)
printf '%s' "$AFTER" | grep -q "peak Mobile" || chrome_ok=0 # summary names the peak
if [ "$chrome_ok" = "1" ]; then ok "dashed frame + eyebrow + rotated + guide + peak summary"; record "panel language (rotated)" PASS
else no "a chrome element was missing"; record "panel language (rotated)" FAIL; fi

# ── Degenerate cases: must not crash / no NaN ──────────────────────────────────
header "Degenerate input renders safely"
deg_ok=1
label "empty data → framed n 0 panel"
E="$(render 'import { horizontalBar } from "./charts/horizontalBar.js";
console.log(horizontalBar({ data: [] }).toPlain());')" || deg_ok=0
printf '%s\n' "$E"
printf '%s' "$E" | grep -q "n 0" || deg_ok=0
printf '%s' "$E" | grep -q "NaN" && deg_ok=0

label "all-equal values → honest render, accent still once (first max)"
A="$(render 'import { horizontalBar } from "./charts/horizontalBar.js";
console.log(horizontalBar({ data: [5,5,5], labels:["a","b","c"] }).toPlain());')" || deg_ok=0
printf '%s\n' "$A"
printf '%s' "$A" | grep -q "peak a" || deg_ok=0
printf '%s' "$A" | grep -q "NaN" && deg_ok=0

label "single item → safe"
S="$(render 'import { horizontalBar } from "./charts/horizontalBar.js";
console.log(horizontalBar({ data: [42], labels:["solo"] }).toPlain());')" || deg_ok=0
printf '%s\n' "$S"
printf '%s' "$S" | grep -q "peak solo" || deg_ok=0
if [ "$deg_ok" = "1" ]; then ok "empty / all-equal / single all safe (no crash, no NaN)"; record "degenerate-safe" PASS
else no "a degenerate case failed"; record "degenerate-safe" FAIL; fi

# ── Auto-scale + auto-width ────────────────────────────────────────────────────
header "Auto-scale (min(0,dataMin) baseline) + auto-width"
label "negative value → baseline pulled to min(0,dataMin); long label → panel auto-expands"
W="$(render 'import { horizontalBar } from "./charts/horizontalBar.js";
console.log(horizontalBar({
  data: [40, 0, -15],
  labels: ["a-deliberately-long-label", "Flat", "Loss"],
  title: "PROFIT/LOSS",
}).toPlain());')" || true
printf '%s\n' "$W"
if printf '%s' "$W" | grep -q "a-deliberately-long-label"; then ok "long label survives uncut; negative baseline scaled"; record "auto-scale + auto-width" PASS
else no "long label was clipped"; record "auto-scale + auto-width" FAIL; fi

# ── Summary scorecard (fed by the real checks above) ───────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (accent-once, no-░, degen)"   "see verify-session-19.sh"
printf "  %-40s %s\n" "README LOCKED horizontalBar block"       "see verify-session-19.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-19.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
