#!/usr/bin/env bash
# demo-session-23.sh — S23: the progress chart, locked to the reference/panel language.
# Cumulative: the locked family now spans circular (S09), area (S09), line (S10),
# bar (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
# timeline (S21), gauge (S22), and — this session — progress (S23), completing the
# founder-named trio (timeline → gauge → progress) with the shade-texture ruling.
#
# Every case runs the REAL progress chart and prints observed output (no stderr/
# exit-code swallowing), and the accent-once + honest-footer claims are FALSIFIABLE
# checks that go red on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="23"
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

# Render a progress snippet through the REAL source. Errors are NOT swallowed:
# stderr is shown and a non-zero exit from the render aborts the case.
render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s23_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s23_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — progress LOCKED to the reference/panel language"
printf "${DIM}  (accent once on the solid █ fill edge · grey ramp + ░▒▓ shade texture · ─ scale track · dashed panel chrome · no rainbow · no naked [bar])${RESET}\n"

# ── BEFORE → AFTER on one reading ────────────────────────────────────────────────
label "BEFORE (pre-lock, reconstructed from git — NOT a live render)"
printf "${DIM}  Traffic-light hue by band · naked [bar] pct · sub-block texture · no frame · silent clamp:${RESET}\n"
cat <<'EOF'
  Build     [██████████████████████████▁░░░░] 87.0%
EOF

label "AFTER (live render of the identical reading through the real progress chart)"
AFTER="$(render 'import { progress } from "./charts/progress.js";
console.log(progress({
  value: 87,
  label: "Build",
  max: 100,
  width: 40,
}).toString());')"
printf '%s\n' "$AFTER"
# Text-level checks need the plain render — ANSI colour codes split the accented
# `value 87` fact from the `· 0..100 · 87.0%` tail in the raw output.
PLAIN="$(render 'import { progress } from "./charts/progress.js";
console.log(progress({
  value: 87,
  label: "Build",
  max: 100,
  width: 40,
}).toPlain());')"

