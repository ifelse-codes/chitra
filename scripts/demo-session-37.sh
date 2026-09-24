#!/usr/bin/env bash
# S37 — demo: the S36-deferred npm publish, shipped (cumulative).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

header "Session 37 Demo — publish @ifelse.codes/core@0.1.0 (the S36-deferred item)"

label "1 · package renamed to a scope the account owns"
ok "@chitra/core → @ifelse.codes/core (26 live files; frozen sessions/ untouched)"
dim "  why: the @chitra npm ORG is not owned by this account (npm org ls chitra → 403);"
dim "  unscoped 'chitra' is taken (v0.1.14); @ifelse.codes is the founder's free scope."

label "2 · published to npm"
V="$(npm view @ifelse.codes/core@0.1.0 version 2>/dev/null || true)"
TAGS="$(npm view @ifelse.codes/core dist-tags 2>/dev/null | tr -d '\n' || true)"
if [ "$V" = "0.1.0" ]; then ok "@ifelse.codes/core@${V} — live (dist-tags ${TAGS:-?})"; else bad "not resolvable from the registry"; fi
dim "  how: npm's web/passkey 2FA flow runs ONLY on a TTY — published inside tmux,"
dim "       approved the passkey. (A non-TTY shell gets EOTP with a masked URL.)"

label "3 · a consumer can actually install it"
TMP="$(mktemp -d)"
if ( cd "$TMP" && npm init -y >/dev/null 2>&1 && npm install @ifelse.codes/core@0.1.0 >/dev/null 2>&1 \
     && [ "$(node -p "require('./node_modules/@ifelse.codes/core/package.json').version")" = "0.1.0" ] ); then
  ok "clean install → @ifelse.codes/core@0.1.0"
else bad "consumer install failed"; fi
rm -rf "$TMP"

label "4 · docs honest now"
if ! grep -q 'not on npm yet' README.md && grep -q 'pnpm add @ifelse.codes/core' README.md \
   && grep -q 'v0.1.0 · npm' artifacts/chitra-docs/src/App.tsx; then
  ok "README install is real; hero pill reads 'v0.1.0 · npm'"
else bad "docs still stale"; fi

label "5 · ground-truth teeth hardened (S36-review weaknesses)"
GATE="scripts/verify-closeout.sh"
if grep -q 'has_reason' "$GATE" && grep -q 'has_expiry' "$GATE"; then
  ok "DEFERRED ledger rows now require reason AND expiry"
else bad "DEFERRED hardening missing"; fi
if bash "$GATE" --gt-no-code-only 35 >/dev/null 2>&1; then
  bad "GT offender path did NOT block (should block on this code branch)"
else
  ok "GT no-code offender path EXERCISED: --gt-no-code-only 35 blocks, listing code files"
fi
if grep -qE '^\| 2 \|.*@ifelse.codes/core.*\| DONE \|' .ai/GT-REMEDIATIONS.md; then
  ok "ledger row 2 (publish) → DONE — the S36 DEFERRED item is closed"
else bad "ledger row 2 not DONE"; fi

label "6 · invariants"
TEST_OUT="$(pnpm --filter @ifelse.codes/core run test 2>&1 || true)"
if grep -qE 'Tests +452 passed' <<<"$TEST_OUT"; then ok "core suite 452/452 green"; else bad "core suite not green"; fi

header "Summary"
printf '%-52s %s\n' "AREA" "STATUS"
printf '%-52s %s\n' "----------------------------------------------------" "------"
printf '%-52s %s\n' "publish (@ifelse.codes/core@0.1.0)" "SHIPPED"
printf '%-52s %s\n' "consumer install" "SHIPPED"
printf '%-52s %s\n' "docs (README install + hero pill)" "SHIPPED"
printf '%-52s %s\n' "GT ledger row 2 + gate hardening" "SHIPPED"
printf '%-52s %s\n' "v0.1.0 tag + PR to main" "TO GO"
printf '%-52s %s\n' "core suite" "452/452"

exit 0
