#!/usr/bin/env bash
# demo-session-24.sh — S24: docs-site grouped chart nav (no status badges).
# Cumulative: the catalog sidebar moves from one flat history-ordered list to six
# semantic groups with collapsible headers. Lock state stays internal — the nav
# carries zero badges.
#
# Every case reads the REAL generated data (no fixtures), and the group claims
# are FALSIFIABLE checks that go red on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="24"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }

DEMO_FAIL=0
scorecard=()
record() { # name  PASS|FAIL
  scorecard+=("$(printf '%-40s %s' "$1" "$2")")
  [ "$2" = "PASS" ] || DEMO_FAIL=1
}

gen_tsx() { # run a snippet against the REAL docs sources; never swallow errors
  local body="$1"
  local tmp="artifacts/chitra-docs/src/__demo_s24_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd artifacts/chitra-docs && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s24_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — grouped chart nav (lock state stays internal)"
printf "${DIM}  (six semantic groups · collapsible + persisted + auto-expanded · zero status badges)${RESET}\n"

# ── BEFORE → AFTER ──────────────────────────────────────────────────────────
label "BEFORE (git main — one flat history-ordered list, no groups, no badges)"
BEFORE="$(git show main:artifacts/chitra-docs/src/data/charts.ts | grep -o 'id: "[a-zA-Z]*"' | sed 's/id: //;s/"//g' | paste -sd' · ' -)"
printf "${DIM}  Chart Types: %s${RESET}\n" "$BEFORE"

label "AFTER (live render of the REAL generated CHARTS as the sidebar shows them)"
AFTER="$(gen_tsx 'import { CHARTS } from "./data/charts.js";
const GROUPS = ["Trend & time","Comparison","Distribution & density","Part-to-whole","Flow & accumulation","Single value & progress"];
// same reader-facing order as the sidebar renderer (CHART_ORDER in App.tsx)
const ORDER = ["line","area","timeline","candlestick","bar","horizontalBar","scatter","radar","histogram","boxplot","heatmap","pie","donut","treemap","funnel","sankey","waterfall","gauge","progress","sparkline"];
const byId: Record<string, (typeof CHARTS)[number]> = Object.fromEntries(CHARTS.map((c) => [c.id, c]));
for (const g of GROUPS) {
  const items = ORDER.map((id) => byId[id]).filter((c) => c.group === g);
  console.log("▾ " + g + " (" + items.length + ")");
  for (const c of items) console.log("    " + c.id);
}')" 
printf '%s\n' "$AFTER"

# ── Falsifiable check: six groups, exact membership ─────────────────────────
label "Check: 20 charts in exactly six generated groups"
GROUPS_CHECK="$(gen_tsx 'import { CHARTS } from "./data/charts.js";
const groups = [...new Set(CHARTS.map((c) => c.group))];
console.log(CHARTS.length + " " + groups.length);')"
if [ "$GROUPS_CHECK" = "20 6" ]; then
  ok "20 charts · 6 groups"; record "six-groups" PASS
else no "got: $GROUPS_CHECK"; record "six-groups" FAIL; fi

# ── Falsifiable check: zero badge vocabulary anywhere near the nav ──────────
label "Check: no badges — not in generated data, not in the renderer, not in styles"
NOBADGE="$(gen_tsx 'import { readFileSync } from "node:fs";
import { CHARTS } from "./data/charts.js";
let bad = "";
for (const c of CHARTS) {
  for (const k of ["locked", "trio", "inFlight"]) {
    if ((c as Record<string, unknown>)[k] !== undefined) bad += " data:" + c.id + "." + k;
  }
}
for (const f of ["src/App.tsx", "src/index.css", "scripts/generate-charts.ts", "scripts/chart-specs.ts"]) {
  const src = readFileSync(f, "utf8");
  const hits = src.split("\n").filter((l) =>
    /badge\.(locked|trio|inflight)|locked:\s*(true|false)|trio:\s*(true|false)|inFlight:/.test(l));
  if (hits.length > 0) bad += " src:" + f;
}
console.log(bad === "" ? "CLEAN" : "BAD:" + bad);')"
if [ "$NOBADGE" = "CLEAN" ]; then
  ok "20 grouped rows · zero badge vocabulary"; record "no-badges" PASS
else no "badge remnants:$NOBADGE"; record "no-badges" FAIL; fi

# ── Behavior wiring present ─────────────────────────────────────────────────
label "Check: collapse + persist + auto-expand + expand-all wiring in the renderer"
wire_ok=1
grep -q "chitra:nav-collapsed:v1" artifacts/chitra-docs/src/App.tsx || wire_ok=0
grep -q "localStorage" artifacts/chitra-docs/src/App.tsx || wire_ok=0
grep -q "aria-expanded" artifacts/chitra-docs/src/App.tsx || wire_ok=0
grep -q "expand all" artifacts/chitra-docs/src/App.tsx || wire_ok=0
grep -q "collapse all" artifacts/chitra-docs/src/App.tsx || wire_ok=0
grep -q "auto-expands its group" artifacts/chitra-docs/src/App.tsx || wire_ok=0
if [ "$wire_ok" = "1" ]; then ok "localStorage persist · aria-expanded · expand/collapse-all · auto-expand"; record "behavior-wiring" PASS
else no "a behavior wire is missing"; record "behavior-wiring" FAIL; fi

# ── Mock tokens extracted (mock itself NOT committed) ───────────────────────
# (group/caret/count values only — badge styles were deliberately not carried over)
label "Check: approved-mock group values live in the real stylesheet"
css_ok=1
grep -q "nav-group-label" artifacts/chitra-docs/src/index.css || css_ok=0
grep -q "nav-group-count" artifacts/chitra-docs/src/index.css || css_ok=0
grep -q "\.caret" artifacts/chitra-docs/src/index.css || css_ok=0
grep -q "nav-expand-btn" artifacts/chitra-docs/src/index.css || css_ok=0
if git ls-files --error-unmatch design-reference/nav-groups-mock.html >/dev/null 2>&1; then
  no "the throwaway mock is tracked — it must stay uncommitted"; css_ok=0
fi
if [ "$css_ok" = "1" ]; then ok "group/caret/count/expand styles extracted · mock stays untracked"; record "mock-tokens" PASS
else no "mock extraction incomplete"; record "mock-tokens" FAIL; fi

# ── Summary scorecard (fed by the real checks above) ───────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "browser collapse/persist (14 checks)" "see verify-session-24.sh"
printf "  %-40s %s\n" "S15 suite on the new DOM"            "see verify-session-24.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-24.sh)\n"
printf "  · it does not prove the drift gate or the browser pass are green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