# ── Falsifiable check: accent spent once on the solid █ edge, zero rainbow leaks ─
label "Check: accent on the solid █ fill edge only, fill on the grey ramp (raw-ANSI census)"
CENSUS="$(render 'import { progress } from "./charts/progress.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = progress({ value: 73, max: 100 }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0, accentBody = "";
for (const s of segs) {
  if (!BAR.test(s[2])) continue;
  if (s[1] === theme.accent) { accent++; accentBody = s[2]; }
  else if (theme.tones.includes(s[1])) grey++;
  else other++;
}
console.log(accent + " " + grey + " " + other + " " + accentBody);')"
read -r ACCENT_N GREY_N OTHER_N ACCENT_BODY <<< "$CENSUS"
if [ "$ACCENT_N" = "1" ] && [ "$OTHER_N" = "0" ] && [ "$GREY_N" -gt 0 ] && [ "$ACCENT_BODY" = "█" ]; then
  ok "accent once on the █ edge · $GREY_N grey-ramp segs · 0 rainbow leaks"; record "accent-on-edge (raw-ANSI)" PASS
else no "accent=$ACCENT_N grey=$GREY_N other=$OTHER_N edge=$ACCENT_BODY"; record "accent-on-edge (raw-ANSI)" FAIL; fi

# ── Falsifiable check: NO theme.colors rainbow + off-vocabulary renderers gone ──
label "Check: no live theme.colors[i] band rainbow and no block/ascii bar renderers in progress.ts"
src_bad=0
if sed -e '/\/\*/,/\*\//d' -e 's://.*$::' packages/core/src/charts/progress.ts | grep -q "theme\.colors\["; then
  no "theme.colors[] rainbow still present"; src_bad=1
fi
if sed -e '/\/\*/,/\*\//d' -e 's://.*$::' packages/core/src/charts/progress.ts | grep -q "buildHorizontalBlockBar\|buildAsciiHBar"; then
  no "off-vocabulary block/ascii renderers still used"; src_bad=1
fi
if [ "$src_bad" = "0" ]; then ok "rainbow assignment gone · block/ascii renderers gone (only comments reference them)"; record "source-locked" PASS
else record "source-locked" FAIL; fi

# ── Panel chrome present in real output ─────────────────────────────────────────
label "Check: locked panel chrome present (dashed frame · eyebrow · guide · rules · footer)"
chrome_ok=1
printf '%s' "$AFTER" | grep -q "┌╌"       || chrome_ok=0  # dashed frame top
printf '%s' "$PLAIN" | grep -q "BUILD"   || chrome_ok=0  # uppercased opts.label eyebrow
printf '%s' "$AFTER" | grep -q "+╌"      || chrome_ok=0  # value-axis guide
printf '%s' "$AFTER" | grep -q "│ ╌"     || chrome_ok=0  # rule separator
printf '%s' "$PLAIN" | grep -q "value 87 · 0..100 · 87.0%" || chrome_ok=0  # footer
if [ "$chrome_ok" = "1" ]; then ok "dashed frame + BUILD eyebrow + guide + rules + value footer"; record "panel language" PASS
else no "a chrome element was missing"; record "panel language" FAIL; fi

# ── Shade texture: the level reads through noColor ──────────────────────────────
label "Check: ░▒▓█ shade texture carries the level through noColor (light → dark)"
P="$(render 'import { progress } from "./charts/progress.js";
for (const v of [20, 45, 70, 95]) {
  const row = progress({ value: v, max: 100, noColor: true }).toPlain()
    .split("\n").find((l) => /[░▒▓█]/.test(l))!;
  console.log(String(v).padStart(3) + " → " + row.trim());
}')"
printf '%s\n' "$P"
ramp_ok=1
printf '%s' "$P" | grep -q "20 → .*░" || ramp_ok=0
printf '%s' "$P" | grep -q "45 → .*▒" || ramp_ok=0
printf '%s' "$P" | grep -q "70 → .*▓" || ramp_ok=0
printf '%s' "$P" | grep -q "95 → .*█" || ramp_ok=0
if [ "$ramp_ok" = "1" ]; then ok "░ → ▒ → ▓ → █ progression survives stripAnsi"; record "shade-texture" PASS
else no "the ramp progression did not read through noColor"; record "shade-texture" FAIL; fi

# ── Retired glyphs ──────────────────────────────────────────────────────────────
label "Check: naked [bar] pct · ▁▂▃ sub-blocks · =/. ascii all retired — under EVERY style"
RETIRED="$(render 'import { progress } from "./charts/progress.js";
let bad = "";
for (const style of ["bar", "blocks", "braille", "ascii"] as const) {
  const plain = progress({ value: 73, style }).toPlain();
  if (/[[\]]/.test(plain)) bad += " brackets(" + style + ")";
  if (/[▁▂▃▄▅▆▇]/.test(plain)) bad += " subblocks(" + style + ")";
  if (/=/.test(plain)) bad += " ascii(" + style + ")";
}
console.log(bad === "" ? "CLEAN" : "BAD:" + bad);')" || true
if [ "$RETIRED" = "CLEAN" ]; then ok "no off-vocabulary glyph anywhere in any style"; record "retired-glyphs" PASS
else no "retired glyphs present:$RETIRED"; record "retired-glyphs" FAIL; fi

# ── Degenerate cases: must not crash / no NaN / honest footers ──────────────────
header "Degenerate input renders safely"
deg_ok=1
label "value past max → fill clips at full width, footer reports the TRUE 140% (no silent clamp)"
O="$(render 'import { progress } from "./charts/progress.js";
console.log(progress({ value: 140, max: 100 }).toPlain());')" || deg_ok=0
printf '%s\n' "$O"
printf '%s' "$O" | grep -q "value 140 · 0..100 · 140.0%" || deg_ok=0
printf '%s' "$O" | grep -q "NaN" && deg_ok=0

label "non-finite value → framed value n/a panel"
N="$(render 'import { progress } from "./charts/progress.js";
console.log(progress({ value: NaN, max: 100 }).toPlain());')" || deg_ok=0
printf '%s\n' "$N"
printf '%s' "$N" | grep -q "value n/a · 0..100" || deg_ok=0
printf '%s' "$N" | grep -q "NaN\|Infinity" && deg_ok=0

label "collapsed range (max == 0) → honest render, no division by zero"
C="$(render 'import { progress } from "./charts/progress.js";
console.log(progress({ value: 50, max: 0 }).toPlain());')" || deg_ok=0
printf '%s\n' "$C"
printf '%s' "$C" | grep -q "NaN\|Infinity" && deg_ok=0
if [ "$deg_ok" = "1" ]; then ok "past-max / n-a / collapsed all safe (no crash, no NaN, honest footers)"; record "degenerate-safe" PASS
else no "a degenerate case failed"; record "degenerate-safe" FAIL; fi

# ── Agent surface ───────────────────────────────────────────────────────────────
label "Agent surface: toJSON() carries the additive facts (value · max · percent · bucket)"
J="$(render 'import { progress } from "./charts/progress.js";
const json = progress({ value: 73, max: 100 }).toJSON();
console.log(JSON.stringify({ type: json.type, value: json.value, max: json.max, percent: json.percent, bucket: json.bucket }));')" || true
printf '%s\n' "$J"
printf '%s' "$J" | grep -q '"type":"progress"' && printf '%s' "$J" | grep -q '"percent":73' && printf '%s' "$J" | grep -q '"bucket":2' \
  && { ok "additive agent facts present (type/value/max/percent/bucket)"; record "tojson-agent-surface" PASS; } \
  || { no "agent surface incomplete"; record "tojson-agent-surface" FAIL; }

# ── Summary scorecard (fed by the real checks above) ───────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests (accent, chrome, degen)"     "see verify-session-23.sh"
printf "  %-40s %s\n" "README LOCKED progress block"          "see verify-session-23.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-23.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
