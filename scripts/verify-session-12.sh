#!/usr/bin/env bash
# verify-session-12.sh — S12: bar chart reference-locked to the shared design language.
# Proves: the bar chart carries one accent + grey tone ramp (no rainbow), a dashed panel
# frame + eyebrow row + + y-guide top + + x-tick row, per-series MIN/MAX/AVG/LAST summary
# rows, and the three locked families (circular, area, line) are byte-identical to main.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="12"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-44s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-44s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
    echo "  ↳ FAIL log: $LOG" >&2
  fi
}

# ── Criterion 1: one accent + grey tone ramp — no rainbow ─────
run_check "bar-no-rainbow-colors"  bash -c '
  ! grep -q "theme\.colors\[" packages/core/src/charts/bar.ts
'
run_check "bar-accent-once"        grep -q "maxSi && bi === maxBi" packages/core/src/charts/bar.ts
run_check "bar-tone-ramp"          grep -q "toneOrder" packages/core/src/charts/bar.ts

# ── Criterion 2: dashed frame + eyebrow + + y-guide + + x-ticks ─
run_check "bar-dashed-frame"       grep -q 'noColor, true)' packages/core/src/charts/bar.ts
run_check "bar-eyebrow-row"        grep -q 'eyebrow' packages/core/src/charts/bar.ts
run_check "bar-yguide-plus"        bash -c 'grep -q '"'"'row === 0 ? "+" : "│"'"'"' packages/core/src/charts/bar.ts'
run_check "bar-xtick-plus"         bash -c 'grep -q '"'"'cells\[mid\] = "+"'"'"' packages/core/src/charts/bar.ts'
run_check "bar-frame-rule"         grep -q "frameRule" packages/core/src/charts/bar.ts

# ── Criterion 3: per-series summary rows ──────────────────────
run_check "bar-summary-min"        bash -c 'grep -q "formatNumber(stats.min)" packages/core/src/charts/bar.ts'
run_check "bar-summary-max"        bash -c 'grep -q "formatNumber(stats.max)" packages/core/src/charts/bar.ts'
run_check "bar-summary-avg"        bash -c 'grep -q "formatNumber(stats.avg)" packages/core/src/charts/bar.ts'
run_check "bar-summary-last"       bash -c 'grep -q "formatNumber(stats.last)" packages/core/src/charts/bar.ts'

# ── Criterion 3: smoke test — run bar and inspect output ──────
run_check "bar-smoke-single-series" bash -c 'cat > .bar-smoke.mts <<'"'"'EOF'"'"'
import { bar } from "./packages/core/src/charts/bar.js";
const s = bar({
  data: [42, 67, 38, 55, 72],
  labels: ["Jan","Feb","Mar","Apr","May"],
  title: "Deploys",
}).toString();
if (!s.includes("┌╌"))            { console.error("no dashed frame top"); process.exit(1); }
if (!s.includes("└╌"))            { console.error("no dashed frame bottom"); process.exit(2); }
if (!s.includes("VALUES"))         { console.error("no eyebrow row"); process.exit(3); }
if (!/\+/.test(s))                 { console.error("no + tick"); process.exit(4); }
if (!s.includes("min"))            { console.error("no min in summary"); process.exit(5); }
if (!s.includes("max"))            { console.error("no max in summary"); process.exit(6); }
if (!s.includes("avg"))            { console.error("no avg in summary"); process.exit(7); }
if (!s.includes("last"))           { console.error("no last in summary"); process.exit(8); }
EOF
./packages/core/node_modules/.bin/tsx .bar-smoke.mts; rc=$?; rm -f .bar-smoke.mts; exit $rc'

run_check "bar-smoke-multi-series" bash -c 'cat > .bar-multi.mts <<'"'"'EOF'"'"'
import { bar } from "./packages/core/src/charts/bar.js";
const s = bar({
  data: [[10, 20, 30], [15, 25, 35]],
  seriesLabels: ["Alpha", "Beta"],
  title: "Multi",
}).toString();
if (!s.includes("Alpha"))          { console.error("no Alpha in output"); process.exit(1); }
if (!s.includes("Beta"))           { console.error("no Beta in output"); process.exit(2); }
if (!s.includes("┌╌"))            { console.error("no dashed frame"); process.exit(3); }
const minCount = (s.match(/min /g) || []).length;
if (minCount < 2)                  { console.error("expected ≥2 min rows, got " + minCount); process.exit(4); }
EOF
./packages/core/node_modules/.bin/tsx .bar-multi.mts; rc=$?; rm -f .bar-multi.mts; exit $rc'

