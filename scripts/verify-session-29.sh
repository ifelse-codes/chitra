#!/usr/bin/env bash
# verify-session-29.sh — S29: family-wide footer pass (B-diet+).
# Proves: plain-words takeaway footers on all 20 charts (no jargon tokens in
# footers), exactly ONE rule separator per panel, accent still spent once on
# the takeaway, empty panels use plain nouns with honest null facts, toJSON
# agent surface unchanged, full suite + typecheck green, README S29 block,
# docs previews in sync, dist carries the new footers, zero runtime deps.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="29"
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

# ── Criterion 1: plain-words takeaway footers, no jargon ──
run_check "footer-plain-words" bash -c '
  cd packages/core
  cat > src/__verify_s29_c1.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
import { horizontalBar } from "./charts/horizontalBar.js";
import { sparkline } from "./charts/sparkline.js";
import { gauge } from "./charts/gauge.js";
import { histogram } from "./charts/histogram.js";
import { heatmap } from "./charts/heatmap.js";
import { scatter } from "./charts/scatter.js";
import { treemap } from "./charts/treemap.js";
import { radar } from "./charts/radar.js";
import { candlestick } from "./charts/candlestick.js";
import { boxplot } from "./charts/boxplot.js";
import { stripAnsi } from "./ansi.js";
const feet: Array<[string, string]> = [
  ["timeline", stripAnsi(timeline({ events: [{label:"Build",start:0,end:8},{label:"Test",start:2,end:5}], noColor: true }).toString())],
  ["hbar", stripAnsi(horizontalBar({ data: [3,8], labels: ["a","b"], noColor: true }).toString())],
  ["spark", stripAnsi(sparkline({ data: [1,3,2,5,4], noColor: true }).toString())],
  ["gauge", stripAnsi(gauge({ value: 72, min: 0, max: 100, noColor: true }).toString())],
  ["hist", stripAnsi(histogram({ data: [1,1,2,2,2,5,9], noColor: true }).toString())],
  ["heat", stripAnsi(heatmap({ data: [[1,2],[3,9]], noColor: true }).toString())],
  ["scatter", stripAnsi(scatter({ data: [{x:1,y:2},{x:10,y:12}], noColor: true }).toString())],
  ["tree", stripAnsi(treemap({ data: [{label:"A",value:5},{label:"B",value:2}], noColor: true }).toString())],
  ["radar", stripAnsi(radar({ data: [10,50,30], labels: ["a","b","c"], noColor: true }).toString())],
  ["candle", stripAnsi(candlestick({ data: [{open:1,high:5,low:1,close:4},{open:4,high:6,low:3,close:6},{open:6,high:7,low:5,close:5}], noColor: true }).toString())],
  ["box", stripAnsi(boxplot({ data: [[1,2,3],[4,9,16]], labels: ["A","C"], noColor: true }).toString())],
];
const footOf = (plain: string) => plain.split("\n").at(-2) ?? "";
const must: Array<[string, RegExp]> = [
  ["timeline", /2 events · longest Build/],
  ["hbar", /2 items · peak b \(8\)/],
  ["spark", /5 readings · peak 5/],
  ["gauge", /72 of 0\.\.100 · 72\.0%/],
  ["hist", /7 samples · peak/],
  ["heat", /grid · peak/],
  ["scatter", /2 points · peak/],
  ["tree", /2 leaves · peak/],
  ["radar", /average .* · peak/],
  ["candle", /3 candles · high .* · low .* · last/],
  ["box", /2 groups · median .* · peak/],
];
for (const [name, re] of must) {
  const foot = footOf(feet.find(([n]) => n === name)![1]);
  if (!re.test(foot)) { console.error("FAIL [" + name + "] foot: " + JSON.stringify(foot)); process.exit(1); }
}
// Jargon must be gone from footers (n ·, min/max tokens, span/MED/AVG/GROUPS/HI caps)
const jargon = [/\bn \d+ ·/, /· min \d/, /· max \d/, /· span \w/, /· MED /, /AVG \d/, /GROUPS \d/, /N \d+ · HI/];
for (const [name, plain] of feet) {
  const foot = footOf(plain);
  for (const j of jargon) {
    if (j.test(foot)) { console.error("FAIL [" + name + "] jargon leak: " + JSON.stringify(foot)); process.exit(1); }
  }
}
console.log("OK: 11 takeaway footers plain, 0 jargon leaks");
TS
  npx tsx src/__verify_s29_c1.ts; rc=$?
  rm -f src/__verify_s29_c1.ts
  exit $rc
'

# ── Criterion 2: exactly one rule separator per panel ──
run_check "one-rule" bash -c '
  cd packages/core
  cat > src/__verify_s29_c2.ts <<'"'"'TS'"'"'
