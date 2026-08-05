#!/usr/bin/env bash
# Session 10 verify — line chart rebuilt to carry the LOCKED Session 09 design
# language (the area/circular look). Proves: the README documents the LOCKED
# line contract, the options/model auto-scale to the data, line.ts renders the
# dashed panel + eyebrow + tone-ramp curve with the accent spent once on the
# peak + footer max, empty cells are spaces (never blank-braille), the ascii
# renderer still works for the docs NIFTY preview, and the whole suite stays
# green (core tests · typecheck · docs chart-drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="10"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-40s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-40s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# 1. README documents the LOCKED line contract
run_check "readme-line-locked"      grep -q "LOCKED: line chart" packages/core/README.md
run_check "readme-line-dashed"      grep -qi "dashed frame" packages/core/README.md
run_check "readme-line-accent-once" grep -qi "one accent, spent once" packages/core/README.md
run_check "readme-line-blank-braille" grep -q "U+2800" packages/core/README.md

# 2. Options + shared model carry the locked semantics
run_check "types-line-eyebrow"      grep -q "eyebrow?: string" packages/core/src/types.ts
run_check "model-auto-scale"        grep -q "options.yMin ?? min" packages/core/src/charts/line-model.ts
run_check "model-tick-clamp"        grep -q "t >= yMin" packages/core/src/charts/line-model.ts

# 3. line.ts renders the LOCKED language
run_check "line-dashed-frame"       grep -q ', true)' packages/core/src/charts/line.ts
run_check "line-eyebrow"            grep -q "opts.eyebrow" packages/core/src/charts/line.ts
run_check "line-spaces-not-blank"   grep -q 'toLines(" ")' packages/core/src/charts/line.ts
run_check "line-accent-peak"        grep -q "primaryPeakCap" packages/core/src/charts/line.ts
run_check "line-accent-once"        grep -q "if (inCap)" packages/core/src/charts/line.ts
run_check "line-footer-max-accent"  grep -q 'max \${formatNumber' packages/core/src/charts/line.ts
run_check "line-legend-glyph"       grep -q '\${dashCharsFor(i)}\${s.marker}' packages/core/src/charts/line.ts
run_check "line-multi-dash"         grep -q 'markerCells' packages/core/src/charts/line.ts
run_check "line-thin-line"          grep -q 'plotLineOnBrailleCanvas' packages/core/src/charts/line.ts
run_check "line-gridlines"          grep -q 'theme.grid ?? theme.axis' packages/core/src/charts/line.ts
run_check "line-summary-avg"        grep -q 'avg \${formatNumber' packages/core/src/charts/line.ts

# 4. line runs with the LOCKED look (braille + ascii + multi-series)
run_check "line-locked-smoke"       bash -c 'cat > .line-locked.mts <<'"'"'EOF'"'"'
import { line } from "./packages/core/src/charts/line.js";
const o = line({
  data: [12, 19, 15, 28, 34, 31, 42, 38, 52, 47, 61, 58],
  title: "REVENUE",
  eyebrow: "Monthly · Trend",
  status: "ok",
});
const s = o.toString();
if (!s.includes("┌╌") || !s.includes("REVENUE") || !s.includes("MONTHLY · TREND")) process.exit(1);
if (s.includes("\u2800")) process.exit(2);
if (!o.toPlain().includes("Status: ok")) process.exit(3);
EOF
./packages/core/node_modules/.bin/tsx .line-locked.mts >/dev/null 2>&1; rc=$?; rm -f .line-locked.mts; exit $rc'
run_check "line-ascii-smoke"        bash -c 'cat > .line-ascii.mts <<'"'"'EOF'"'"'
import { line } from "./packages/core/src/charts/line.js";
const o = line({
  data: Array.from({ length: 50 }, (_, i) => 23800 + Math.round(Math.sin(i / 8) * 300) + i),
  labels: ["7D Ago", "6D Ago", "5D Ago", "4D Ago", "3D Ago", "2D Ago", "1D Ago", "Now"],
  title: "NIFTY 50 INDEX",
  width: 72,
  height: 18,
  renderer: "ascii",
});
const s = o.toString();
if (!s.includes("┌╌") || !s.includes("max")) process.exit(1);
EOF
./packages/core/node_modules/.bin/tsx .line-ascii.mts >/dev/null 2>&1; rc=$?; rm -f .line-ascii.mts; exit $rc'
run_check "line-multi-smoke"        bash -c 'cat > .line-multi.mts <<'"'"'EOF'"'"'
import { line } from "./packages/core/src/charts/line.js";
const p = line({ data: [[1, 2, 3, 4], [4, 3, 2, 1]], seriesLabels: ["Up", "Down"] }).toPlain();
if (!p.includes("Up") || !p.includes("Down") || !p.includes("┌╌")) process.exit(1);
EOF
./packages/core/node_modules/.bin/tsx .line-multi.mts >/dev/null 2>&1; rc=$?; rm -f .line-multi.mts; exit $rc'

# 5. Suite stays green
run_check "core-tests-green"        pnpm --filter @chitra/core run test
run_check "core-typecheck"          pnpm --filter @chitra/core run typecheck
run_check "docs-drift"              pnpm --filter @workspace/chitra-docs run gen:charts:check

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