run_check "bar-smoke-ascii-renderer" bash -c 'cat > .bar-ascii.mts <<'"'"'EOF'"'"'
import { bar } from "./packages/core/src/charts/bar.js";
const s = bar({ data: [10, 20, 30], renderer: "ascii" }).toString();
if (!s.includes("┌╌") || !s.includes("min")) process.exit(1);
EOF
./packages/core/node_modules/.bin/tsx .bar-ascii.mts; rc=$?; rm -f .bar-ascii.mts; exit $rc'

# Regression check (S12 cold review REJECT finding): the panel used to size itself exactly to
# fit the summary text, leaving zero room for the spark, so this exact demo example — shipped
# as evidence in session-12-summary.md — silently never showed a spark glyph. Real execute-based
# check, not a source grep: runs the exact example and asserts a spark glyph is present.
run_check "bar-summary-spark-not-dead" bash -c 'cat > .bar-spark.mts <<'"'"'EOF'"'"'
import { bar } from "./packages/core/src/charts/bar.js";
const s = bar({
  data: [42, 67, 38, 55, 72],
  labels: ["Jan","Feb","Mar","Apr","May"],
  title: "Monthly Deploys",
}).toString();
if (!/[▁▂▃▄▅▆▇█]/.test(s.split("\n").find(l => l.includes("last")) ?? "")) {
  console.error("sparkline glyph absent from summary row — dead under default sizing");
  process.exit(1);
}
EOF
./packages/core/node_modules/.bin/tsx .bar-spark.mts; rc=$?; rm -f .bar-spark.mts; exit $rc'

run_check "bar-smoke-no-color" bash -c 'cat > .bar-nc.mts <<'"'"'EOF'"'"'
import { bar } from "./packages/core/src/charts/bar.js";
const s = bar({ data: [1, 2, 3], noColor: true }).toString();
if (s.includes("\x1b[")) { console.error("ANSI codes found in noColor output"); process.exit(1); }
EOF
./packages/core/node_modules/.bin/tsx .bar-nc.mts; rc=$?; rm -f .bar-nc.mts; exit $rc'

# ── Criterion 4: locked families unchanged from main ─────────
run_check "circular-unchanged"     bash -c '
  changed=$(git diff main -- packages/core/src/charts/pie.ts packages/core/src/charts/donut.ts 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "circular charts changed: $changed lines"; exit 1; }
'
run_check "area-unchanged"         bash -c '
  changed=$(git diff main -- packages/core/src/charts/area.ts 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "area.ts changed: $changed lines"; exit 1; }
'
run_check "line-unchanged"         bash -c '
  changed=$(git diff main -- packages/core/src/charts/line.ts packages/core/src/charts/line-model.ts 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "line.ts / line-model.ts changed: $changed lines"; exit 1; }
'

# ── Criterion 5: README LOCKED section ───────────────────────
run_check "readme-bar-locked"      grep -q "LOCKED: bar chart" packages/core/README.md
run_check "readme-bar-accent-once" grep -qi "spent once" packages/core/README.md
run_check "readme-bar-xticks"      grep -qi "x-axis tick" packages/core/README.md
run_check "readme-bar-summary"     grep -qi "MIN / MAX / AVG / LAST" packages/core/README.md
run_check "knowledge-bar-locked"   grep -q "Bar chart locked" .ai/KNOWLEDGE.md

# ── Criterion 6: tests + typecheck ───────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck

# ── Criterion 7: branch is s12 ───────────────────────────────
run_check "branch-is-s12"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-12-* ]] || { echo "branch=$branch, expected session-12-*"; exit 1; }
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-44s %s\n' "STEP" "RESULT"
printf '%-44s %s\n' "--------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
