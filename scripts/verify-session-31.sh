#!/usr/bin/env bash
# S31 — antra design atoms in chitra-docs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-31/${TS}"
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

CSS=artifacts/chitra-docs/src/index.css
APP=artifacts/chitra-docs/src/App.tsx
run_check "tokens-namespaced"    grep -q -e '--antra-violet: #8B7CF6' artifacts/chitra-docs/src/index.css
run_check "tokens-bright"        grep -q -e '--antra-violet-bright: #B7AEFF' artifacts/chitra-docs/src/index.css
run_check "eyebrow-kicker"       grep -q -e 'hero-kicker::before' artifacts/chitra-docs/src/index.css
run_check "hero-accent-solid"    bash -c 'grep -A6 "Hero accent word" artifacts/chitra-docs/src/index.css | grep -q antra-violet-bright'
run_check "install-strip-css"    grep -q -e '\.install-strip' artifacts/chitra-docs/src/index.css
run_check "install-strip-tsx"    grep -q -e 'pnpm add @chitra/core' "$APP"
run_check "route-hairline"       bash -c 'grep -A2 "^\.route-grid {" artifacts/chitra-docs/src/index.css | grep -q "gap: 1px"'
run_check "footer-css"           grep -q -e '\.site-footer' artifacts/chitra-docs/src/index.css
run_check "footer-tsx"           grep -q -e 'SiteFooter' "$APP"
run_check "reveal-css"           grep -q -e '\.reveal\.visible' artifacts/chitra-docs/src/index.css
run_check "reveal-tsx"           grep -q -e 'IntersectionObserver' "$APP"
run_check "atmosphere-grid"      bash -c 'grep -A6 "Atmosphere: violet glow" artifacts/chitra-docs/src/index.css | grep -q "repeating-linear-gradient"'
run_check "mandala-css"          grep -q -e '#mandala-field' artifacts/chitra-docs/src/index.css
run_check "mandala-tsx"          grep -q -e 'MandalaField' "$APP"
run_check "motion-guarded"       bash -c 'grep -c "prefers-reduced-motion" artifacts/chitra-docs/src/index.css | grep -qv "^0$"; grep -q "prefers-reduced-motion" artifacts/chitra-docs/src/App.tsx'
run_check "hero-fixed-dims"      python3 scripts/check-hero-dims.py
run_check "hero-cycle"           bash -c 'grep -q "HERO_CYCLE" artifacts/chitra-docs/src/App.tsx; grep -q "hero-cycle-stack" artifacts/chitra-docs/src/index.css'
run_check "actions-aligned"      bash -c 'grep -A1 "share one measure" artifacts/chitra-docs/src/index.css | grep -q "hero-actions"'
run_check "editor-toolbar"       bash -c 'grep -A1 "Editor: antra-borrow toolbar" artifacts/chitra-docs/src/index.css | grep -q "ct-bar"'
run_check "editor-run-violet"    bash -c 'grep "ct-run { background-color: var(--antra-violet)" artifacts/chitra-docs/src/index.css | grep -q antra'
run_check "editor-tabs-prompt"   bash -c 'grep -q "vim-tab-active { border-bottom-color: var(--antra-violet)" artifacts/chitra-docs/src/index.css; grep -q "term-prompt-dollar { color: var(--antra-violet)" artifacts/chitra-docs/src/index.css'
run_check "docs-typecheck"       pnpm --filter @workspace/chitra-docs run typecheck
run_check "docs-build"           bash -c 'PORT=5174 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build'
run_check "drift-gate"           pnpm --filter @workspace/chitra-docs run gen:charts:check

( cd ".ai/verify/session-31" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 31 Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
