#!/usr/bin/env bash
# verify-session-21.sh — S21: lock the timeline chart to the reference/panel language.
# Proves: timeline now renders the locked panel (one accent spent once on the longest
# span via raw-RGB accent census, grey tone ramp for every other bar, NO
# theme.colors[i % n] rainbow, dashed frame/SPAN eyebrow/+╌…╌+ guide/rule separators,
# n · min..max · span <label> summary footer, ─ scale track kept, ▶/◀ retired,
# degenerate-safe), the falsifiability tests pass, the full core suite + typecheck stay
# green, and the regenerated docs previews are in sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="21"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
    echo "  ↳ FAIL log: $LOG" >&2
  fi
}

# ── Criterion 1: raw-RGB — accent hue spent EXACTLY once on the longest span ──
run_check "raw-rgb-accent-once" bash -c '
  cd packages/core
  cat > src/__verify_s21_accent.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = timeline({
  events: [
    { label: "Design", start: 0, end: 2 },
    { label: "Build", start: 2, end: 6 },
    { label: "Test", start: 5, end: 7 },
    { label: "Deploy", start: 7, end: 8 },
  ],
  title: "Sprint Timeline",
}).toString();
// Census coloured BAR segments (one segment per event row). The `─` track is
// axis scale, not fill; only shade-ramp runs (░▒▓█) count.
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (!BAR.test(body)) continue;
  if (code === theme.accent) accent++;
  else if (theme.tones!.includes(code)) grey++;
  else other++;
}
if (accent !== 1) { console.error("FAIL: accent must be spent EXACTLY once, got " + accent); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " bar segments are neither accent nor a grey tone (rainbow leak)"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp bars"); process.exit(1); }
console.log("OK: accent spent once on the longest span, " + grey + " grey-ramp segs, 0 rainbow leaks");
TS
  npx tsx src/__verify_s21_accent.ts; rc=$?
  rm -f src/__verify_s21_accent.ts
  exit $rc
'

# ── Criterion 2: panel chrome present ───────────────────────────────────────
run_check "panel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s21_chrome.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
const plain = timeline({ events: [{ label: "A", start: 0, end: 1 }] }).toPlain();
const lines = plain.split("\n");
const topOk = lines[0].startsWith("┌╌");
const bottomOk = lines[lines.length - 1].startsWith("└╌");
const rules = (plain.match(/│ ╌/g) || []).length;
const eyebrow = plain.includes("SPAN");
const guide = /\+╌+\+/.test(plain);
if (!topOk || !bottomOk || rules !== 2 || !eyebrow || !guide) {
  console.error("FAIL: missing dashed frame/eyebrow/guide/rule separators"); process.exit(1);
}
console.log("OK: dashed frame, SPAN eyebrow, +╌…╌+ guide, two rule separators");
TS
  npx tsx src/__verify_s21_chrome.ts; rc=$?
  rm -f src/__verify_s21_chrome.ts
  exit $rc
'

# ── Criterion 3: footer reports n · min..max · span <label> ────────────────
run_check "footer-format" bash -c '
  cd packages/core
  cat > src/__verify_s21_footer.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
const plain = timeline({
  events: [
    { label: "Design", start: 0, end: 2 },
    { label: "Build", start: 2, end: 6 },
  ],
}).toPlain();
if (!/n 2 · 0\.\.6 · span Build/.test(plain)) {
  console.error("FAIL: footer format incorrect: " + plain.split("\n").slice(-3).join(" | ")); process.exit(1);
}
console.log("OK: footer reports n · min..max · span <label>");
TS
  npx tsx src/__verify_s21_footer.ts; rc=$?
  rm -f src/__verify_s21_footer.ts
  exit $rc
'

# ── Criterion 4: retired glyphs gone; fill is the shade ramp + ─ scale only ─
run_check "no-retired-glyphs" bash -c '
  cd packages/core
  cat > src/__verify_s21_glyphs.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
const EVENTS = [
  { label: "Design", start: 0, end: 2 },
  { label: "Build", start: 2, end: 6 },
  { label: "Test", start: 5, end: 7 },
  { label: "Deploy", start: 7, end: 8 },
];
const out = timeline({ events: EVENTS }).toString();
const ANSI = /\x1b\[[0-9;]*m|\x1b\[0m/g;
if (/[▶◀]/.test(out)) { console.error("FAIL: retired ▶/◀ markers still present"); process.exit(1); }
for (const row of out.split("\n").filter((l) => /[░▒▓█]/.test(l))) {
  const residue = row.replace(ANSI, "").replace(/[A-Za-z0-9 +.,_…\-│┌┐└┘╌─]/g, "");
  if (!/^[░▒▓█]*$/.test(residue)) { console.error("FAIL: non-ramp fill: " + JSON.stringify(residue)); process.exit(1); }
}
// the ramp ordering must survive noColor: spans are [2,4,2,1] → Design/Test
// read ▒ (bucket 1), Deploy reads ░ (bucket 0), the peak reads solid █
const plain = timeline({ events: EVENTS, noColor: true }).toPlain();
const rowFor = (label: string) => plain.split("\n").find((l) => l.includes(label))!;
if (!rowFor("Deploy").includes("░") || rowFor("Deploy").match(/[▒▓█]/)) {
  console.error("FAIL: shortest span is not the ░ ramp step"); process.exit(1);
}
if (!rowFor("Design").includes("▒") || rowFor("Design").match(/[░▓█]/)) {
  console.error("FAIL: mid-span event is not the ▒ ramp step"); process.exit(1);
}
if (!rowFor("Build").includes("█")) {
  console.error("FAIL: peak is not the solid █ block"); process.exit(1);
}
// a point event (NOT the peak) renders exactly one ░
const pEvents = [
  { label: "milestone", start: 3 },
  { label: "phase", start: 0, end: 6 },
];
const pplain = timeline({ events: pEvents, noColor: true }).toPlain();
const prow = pplain.split("\n").find((l) => l.includes("milestone"))!;
const glyphs = prow.match(/[░▒▓█]/g) || [];
if (glyphs.length !== 1 || glyphs[0] !== "░") {
  console.error("FAIL: point event rendered " + JSON.stringify(glyphs) + ", expected exactly one ░"); process.exit(1);
}
console.log("OK: no ▶/◀; plot rows are shade-ramp runs + ─ scale only; ramp ░▒▓ ordering survives noColor; point event = one ░");
TS
  npx tsx src/__verify_s21_glyphs.ts; rc=$?
  rm -f src/__verify_s21_glyphs.ts
  exit $rc
'

# ── Criterion 5: degenerate input renders safely (no crash, no NaN) ──────────
run_check "degenerate-safe" bash -c '
  cd packages/core
  cat > src/__verify_s21_degen.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
const CASES: Array<{ label: string; events: Array<{ label: string; start: number; end?: number }> }> = [
  { label: "empty", events: [] },
  { label: "single", events: [{ label: "solo", start: 2, end: 5 }] },
  { label: "collapsed", events: [{ label: "a", start: 5 }, { label: "b", start: 5 }] },
  { label: "backwards", events: [{ label: "x", start: 4, end: 1 }] },
];
for (const c of CASES) {
  const out = timeline(c).toPlain();
  if (out.includes("NaN") || out.includes("Infinity")) {
    console.error("FAIL: NaN/Infinity for case " + c.label); process.exit(1);
  }
  if (!out.startsWith("┌╌")) { console.error("FAIL: missing dashed frame for " + c.label); process.exit(1); }
}
console.log("OK: empty / single / collapsed-range / backwards all render safely");
TS
  npx tsx src/__verify_s21_degen.ts; rc=$?
  rm -f src/__verify_s21_degen.ts
  exit $rc
'

# ── Criterion 6: the rainbow default is gone from the source ────────────────
run_check "source-locked" bash -c '
  # strip block + line comments, then look for a live rainbow assignment
  if sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/timeline.ts | grep -q "theme\.colors\["; then
    echo "theme.colors[] rainbow still present in timeline.ts"; exit 1
  fi
  grep -q "frameTop" packages/core/src/charts/timeline.ts || { echo "no panel frame in timeline.ts"; exit 1; }
  grep -q "theme.accent" packages/core/src/charts/timeline.ts || { echo "no accent hue in timeline.ts"; exit 1; }
'

# ── Criterion 7: core tests green ──────────────────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "timeline-tests"         pnpm --filter @chitra/core run test -- timeline

# ── Criterion 8: README carries the LOCKED contract block ──────────────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: timeline chart — session 21 design" packages/core/README.md
'

# ── Criterion 9: docs previews in sync (no chart drift) ────────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 10: branch is s21 ────────────────────────────────────────────
run_check "branch-is-s21"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-21-* ]] || { echo "branch=$branch, expected session-21-*"; exit 1; }
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf "%-34s %s\n" "STEP" "RESULT"
printf "%-34s %s\n" "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
