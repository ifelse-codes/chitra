#!/usr/bin/env bash
# S30 — host chitra-docs on chitra.iifelse.com (Cloudflare Pages).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-30/${TS}"
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

run_check "redirects-in-public"  test -f artifacts/chitra-docs/public/_redirects
run_check "redirects-spa-rule"   grep -q '/\* /index.html 200' artifacts/chitra-docs/public/_redirects
run_check "redirects-in-dist"    test -f artifacts/chitra-docs/dist/public/_redirects
run_check "docs-build"           bash -c 'PORT=5174 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build'
run_check "pages-project"        bash -c 'wrangler pages project list 2>&1 | grep -q "^│ chitra "'

( cd ".ai/verify/session-30" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 30 Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
