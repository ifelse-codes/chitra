#!/usr/bin/env bash
# Session 09 verify — design-reference language.
# Proves: the README Design Style section documents the language, the direction
# is the mudra one-hue contract, the donut demo renders the target look with
# chitra's own primitives (no lib changes), and the design references exist.

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

DEMO_OUT() { ./packages/core/node_modules/.bin/tsx scripts/src/demo09-donut.ts 2>/dev/null; }

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

# 3. Demo source renders the target look (mudra one-hue)
run_check "demo-src-exists"            test -f scripts/src/demo09-donut.ts
run_check "demo-dashed-frame"          grep -q '┌╌' scripts/src/demo09-donut.ts
run_check "demo-tone-ramp"             grep -q 'tones:' scripts/src/demo09-donut.ts
run_check "demo-accent-on-primary"     grep -q 'primary ? h(TOKENS.frame)' scripts/src/demo09-donut.ts
run_check "demo-glyph-legend"          grep -q 'GLYPHS' scripts/src/demo09-donut.ts
run_check "demo-metric-cells"          grep -q 'metricCells' scripts/src/demo09-donut.ts
run_check "demo-runs-mudra"            bash -c 'DEMO_OUT() { ./packages/core/node_modules/.bin/tsx scripts/src/demo09-donut.ts 2>/dev/null; }; DEMO_OUT | grep -q "TARGET A — mudra"'

# 4. No library code changed — design language is demoed, not yet implemented
run_check "core-unchanged"             git diff --quiet HEAD~1 -- packages/core/src
run_check "no-implementation-yet"      bash -c '! grep -rl "TOKENS" packages/core/src >/dev/null'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
