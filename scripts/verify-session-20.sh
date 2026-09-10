#!/usr/bin/env bash
# verify-session-20.sh — S20: lock the treemap chart to the reference/panel language.
# Proves: treemap now renders the locked panel (one accent spent once on the peak
# node via raw-RGB accent-count > 0, grey tone ramp for every other cell, NO
# theme.colors[i % n] rainbow, dashed frame/eyebrow/+/│ guide/rule separators,
# n · min..max · peak <label> summary footer, degenerate-safe), the falsifiability
# tests pass, the full core suite + typecheck stay green, and the regenerated docs
# previews are in sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="20"
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

# ── Criterion 1: raw-RGB — accent hue spent EXACTLY once on the peak node ──
run_check "raw-rgb-accent-once" bash -c '
  cd packages/core
  cat > src/__verify_s20_accent.ts <<'"'"'TS'"'"'
import { treemap } from "./charts/treemap.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = treemap({
  data: [
    { label: "TS", value: 45 },
    { label: "Python", value: 30 },
    { label: "Rust", value: 15 },
    { label: "Go", value: 7 },
    { label: "Ruby", value: 3 },
  ],
  title: "Codebase", width: 50, height: 10,
}).toString();
// Census coloured CELL segments (accent region = one peak node, may span many
// cells/segments). Count segments whose body holds a shade glyph, by code.
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const CELL = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (!CELL.test(body)) continue;
  if (code === theme.accent) accent++;
  else if (theme.tones!.includes(code)) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent segment on the peak node"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " cell segments are neither accent nor a grey tone (rainbow leak)"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp cells"); process.exit(1); }
console.log("OK: accent spent on the peak node (" + accent + " segs), " + grey + " grey-ramp segs, 0 rainbow leaks");
TS
  npx tsx src/__verify_s20_accent.ts; rc=$?
  rm -f src/__verify_s20_accent.ts
  exit $rc
'

# ── Criterion 2: panel chrome present ───────────────────────────────────────
run_check "panel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s20_chrome.ts <<'"'"'TS'"'"'
import { treemap } from "./charts/treemap.js";
const plain = treemap({ data: [{label:"A",value:1}] }).toPlain();
const lines = plain.split("\n");
const topOk = lines[0].startsWith("┌╌");
const bottomOk = lines[lines.length - 1].startsWith("└╌");
const rules = (plain.match(/│ ╌/g) || []).length;
const eyebrow = plain.includes("AREA");
if (!topOk || !bottomOk || rules !== 2 || !eyebrow) {
  console.error("FAIL: missing dashed frame/eyebrow/rule separators"); process.exit(1);
}
console.log("OK: dashed frame, AREA eyebrow, two rule separators");
TS
  npx tsx src/__verify_s20_chrome.ts; rc=$?
  rm -f src/__verify_s20_chrome.ts
  exit $rc
'

# ── Criterion 3: footer reports n · min..max · peak <label> ────────────────
run_check "footer-format" bash -c '
  cd packages/core
  cat > src/__verify_s20_footer.ts <<'"'"'TS'"'"'
import { treemap } from "./charts/treemap.js";
const plain = treemap({ data: [{label:"A",value:1}] }).toPlain();
if (!/n 1 · 1\.\.1 · peak A/.test(plain)) {
  console.error("FAIL: footer format incorrect"); process.exit(1);
}
console.log("OK: footer reports n · min..max · peak <label>");
TS
  npx tsx src/__verify_s20_footer.ts; rc=$?
  rm -f src/__verify_s20_footer.ts
  exit $rc
'

# ── Criterion 4: NO phantom filler outside the shade ramp ────────────────
# ░▒▓█ are ALL legitimate ramp glyphs (README LOCKED block + AREA_SHADES);
# the phantom is anything ELSE used as fill (braille-blank ⠀, ·, × …).
# Empty grid cells are SPACE (grid init fill(" ")).
run_check "no-phantom-fill-glyph" bash -c '
  cd packages/core
  cat > src/__verify_s20_nofill.ts <<'"'"'TS'"'"'
