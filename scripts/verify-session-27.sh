#!/usr/bin/env bash
# verify-session-27.sh — S27: lock candlestick + boxplot to the reference/panel language.
# Proves: candlestick renders tonal kinds (ups solid ▓ on the grey ramp, downs
# as dashed outline boxes, peak close as solid █ accent spent EXACTLY once via
# raw-ANSI census, NO theme.colors green/red flood; adaptive price labels, never
# float sprawl; dashed panel/OHLC eyebrow/baseline/period labels/rules;
# N·HI·LO·LAST foot with LAST accented; empty/flat/non-finite/narrow
# degenerate-safe; additive toJSON) AND boxplot renders tonal groups (peak
# median accent once, grey ramp + ░▒▓ shade fill elsewhere, NO per-group
# rainbow; median ───/═══ distinct from │ edges; SPREAD eyebrow;
# GROUPS·MED·PEAK foot with PEAK accented; empty/single-value/non-finite/narrow
# safe; additive peakGroup), the falsifiability tests pass, the full core suite
# + typecheck stay green, and the regenerated docs previews are in sync.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="27"
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

# ── Criterion 1: bearish candles are outline boxes, never rainbow ──
run_check "candle-outline-downs" bash -c '
  cd packages/core
  cat > src/__verify_s27_c1.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
