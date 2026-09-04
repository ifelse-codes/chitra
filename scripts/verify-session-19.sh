#!/usr/bin/env bash
# verify-session-19.sh — S19: lock the horizontalBar chart to the reference/panel language.
# Proves: horizontalBar now renders the locked panel (one accent spent once on the global-max
# bar via the raw-RGB accent-count==1 assertion, grey tone ramp for every other bar, NO ░
# phantom filler, dashed frame/eyebrow/rotated + value-axis guide/rule separators, per-item
# value labels with the peak in accent, auto-scale + auto-width, degenerate-safe), the
# falsifiability tests pass, the full core suite + typecheck stay green, and the regenerated
# docs previews are in sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="19"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-46s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-46s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
    echo "  ↳ FAIL log: $LOG" >&2
  fi
}

# ── Criterion 8: the core library is green ──────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "horizontalbar-tests"    pnpm --filter @chitra/core run test -- horizontalBar

# ── Criterion 1: raw-RGB — accent hue spent EXACTLY once (global max) ───────────
run_check "raw-rgb-accent-count-1" bash -c '
  cd packages/core
  cat > src/__verify_s19_accent.ts <<'"'"'TS'"'"'
import { horizontalBar } from "./charts/horizontalBar.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = horizontalBar({ data: [12, 47, 23, 8, 35], theme: "default", showAxes: false }).toString();
const cellCodes = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map(m => m[0]);
const accent = cellCodes.filter(c => c === theme.accent).length;
const allRampOrAccent = cellCodes.every(c => c === theme.accent || theme.tones!.includes(c));
const rainbow = theme.colors.filter(c => c !== theme.accent && !theme.tones!.includes(c));
const leak = cellCodes.some(c => rainbow.includes(c));
if (accent !== 1) { console.error("FAIL: accent count = " + accent + " (expected 1)"); process.exit(1); }
if (!allRampOrAccent) { console.error("FAIL: a bar cell is neither accent nor a grey tone"); process.exit(1); }
if (leak) { console.error("FAIL: a theme.colors rainbow hue leaked onto a bar"); process.exit(1); }
console.log("OK: raw-RGB accent count == 1, every other bar on the grey ramp, no rainbow leak");
TS
  npx tsx src/__verify_s19_accent.ts; rc=$?
  rm -f src/__verify_s19_accent.ts
  exit $rc
'

# ── Criterion 3: NO ░ phantom filler in the rendered output (blocks + ascii) ────
run_check "no-phantom-fill-glyph"  bash -c '
  cd packages/core
  cat > src/__verify_s19_nofill.ts <<'"'"'TS'"'"'
import { horizontalBar } from "./charts/horizontalBar.js";
const blocks = horizontalBar({ data: [12, 47, 23, 8, 35] }).toString();
const ascii  = horizontalBar({ data: [12, 47, 23, 8, 35], renderer: "ascii" }).toString();
if (blocks.includes("░") || ascii.includes("░")) { console.error("FAIL: found ░ phantom filler"); process.exit(1); }
console.log("OK: no ░ in blocks or ascii output — empty cells are spaces");
TS
  npx tsx src/__verify_s19_nofill.ts; rc=$?
  rm -f src/__verify_s19_nofill.ts
  exit $rc
'

# ── Criterion 6: degenerate input renders safely (no crash, no NaN) ─────────────
run_check "degenerate-safe"        bash -c '
  cd packages/core
  cat > src/__verify_s19_degen.ts <<'"'"'TS'"'"'
import { horizontalBar } from "./charts/horizontalBar.js";
for (const data of [[], [42], [5, 5, 5]]) {
  const out = horizontalBar({ data }).toPlain();
  if (out.includes("NaN") || out.includes("Infinity")) { console.error("FAIL: NaN/Infinity for " + JSON.stringify(data)); process.exit(1); }
  if (!out.startsWith("┌╌")) { console.error("FAIL: missing dashed frame for " + JSON.stringify(data)); process.exit(1); }
}
console.log("OK: empty / single / all-equal all render safely");
TS
  npx tsx src/__verify_s19_degen.ts; rc=$?
  rm -f src/__verify_s19_degen.ts
  exit $rc
'

# ── Criterion 1/3: the rainbow + ░ default are gone from the source ─────────────
run_check "source-locked"          bash -c '
  if grep -q "theme.colors\[" packages/core/src/charts/horizontalBar.ts; then
    echo "theme.colors[] rainbow still present in horizontalBar.ts"; exit 1
  fi
  grep -q "frameTop" packages/core/src/charts/horizontalBar.ts || { echo "no panel frame in horizontalBar.ts"; exit 1; }
  grep -q "theme.accent" packages/core/src/charts/horizontalBar.ts || { echo "no accent hue in horizontalBar.ts"; exit 1; }
'

# ── Criterion 7: README carries the LOCKED contract block ───────────────────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: horizontalBar chart — session 19 design" packages/core/README.md
'

# ── Criterion 8: docs previews in sync (no chart drift) ─────────────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 8: the demo re-runs green ─────────────────────────────────────────
run_check "demo-runs-green"        bash scripts/demo-session-19.sh

# ── Branch is s19 ───────────────────────────────────────────────────────────────
run_check "branch-is-s19"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-19-* ]] || { echo "branch=$branch, expected session-19-*"; exit 1; }
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-46s %s\n' "STEP" "RESULT"
printf '%-46s %s\n' "----------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
