#!/usr/bin/env bash
# S38 — demo: the release runway. Token-based CI publish → Trusted Publishing (OIDC).
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
row()    { printf "  %-26s %s\n" "$1" "$2"; }

header "Session 38 Demo — releases with no human in the loop"

label "1 · the publish job authenticates with OIDC, not a token"
dim "  before → after (the whole auth story is these lines):"
dim "     permissions: { contents: read }        →  { id-token: write, contents: read }"
dim "     env: NODE_AUTH_TOKEN: \${{ secrets.… }}  →  (deleted — no npm secret at all)"
dim "     pnpm … publish                          →  npm publish   ← the real S38 bug"
ok "GitHub mints an OIDC token; npm exchanges it for a short-lived publish token"

label "2 · why the publish step had to leave pnpm  ← the bug this session caught"
row "pnpm (pinned 9.12.3)" "predates Trusted Publishing"
row "pnpm auth surface" "_authToken / _auth / tokenHelper"
row "pnpm OIDC exchange" "does not exist"
row "npm ≥ 11.5.1" "OIDC-capable  (local: npm $(npm -v))"
dim "  Left as-is, the release would have failed at publish with an auth error that"
dim "  looks like a config typo. pnpm still does install/build/test — only publish moved."

label "3 · what OIDC does NOT give us (the repo is private)"
VIS="$(gh repo view ifelse-codes/chitra --json visibility --jq .visibility 2>/dev/null || echo '?')"
row "GitHub repo visibility" "$VIS"
row "OIDC publishing" "works from a private repo"
row "npm provenance" "NOT generated (private repo)"
dim "  npm does not generate provenance attestations for private repositories, even"
dim "  under trusted publishing — a known npm limitation, not a config error."
dim "  So 0.2.0 will ship WITHOUT a provenance badge. Making the repo public fixes"
dim "  that, and arguably suits an MIT-licensed package. Founder's call, not ours."

label "4 · a consumer installs the CI-published version"
V="$(npm view @ifelse.codes/core@0.2.0 version 2>/dev/null || true)"
TAGS="$(npm view @ifelse.codes/core dist-tags 2>/dev/null | tr -d '\n' || true)"
if [ "$V" = "0.2.0" ]; then
  ok "@ifelse.codes/core@${V} — live (dist-tags ${TAGS:-?})"
  TMP="$(mktemp -d)"
  if ( cd "$TMP" && npm init -y >/dev/null 2>&1 && npm install --silent @ifelse.codes/core@0.2.0 >/dev/null 2>&1 ); then
    ok "clean npm install resolved @ifelse.codes/core@0.2.0"
    dim "  $(node -p "const p=require('$TMP/node_modules/@ifelse.codes/core/package.json');\`\${p.name}@\${p.version} · \${p.files.length} file groups\`" 2>/dev/null || echo 'installed')"
  else
    bad "clean install FAILED"
  fi
  rm -rf "$TMP"
else
  bad "@ifelse.codes/core@0.2.0 not on the registry yet"
  dim "  expected until the merged v0.2.0 tag is pushed — see step 5."
fi

label "5 · the CI token path is gone"
# `--json name` returns a literal `[]` when there are none, so test the COUNT,
# not string emptiness — otherwise "no secrets" reads as "secrets present".
NSEC="$(gh secret list --repo ifelse-codes/chitra --json name --jq 'length' 2>/dev/null || echo 'ERR')"
case "$NSEC" in
  0)   ok "repo has zero Actions secrets — no NODE_AUTH_TOKEN to leak or rotate"
       dim "  correction: S37 planned 'gh secret set NODE_AUTH_TOKEN' but never ran it"
       dim "  (its own contract logs step 2 as deferred). So there was never a CI"
       dim "  secret to revoke — the workflow no longer references one either way." ;;
  ERR) bad "could not read repo secrets (gh failed) — not asserting anything" ;;
  *)   if gh secret list --repo ifelse-codes/chitra --json name --jq '.[].name' 2>/dev/null | grep -q NODE_AUTH_TOKEN; then
         bad "NODE_AUTH_TOKEN secret still present in the repo ($NSEC secrets)"
       else
         bad "$NSEC secrets present, none named NODE_AUTH_TOKEN — review them"
       fi ;;
esac
dim "  ⚠ the npm ACCOUNT token pasted in the S37 chat (npm_xToANF…) is separate"
dim "    and still valid — only the founder can revoke it (npmjs.com → Access Tokens)."
dim "    Not assertable from CI; tracked in prompts/38-task-release-runway.md step 5."

label "6 · release is unattended"
if git ls-remote --tags origin 'refs/tags/v0.2.0' 2>/dev/null | grep -q .; then
  ok "v0.2.0 tag pushed → Release workflow published with no tmux, no passkey"
else
  dim "  v0.2.0 not tagged yet — cut from merged main to publish 0.2.0 unattended."
fi

label "7 · deferring the MCP server left no dangling promise"
ok "README now marks the render_chart handler 'not shipped yet' → .ai/ROADMAP.md"
dim "  deferred at the founder's direction until a release exists AND someone asks."

echo ""
echo "=== Session 38 Summary ==="
printf "  %-34s %s\n" "ITEM" "STATE"
printf "  %-34s %s\n" "----------------------------------" "------"
printf "  %-34s %s\n" "OIDC trusted publisher wired" "release.yml · id-token: write"
printf "  %-34s %s\n" "NODE_AUTH_TOKEN removed" "no npm secret referenced"
printf "  %-34s %s\n" "pnpm→npm publish fix" "pnpm 9 cannot do OIDC"
printf "  %-34s %s\n" "provenance" "none — repo is private (npm limit)"
printf "  %-34s %s\n" "core version" "0.2.0"
printf "  %-34s %s\n" "npm release" "$([ "$V" = "0.2.0" ] && echo '0.2.0 live (CI-published)' || echo 'pending tag push')"
printf "  %-34s %s\n" "npm account token" "FOUNDER: revoke npm_xToANF… at npmjs"
printf "  %-34s %s\n" "MCP server" "deferred (founder, demand-led)"
printf "  %-34s %s\n" "GTM proof pack" "S39 — now has a release to point at"
echo ""
