#!/usr/bin/env bash
# verify-session-28.sh — S28: lock sparkline to the reference/panel language.
# Proves: sparkline renders shape+shade columns (height by share of range,
# ░▒▓ grey-ramp glyphs, peak as solid █ accent spent EXACTLY once via
# raw-ANSI census, NO theme.colors[0] teal flood; ties resolve to the first
# reading with accent exclusivity; dashed panel/SPARKLINE eyebrow/2 rules/
# label-on-top/n·min·max·last·peak foot with peak accented; renderer option
# accepted but superseded; width keeps column meaning with deterministic
# downsample; empty/flat/non-finite/narrow degenerate-safe; additive toJSON),
# the full core suite + typecheck stay green, and the regenerated docs
# previews are in sync.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="28"
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

# ── Criterion 1: shape+shade vocabulary, never a single-colour strip ──
run_check "shape-shade-vocab" bash -c '
  cd packages/core
  cat > src/__verify_s28_c1.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { stripAnsi } from "./ansi.js";
const text = stripAnsi(sparkline({ data: [45, 60, 75, 88, 95, 88, 75, 60, 48, 55, 70, 85, 96, 102, 90, 76, 62, 50, 58, 72, 86, 94, 87, 74, 61, 52, 66, 80], noColor: true }).toString());
const rows = text.split("\n").filter((l) => /[░▒▓█]/.test(l));
if (rows.length !== 4) { console.error("FAIL: expected 4 strip rows, got " + rows.length); process.exit(1); }
if (!/[░▒▓]/.test(text)) { console.error("FAIL: no ramp shade glyphs"); process.exit(1); }
if (!text.includes("█")) { console.error("FAIL: no solid peak column"); process.exit(1); }
if (/[▁▂▃▄▅▆▇]/.test(text)) { console.error("FAIL: retired sub-block strip leaked"); process.exit(1); }
console.log("OK: 4-row shape+shade strip, ramp + peak, no sub-blocks");
TS
  npx tsx src/__verify_s28_c1.ts; rc=$?
  rm -f src/__verify_s28_c1.ts
  exit $rc
'

# ── Criterion 2: raw-ANSI — accent ONLY on solid peak cells, grey rest ──
run_check "spark-tonal-census" bash -c '
  cd packages/core
  cat > src/__verify_s28_c2.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = sparkline({ data: [45, 60, 75, 88, 95, 88, 75, 60, 48, 55, 70, 85, 96, 102, 90, 76, 62, 50, 58, 72, 86, 94, 87, 74, 61, 52, 66, 80] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (code === theme.axis) continue;
  if (!/[░▒▓█]/.test(body)) continue;
  if (/[A-Za-z0-9]/.test(body)) continue;
  if (code === theme.accent) {
    accent++;
    if (!/^█+$/.test(body)) { console.error("FAIL: accent on non-solid " + JSON.stringify(body)); process.exit(1); }
  }
  else if (GREY_TONES.includes(code)) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the peak column"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp columns"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " segments are neither accent nor grey (teal flood?)"); process.exit(1); }
console.log("OK: accent only on peak solids (" + accent + "), grey ×" + grey + ", 0 leaks");
TS
  npx tsx src/__verify_s28_c2.ts; rc=$?
  rm -f src/__verify_s28_c2.ts
  exit $rc
'

# ── Criterion 3: ties-first accent exclusivity ──
run_check "ties-first-exclusive" bash -c '
  cd packages/core
  cat > src/__verify_s28_c3.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const j = sparkline({ data: [5, 1, 5], noColor: true }).toJSON() as Record<string, unknown>;
if ((j.peak as Record<string, unknown>).index !== 0) { console.error("FAIL: peak index not first tie"); process.exit(1); }
const raw = sparkline({ data: [5, 1, 5] }).toString();
const solids = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)].filter(
  (s) => s[1] === theme.accent && /^█+$/.test(s[2]));
if (solids.length !== 4) { console.error("FAIL: expected 4 accent solids (peak full height), got " + solids.length); process.exit(1); }
console.log("OK: ties → first, accent spent on one column only");
TS
  npx tsx src/__verify_s28_c3.ts; rc=$?
  rm -f src/__verify_s28_c3.ts
  exit $rc
'

