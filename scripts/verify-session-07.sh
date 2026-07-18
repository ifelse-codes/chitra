#!/usr/bin/env bash
# Session 07 verify — CI workflow.
# Proves: .github/workflows/ci.yml exists, parses as YAML, pins Node + pnpm,
# installs with a frozen lockfile, wires every gate (core test/typecheck/build,
# docs typecheck/build, chart-generation drift), and core still passes 116 tests.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="07"
WF=".github/workflows/ci.yml"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# Real YAML parse — resolves the yaml package from the pnpm store (transitive
# dep, never hoisted), so this needs no new dependency and works offline.
YAML_PRELUDE='
const fs = require("node:fs"), path = require("node:path");
function loadYaml() {
  try { return require("yaml"); } catch {}
  const store = path.resolve("node_modules/.pnpm");
  const hit = fs.readdirSync(store).find((d) => /^yaml@\d/.test(d));
  if (!hit) throw new Error("no yaml parser found in node_modules");
  return require(path.join(store, hit, "node_modules/yaml"));
}
const doc = loadYaml().parse(fs.readFileSync(".github/workflows/ci.yml", "utf8"));
'

run_check "workflow-exists"        test -f "$WF"
run_check "workflow-valid-yaml"    node -e "$YAML_PRELUDE
  if (!doc.jobs || typeof doc.jobs !== \"object\" || !Object.keys(doc.jobs).length)
    throw new Error(\"no jobs defined\");
  console.log(\"jobs:\", Object.keys(doc.jobs).join(\", \"));"
run_check "workflow-triggers"      node -e "$YAML_PRELUDE
  if (!doc.on.push || !doc.on.push.branches.includes(\"main\"))
    throw new Error(\"missing push -> main trigger\");
  if (!(\"pull_request\" in doc.on))
    throw new Error(\"missing pull_request trigger\");"
run_check "workflow-pins-node"     grep -q 'NODE_VERSION: "26"' "$WF"
run_check "workflow-pins-pnpm"     grep -q 'PNPM_VERSION: "9.12.3"' "$WF"
run_check "workflow-frozen-install" grep -q -- 'pnpm install --frozen-lockfile' "$WF"
run_check "gate-core-test"         grep -q 'pnpm --filter @chitra/core run test$' "$WF"
run_check "gate-core-typecheck"    grep -q 'pnpm --filter @chitra/core run typecheck$' "$WF"
run_check "gate-core-build"        grep -q 'pnpm --filter @chitra/core run build$' "$WF"
run_check "gate-docs-typecheck"    grep -q 'pnpm --filter @workspace/chitra-docs run typecheck$' "$WF"
run_check "gate-docs-build"        grep -q 'pnpm --filter @workspace/chitra-docs run build$' "$WF"
run_check "gate-chart-drift"       grep -q 'pnpm --filter @workspace/chitra-docs run gen:charts:check$' "$WF"
run_check "core-tests-116"         bash -c "pnpm --filter @chitra/core run test 2>&1 | grep -q '116 passed'"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
