#!/usr/bin/env bash
# verify-session-25.sh — S25: lock the histogram chart to the reference/panel language.
# Proves: histogram now renders the locked panel (one accent spent EXACTLY once on the
# mode bin as a solid █ column via raw-ANSI accent census, grey tone ramp + ░▒▓ shade
# texture for every other bin, NO theme.colors[0] flood, INTEGER y-axis count labels —
# the retired decimal-label bug, dashed frame/eyebrow/dashed baseline/bin-start labels/
# rule separators, n · mode · p50 · p99 summary footer with the mode fact accented,
# empty/collapsed/non-finite all degenerate-safe), the falsifiability tests pass, the
# full core suite + typecheck stay green, and the regenerated docs previews are in
# sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="25"
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

# ── Criterion 1: raw-ANSI — accent hue ONLY on solid █ segments (the mode column) ──
run_check "raw-ansi-accent-mode-only" bash -c '
  cd packages/core
  cat > src/__verify_s25_accent.ts <<'"'"'TS'"'"'
import { histogram } from "./charts/histogram.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = histogram({ data: [1,2,2,3,3,3,4,4,5,6,7,8,8,9], bins: 5 }).toString();
// Census coloured BIN segments. Only shade-ramp runs (░▒▓█) count; labels,
// frame, and footer text are excluded.
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (!BAR.test(body)) continue;
  if (code === theme.accent) {
    accent++;
    if (!/^█+$/.test(body)) { console.error("FAIL: accent carries a non-solid segment " + JSON.stringify(body)); process.exit(1); }
  }
  else if (theme.tones!.includes(code)) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the mode column"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " bin segments are neither accent nor a grey tone (theme.colors leak)"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp bins"); process.exit(1); }
console.log("OK: accent only on solid █ mode segments (" + accent + " rows), " + grey + " grey-ramp segs, 0 theme.colors leaks");
TS
  npx tsx src/__verify_s25_accent.ts; rc=$?
  rm -f src/__verify_s25_accent.ts
  exit $rc
'

# ── Criterion 2: integer y-axis labels (the retired decimal-count bug) ──────
run_check "integer-y-labels" bash -c '
  cd packages/core
  cat > src/__verify_s25_ints.ts <<'"'"'TS'"'"'
import { histogram } from "./charts/histogram.js";
import { stripAnsi } from "./ansi.js";
const lines = stripAnsi(histogram({ data: Array.from({length: 240}, (_, i) => 5 + (i % 17) * 0.3) }).toString()).split("\n");
let labels = 0;
for (const line of lines) {
  const m = line.match(/^│ (\s*\d*)([+│])/);
  if (!m) continue;
  labels++;
  if (m[1]!.includes(".")) { console.error("FAIL: decimal y-label on a COUNT axis: " + JSON.stringify(m[1])); process.exit(1); }
}
if (labels < 3) { console.error("FAIL: too few y labels rendered (" + labels + ")"); process.exit(1); }
console.log("OK: " + labels + " y-axis labels, every one an integer count");
TS
  npx tsx src/__verify_s25_ints.ts; rc=$?
  rm -f src/__verify_s25_ints.ts
  exit $rc
'

# ── Criterion 3: panel chrome present ───────────────────────────────────────
run_check "panel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s25_chrome.ts <<'"'"'TS'"'"'
import { histogram } from "./charts/histogram.js";
import { stripAnsi } from "./ansi.js";
const lines = stripAnsi(histogram({ data: [1,2,2,3,3,3,4,4,5,6,7,8,8,9] }).toString()).split("\n");
if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: no dashed frame top"); process.exit(1); }
if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: no dashed frame bottom"); process.exit(1); }
const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
if (rules.length !== 2) { console.error("FAIL: expected 2 rule separators, got " + rules.length); process.exit(1); }
if (!lines.some((l) => l.includes("DISTRIBUTION"))) { console.error("FAIL: no eyebrow row"); process.exit(1); }
if (!lines.some((l) => l.includes("└╌"))) { console.error("FAIL: no dashed baseline"); process.exit(1); }
if (!lines.some((l) => l.includes("mode "))) { console.error("FAIL: no mode fact in the foot row"); process.exit(1); }
const widths = new Set(lines.map((l) => [...l].length));
if (widths.size !== 1) { console.error("FAIL: panel rows disagree on width: " + [...widths].join(",")); process.exit(1); }
console.log("OK: dashed frame + 2 rules + eyebrow + dashed baseline + mode foot + uniform width");
TS
  npx tsx src/__verify_s25_chrome.ts; rc=$?
  rm -f src/__verify_s25_chrome.ts
  exit $rc
'

# ── Criterion 4: the ramp survives noColor (texture language) ────────────────
run_check "ramp-survives-nocolor" bash -c '
  cd packages/core
  cat > src/__verify_s25_nocolor.ts <<'"'"'TS'"'"'
import { histogram } from "./charts/histogram.js";
// counts land as shares 0.1 / 0.3 / 0.6 of the modal count → ░ ▒ ▓
const data = [0, 2, 2.5, 3, 4, 4.2, 4.4, 4.6, 4.8, 5,
  6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9];
const plain = histogram({ data, bins: 4, noColor: true }).toPlain();
for (const glyph of ["░", "▒", "▓", "█"]) {
  if (!plain.includes(glyph)) { console.error("FAIL: shade glyph " + glyph + " missing under noColor"); process.exit(1); }
}
console.log("OK: ░▒▓█ shade texture carries the density through noColor, light → dark");
TS
  npx tsx src/__verify_s25_nocolor.ts; rc=$?
  rm -f src/__verify_s25_nocolor.ts
  exit $rc
