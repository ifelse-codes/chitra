#!/usr/bin/env bash
# verify-session-24.sh — S24: docs-site grouped chart nav (no status badges).
# Proves: the 20 charts sit in EXACTLY six generated groups with exact membership,
# the nav carries zero status badges (lock state is internal — no locked/trio/
# in-flight/session-number/queued vocabulary anywhere), the drift gate holds
# (no hand-edits to generated files), docs typecheck + build + catalog QA stay
# green, the S15 browser suite passes on the new DOM, and the scripted Playwright
# pass verifies collapse/persist/auto-expand in a real browser.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="24"
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

# ── (a) six groups, exact member ids, in the GENERATED data ──────────────
run_check "groups-in-generated-data" bash -c '
  cd artifacts/chitra-docs
  cat > src/__verify_s24_groups.ts <<'"'"'TS'"'"'
import { CHARTS } from "./data/charts.js";
const EXPECTED: Record<string, string[]> = {
  "Trend & time": ["line", "area", "timeline", "candlestick"],
  "Comparison": ["bar", "horizontalBar", "scatter", "radar"],
  "Distribution & density": ["histogram", "boxplot", "heatmap"],
  "Part-to-whole": ["pie", "donut", "treemap", "funnel"],
  "Flow & accumulation": ["sankey", "waterfall"],
  "Single value & progress": ["gauge", "progress", "sparkline"],
};
const groups = [...new Set(CHARTS.map((c) => c.group))];
if (CHARTS.length !== 20) { console.error("FAIL: " + CHARTS.length + " charts, want 20"); process.exit(1); }
if (groups.length !== 6) { console.error("FAIL: " + groups.length + " groups: " + JSON.stringify(groups)); process.exit(1); }
for (const [g, ids] of Object.entries(EXPECTED)) {
  const got = CHARTS.filter((c) => c.group === g).map((c) => c.id).sort();
  if (JSON.stringify(got) !== JSON.stringify([...ids].sort())) {
    console.error("FAIL: group " + JSON.stringify(g) + " = " + JSON.stringify(got)); process.exit(1);
  }
}
console.log("OK: 20 charts in exactly 6 generated groups, membership exact");
TS
  npx tsx src/__verify_s24_groups.ts; rc=$?
  rm -f src/__verify_s24_groups.ts
  exit $rc
'

# ── (b) no badge vocabulary: not in generated data, not in the renderer ───
run_check "no-badge-vocabulary" bash -c '
  cd artifacts/chitra-docs
  cat > src/__verify_s24_nobadge.ts <<'"'"'TS'"'"'
import { readFileSync } from "node:fs";
import { CHARTS } from "./data/charts.js";
// generated rows carry a group and nothing else status-like
for (const c of CHARTS) {
  for (const k of ["locked", "trio", "inFlight"] as const) {
    if ((c as Record<string, unknown>)[k] !== undefined) {
      console.error("FAIL: generated chart " + c.id + " carries badge field " + k); process.exit(1);
    }
  }
  if (typeof c.group !== "string" || c.group.length === 0) {
    console.error("FAIL: generated chart " + c.id + " has no group"); process.exit(1);
  }
}
// the renderer + stylesheet carry no badge vocabulary either
for (const f of ["src/App.tsx", "src/index.css", "scripts/generate-charts.ts", "scripts/chart-specs.ts"]) {
  const src = readFileSync(f, "utf8");
  const hits = src.split("\n").filter((l) =>
    /badge\.(locked|trio|inflight)|["'"'"'`](locked|trio|in[ -]?flight)["'"'"'`]|locked:\s*(true|false)|trio:\s*(true|false)|inFlight:/.test(l));
  if (hits.length > 0) { console.error("FAIL: badge vocabulary in " + f + ":\n" + hits.join("\n")); process.exit(1); }
}
console.log("OK: 20 grouped rows, zero badge vocabulary in data + renderer + styles");
TS
  npx tsx src/__verify_s24_nobadge.ts; rc=$?
  rm -f src/__verify_s24_nobadge.ts
  exit $rc
'

# ── (c) drift gate (no hand-edits to generated files) ────────────────────
run_check "chart-drift-gate" pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── (d) docs typecheck + build green ─────────────────────────────────────
run_check "docs-typecheck" pnpm --filter @workspace/chitra-docs run typecheck
run_check "docs-build" bash -c 'PORT=5174 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build'

# ── standing gates ───────────────────────────────────────────────────────
run_check "catalog-examples-execute" pnpm --filter @workspace/chitra-docs run check:catalog
run_check "core-tests-green" pnpm --filter @chitra/core run test
run_check "core-typecheck" pnpm --filter @chitra/core run typecheck
run_check "core-unchanged" bash -c '
  changed=$(git diff main -- packages/core 2>/dev/null | wc -l)
  [ "$changed" -eq 0 ] || { echo "packages/core changed: $changed lines (S24 is docs-only)"; exit 1; }
'

# ── (e) scripted Playwright nav pass (collapse → reload → auto-expand) ───
export QA_ARTIFACTS="$ARTIFACTS/nav-qa"
run_check "qa-nav-groups" node scripts/qa-nav-groups.mjs

# ── S15 browser suite passes on the new DOM ──────────────────────────────
export QA_ARTIFACTS="$ARTIFACTS/catalog-qa"
run_check "qa-catalog-runs" node scripts/qa-catalog.mjs

# ── branch is s24 ────────────────────────────────────────────────────────
run_check "branch-is-s24" bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-24-* ]] || { echo "branch=$branch, expected session-24-*"; exit 1; }
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
