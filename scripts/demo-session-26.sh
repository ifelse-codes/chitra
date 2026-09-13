#!/usr/bin/env bash
# demo-session-26.sh — S26: waterfall + funnel + sankey + radar, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
# timeline (S21), gauge (S22), progress (S23), histogram (S25), waterfall (S26),
# funnel (S26, centered), sankey (S26), and radar (S26).
#
# Every case runs the REAL chart and prints observed output (no stderr/
# exit-code swallowing), and the lock claims are FALSIFIABLE checks that go red
# on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="26"
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

# Render a waterfall snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s26_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s26_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — waterfall LOCKED to the reference/panel language"
printf "${DIM}  (P0 flat-dash retired: downs are outline boxes · tonal kinds, accent once on Total · integer labels · dashed panel + NET eyebrow + ┄ connectors)${RESET}\n"

# ── BEFORE → AFTER on one sample ──────────────────────────────────────────────
label "BEFORE (pre-lock, captured in design-reference/mudra-audit.md — NOT a live render)"
printf "${DIM}  theme.colors rainbow · decimal labels · COGS/OpEx invisible flat dashes on the baseline:${RESET}\n"
cat <<'EOF'
 550│                            ██████ ██████
    │██████ ██████               ██████ ██████
392.86│██████ ██████ ██████               ██████
    │██████                             ██████
235.71│██████                             ██████
    │██████                             ██████
78.57│██████                             ██████
   0│██████ ────── ────── ────── ────── ██████
    └──────────────────────────────────────────
     Start  COGS   Rev    OpEx   Sales  Total
EOF

label "AFTER (live render of cloud spend through the real waterfall chart)"
AFTER="$(render 'import { waterfall } from "./charts/waterfall.js";
console.log(waterfall({ data: [500, -120, 80, -60, 150], labels: ["Start", "COGS", "Rev", "OpEx", "Sales"], noColor: true }).toString());')" || true
printf '%s\n' "$AFTER"

# ── Falsifiable check: P0 outline boxes ───────────────────────────────────────
label "Check: down-deltas are dashed outline boxes (the flat-dash P0 is dead)"
if printf '%s' "$AFTER" | grep -q "┌╌" && printf '%s' "$AFTER" | grep -q "└╌"; then
  ok "COGS −120 and OpEx −60 render as ┌╌╌┐ outline boxes"; record "p0-outline-boxes" PASS
else no "no outline boxes in the render"; record "p0-outline-boxes" FAIL; fi

# ── Falsifiable check: tonal census ───────────────────────────────────────────
label "Check: accent once on Total (solid █), kinds on the grey ramp (raw-ANSI census)"
CENSUS="$(render 'import { waterfall } from "./charts/waterfall.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = waterfall({ data: [500, -120, 80, -60, 150] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[█▓┌╌┐│└┘]/;
let accent = 0, grey = 0, other = 0, badAccent = "";
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!BAR.test(s[2])) continue;
  if (s[1] === theme.accent) { accent++; if (!/^█+$/.test(s[2])) badAccent = s[2]; }
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other + " " + JSON.stringify(badAccent));')" || true
read -r ACCENT_N GREY_N OTHER_N BAD_ACCENT <<< "$CENSUS"
if [ "$OTHER_N" = "0" ] && [ "$GREY_N" -gt 0 ] && [ "$ACCENT_N" -gt 0 ] && [ "$BAD_ACCENT" = "\"\"" ]; then
  ok "accent only on solid █ Total rows · $GREY_N grey-ramp segs · 0 theme.colors leaks"; record "tonal-kinds (raw-ANSI)" PASS
else no "accent=$ACCENT_N grey=$GREY_N other=$OTHER_N bad=$BAD_ACCENT"; record "tonal-kinds (raw-ANSI)" FAIL; fi

# ── Panel chrome ──────────────────────────────────────────────────────────────
label "Check: locked panel chrome present (dashed frame · NET eyebrow · connectors · foot)"
chrome_ok=1
printf '%s' "$AFTER" | grep -q "┌╌"          || chrome_ok=0
printf '%s' "$AFTER" | grep -q "NET +550"   || chrome_ok=0
printf '%s' "$AFTER" | grep -q "┄"           || chrome_ok=0
printf '%s' "$AFTER" | grep -q "−120"        || chrome_ok=0
printf '%s' "$AFTER" | grep -q "START 500 · Δ" || chrome_ok=0
printf '%s' "$AFTER" | grep -q "TOTAL 550"   || chrome_ok=0
if [ "$chrome_ok" = "1" ]; then ok "frame + NET eyebrow + ┄ connectors + signed deltas + START/Δ/TOTAL foot"; record "panel language" PASS
else no "a chrome element was missing"; record "panel language" FAIL; fi