# ── Criterion 4: locked panel chrome ──
run_check "panel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s28_c4.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { stripAnsi } from "./ansi.js";
const lines = stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], label: "CPU", noColor: true }).toString()).split("\n");
if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: no dashed frame top"); process.exit(1); }
if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: no dashed frame bottom"); process.exit(1); }
if (!lines[0]!.includes("CPU")) { console.error("FAIL: label not on frame top"); process.exit(1); }
const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
if (rules.length !== 2) { console.error("FAIL: expected 2 rules, got " + rules.length); process.exit(1); }
if (!lines.some((l) => l.includes("SPARKLINE"))) { console.error("FAIL: no SPARKLINE eyebrow"); process.exit(1); }
if (new Set(lines.map((l) => [...l].length)).size !== 1) { console.error("FAIL: ragged width"); process.exit(1); }
console.log("OK: dashed frame + label top, SPARKLINE eyebrow, 2 rules, uniform width");
TS
  npx tsx src/__verify_s28_c4.ts; rc=$?
  rm -f src/__verify_s28_c4.ts
  exit $rc
'

# ── Criterion 5: foot facts with accented peak ──
run_check "foot-facts" bash -c '
  cd packages/core
  cat > src/__verify_s28_c5.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { stripAnsi } from "./ansi.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = sparkline({ data: [1, 3, 2, 5, 4] }).toString();
const foot = raw.split("\n").find((l) => l.includes("peak "))!;
if (!foot || !stripAnsi(foot).includes("n 5 · min 1 · max 5 · last 4 · peak 5")) {
  console.error("FAIL: foot wrong: " + stripAnsi(foot ?? "")); process.exit(1);
}
if (!foot.includes(theme.accent!)) { console.error("FAIL: peak not accented"); process.exit(1); }
const hidden = stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], showValue: false, noColor: true }).toString());
if (hidden.includes("last")) { console.error("FAIL: showValue:false kept last"); process.exit(1); }
console.log("OK: n·min·max·last·peak, peak accented, showValue:false drops last");
TS
  npx tsx src/__verify_s28_c5.ts; rc=$?
  rm -f src/__verify_s28_c5.ts
  exit $rc
'

# ── Criterion 6: renderer superseded + width/downsample ──
run_check "renderer-width" bash -c '
  cd packages/core
  cat > src/__verify_s28_c6.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
import { stripAnsi } from "./ansi.js";
const base = stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], noColor: true }).toString());
for (const renderer of ["blocks", "braille", "ascii"] as const) {
  const alt = stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], renderer, noColor: true }).toString());
  if (alt !== base) { console.error("FAIL: renderer " + renderer + " diverged"); process.exit(1); }
}
const wide = stripAnsi(sparkline({ data: [1, 2, 3, 4, 5, 6, 7, 8], width: 4, noColor: true }).toString());
const strip = wide.split("\n").filter((l) => /[░▒▓█]/.test(l));
if (strip.length !== 4) { console.error("FAIL: downsampled strip rows"); process.exit(1); }
const bottom = strip[strip.length - 1]!.replace(/^│ /, "").replace(/ │$/, "").trimEnd();
if ([...bottom].length !== 8) { console.error("FAIL: width columns wrong: " + JSON.stringify(bottom)); process.exit(1); }
console.log("OK: renderers identical, width downsamples to 4 columns");
TS
  npx tsx src/__verify_s28_c6.ts; rc=$?
  rm -f src/__verify_s28_c6.ts
  exit $rc
'

# ── Criterion 7: degenerate-safe ──
run_check "degenerate-safe" bash -c '
  cd packages/core
  cat > src/__verify_s28_c7.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