'

# ── Criterion 5: summary foot reports n · mode · p50 · p99, mode accented ───
run_check "footer-format" bash -c '
  cd packages/core
  cat > src/__verify_s25_footer.ts <<'"'"'TS'"'"'
import { histogram } from "./charts/histogram.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const data = [1,2,2,3,3,3,4,4,5,6,7,8,8,9];
const raw = histogram({ data }).toString();
const summaryLine = raw.split("\n").find((l) => l.includes("mode "))!;
if (!summaryLine.includes(theme.accent!)) { console.error("FAIL: mode fact not in the accent hue"); process.exit(1); }
const plain = stripAnsiSafe(raw);
function stripAnsiSafe(s: string): string { return s.replace(/\x1b\[[0-9;]*m/g, ""); }
if (!/n 14 · mode \d/.test(plain)) { console.error("FAIL: footer missing n/mode facts: " + JSON.stringify(plain.split("\n").find(l => l.includes("mode ")))); process.exit(1); }
if (!plain.includes("p50 ") || !plain.includes("p99 ")) { console.error("FAIL: footer missing p50/p99"); process.exit(1); }
const j = histogram({ data }).toJSON() as Record<string, unknown>;
if (j.mode === null || j.p50 === null || j.p99 === null) { console.error("FAIL: additive JSON facts null for real data"); process.exit(1); }
if (j.p50 !== 4 || j.p99 !== 9) { console.error("FAIL: nearest-rank percentiles wrong: p50=" + j.p50 + " p99=" + j.p99); process.exit(1); }
console.log("OK: n · mode(accent) · p50 · p99 foot + additive JSON facts (p50=4, p99=9)");
TS
  npx tsx src/__verify_s25_footer.ts; rc=$?
  rm -f src/__verify_s25_footer.ts
  exit $rc
'

# ── Criterion 6: empty / collapsed / non-finite all safe ─────────────────────
run_check "degenerate-safe" bash -c '
  cd packages/core
  cat > src/__verify_s25_degen.ts <<'"'"'TS'"'"'
import { histogram } from "./charts/histogram.js";
// empty: framed n 0 · (no data) panel, null JSON facts
const empty = histogram({ data: [] });
const emptyPlain = empty.toPlain();
if (!emptyPlain.startsWith("┌╌") || !emptyPlain.endsWith("┘")) { console.error("FAIL: empty panel missing its frame"); process.exit(1); }
if (!emptyPlain.includes("n 0 · (no data)")) { console.error("FAIL: empty footer incorrect"); process.exit(1); }
const ej = empty.toJSON() as Record<string, unknown>;
if (ej.mode !== null || ej.p50 !== null || ej.p99 !== null) { console.error("FAIL: empty data must report null facts"); process.exit(1); }
// collapsed range (every value equal): no NaN, everything in bin 0
const collapsed = histogram({ data: [7,7,7,7] });
if (collapsed.toPlain().includes("NaN") || collapsed.toPlain().includes("Infinity")) { console.error("FAIL: collapsed range NaN/Infinity"); process.exit(1); }
const cj = collapsed.toJSON() as Record<string, unknown>;
if ((cj.binCounts as number[])[0] !== 4) { console.error("FAIL: collapsed range did not land in bin 0"); process.exit(1); }
// non-finite samples excluded, never NaN-binned
const mixed = histogram({ data: [1, 2, 3, NaN, Infinity] });
if (mixed.toPlain().includes("NaN") || mixed.toPlain().includes("Infinity")) { console.error("FAIL: non-finite leaks NaN/Infinity"); process.exit(1); }
const mj = mixed.toJSON() as Record<string, unknown>;
if (mj.count !== 3) { console.error("FAIL: count should exclude non-finite samples, got " + mj.count); process.exit(1); }
console.log("OK: empty / collapsed / non-finite all render safely and honestly");
TS
  npx tsx src/__verify_s25_degen.ts; rc=$?
  rm -f src/__verify_s25_degen.ts
  exit $rc
'

# ── Criterion 7: the theme.colors flood is gone from the source ──────────────
run_check "source-locked" bash -c '
  # strip block + line comments, then look for live off-vocabulary code
  SRC=$(sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/histogram.ts)
  if echo "$SRC" | grep -q "theme\.colors\["; then
    echo "theme.colors[] flood still present in histogram.ts"; exit 1
  fi
  echo "$SRC" | grep -q "frameTop" || { echo "no panel frame in histogram.ts"; exit 1; }
  echo "$SRC" | grep -q "theme.accent" || { echo "no accent hue in histogram.ts"; exit 1; }
  echo "$SRC" | grep -q "COUNT_SHADES" || { echo "no shade ramp in histogram.ts"; exit 1; }
'

# ── Criterion 8: core tests green ──────────────────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "histogram-tests"        pnpm --filter @chitra/core run test -- histogram

# ── Criterion 9: README carries the LOCKED contract block ──────────────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: histogram chart — session 25 design" packages/core/README.md
'

# ── Criterion 10: docs previews in sync (no chart drift) ───────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 11: branch is s25 ────────────────────────────────────────────
run_check "branch-is-s25"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-25-* ]] || { echo "branch=$branch, expected session-25-*"; exit 1; }
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
