#!/usr/bin/env bash
# S36 — close the S35 ground-truth gaps + ship v0.1.0.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-36/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

APP=artifacts/chitra-docs/src/App.tsx
KNOW=.ai/KNOWLEDGE.md
REL=.github/workflows/release.yml

# ── Req 5: docs pills honest ────────────────────────────────────
run_check "pill-no-false-stable"  bash -c "! grep -q 'v0.1.0 — stable' $APP"
run_check "pill-count-452"        bash -c "grep -q '>452<' $APP"
run_check "pill-no-stale-134"     bash -c "! grep -q '>134<' $APP"

# ── Req 6: KNOWLEDGE one canonical count, no stale facts ────────
run_check "know-452"              bash -c "grep -q '452' $KNOW"
run_check "know-no-stale-counts"  bash -c "! grep -qE '142 tests|163 core tests|442 tests' $KNOW"
run_check "know-23-files"         bash -c "grep -q '23 files' $KNOW"
run_check "know-node-26"          bash -c "grep -q 'Node \*\*26\*\*\|Node 26' $KNOW"
run_check "know-main-range"       bash -c "grep -q 'S00–S34' $KNOW"
run_check "know-s36-extension"    bash -c "grep -q 'S36 extension' $KNOW"

# ── Req 2/3: release hygiene (publish deferred by founder to S37) ──
run_check "release-idempotent"    bash -c "grep -q 'already published' $REL || grep -q 'npm view' $REL"
run_check "no-stale-v0.1.0-tag"   bash -c "! git rev-parse -q --verify v0.1.0 >/dev/null 2>&1"
run_check "release-deferred-noted" bash -c "grep -qi 'Automation token' .ai/STATE.md && grep -qi 'DEFERRED' .ai/GT-REMEDIATIONS.md"

# ── Req 8/9/10: governance teeth ────────────────────────────────
run_check "gt-hook-exists"        test -x .ai/hooks/hook-ground-truth-guard.sh
run_check "gt-hook-wired"         bash -c "grep -q 'hook-ground-truth-guard.sh' .claude/settings.json"
run_check "gt-ledger-exists"      test -s .ai/GT-REMEDIATIONS.md
run_check "closeout-integrity-exec" bash scripts/verify-closeout.sh --integrity-only 36
run_check "s17-backfilled"        bash -c "test -f sessions/session-17-summary.md && test -f prompts/17-task-scatter-lock.md"
run_check "s32-backfilled"        bash -c "test -f sessions/session-32-summary.md && test -f prompts/32-task-wall-playbook.md"

# ── Req 9/10: roadmap demand ────────────────────────────────────
run_check "roadmap-mcp-item"      bash -c "grep -qi 'MCP server' .ai/ROADMAP.md"
run_check "roadmap-s36"           bash -c "grep -q 'Session 36' .ai/ROADMAP.md"

# ── Req 11: cost line ───────────────────────────────────────────
run_check "cost-measured"         bash -c "grep -qi 'unmeasured' .ai/STATE.md || grep -qE 'S36 measured' .ai/STATE.md"

# ── Req 12 + invariants ─────────────────────────────────────────
run_check "prompt-exists"         test -f prompts/36-task-close-audit-gaps.md
run_check "core-tests-452"        bash -c "pnpm --filter @chitra/core run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"        pnpm --filter @chitra/core run typecheck
run_check "git-closeout-integrity" bash -c "git merge-base --is-ancestor main HEAD"
run_check "branch-is-s36"         bash -c '[[ "$(git rev-parse --abbrev-ref HEAD)" == session-36-* ]]'

( cd ".ai/verify/session-36" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 36 Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
