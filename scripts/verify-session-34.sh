#!/usr/bin/env bash
# S34 — GTM README: root front door, honest facts, real renders, MIT LICENSE.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-34/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

README=README.md
CORE_PKG=packages/core/package.json
TSX=packages/core/node_modules/.bin/tsx

# ── Req 1: root README exists with the GTM spine ────────────────
run_check "root-readme-exists"   test -f "$README"
run_check "positioning-line"     bash -c "grep -q 'Terminal charts for CLIs and agents.' $README"
run_check "hero-badges"          bash -c "grep -q 'badge/npm' $README && grep -q 'license-MIT' $README && grep -q 'dependencies-0' $README && grep -q 'tests-452' $README"
for s in "Why chitra" "Install" "Quickstart" "Built for AI agents" "Built for terminals" "Chart gallery" "Documentation" "License"; do
  run_check "section-$(echo "$s" | tr ' ' '-')" bash -c "grep -q '## $s' $README"
done

# ── Req 2: real renders, drift-checked against the library ──────
# Generate each chart from source and require the README to embed the EXACT
# contiguous block, byte-for-byte — not just its footer caption. A fabricated
# chart body with a copied caption fails.
check_render() {
  local NAME="$1" EXPR="$2" out first n start block
  local LOG="$ARTIFACTS/${NAME}.log"
  out="$("$TSX" -e "$EXPR" 2>/dev/null)"
  first="$(printf '%s\n' "$out" | head -1)"
  n="$(printf '%s\n' "$out" | grep -c .)"
  start="$(grep -nF -- "$first" "$README" | head -1 | cut -d: -f1)"
  if [ -z "$start" ]; then
    echo "block start not found in README: [$first]" > "$LOG"
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1)); return
  fi
  block="$(sed -n "${start},$((start+n-1))p" "$README")"
  if diff <(printf '%s\n' "$out") <(printf '%s\n' "$block") > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    { echo "README block ($n lines from $start) differs from generated render:"; cat "$LOG"; } > "$LOG"
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}
check_render "render-line-is-real" 'import { line } from "./packages/core/src/index.ts"; process.stdout.write(line({ data: [12, 19, 14, 27, 22, 34, 29, 41], title: "Weekly active users", noColor: true }).toPlain())'
check_render "render-hbar-is-real" 'import { horizontalBar } from "./packages/core/src/index.ts"; process.stdout.write(horizontalBar({ data: [82, 64, 51, 37, 22], labels: ["TypeScript", "Rust", "Go", "Python", "Shell"], title: "Repo languages", noColor: true }).toPlain())'
check_render "render-spark-is-real" 'import { sparkline } from "./packages/core/src/index.ts"; process.stdout.write(sparkline({ data: [3, 5, 4, 8, 6, 11, 9, 13, 12, 15], label: "p99 latency", noColor: true }).toPlain())'

# ── Req 3: AI-builder lane leads, terminal lane follows ─────────
run_check "ai-section-before-term" bash -c "awk '/## Built for AI agents/{a=NR} /## Built for terminals/{t=NR} END{exit !(a<t)}' $README"
run_check "ai-export-methods"     bash -c "grep -q 'toContent()' $README && grep -q 'toJSON()' $README && grep -q 'toPlain()' $README"
run_check "ai-data-link"          bash -c "grep -q 'chitra.iifelse.com/ai-data' $README"
run_check "mcp-handler"           bash -c "grep -q 'server.tool' $README"

# ── Req 4: gallery + navigation ─────────────────────────────────
run_check "docs-link"             bash -c "grep -q 'chitra.iifelse.com' $README"
run_check "api-ref-link"          bash -c "grep -q 'packages/core/README.md' $README"
run_check "gallery-20-charts"     bash -c "n=0; for c in line area timeline candlestick bar horizontal scatter radar histogram boxplot heatmap pie donut treemap funnel sankey waterfall gauge progress sparkline; do grep -qi \"\$c\" $README && n=\$((n+1)); done; [ \$n -eq 20 ]"

# ── Req 5: honest, verifiable facts ─────────────────────────────
run_check "chart-export-count-20" bash -c "$TSX -e 'import * as c from \"./packages/core/src/index.ts\"; const n=[\"bar\",\"line\",\"area\",\"sparkline\",\"histogram\",\"scatter\",\"pie\",\"donut\",\"heatmap\",\"progress\",\"gauge\",\"horizontalBar\",\"timeline\",\"radar\",\"boxplot\",\"waterfall\",\"funnel\",\"candlestick\",\"treemap\",\"sankey\"]; const k=n.filter(x=>typeof (c as any)[x]===\"function\").length; if(k!==20){console.error(\"charts=\"+k);process.exit(1)}' 2>/dev/null"
run_check "theme-count-7"         bash -c "$TSX -e 'import { themes } from \"./packages/core/src/index.ts\"; const k=Object.keys(themes).length; if(k!==7){console.error(\"themes=\"+k);process.exit(1)}' 2>/dev/null"
run_check "zero-deps"             bash -c "! grep -q '\"dependencies\"' $CORE_PKG"
run_check "readme-says-20-charts" bash -c "grep -q 'charts: 20' $README && grep -q '20 chart types' $README"
run_check "readme-says-7-themes"  bash -c "grep -q '7 themes' $README"
run_check "readme-says-3-renders" bash -c "grep -q '3 renderers' $README"
run_check "renderer-source-3"     bash -c "test -f packages/core/src/renderers/braille.ts && test -f packages/core/src/renderers/blocks.ts && test -f packages/core/src/renderers/ascii.ts"
run_check "test-count-matches"    bash -c "out=\$(pnpm --filter @chitra/core run test 2>&1); echo \"\$out\" | grep -qE 'Tests +452 passed' && grep -q 'tests: 452 passing' $README"
run_check "core-typecheck"        pnpm --filter @chitra/core run typecheck
run_check "no-stale-test-count"   bash -c "! grep -qiE '134 (tests|passing)' $README"
run_check "no-false-stable-claim" bash -c "! grep -q 'v0.1.0 — stable' $README && grep -q 'not on npm yet' $README"

# ── Req 6: MIT LICENSE ──────────────────────────────────────────
run_check "license-exists"        test -f LICENSE
run_check "license-is-mit"        bash -c "grep -q 'MIT License' LICENSE && grep -q 'Permission is hereby granted' LICENSE"
run_check "readme-links-license"  bash -c "grep -q '(LICENSE)' $README"

# ── Local links resolve ─────────────────────────────────────────
run_check "link-core-readme"      test -f packages/core/README.md
run_check "link-contributing"     test -f CONTRIBUTING.md

# ── Branch discipline ───────────────────────────────────────────
run_check "branch-is-s34"         bash -c '[[ "$(git rev-parse --abbrev-ref HEAD)" == session-34-* ]]'

( cd ".ai/verify/session-34" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 34 Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