const empty = sparkline({ data: [] });
if (!empty.toPlain().includes("n 0 · (no data)")) { console.error("FAIL: empty panel wrong"); process.exit(1); }
const j = empty.toJSON() as Record<string, unknown>;
if (j.count !== 0 || j.min !== null || j.max !== null || j.last !== null || j.peak !== null) {
  console.error("FAIL: empty facts dishonest"); process.exit(1);
}
const flat = sparkline({ data: [7, 7, 7], noColor: true });
if (flat.toPlain().includes("NaN") || !flat.toPlain().includes("█")) { console.error("FAIL: flat range"); process.exit(1); }
const mixed = sparkline({ data: [1, NaN, 2, Infinity, 3], noColor: true });
if (mixed.toPlain().includes("NaN") || mixed.toPlain().includes("Infinity")) { console.error("FAIL: non-finite leak"); process.exit(1); }
if ((mixed.toJSON() as Record<string, unknown>).count !== 3) { console.error("FAIL: bad readings counted"); process.exit(1); }
const narrow = sparkline({ data: [1, 2, 3], width: 1, noColor: true });
if (!narrow.toPlain().startsWith("┌╌")) { console.error("FAIL: narrow width broke"); process.exit(1); }
console.log("OK: empty/flat/non-finite/narrow all safe");
TS
  npx tsx src/__verify_s28_c7.ts; rc=$?
  rm -f src/__verify_s28_c7.ts
  exit $rc
'

# ── Criterion 8: additive toJSON ──
run_check "tojson-additive" bash -c '
  cd packages/core
  cat > src/__verify_s28_c8.ts <<'"'"'TS'"'"'
import { sparkline } from "./charts/sparkline.js";
const j = sparkline({ data: [1, 2, 42], label: "CPU" }).toJSON() as Record<string, unknown>;
if (j.type !== "sparkline" || j.count !== 3 || j.min !== 1 || j.max !== 42 || j.last !== 42) {
  console.error("FAIL: facts " + JSON.stringify(j)); process.exit(1);
}
if (JSON.stringify(j.peak) !== JSON.stringify({ index: 2, value: 42 })) { console.error("FAIL: peak"); process.exit(1); }
if (!Array.isArray(j.data) || j.label !== "CPU" || typeof j.plain !== "string") {
  console.error("FAIL: legacy keys"); process.exit(1);
}
console.log("OK: count/min/max/last/peak + type/data/label/plain");
TS
  npx tsx src/__verify_s28_c8.ts; rc=$?
  rm -f src/__verify_s28_c8.ts
  exit $rc
'

# ── Criterion 9: the old strip is gone from the source ──
run_check "source-locked" bash -c '
  SRC=$(sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/sparkline.ts)
  if echo "$SRC" | grep -q "theme\.colors\["; then
    echo "theme.colors[] flood still present in sparkline.ts"; exit 1
  fi
  for retired in sparklineBlocks sparklineAscii BrailleCanvas; do
    if echo "$SRC" | grep -q "$retired"; then
      echo "retired renderer $retired still wired in sparkline.ts"; exit 1
    fi
  done
  echo "$SRC" | grep -q "frameTop" || { echo "no panel frame in sparkline.ts"; exit 1; }
  echo "$SRC" | grep -q "theme.accent" || { echo "no accent hue in sparkline.ts"; exit 1; }
  echo "sparkline: no flood, no retired renderers, panel + accent present"
'

# ── Criterion 10: core tests green ───────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "sparkline-tests"        pnpm --filter @chitra/core run test -- sparkline

# ── Criterion 11: README carries the LOCKED contract block ──────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: sparkline chart — session 28 design" packages/core/README.md
'

# ── Criterion 12: docs previews in sync + dist carries the lock ─
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "dist-carries-lock"      bash -c '
  node -e "
    const { sparkline } = require(\"./packages/core/dist/index.cjs\");
    const e = sparkline({ data: [], noColor: true }).toPlain();
    if (!e.includes(\"n 0\") || !e.includes(\"(no data)\")) { console.error(\"dist spark stale\"); process.exit(1); }
    const s = sparkline({ data: [1, 3, 2, 5, 4], label: \"CPU\", noColor: true }).toPlain();
    if (!s.includes(\"peak 5\") || !s.includes(\"┌\") || !s.includes(\"SPARKLINE\")) { console.error(\"dist spark not locked\"); process.exit(1); }
    console.log(\"OK: dist renders the locked sparkline\");
  "
'
run_check "zero-runtime-deps"      bash -c '
  node -e "const d=require(\"./packages/core/package.json\"); const n=Object.keys(d.dependencies||{}).length; if(n!==0){console.error(\"deps: \"+n);process.exit(1)} console.log(\"OK: zero runtime deps\")"
'

# ── Criterion 13: branch is s28 ──────────────────────────────────
run_check "branch-is-s28"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-28-* ]] || { echo "branch=$branch, expected session-28-*"; exit 1; }
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
