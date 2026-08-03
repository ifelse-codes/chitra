#!/usr/bin/env bash
# Session 09 verify — design-reference language, implemented in the donut chart.
# Proves: the design references exist, the README documents the design style,
# the theme layer carries the mudra one-hue tokens (accent + tone ramp), the
# panel primitives support the dashed frame, and the donut chart renders the
# target language (dashed panel, eyebrow, tone+glyph legend, metric cells,
# status) while keeping the core test suite green.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="09"
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

# 1. Design references exist
run_check "ref-tui-chart"        test -f design-reference/tui-chart.html
run_check "ref-mudra-chart"      test -f design-reference/mudra-chart.html
run_check "ref-mudra-dashboard"  test -f design-reference/mudra-dashboard.html

# 2. README documents the design style
run_check "readme-design-section"      grep -q "## Design Style" packages/core/README.md
run_check "readme-dashed-frame"        grep -qi "dashed panel frame" packages/core/README.md
run_check "readme-one-accent-hue"      grep -qi "one accent hue" packages/core/README.md
run_check "readme-tone-dash-glyph"     grep -qi "tone + dash + glyph" packages/core/README.md
run_check "readme-metric-cells"        grep -qi "metric summary cells" packages/core/README.md
run_check "readme-svg-mirrors"         grep -qi "svg output mirrors" packages/core/README.md

# 3. Theme layer carries mudra one-hue tokens
run_check "theme-accent-field"        grep -q "accent" packages/core/src/types.ts
run_check "theme-tone-field"          grep -q "tones" packages/core/src/types.ts
run_check "theme-grey-tones"          grep -q "GREY_TONES" packages/core/src/themes/index.ts
run_check "theme-accent-default"      grep -q 'accent: h("#8B7CF6")' packages/core/src/themes/index.ts

# 4. Panel primitives support the dashed frame
run_check "panel-dashed-top"          grep -q 'dashed = false' packages/core/src/renderers/panel.ts
run_check "panel-dashed-dash"         grep -q 'dashed ? "╌" : "─"' packages/core/src/renderers/panel.ts

# 5. Donut + pie render the design language (shared ring renderer)
run_check "ring-module-exists"        test -f packages/core/src/charts/ring.ts
run_check "ring-braille-circle"       grep -q "BRAILLE_BITS" packages/core/src/charts/ring.ts
run_check "ring-braille-glyph"        grep -q "braille(dots)" packages/core/src/charts/ring.ts
run_check "ring-accent-largest"       grep -q "indexOf(Math.max" packages/core/src/charts/ring.ts
run_check "ring-tone-ramp"            grep -q "tones\[i % tones.length\]" packages/core/src/charts/ring.ts
run_check "ring-slice-sampler"        grep -q "sliceAt" packages/core/src/charts/ring.ts
run_check "ring-right-legend"         grep -q "renderLegend" packages/core/src/charts/ring.ts
run_check "donut-dashed-frame"        grep -q ', true)' packages/core/src/charts/donut.ts
run_check "donut-eyebrow"             grep -q "eyebrow" packages/core/src/charts/donut.ts
run_check "donut-status-footer"       grep -q "opts.status" packages/core/src/charts/donut.ts
run_check "pie-shared-renderer"       grep -q "buildSlices" packages/core/src/charts/pie.ts
run_check "donut-shared-renderer"     grep -q "buildSlices" packages/core/src/charts/donut.ts
run_check "donut-runs"                bash -c 'echo "import { donut } from \"./packages/core/src/charts/donut.js\"; const o = donut({ data: [30,40,30], labels: [\"X\",\"Y\",\"Z\"], status: \"ok\" }); if (!o.toString().includes(\"Status: ok\")) process.exit(1);" > .donut-smoke.mts; ./packages/core/node_modules/.bin/tsx .donut-smoke.mts >/dev/null 2>&1; rc=$?; rm -f .donut-smoke.mts; exit $rc'
run_check "pie-plain-patterns"        bash -c 'echo "import { pie } from \"./packages/core/src/charts/pie.js\"; const o = pie({ data: [40,30,30], noColor: true }); if (!o.toPlain().includes(\"█\")) process.exit(1);" > .pie-smoke.mts; ./packages/core/node_modules/.bin/tsx .pie-smoke.mts >/dev/null 2>&1; rc=$?; rm -f .pie-smoke.mts; exit $rc'

# 6. Area chart carries the LOCKED language (line = fill's top edge, one accent,
#    auto-scaled range, spaces not blank-braille, dashed panel + eyebrow)
run_check "area-locked-renderer"      grep -q "lineTop" packages/core/src/charts/area.ts
run_check "area-fill-top-edge"        grep -q "fill.fillColumn" packages/core/src/charts/area.ts
run_check "area-spaces-not-blank"     grep -q 'b === 0 ? " "' packages/core/src/charts/area.ts
run_check "area-auto-scale-range"     grep -q "opts.yMin ?? dataMin" packages/core/src/charts/area.ts
run_check "area-accent-peak"          grep -q "peakCap" packages/core/src/charts/area.ts
run_check "area-dashed-frame"         grep -q ", true)" packages/core/src/charts/area.ts
run_check "area-eyebrow"              grep -q "eyebrow" packages/core/src/charts/area.ts
run_check "area-runs"                 bash -c 'echo "import { area } from \"./packages/core/src/charts/area.js\"; const o = area({ data: [12,19,15,28,34,31,42,38,52,47,61,58] }); const s = o.toString(); if (!s.includes(\"┌╌\") || s.includes(\"\u2800\")) process.exit(1);" > .area-smoke.mts; ./packages/core/node_modules/.bin/tsx .area-smoke.mts >/dev/null 2>&1; rc=$?; rm -f .area-smoke.mts; exit $rc'

# 7. Suite stays green
run_check "core-tests-green"          pnpm --filter @chitra/core run test
run_check "core-typecheck"            pnpm --filter @chitra/core run typecheck

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