import { stripAnsi } from "./ansi.js";
const text = stripAnsi(candlestick({ data: [
  { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
  { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
  { open: 98, high: 108, low: 96, close: 107, label: "Day3" },
], noColor: true }).toString());
if (!text.includes("┌╌") || !text.includes("└╌")) {
  console.error("FAIL: no dashed outline boxes for the bearish candle"); process.exit(1);
}
if (!text.includes("▓")) { console.error("FAIL: no solid bullish fill"); process.exit(1); }
if (!text.includes("█")) { console.error("FAIL: no solid peak body"); process.exit(1); }
console.log("OK: bearish outline boxes, bullish solids, peak solid");
TS
  npx tsx src/__verify_s27_c1.ts; rc=$?
  rm -f src/__verify_s27_c1.ts
  exit $rc
'

# ── Criterion 2: raw-ANSI — accent ONLY on solid █ bodies, grey ramp rest ──
run_check "candle-tonal-census" bash -c '
  cd packages/core
  cat > src/__verify_s27_c2.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = candlestick({ data: [
  { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
  { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
  { open: 98, high: 108, low: 96, close: 107, label: "Day3" },
] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[█▓┌╌┐│└┘]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (code === theme.axis) continue; // frame/guides/baseline, never candles
  if (!BAR.test(body)) continue;
  if (code === theme.accent) {
    accent++;
    if (!/^█+$/.test(body.replace(/\s/g, ""))) { console.error("FAIL: accent on non-solid " + JSON.stringify(body)); process.exit(1); }
  }
  else if (GREY_TONES.includes(code)) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the peak candle"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " segments are neither accent nor grey (theme.colors leak)"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp candles"); process.exit(1); }
console.log("OK: accent only on solid peak bodies (" + accent + " rows), " + grey + " grey segs, 0 leaks");
TS
  npx tsx src/__verify_s27_c2.ts; rc=$?
  rm -f src/__verify_s27_c2.ts
  exit $rc
'

# ── Criterion 3: boxplot raw-ANSI — accent on peak group only ──
run_check "boxplot-tonal-census" bash -c '
  cd packages/core
  cat > src/__verify_s27_c3.ts <<'"'"'TS'"'"'
import { boxplot } from "./charts/boxplot.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = boxplot({ data: [[1,2,3,4,5,6,7,8,9],[2,3,4,5,6],[10,12,14,16,18,20,22]], labels: ["A","B","C"] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BOX = /[│┬┴─═░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (code === theme.axis) continue;
  if (!BOX.test(body)) continue;
  if (/[A-Za-z0-9]/.test(body)) continue;
  if (code === theme.accent) accent++;
  else if (GREY_TONES.includes(code)) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the peak group"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no toned non-peak groups"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " theme.colors leaks"); process.exit(1); }
console.log("OK: peak accent (" + accent + " segs), toned rest (" + grey + "), 0 leaks");
TS
  npx tsx src/__verify_s27_c3.ts; rc=$?
  rm -f src/__verify_s27_c3.ts
  exit $rc
'

# ── Criterion 4: median marker distinct from box edges + shade texture ──
run_check "boxplot-median-marker" bash -c '
  cd packages/core
  cat > src/__verify_s27_c4.ts <<'"'"'TS'"'"'
import { boxplot } from "./charts/boxplot.js";
import { stripAnsi } from "./ansi.js";
const text = stripAnsi(boxplot({ data: [[1,2,3,4,5,6,7,8,9],[2,3,4,5,6],[10,12,14,16,18,20,22]], labels: ["A","B","C"], noColor: true }).toString());
if (!/───|═══/.test(text)) { console.error("FAIL: no horizontal median run"); process.exit(1); }
if (!text.includes("│")) { console.error("FAIL: no vertical box edges"); process.exit(1); }
if (!/[░▒▓]/.test(text)) { console.error("FAIL: no shade fill on non-peak boxes"); process.exit(1); }
if (!text.includes("█")) { console.error("FAIL: no solid peak fill"); process.exit(1); }
console.log("OK: ───/═══ medians vs │ edges, ░▒▓ shade + █ peak fill");
TS
  npx tsx src/__verify_s27_c4.ts; rc=$?
  rm -f src/__verify_s27_c4.ts
  exit $rc
'

# ── Criterion 5: locked panel chrome on both charts ──
run_check "panel-chrome-both" bash -c '
  cd packages/core
  cat > src/__verify_s27_c5.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
import { boxplot } from "./charts/boxplot.js";
import { stripAnsi } from "./ansi.js";
const c = stripAnsi(candlestick({ data: [{ open: 100, high: 110, low: 95, close: 105, label: "D1" }], noColor: true }).toString()).split("\n");
const b = stripAnsi(boxplot({ data: [[1,2,3],[4,5,9]], labels: ["A","B"], noColor: true }).toString()).split("\n");
for (const [name, lines, eyebrow] of [["candle", c, "OHLC"], ["box", b, "SPREAD"]] as const) {
  if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: " + name + " no dashed frame top"); process.exit(1); }
  if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: " + name + " no dashed frame bottom"); process.exit(1); }
  const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
  if (rules.length !== 2) { console.error("FAIL: " + name + " expected 2 rules, got " + rules.length); process.exit(1); }
  if (!lines.some((l) => l.includes(eyebrow))) { console.error("FAIL: " + name + " no " + eyebrow + " eyebrow"); process.exit(1); }
  if (new Set(lines.map((l) => [...l].length)).size !== 1) { console.error("FAIL: " + name + " ragged width"); process.exit(1); }
}
console.log("OK: dashed frames, OHLC/SPREAD eyebrows, 2 rules each, uniform width");
TS
  npx tsx src/__verify_s27_c5.ts; rc=$?
  rm -f src/__verify_s27_c5.ts
  exit $rc
'

# ── Criterion 6: the S27 precision rule (integers wide, ≤2dp tight) ──
run_check "label-precision-rule" bash -c '
  cd packages/core
  cat > src/__verify_s27_c6.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
import { stripAnsi } from "./ansi.js";
function yLabels(data: Parameters<typeof candlestick>[0]["data"]): string[] {
  const lines = stripAnsi(candlestick({ data, noColor: true }).toString()).split("\n");
  const out: string[] = [];
  for (const line of lines) {
    const m = line.match(/^│ (\s*\S*)([+│])/);
    if (m && m[1]!.trim()) out.push(m[1]!.trim());
  }
  return out;
}
// Wide range (span 400+): every label an integer.
const wide = yLabels([
  { open: 100, high: 500, low: 50, close: 450, label: "W" },
  { open: 450, high: 480, low: 200, close: 300, label: "X" },
]);
if (wide.length < 3) { console.error("FAIL: too few wide labels"); process.exit(1); }
for (const l of wide) if (l.includes(".")) { console.error("FAIL: decimal on wide axis: " + l); process.exit(1); }
// Tight prices: compact, never float sprawl (3+ decimals).
const tight = yLabels([
  { open: 100, high: 110, low: 95, close: 105, label: "A" },
  { open: 105, high: 115, low: 100, close: 98, label: "B" },
]);
if (tight.length < 3) { console.error("FAIL: too few tight labels"); process.exit(1); }
for (const l of tight) if (!/^-?\d+(\.\d{1,2})?$/.test(l)) { console.error("FAIL: sprawl on tight axis: " + l); process.exit(1); }
console.log("OK: " + wide.length + " integer wide labels, " + tight.length + " compact tight labels");
TS
  npx tsx src/__verify_s27_c6.ts; rc=$?
  rm -f src/__verify_s27_c6.ts
  exit $rc
'

# ── Criterion 7: feet formats with accented key facts ──
run_check "feet-formats" bash -c '
  cd packages/core
  cat > src/__verify_s27_c7.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
import { boxplot } from "./charts/boxplot.js";
import { stripAnsi, } from "./ansi.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const craw = candlestick({ data: [
  { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
  { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
  { open: 98, high: 108, low: 96, close: 107, label: "Day3" },
] }).toString();
const cfoot = craw.split("\n").find((l) => l.includes("LAST "))!;
if (!cfoot || !stripAnsi(cfoot).includes("N 3 · HI 115 · LO 95 · LAST 107")) { console.error("FAIL: candle foot wrong: " + stripAnsi(cfoot ?? "")); process.exit(1); }
if (!cfoot.includes(theme.accent!)) { console.error("FAIL: LAST not accented"); process.exit(1); }
const braw = boxplot({ data: [[1,2,3,4,5],[10,20,30]], labels: ["A","B"] }).toString();
const bfoot = braw.split("\n").find((l) => l.includes("PEAK "))!;
if (!bfoot || !stripAnsi(bfoot).includes("GROUPS 2 · MED") || !stripAnsi(bfoot).includes("PEAK B 20")) { console.error("FAIL: box foot wrong: " + stripAnsi(bfoot ?? "")); process.exit(1); }
if (!bfoot.includes(theme.accent!)) { console.error("FAIL: PEAK not accented"); process.exit(1); }
console.log("OK: N·HI·LO·LAST + GROUPS·MED·PEAK, key facts accented");
TS
  npx tsx src/__verify_s27_c7.ts; rc=$?
  rm -f src/__verify_s27_c7.ts
  exit $rc
'

# ── Criterion 8: candlestick degenerate-safe ──
run_check "candle-degenerate" bash -c '
  cd packages/core
  cat > src/__verify_s27_c8.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
const empty = candlestick({ data: [] });
if (!empty.toPlain().includes("N 0 · (no data)")) { console.error("FAIL: empty panel wrong"); process.exit(1); }
const j = empty.toJSON() as Record<string, unknown>;
if (j.count !== 0 || j.high !== null || j.low !== null || j.last !== null) { console.error("FAIL: empty facts dishonest"); process.exit(1); }
const flat = candlestick({ data: [{ open: 50, high: 50, low: 50, close: 50, label: "F" }], noColor: true });
if (flat.toPlain().includes("NaN") || !flat.toPlain().includes("█")) { console.error("FAIL: flat range not visible"); process.exit(1); }
const mixed = candlestick({ data: [
  { open: 100, high: 110, low: 95, close: 105, label: "Ok" },
  { open: NaN, high: Infinity, low: 1, close: 2, label: "Bad" },
], noColor: true });
if (mixed.toPlain().includes("NaN") || mixed.toPlain().includes("Infinity")) { console.error("FAIL: non-finite leak"); process.exit(1); }
if ((mixed.toJSON() as Record<string, unknown>).count !== 1) { console.error("FAIL: bad candle counted"); process.exit(1); }
const narrow = candlestick({ data: [{ open: 1, high: 2, low: 1, close: 2, label: "N" }], width: 5, noColor: true });
if (!narrow.toPlain().startsWith("┌╌")) { console.error("FAIL: narrow width broke"); process.exit(1); }
console.log("OK: empty/flat/non-finite/narrow all safe");
TS
  npx tsx src/__verify_s27_c8.ts; rc=$?
  rm -f src/__verify_s27_c8.ts
  exit $rc
'

# ── Criterion 9: boxplot degenerate-safe ──
run_check "boxplot-degenerate" bash -c '
  cd packages/core
  cat > src/__verify_s27_c9.ts <<'"'"'TS'"'"'
import { boxplot } from "./charts/boxplot.js";
const empty = boxplot({ data: [] });
if (!empty.toPlain().includes("GROUPS 0 · (no data)")) { console.error("FAIL: empty panel wrong"); process.exit(1); }
const j = empty.toJSON() as Record<string, unknown>;
if (j.stats !== null || j.peakGroup !== null) { console.error("FAIL: empty facts dishonest"); process.exit(1); }
const single = boxplot({ data: [[5],[5],[5]], labels: ["X","Y","Z"], noColor: true });
if (single.toPlain().includes("NaN")) { console.error("FAIL: single-value NaN"); process.exit(1); }
const mixed = boxplot({ data: [[1, 2, NaN, Infinity, 3]], labels: ["M"], noColor: true });
if (mixed.toPlain().includes("NaN") || mixed.toPlain().includes("Infinity")) { console.error("FAIL: non-finite leak"); process.exit(1); }
const narrow = boxplot({ data: [[1,2,3],[4,5,9]], width: 5, noColor: true });
if (!narrow.toPlain().startsWith("┌╌")) { console.error("FAIL: narrow width broke"); process.exit(1); }
console.log("OK: empty/single/non-finite/narrow all safe");
TS
  npx tsx src/__verify_s27_c9.ts; rc=$?
  rm -f src/__verify_s27_c9.ts
  exit $rc
'

# ── Criterion 10: additive toJSON on both ──
run_check "tojson-additive" bash -c '
  cd packages/core
  cat > src/__verify_s27_c10.ts <<'"'"'TS'"'"'
import { candlestick } from "./charts/candlestick.js";
import { boxplot } from "./charts/boxplot.js";
const cj = candlestick({ data: [{ open: 100, high: 110, low: 95, close: 105, label: "D" }] }).toJSON() as Record<string, unknown>;
if (cj.type !== "candlestick" || cj.count !== 1 || cj.high !== 110 || cj.low !== 95 || cj.last !== 105) { console.error("FAIL: candle facts " + JSON.stringify(cj)); process.exit(1); }
if (!Array.isArray(cj.data) || typeof cj.plain !== "string") { console.error("FAIL: candle legacy keys"); process.exit(1); }
const bj = boxplot({ data: [[1,2,3],[10,20,30]], labels: ["A","B"] }).toJSON() as Record<string, unknown>;
if (bj.type !== "boxplot" || !Array.isArray(bj.stats)) { console.error("FAIL: box legacy keys"); process.exit(1); }
const pg = bj.peakGroup as Record<string, unknown>;
if (pg.label !== "B" || pg.index !== 1 || pg.median !== 20) { console.error("FAIL: peakGroup " + JSON.stringify(pg)); process.exit(1); }
console.log("OK: count/high/low/last + stats/peakGroup, legacy keys kept");
TS
  npx tsx src/__verify_s27_c10.ts; rc=$?
  rm -f src/__verify_s27_c10.ts
  exit $rc
'

# ── Criterion 11: the theme.colors rainbow is gone from both sources ──
run_check "source-locked" bash -c '
  for f in candlestick boxplot; do
    SRC=$(sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/$f.ts)
    if echo "$SRC" | grep -q "theme\.colors\["; then
      echo "theme.colors[] rainbow still present in $f.ts"; exit 1
    fi
    echo "$SRC" | grep -q "frameTop" || { echo "no panel frame in $f.ts"; exit 1; }
    echo "$SRC" | grep -q "theme.accent" || { echo "no accent hue in $f.ts"; exit 1; }
  done
  echo "candlestick + boxplot: no rainbow, panel + accent present"
'

# ── Criterion 12: core tests green ───────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "candlestick-tests"      pnpm --filter @chitra/core run test -- candlestick
run_check "boxplot-tests"          pnpm --filter @chitra/core run test -- boxplot

# ── Criterion 13: README carries both LOCKED contract blocks ─────
run_check "readme-lock-blocks"     bash -c '
  grep -q "### LOCKED: candlestick chart — session 27 design" packages/core/README.md &&
  grep -q "### LOCKED: boxplot chart — session 27 design" packages/core/README.md
'

# ── Criterion 14: docs previews in sync + dist carries both locks ─
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "dist-carries-locks"     bash -c '
  node -e "
    const { candlestick, boxplot } = require(\"./packages/core/dist/index.cjs\");
    const c = candlestick({ data: [], noColor: true }).toPlain();
    if (!c.includes(\"N 0\") || !c.includes(\"(no data)\")) { console.error(\"dist candle stale\"); process.exit(1); }
    const b = boxplot({ data: [], noColor: true }).toPlain();
    if (!b.includes(\"GROUPS 0\") || !b.includes(\"(no data)\")) { console.error(\"dist box stale\"); process.exit(1); }
    const c2 = candlestick({ data: [{open:1,high:2,low:1,close:2,label:\"D\"}], noColor: true }).toPlain();
    if (!c2.includes(\"LAST 2\") || !c2.includes(\"┌\")) { console.error(\"dist candle not locked\"); process.exit(1); }
    console.log(\"OK: dist renders both locked charts\");
  "
'
run_check "zero-runtime-deps"      bash -c '
  node -e "const d=require(\"./packages/core/package.json\"); const n=Object.keys(d.dependencies||{}).length; if(n!==0){console.error(\"deps: \"+n);process.exit(1)} console.log(\"OK: zero runtime deps\")"
'

# ── Criterion 15: branch is s27 ──────────────────────────────────
run_check "branch-is-s27"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-27-* ]] || { echo "branch=$branch, expected session-27-*"; exit 1; }
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