import { line } from "./charts/line.js";
import { bar } from "./charts/bar.js";
import { area } from "./charts/area.js";
import { pie } from "./charts/pie.js";
import { donut } from "./charts/donut.js";
import { timeline } from "./charts/timeline.js";
import { gauge } from "./charts/gauge.js";
import { progress } from "./charts/progress.js";
import { histogram } from "./charts/histogram.js";
import { heatmap } from "./charts/heatmap.js";
import { scatter } from "./charts/scatter.js";
import { horizontalBar } from "./charts/horizontalBar.js";
import { treemap } from "./charts/treemap.js";
import { radar } from "./charts/radar.js";
import { boxplot } from "./charts/boxplot.js";
import { waterfall } from "./charts/waterfall.js";
import { funnel } from "./charts/funnel.js";
import { candlestick } from "./charts/candlestick.js";
import { sankey } from "./charts/sankey.js";
import { sparkline } from "./charts/sparkline.js";
import { stripAnsi } from "./ansi.js";
const panels: Array<[string, string]> = [
  ["line", stripAnsi(line({ data: [1,2,3], noColor: true }).toString())],
  ["bar", stripAnsi(bar({ data: [1,2,3], noColor: true }).toString())],
  ["area", stripAnsi(area({ data: [1,2,3], noColor: true }).toString())],
  ["pie", stripAnsi(pie({ data: [3,1], labels: ["a","b"], noColor: true }).toString())],
  ["donut", stripAnsi(donut({ data: [3,1], labels: ["a","b"], noColor: true }).toString())],
  ["timeline", stripAnsi(timeline({ events: [{label:"B",start:0,end:2}], noColor: true }).toString())],
  ["gauge", stripAnsi(gauge({ value: 5, min: 0, max: 10, noColor: true }).toString())],
  ["progress", stripAnsi(progress({ value: 5, max: 10, noColor: true }).toString())],
  ["hist", stripAnsi(histogram({ data: [1,2,2], noColor: true }).toString())],
  ["heat", stripAnsi(heatmap({ data: [[1,2],[3,4]], noColor: true }).toString())],
  ["scatter", stripAnsi(scatter({ data: [{x:1,y:1}], noColor: true }).toString())],
  ["hbar", stripAnsi(horizontalBar({ data: [2], noColor: true }).toString())],
  ["tree", stripAnsi(treemap({ data: [{label:"A",value:1}], noColor: true }).toString())],
  ["radar", stripAnsi(radar({ data: [10,50,30], labels: ["a","b","c"], noColor: true }).toString())],
  ["box", stripAnsi(boxplot({ data: [[1,2,3]], labels: ["A"], noColor: true }).toString())],
  ["water", stripAnsi(waterfall({ data: [5,-2,4], noColor: true }).toString())],
  ["funnel", stripAnsi(funnel({ data: [10,5,2], noColor: true }).toString())],
  ["candle", stripAnsi(candlestick({ data: [{open:1,high:2,low:1,close:2}], noColor: true }).toString())],
  ["sankey", stripAnsi(sankey({ nodes: ["a","b"], links: [{source:"a",target:"b",value:3}], noColor: true }).toString())],
  ["spark", stripAnsi(sparkline({ data: [1,2], noColor: true }).toString())],
];
for (const [name, plain] of panels) {
  const rules = plain.split("\n").filter((l) => /^│ ╌+ │$/.test(l));
  if (rules.length !== 1) { console.error("FAIL [" + name + "]: " + rules.length + " rules"); process.exit(1); }
}
console.log("OK: 20/20 panels carry exactly 1 rule");
TS
  npx tsx src/__verify_s29_c2.ts; rc=$?
  rm -f src/__verify_s29_c2.ts
  exit $rc
'

# ── Criterion 3: accent still spent once (spot census) ──
run_check "accent-once" bash -c '
  cd packages/core
  cat > src/__verify_s29_c3.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { timeline } from "./charts/timeline.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = sparkline({ data: [1, 3, 2, 5, 4] }).toString();
const foot = raw.split("\n").find((l) => l.includes("peak "))!;
if (!foot.includes(theme.accent!)) { console.error("FAIL: spark peak foot not accented"); process.exit(1); }
const t = timeline({ events: [{label:"Build",start:0,end:8},{label:"Test",start:2,end:5}] }).toString();
const tf = t.split("\n").find((l) => l.includes("longest "))!;
if (!tf.includes(theme.accent!)) { console.error("FAIL: timeline longest foot not accented"); process.exit(1); }
console.log("OK: takeaway accented on spark + timeline feet");
TS
  npx tsx src/__verify_s29_c3.ts; rc=$?
  rm -f src/__verify_s29_c3.ts
  exit $rc
