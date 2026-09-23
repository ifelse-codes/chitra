#!/usr/bin/env bash
# S34 demo — GTM README: root front door, honest facts, real renders, MIT LICENSE.
# Every summary row is computed, not printed — the demo exits non-zero on any fail.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; RESET="\033[0m"
TSX=packages/core/node_modules/.bin/tsx

PASS=0; FAIL=0; RESULTS=()
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }
record() { if [ "$2" = 0 ]; then RESULTS+=("$(printf '%-36s %s' "$1" PASS)"); PASS=$((PASS+1));
           else RESULTS+=("$(printf '%-36s %s' "$1" FAIL)"); FAIL=$((FAIL+1)); fi; }

header "Session 34 Demo — GTM README"

header "1 · Before → after: the front door"
label "before (main): no root README"
if git ls-tree main --name-only -- README.md 2>/dev/null | grep -q .; then
  echo "  README.md existed on main"; before=1; else echo "  (none — GitHub landing page was empty)"; before=0; fi
label "after (this branch): a landing page"
printf "  %s\n" "$(grep -m1 '^\*\*Terminal charts' README.md)"
printf "  %s lines · %s words\n" "$(wc -l < README.md | tr -d ' ')" "$(wc -w < README.md | tr -d ' ')"
grep -nE '^## ' README.md | sed 's/^/  /'
rc=0; [ "$before" = 0 ] && [ -f README.md ] || rc=1; record "root README created" "$rc"

header "2 · The renders in the README are real library output (whole block)"
for spec in \
  'line|line({ data: [12, 19, 14, 27, 22, 34, 29, 41], title: "Weekly active users", noColor: true })' \
  'horizontalBar|horizontalBar({ data: [82, 64, 51, 37, 22], labels: ["TypeScript", "Rust", "Go", "Python", "Shell"], title: "Repo languages", noColor: true })' \
  'sparkline|sparkline({ data: [3, 5, 4, 8, 6, 11, 9, 13, 12, 15], label: "p99 latency", noColor: true })'; do
  name="${spec%%|*}"; call="${spec#*|}"
  out="$("$TSX" -e "import { $name } from \"./packages/core/src/index.ts\"; process.stdout.write($call.toPlain())" 2>/dev/null)"
  first="$(printf '%s\n' "$out" | head -1)"; n="$(printf '%s\n' "$out" | grep -c .)"
  start="$(grep -nF -- "$first" README.md | head -1 | cut -d: -f1)"
  block="$(sed -n "${start:-1},$(( ${start:-1} + n - 1 ))p" README.md)"
  if [ -n "$start" ] && [ "$block" = "$out" ]; then
    printf "  ${GREEN}✓${RESET} %-14s %s lines byte-matched\n" "$name" "$n"; rc=0
  else
    printf "  ${RED}✗${RESET} %-14s drift\n" "$name"; rc=1
  fi
  record "render $name is real (whole block)" $rc
done

header "3 · AI-builder lane leads, terminal lane follows"
a=$(grep -n '## Built for AI agents' README.md | cut -d: -f1)
t=$(grep -n '## Built for terminals' README.md | cut -d: -f1)
echo "  AI agents  line ${a:-?}   terminals  line ${t:-?}"
rc=0; [ -n "$a" ] && [ -n "$t" ] && [ "$a" -lt "$t" ] || rc=1; record "AI lane before terminal lane" "$rc"

header "4 · Honest facts, cross-checked against the source"
charts=$("$TSX" -e 'import * as c from "./packages/core/src/index.ts"; const n=["bar","line","area","sparkline","histogram","scatter","pie","donut","heatmap","progress","gauge","horizontalBar","timeline","radar","boxplot","waterfall","funnel","candlestick","treemap","sankey"]; console.log(n.filter(x=>typeof (c as any)[x]==="function").length)' 2>/dev/null)
themes=$("$TSX" -e 'import { themes } from "./packages/core/src/index.ts"; console.log(Object.keys(themes).length)' 2>/dev/null)
tests=$(pnpm --filter @chitra/core run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+' | head -1)
deps=$(grep -c '"dependencies"' packages/core/package.json || true)
stale=$(grep -ciE '134 (tests|passing)' README.md || true)
printf '  %-22s %s (README badge %s)\n' "chart types" "$charts" "$(grep -oE 'charts-[0-9]+' README.md | head -1)"
printf '  %-22s %s (README "%s")\n' "themes" "$themes" "$(grep -oE '[0-9]+ themes' README.md | head -1)"
printf '  %-22s %s (README badge %s)\n' "tests passing" "$tests" "$(grep -oE 'tests-[0-9]+' README.md | head -1)"
printf '  %-22s %s (README "%s")\n' "renderers" "3" "$(grep -oE '[0-9]+ renderers' README.md | head -1)"
printf '  %-22s %s\n' "runtime dependencies" "$deps"
printf '  %-22s %s (want 0)\n' "stale '134' claim" "$stale"
rc=0; { [ "$charts" = 20 ] && [ "$themes" = 7 ] && [ "$tests" = 452 ] && [ "$deps" = 0 ] && [ "$stale" = 0 ]; } || rc=1
record "facts match source (20/7/452/0)" "$rc"

header "5 · MIT LICENSE is now real (repo root + the published package)"
grep -m1 'MIT License' LICENSE | sed 's/^/  /'
grep -m1 'Copyright' LICENSE | sed 's/^/  /'
printf "  packages/core/LICENSE  %s\n" "$(test -f packages/core/LICENSE && echo present || echo MISSING)  (ships via files:[\"LICENSE\"])"
rc=0; { grep -q 'MIT License' LICENSE && grep -q 'Permission is hereby granted' LICENSE && test -f packages/core/LICENSE; } || rc=1
record "MIT LICENSE present (root + package)" "$rc"

header "Summary"
printf '%-36s %s\n' "ITEM" "RESULT"
printf '%-36s %s\n' "------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
if [ "$FAIL" -eq 0 ]; then ok "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else no "RED ($PASS pass, $FAIL fail)"; exit 1; fi