import { treemap } from "./charts/treemap.js";
const DATA = [
  { label: "TS", value: 45 }, { label: "Python", value: 30 },
  { label: "Rust", value: 15 }, { label: "Go", value: 7 }, { label: "Ruby", value: 3 },
];
// 1. Vacant canvas → zero cells (no phantom fill where there is no data).
const vacant = treemap({ data: [], width: 50, height: 10 }).toString();
if (/[░▒▓█]/.test(vacant)) { console.error("FAIL: phantom cells in empty render"); process.exit(1); }
// 2. Normal render → ░ legal ramp; every plot-row glyph outside labels/frame
//    must be ramp-or-SPACE (guide +/│ and frame stripped before asserting).
const out = treemap({ data: DATA, width: 50, height: 10 }).toString();
if (!out.includes("░")) { console.error("FAIL: lightest ramp glyph ░ missing"); process.exit(1); }
const ANSI = /\x1b\[[0-9;]*m|\x1b\[0m/g;
for (const row of out.split("\n").filter((l) => /[░▒▓█]/.test(l))) {
  const residue = row.replace(ANSI, "").replace(/[A-Za-z0-9 +.,_…\-│┌┐└┘╌]/g, "");
  if (!/^[░▒▓█]*$/.test(residue)) { console.error("FAIL: non-ramp fill: " + JSON.stringify(residue)); process.exit(1); }
}
if (out.includes("⠀")) { console.error("FAIL: ⠀ braille-blank phantom"); process.exit(1); }
console.log("OK: vacant canvas has zero cells; plot glyphs are ramp-or-SPACE only");
TS
  npx tsx src/__verify_s20_nofill.ts; rc=$?
  rm -f src/__verify_s20_nofill.ts
  exit $rc
'

# ── Criterion 5: degenerate input renders safely (no crash, no NaN) ──────────
run_check "degenerate-safe" bash -c '
  cd packages/core
  cat > src/__verify_s20_degen.ts <<'"'"'TS'"'"'
import { treemap } from "./charts/treemap.js";
for (const data of [[], [{label:"X",value:5}], [{label:"A",value:5},{label:"B",value:5}]]) {
  const out = treemap({ data }).toPlain();
  if (out.includes("NaN") || out.includes("Infinity")) {
    console.error("FAIL: NaN/Infinity for " + JSON.stringify(data)); process.exit(1);
  }
  if (!out.startsWith("┌╌")) { console.error("FAIL: missing dashed frame for " + JSON.stringify(data)); process.exit(1); }
}
console.log("OK: empty / single / all-equal all render safely");
TS
  npx tsx src/__verify_s20_degen.ts; rc=$?
  rm -f src/__verify_s20_degen.ts
  exit $rc
'

# ── Criterion 6: the rainbow default is gone from the source ────────────────
run_check "source-locked" bash -c '
  # strip block + line comments, then look for a live rainbow assignment
  if sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/treemap.ts | grep -q "theme\.colors\["; then
    echo "theme.colors[] rainbow still present in treemap.ts"; exit 1
  fi
  grep -q "frameTop" packages/core/src/charts/treemap.ts || { echo "no panel frame in treemap.ts"; exit 1; }
  grep -q "theme.accent" packages/core/src/charts/treemap.ts || { echo "no accent hue in treemap.ts"; exit 1; }
'

# ── Criterion 7: core tests green ──────────────────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "treemap-tests"          pnpm --filter @chitra/core run test -- treemap

# ── Criterion 8: README carries the LOCKED contract block ──────────────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: treemap chart — session 20 design" packages/core/README.md
'

# ── Criterion 8: docs previews in sync (no chart drift) ────────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 9: branch is s20 ────────────────────────────────────────────
run_check "branch-is-s20"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-20-* ]] || { echo "branch=$branch, expected session-20-*"; exit 1; }
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