# ── Integer y labels ──────────────────────────────────────────────────────────
label "Check: y-axis labels are integers (392.86-style decimals retired)"
INTS="$(render 'import { waterfall } from "./charts/waterfall.js";
const lines = waterfall({ data: [500, -120, 80, -60, 150], noColor: true }).toPlain().split("\n");
let labels = 0, decimals = 0;
for (const line of lines) {
  const m = line.match(/^│ (\s*\S*)([+│])/);
  if (!m) continue;
  labels++;
  if (m[1]!.includes(".")) decimals++;
}
console.log(labels + " " + decimals);')" || true
read -r LABELS_N DECIMALS_N <<< "$INTS"
if [ "$DECIMALS_N" = "0" ] && [ "$LABELS_N" -ge 3 ]; then
  ok "$LABELS_N integer y labels · 0 decimal labels"; record "integer-y-labels" PASS
else no "labels=$LABELS_N decimals=$DECIMALS_N"; record "integer-y-labels" FAIL; fi

# ── Degenerate cases ──────────────────────────────────────────────────────────
header "Degenerate input renders safely"
deg_ok=1
label "empty data → framed TOTAL 0 · (no data) panel, empty steps"
E="$(render 'import { waterfall } from "./charts/waterfall.js";
const w = waterfall({ data: [] });
console.log(w.toPlain());
console.log(JSON.stringify({ total: w.toJSON().total, steps: w.toJSON().steps }));')" || deg_ok=0
printf '%s\n' "$E"
printf '%s' "$E" | grep -q "TOTAL 0 · (no data)" || deg_ok=0
printf '%s' "$E" | grep -q '"steps":\[\]' || deg_ok=0

label "all-zero deltas → empty columns, honest TOTAL 0, no NaN"
Z="$(render 'import { waterfall } from "./charts/waterfall.js";
const w = waterfall({ data: [0, 0, 0] });
console.log(w.toPlain().includes("NaN") ? "NaN LEAK" : "no NaN");
console.log("total=" + w.toJSON().total);')" || deg_ok=0
printf '%s\n' "$Z"
printf '%s' "$Z" | grep -q "no NaN" || deg_ok=0
printf '%s' "$Z" | grep -q "total=0" || deg_ok=0
if [ "$deg_ok" = "1" ]; then ok "empty / all-zero safe (no crash, no NaN, honest footers)"; record "degenerate-safe" PASS
else no "a degenerate case failed"; record "degenerate-safe" FAIL; fi

# ── Agent surface ─────────────────────────────────────────────────────────────
label "Agent surface: toJSON() carries steps with running levels + kinds"
J="$(render 'import { waterfall } from "./charts/waterfall.js";
const json = waterfall({ data: [500, -120, 80, -60, 150], labels: ["Start", "COGS", "Rev", "OpEx", "Sales"] }).toJSON();
console.log(JSON.stringify({ type: json.type, total: json.total, kinds: json.steps.map(s => s.kind).join(","), cogs: json.steps[1].start + "->" + json.steps[1].end }));')" || true
printf '%s\n' "$J"
printf '%s' "$J" | grep -q '"type":"waterfall"' && printf '%s' "$J" | grep -q '"total":550' && printf '%s' "$J" | grep -q 'start,down,up,down,up' && printf '%s' "$J" | grep -q '500->380' \
  && { ok "typed steps with running levels (COGS 500→380)"; record "tojson-agent-surface" PASS; } \
  || { no "agent surface incomplete"; record "tojson-agent-surface" FAIL; }

