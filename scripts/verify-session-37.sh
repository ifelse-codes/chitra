#!/usr/bin/env bash
# S37 — the S36-deferred npm publish: package renamed to @ifelse.codes/core and shipped.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-37/${TS}"
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
# PASS when the gate exits NON-ZERO (proof the offender path BLOCKS, as designed).
run_expect_block() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))   # exited 0 => did NOT block
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  fi
}

CORE_PKG=packages/core/package.json
DOCS_PKG=artifacts/chitra-docs/package.json
REL=.github/workflows/release.yml
README=README.md
APP=artifacts/chitra-docs/src/App.tsx
LEDGER=.ai/GT-REMEDIATIONS.md

# ── Req 1: rename + publish ─────────────────────────────────────
run_check "core-pkg-renamed"       bash -c "grep -q '\"name\": \"@ifelse.codes/core\"' $CORE_PKG"
run_check "docs-dep-renamed"       bash -c "grep -q '\"@ifelse.codes/core\": \"workspace:\\*\"' $DOCS_PKG"
run_check "release-uses-new-name"  bash -c "grep -q '@ifelse.codes/core' $REL"
run_check "no-stale-pkg-name"      bash -c "! rg -q '@chitra/core' $CORE_PKG $DOCS_PKG pnpm-lock.yaml \
      artifacts/chitra-docs/src artifacts/chitra-docs/scripts .github/workflows $README"
run_check "npm-published-0.1.0"    bash -c "[ \"\$(npm view @ifelse.codes/core@0.1.0 version 2>/dev/null)\" = '0.1.0' ]"
run_check "npm-dist-tag-latest"    bash -c "npm view @ifelse.codes/core dist-tags 2>/dev/null | grep -q \"latest: '0.1.0'\""

# ── Req 5: docs honest ──────────────────────────────────────────
run_check "readme-no-not-on-npm"   bash -c "! grep -q 'not on npm yet' $README"
run_check "readme-real-install"    bash -c "grep -q 'pnpm add @ifelse.codes/core' $README"
run_check "hero-pill-npm"          bash -c "grep -q 'v0.1.0 · npm' $APP"

# ── Req 6: ledger ───────────────────────────────────────────────
run_check "ledger-row2-done"       bash -c "grep -qE '^\\| 2 \\|.*@ifelse.codes/core.*\\| DONE \\|' $LEDGER"

# ── Req 7: gate hardening ───────────────────────────────────────
run_check "gt-deferred-reason"     bash -c "grep -q 'has_reason' scripts/verify-closeout.sh && grep -q 'has_expiry' scripts/verify-closeout.sh"
run_check "gt-offender-entrypoint" bash -c "grep -q 'gt-no-code-only' scripts/verify-closeout.sh"
run_expect_block "gt-offender-exercised" bash scripts/verify-closeout.sh --gt-no-code-only 35
run_check "integrity-gates-exec"   bash scripts/verify-closeout.sh --integrity-only 37

# ── Req 8 + invariants ──────────────────────────────────────────
run_check "prompt-exists"          test -f prompts/37-task-publish-v0.1.0.md
run_check "core-tests-452"         bash -c "pnpm --filter @ifelse.codes/core run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"         pnpm --filter @ifelse.codes/core run typecheck
run_check "docs-typecheck"         pnpm --filter @workspace/chitra-docs run typecheck
run_check "chart-drift"            pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "branch-is-s37"          bash -c '[[ "$(git rev-parse --abbrev-ref HEAD)" == session-37-* ]]'

( cd ".ai/verify/session-37" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 37 Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
