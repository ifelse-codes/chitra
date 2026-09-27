#!/usr/bin/env bash
# S38 — release runway: npm Trusted Publishing (OIDC) replaces the long-lived
# NODE_AUTH_TOKEN, and `0.2.0` is published by CI with no human in the loop.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-38/${TS}"
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

CORE_PKG=packages/core/package.json
REL=.github/workflows/release.yml
README=README.md
LEDGER=.ai/GT-REMEDIATIONS.md

# `publish` is the last job in release.yml, so its body is "publish: -> EOF".
# NB: do NOT try this as an awk range — the line `  publish:` matches BOTH the
# start pattern and any `^  [a-z-]+:$` end pattern, collapsing the range to one
# line. sed is the honest tool here.
publish_body()      { sed -n '/^  publish:/,$p' .github/workflows/release.yml; }
publish_code()      { publish_body | grep -vE '^[[:space:]]*#'; }   # comments stripped
# run_check shells out via `bash -c`, so both the function AND any variable it
# reads must be exported. The path is hardcoded above for that reason.
export -f publish_body publish_code

# ── Req 2: release.yml speaks OIDC ───────────────────────────────
run_check "oidc-id-token-write"     bash -c "publish_code | grep -qE 'id-token: write'"
run_check "oidc-keeps-contents-read" bash -c "publish_code | grep -q 'contents: read'"
run_check "no-node-auth-token"      bash -c "! publish_code | grep -qE 'NODE_AUTH_TOKEN|secrets\.'"
# Regression guard for the real S38 bug: pnpm 9.x predates Trusted Publishing and
# cannot exchange an OIDC token, so the publish step must NOT shell out to pnpm.
run_check "publish-uses-npm"        bash -c "publish_code | grep -q 'npm publish --access public'"
run_check "publish-not-pnpm"        bash -c "! publish_code | grep -qE 'pnpm .*publish'"
run_check "registry-url-kept"       bash -c "publish_code | grep -q 'registry-url: \"https://registry.npmjs.org\"'"
run_check "idempotency-kept"        bash -c "publish_code | grep -q 'is already on npm — skipping publish'"
# npm's own example says never use caching in release builds.
run_check "no-cache-in-publish"     bash -c "! publish_code | grep -qE 'cache: pnpm'"

# ── Req 1/3 prereqs npm enforces (repo-side) ─────────────────────
# npm requires package.json `repository.url` to match the GitHub repo exactly,
# or OIDC publish fails. This is a static, provable prerequisite.
run_check "repo-url-matches"        bash -c "grep -q 'https://github.com/ifelse-codes/chitra.git' $CORE_PKG"
run_check "npm-cli-oidc-capable"    bash -c "npm -v | awk -F. '{exit !(\$1>11 || (\$1==11 && \$2>=5))}'"
run_check "node-oidc-capable"       bash -c "node -v | sed 's/^v//' | awk -F. '{exit !(\$1>22 || (\$1==22 && \$2>=14))}'"

# ── Req 3: version bumped ────────────────────────────────────────
run_check "version-is-0.2.0"        bash -c "[ \"\$(node -p \"require('./$CORE_PKG').version\")\" = '0.2.0' ]"
run_check "lockfile-unaffected"     pnpm install --frozen-lockfile

# ── Req 6: README honest about deferred MCP ──────────────────────
run_check "readme-mcp-marked-pending" bash -c "grep -q 'MCP tool handler — \*\*not shipped yet' $README"
run_check "readme-mcp-points-roadmap" bash -c "grep -q 'ROADMAP.md' $README"

# ── Req 4: the release actually happened (post-tag) ──────────────
# These three are the only checks that need the merged tag to exist. They are
# expected to FAIL on the pre-PR run and are the real proof of the story.
run_check "npm-0.2.0-live"          bash -c "[ \"\$(npm view @ifelse.codes/core@0.2.0 version 2>/dev/null)\" = '0.2.0' ]"
run_check "npm-latest-is-0.2.0"     bash -c "npm view @ifelse.codes/core dist-tags 2>/dev/null | grep -q \"latest: '0.2.0'\""
run_check "v0.2.0-tag-pushed"       bash -c "git ls-remote --tags origin 'refs/tags/v0.2.0' | grep -q ."
# S38 correction: S37's `gh secret set NODE_AUTH_TOKEN` was never actually run
# (its own contract logs step 2 as "deferred"), so there was never a CI secret to
# revoke — verified: `gh secret list` returns zero secrets. This asserts BOTH
# that gh actually answered (no silent false green) and that no token secret is
# present. The npm ACCOUNT token pasted in the S37 chat is a separate artifact the
# founder must revoke at npmjs.com; it is not observable from CI, so it is not
# asserted here — see prompts/38-task-release-runway.md step 5.
run_check "gh-secret-list-works"    bash -c "gh secret list --repo ifelse-codes/chitra --json name >/dev/null 2>&1"
run_check "ci-no-auth-token-secret" bash -c "! gh secret list --repo ifelse-codes/chitra --json name --jq '.[].name' 2>/dev/null | grep -q NODE_AUTH_TOKEN"
run_check "repo-visibility-known"   bash -c "gh repo view ifelse-codes/chitra --json visibility --jq .visibility | grep -qE 'PUBLIC|PRIVATE'"

# ── Req 7: session invariants ────────────────────────────────────
run_check "prompt-exists"           test -f prompts/38-task-release-runway.md
run_check "core-tests-452"          bash -c "pnpm --filter @ifelse.codes/core run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"          pnpm --filter @ifelse.codes/core run typecheck
run_check "core-build"              pnpm --filter @ifelse.codes/core run build
run_check "docs-typecheck"          pnpm --filter @workspace/chitra-docs run typecheck
run_check "chart-drift"             pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "mcp-not-built"           bash -c "! ls packages | grep -qi mcp"
run_check "branch-is-s38"           bash -c '[[ "$(git rev-parse --abbrev-ref HEAD)" == session-38-* ]]'

( cd ".ai/verify/session-38" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 38 Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
