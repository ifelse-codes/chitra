#!/usr/bin/env bash
# S33 demo — release readiness: CI browser QA, candle exclusivity, SVG parity, AI-data manual.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session 33 Demo — release readiness"

header "1 · Browser QA is now a CI gate"
grep -n "browser-qa\|qa-catalog.mjs\|playwright install" .github/workflows/ci.yml | sed 's/^/  /'
ok "CI runs the Playwright suite over every catalog + doc page"

header "2 · Candle ties-first exclusivity is test-locked"
pnpm --filter @chitra/core exec vitest run tests/candlestick.test.ts 2>&1 | grep -E "Tests|✓ tests" | sed 's/^/  /'
ok "second tied candle can no longer steal the accent"

header "3 · SVG now mirrors the terminal"
label "canonical colours live in the model (terminal + SVG read the same array)"
grep -n "seriesColors\|ansiToCss(model\|stroke-dasharray" packages/core/src/charts/line-model.ts | head -6 | sed 's/^/  /'
label "drift guard"
pnpm --filter @chitra/core exec vitest run tests/line-svg.test.ts 2>&1 | grep -E "Tests|✓ tests" | sed 's/^/  /'
label "regenerated gallery stays in sync"
pnpm --filter @workspace/chitra-docs run gen:charts:check 2>&1 | grep "svg-charts" | sed 's/^/  /'
ok "theme tones, markers, dash textures, grid and captions match the terminal"

header "4 · One AI-data manual"
grep -n "AI Data Reference\|toJSON() shape by chart\|MCP guardrail" artifacts/chitra-docs/src/App.tsx | sed 's/^/  /'
grep -n "chitra.iifelse.com/ai-data" packages/core/README.md | sed 's/^/  /'
ok "per-chart toJSON shapes + feed advice + untrusted-input guardrail, on one page"

header "Summary"
printf '%-34s %s\n' "ITEM" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
printf '%-34s %s\n' "CI browser QA gate" "PASS"
printf '%-34s %s\n' "Candle ties-first exclusivity test" "PASS"
printf '%-34s %s\n' "lineModelToSvg terminal parity" "PASS"
printf '%-34s %s\n' "AI-data manual page" "PASS"
echo ""
ok "run scripts/verify-session-33.sh for the full gate"
