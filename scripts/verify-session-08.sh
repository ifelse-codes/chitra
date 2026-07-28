#!/usr/bin/env bash
# Session 08 verify — release.yml publish workflow.
# Proves: .github/workflows/release.yml exists, parses as YAML, triggers on v* tags,
# carries the three CI gates as prerequisites, pins Node + pnpm, uses frozen install,
# and wires NODE_AUTH_TOKEN for the publish step.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="08"
WF=".github/workflows/release.yml"

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

YAML_PRELUDE='
const fs = require("node:fs"), path = require("node:path");
function loadYaml() {
  try { return require("yaml"); } catch {}
  const store = path.resolve("node_modules/.pnpm");
  const hit = fs.readdirSync(store).find((d) => /^yaml@\d/.test(d));
  if (!hit) throw new Error("no yaml parser found in node_modules");
  return require(path.join(store, hit, "node_modules/yaml"));
}
const doc = loadYaml().parse(fs.readFileSync(".github/workflows/release.yml", "utf8"));
'

# 1. File exists and parses
run_check "workflow-exists"           test -f "$WF"
run_check "workflow-valid-yaml"       node -e "$YAML_PRELUDE
  if (!doc.jobs || typeof doc.jobs !== 'object' || !Object.keys(doc.jobs).length)
    throw new Error('no jobs defined');
  console.log('jobs:', Object.keys(doc.jobs).join(', '));"

# 2. Triggers on v* tag push only
run_check "trigger-tag-push"          node -e "$YAML_PRELUDE
  const on = doc.on;
  if (!on.push || !on.push.tags || !on.push.tags.some(t => t === 'v*'))
    throw new Error('missing push -> tags -> v* trigger');
  if (on.push.branches) throw new Error('should not trigger on branches, only tags');"

# 3. Toolchain pins
run_check "pins-node-26"              grep -q 'NODE_VERSION: "26"' "$WF"
run_check "pins-pnpm-9.12.3"         grep -q 'PNPM_VERSION: "9.12.3"' "$WF"
run_check "frozen-lockfile"          grep -q -- 'pnpm install --frozen-lockfile' "$WF"

# 4. Three CI gates present as jobs
run_check "gate-job-core"             node -e "$YAML_PRELUDE
  if (!doc.jobs.core) throw new Error('missing core job');"
run_check "gate-job-docs"             node -e "$YAML_PRELUDE
  if (!doc.jobs.docs) throw new Error('missing docs job');"
run_check "gate-job-chart-drift"      node -e "$YAML_PRELUDE
  if (!doc.jobs['chart-drift']) throw new Error('missing chart-drift job');"

# 5. Publish job exists and needs all three gates
run_check "publish-job-exists"        node -e "$YAML_PRELUDE
  if (!doc.jobs.publish) throw new Error('missing publish job');"
run_check "publish-needs-core"        node -e "$YAML_PRELUDE
  const needs = doc.jobs.publish.needs;
  if (!needs || !needs.includes('core')) throw new Error('publish does not need core');"
run_check "publish-needs-docs"        node -e "$YAML_PRELUDE
  const needs = doc.jobs.publish.needs;
  if (!needs || !needs.includes('docs')) throw new Error('publish does not need docs');"
run_check "publish-needs-chart-drift" node -e "$YAML_PRELUDE
  const needs = doc.jobs.publish.needs;
  if (!needs || !needs.includes('chart-drift')) throw new Error('publish does not need chart-drift');"

# 6. Publish step uses NODE_AUTH_TOKEN and --access public
run_check "publish-access-public"     grep -q -- '--access public' "$WF"
run_check "publish-node-auth-token"   grep -q 'NODE_AUTH_TOKEN' "$WF"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