'

# ── Criterion 4: empty panels use plain nouns ──
run_check "empty-plain" bash -c '
  cd packages/core
  cat > src/__verify_s29_c4.ts <<'"'"'TS'"'"'
import { timeline } from "./charts/timeline.js";
import { sparkline } from "./charts/sparkline.js";
import { histogram } from "./charts/histogram.js";
import { candlestick } from "./charts/candlestick.js";
import { boxplot } from "./charts/boxplot.js";
import { radar } from "./charts/radar.js";
const checks: Array<[string, string, RegExp]> = [
  ["timeline", timeline({ events: [] }).toPlain(), /0 events · \(no data\)/],
  ["spark", sparkline({ data: [] }).toPlain(), /0 readings · \(no data\)/],
  ["hist", histogram({ data: [] }).toPlain(), /0 samples · \(no data\)/],
  ["candle", candlestick({ data: [] }).toPlain(), /0 candles · \(no data\)/],
  ["box", boxplot({ data: [] }).toPlain(), /0 groups · \(no data\)/],
  ["radar", radar({ data: [], labels: [] }).toPlain(), /0 axes · \(no data\)/],
];
for (const [name, plain, re] of checks) {
  if (!re.test(plain)) { console.error("FAIL [" + name + "]: " + JSON.stringify(plain.split("\n").at(-2))); process.exit(1); }
  if (plain.includes("NaN")) { console.error("FAIL [" + name + "]: NaN leak"); process.exit(1); }
}
const j = sparkline({ data: [] }).toJSON() as Record<string, unknown>;
if (j.count !== 0 || j.peak !== null) { console.error("FAIL: empty facts dishonest"); process.exit(1); }
console.log("OK: 6 empty panels plain + honest nulls");
TS
  npx tsx src/__verify_s29_c4.ts; rc=$?
  rm -f src/__verify_s29_c4.ts
  exit $rc
'

# ── Criterion 5: agent surface unchanged ──
run_check "tojson-stable" bash -c '
  cd packages/core
  cat > src/__verify_s29_c5.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { timeline } from "./charts/timeline.js";
import { candlestick } from "./charts/candlestick.js";
const s = sparkline({ data: [1, 2, 42] }).toJSON() as Record<string, unknown>;
if (s.count !== 3 || s.min !== 1 || s.max !== 42 || s.last !== 42) { console.error("FAIL: spark facts"); process.exit(1); }
if (JSON.stringify(s.peak) !== JSON.stringify({ index: 2, value: 42 })) { console.error("FAIL: spark peak"); process.exit(1); }
const t = timeline({ events: [{label:"B",start:0,end:8}] }).toJSON() as Record<string, unknown>;
if ((t.peak as Record<string, unknown>).label !== "B") { console.error("FAIL: timeline peak"); process.exit(1); }
const c = candlestick({ data: [{open:1,high:5,low:1,close:4}]}).toJSON() as Record<string, unknown>;
if (c.high !== 5 || c.low !== 1 || c.last !== 4) { console.error("FAIL: candle facts"); process.exit(1); }
console.log("OK: toJSON facts intact (spark/timeline/candle)");
TS
  npx tsx src/__verify_s29_c5.ts; rc=$?
  rm -f src/__verify_s29_c5.ts
  exit $rc
'

# ── Criterion 6: suite + typecheck green ─────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck

# ── Criterion 7: README S29 block ────────────────────────────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: family-wide footer (B-diet+) — session 29 design" packages/core/README.md
'

# ── Criterion 8: docs + dist + deps + branch ─────────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "dist-carries-lock"      bash -c '
  node -e "
    const { sparkline, timeline } = require(\"./packages/core/dist/index.cjs\");
    const s = sparkline({ data: [1, 3, 2, 5, 4], noColor: true }).toPlain();
    if (!s.includes(\"5 readings · peak 5\")) { console.error(\"dist spark stale\"); process.exit(1); }
    const t = timeline({ events: [{label:\"B\",start:0,end:2}], noColor: true }).toPlain();
    if (!t.includes(\"longest B\")) { console.error(\"dist timeline stale\"); process.exit(1); }
    console.log(\"OK: dist renders B-diet+ footers\");
  "
'
run_check "zero-runtime-deps"      bash -c '
  node -e "const d=require(\"./packages/core/package.json\"); const n=Object.keys(d.dependencies||{}).length; if(n!==0){console.error(\"deps: \"+n);process.exit(1)} console.log(\"OK: zero runtime deps\")"
'
run_check "branch-is-s29"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-29-* ]] || { echo "branch=$branch, expected session-29-*"; exit 1; }
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