# ── Funnel: live render + falsifiable checks ──────────────────────────────────
header "Funnel LOCKED — live render"
FUNNEL="$(render 'import { funnel } from "./charts/funnel.js";
console.log(funnel({ data: [10000, 6800, 3400, 1200, 340], labels: ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"], noColor: true }).toString());')" || true
printf '%s\n' "$FUNNEL"
label "Check: no ▼ arrows · accent once on peak · integer pcts · CONVERSION foot"
funnel_ok=1
printf '%s' "$FUNNEL" | grep -q "▼" && funnel_ok=0
printf '%s' "$FUNNEL" | grep -q "CONVERSION 3%" || funnel_ok=0
printf '%s' "$FUNNEL" | grep -q "(68%)" || funnel_ok=0
printf '%s' "$FUNNEL" | grep -q "DROP Enterprise" || funnel_ok=0
FCENSUS="$(render 'import { funnel } from "./charts/funnel.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = funnel({ data: [10000, 6800, 3400, 1200, 340] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!/[░▒▓█]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (!GREY_TONES.includes(s[1])) other++;
}
console.log(accent + " " + other);')" || true
read -r F_ACCENT F_OTHER <<< "$FCENSUS"
if [ "$F_OTHER" != "0" ] || [ "$F_ACCENT" = "0" ]; then funnel_ok=0; fi
if [ "$funnel_ok" = "1" ]; then ok "no ▼ · peak accent ×$F_ACCENT · 0 leaks · integer pcts · DROP foot"; record "funnel-locked" PASS
else no "funnel check failed (accent=$F_ACCENT other=$F_OTHER)"; record "funnel-locked" FAIL; fi

# ── Sankey: live render + falsifiable checks ──────────────────────────────────
header "Sankey LOCKED — live render"
SANKEY="$(render 'import { sankey } from "./charts/sankey.js";
console.log(sankey({ nodes: ["Visitors", "Free", "Paid", "Churned"], links: [
  { source: "Visitors", target: "Free", value: 60 },
  { source: "Free", target: "Paid", value: 25 },
  { source: "Free", target: "Churned", value: 20 },
  { source: "Visitors", target: "Paid", value: 5 },
], noColor: true }).toString());')" || true
printf '%s\n' "$SANKEY"
label "Check: no ▶ arrows · accent once on peak flow · FLOW eyebrow · PEAK foot"
sankey_ok=1
printf '%s' "$SANKEY" | grep -q "▶" && sankey_ok=0
printf '%s' "$SANKEY" | grep -q "FLOW 110" || sankey_ok=0
printf '%s' "$SANKEY" | grep -q "PEAK Visitors → Free 60" || sankey_ok=0
printf '%s' "$SANKEY" | grep -q "in:60" || sankey_ok=0
SCENSUS="$(render 'import { sankey } from "./charts/sankey.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = sankey({ nodes: ["A", "B"], links: [{ source: "A", target: "B", value: 10 }] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!/[░▒▓█■]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (!GREY_TONES.includes(s[1])) other++;
}
console.log(accent + " " + other);')" || true
read -r S_ACCENT S_OTHER <<< "$SCENSUS"
if [ "$S_OTHER" != "0" ] || [ "$S_ACCENT" = "0" ]; then sankey_ok=0; fi
if [ "$sankey_ok" = "1" ]; then ok "no ▶ · peak accent ×$S_ACCENT · 0 leaks · FLOW + PEAK foot"; record "sankey-locked" PASS
else no "sankey check failed (accent=$S_ACCENT other=$S_OTHER)"; record "sankey-locked" FAIL; fi

# ── Radar: live render + falsifiable checks ────────────────────────────────────
header "Radar LOCKED — live render"
RADAR="$(render 'import { radar } from "./charts/radar.js";
console.log(radar({ data: [[80, 60, 90, 70, 85], [50, 75, 55, 80, 60]], labels: ["Speed", "Power", "Range", "Accuracy", "Stamina"], seriesLabels: ["Alpha", "Beta"], noColor: true }).toString());')" || true
printf '%s\n' "$RADAR"
label "Check: primary accent · toned secondary + own glyph · labels unclipped · PEAK foot"
radar_ok=1
printf '%s' "$RADAR" | grep -q "AXES 5 · SERIES 2" || radar_ok=0
printf '%s' "$RADAR" | grep -q "Stamina" || radar_ok=0
printf '%s' "$RADAR" | grep -q "PEAK Range 90" || radar_ok=0
printf '%s' "$RADAR" | grep -q "○ ╌╌ Beta" || radar_ok=0
RCENSUS="$(render 'import { radar } from "./charts/radar.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = radar({ data: [[80, 60, 90, 70, 85], [50, 75, 55, 80, 60]], labels: ["Speed", "Power", "Range", "Accuracy", "Stamina"] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis || s[1] === theme.grid) continue;
  if (!/[⠀-⣿●○]/.test(s[2])) continue;
  if (/[A-Za-z0-9]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other);')" || true
read -r R_ACCENT R_GREY R_OTHER <<< "$RCENSUS"
if [ "$R_OTHER" != "0" ] || [ "$R_ACCENT" = "0" ] || [ "$R_GREY" = "0" ]; then radar_ok=0; fi
if [ "$radar_ok" = "1" ]; then ok "primary accent ×$R_ACCENT · toned ×$R_GREY · 0 leaks · labels + PEAK foot"; record "radar-locked" PASS
else no "radar check failed (accent=$R_ACCENT grey=$R_GREY other=$R_OTHER)"; record "radar-locked" FAIL; fi

# ── Summary scorecard ─────────────────────────────────────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (tonal, p0, degen)"     "see verify-session-26.sh"
printf "  %-40s %s\n" "README LOCKED ×4 blocks"           "see verify-session-26.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-26.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
