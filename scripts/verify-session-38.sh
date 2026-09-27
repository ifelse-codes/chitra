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
# The `run:` block of the publish step itself — the only block that executes a
# publish. The S38 cold review proved that grepping the whole publish job is
# hollow: an `if [ "${DRY_RUN:-0}" = 1 ]` branch holding a dead `npm publish`
# makes "uses-npm" pass while the real command is `pnpm … publish`, which is
# exactly the pnpm-can't-do-OIDC bug. Scope the assertion to executed lines.
publish_step()      { publish_code | sed -n '/name: Publish to npm via Trusted Publishing/,$p'; }
wf_code()           { grep -vE '^[[:space:]]*#' .github/workflows/release.yml; }
# run_check shells out via `bash -c`, so both the function AND any variable it
# reads must be exported. The paths are hardcoded above for that reason.
export -f publish_body publish_code publish_step wf_code

# ── Req 2: release.yml speaks OIDC ───────────────────────────────
run_check "oidc-id-token-write"     bash -c "publish_code | grep -qE 'id-token: write'"
run_check "oidc-keeps-contents-read" bash -c "publish_code | grep -q 'contents: read'"
# Whole-file, not just the publish job: a workflow-level `env:` block sits ABOVE
# `  publish:`, so scoping to the job let a reintroduced token hide in plain sight.
run_check "no-node-auth-token"      bash -c "! wf_code | grep -qE 'NODE_AUTH_TOKEN|secrets\.'"
# Regression guard for the real S38 bug: pnpm 9.x predates Trusted Publishing and
# cannot exchange an OIDC token, so the publish step must not shell out to pnpm.
# Now scoped to the publish step and matched at the start of a line, so `pnpx`,
# a leading indent, and a `pub` abbreviation are all caught — the three escapes
# the cold review demonstrated against the previous, broader version.
run_check "publish-uses-npm"        bash -c "publish_step | grep -qE '^[[:space:]]*npm publish([[:space:]]|\\$)'"
run_check "publish-no-pnpm-at-all"  bash -c "! publish_step | grep -qE '^[[:space:]]*(pnpm|pnpx|npx pnpm)'"
run_check "publish-exactly-one-cmd" bash -c "[ \"\$(publish_step | grep -cE '^[[:space:]]*(npm publish|pnpm .*publish)')\" -eq 1 ]"
run_check "registry-url-kept"       bash -c "publish_code | grep -q 'registry-url: \"https://registry.npmjs.org\"'"
run_check "idempotency-kept"        bash -c "publish_code | grep -q 'is already on npm — skipping publish'"
# npm's own example says never use caching in release builds. Quoted `cache: 'pnpm'`
# is the same thing, so the quotes must not defeat the match.
run_check "no-cache-in-publish"     bash -c "! publish_code | grep -qE \"cache:[[:space:]]*['\\\"]?pnpm\""

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
# The S38 cold review's sharpest finding: the three checks above all pass
# identically whether CI published 0.2.0 or a human ran `npm publish` locally two
# minutes earlier with the S37 account token. npm records the authoritative
# publish timestamp, and the Release run records when it started — so assert
# ORDER. This is the only check that separates "unattended" from "looks unattended".
# It needs no npm auth: `npm view … time` is public packument data.
# NB: `time.0.2.0` does NOT work — npm parses the dots as nested field paths, so
# read the whole map and index the version key.
# npm_epoch <iso8601> -> epoch seconds. BSD date (macOS) has no `-d`, GNU does, so
# try BSD's -f first. `${1%%.*}` drops the fractional seconds AND the trailing Z,
# hence the format string carries no literal Z.
npm_epoch() {
  local t="${1%%.*}"
  date -j -u -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null \
    || date -u -d "${1%Z}" +%s 2>/dev/null \
    || echo ""
}
export -f npm_epoch   # run_check uses `bash -c`; unexported functions are invisible there
run_check "published-after-run-start" bash -c '
  NPM_T="$(npm view @ifelse.codes/core time --json 2>/dev/null | node -e "let s=\"\";process.stdin.on(\"data\",d=>s+=d).on(\"end\",()=>{try{process.stdout.write(JSON.parse(s)[\"0.2.0\"]||\"\")}catch(e){}})")"
  RUN_T="$(gh run list --repo ifelse-codes/chitra --workflow release.yml --limit 30 --json headBranch,createdAt \
            --jq ".[] | select(.headBranch==\"v0.2.0\") | .createdAt" | head -1)"
  [ -n "$NPM_T" ] && [ -n "$RUN_T" ] || exit 1
  N="$(npm_epoch "$NPM_T")"; R="$(npm_epoch "$RUN_T")"
  [ -n "$N" ] && [ -n "$R" ] || exit 1
  [ "$N" -ge "$R" ]'
# A human publishing BEFORE the tag would also leave the version present, so the
# ordering check above is the load-bearing one; this guards the reverse mistake.
run_check "run-actually-succeeded"    bash -c "gh run list --repo ifelse-codes/chitra --workflow release.yml --limit 30 --json headBranch,conclusion --jq '.[] | select(.headBranch==\"v0.2.0\") | .conclusion' | grep -q success"

# ── Req 7: session invariants ────────────────────────────────────
run_check "prompt-exists"           test -f prompts/38-task-release-runway.md
run_check "core-tests-452"          bash -c "pnpm --filter @ifelse.codes/core run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"          pnpm --filter @ifelse.codes/core run typecheck
run_check "core-build"              pnpm --filter @ifelse.codes/core run build
run_check "docs-typecheck"          pnpm --filter @workspace/chitra-docs run typecheck
run_check "chart-drift"             pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "mcp-not-built"           bash -c "! ls packages | grep -qi mcp"
# S38 fix: the old form of this check asserted `HEAD == session-38-*`, which cannot
# pass when verify runs against merged `main` — and running against merged main is
# exactly what proves the release. The rule it guards is "this work happened on a
# session branch and reached main via PR, never a direct commit to main". Assert
# THAT instead: a merged PR exists whose head branch is a `session-38-*` branch.
# Derived, not hardcoded to a PR number (the cold review flagged a hardcoded `46`
# as rot), and squash-merge deliberately makes the branch tip a non-ancestor, so
# ancestry is the wrong test.
run_check "pr-from-session-branch"  bash -c "[ -n \"\$(gh pr list --repo ifelse-codes/chitra --state merged --limit 50 --json headRefName --jq '.[] | select(.headRefName | startswith(\"session-38-\")) | .headRefName' | head -1)\" ]"
# Replaces the old `not-on-squashed-main`, which was green on any commit containing
# the phrase "S38: release runway" — including an empty no-op or a revert. Assert
# the squash commit on main actually TOUCHED the workflow.
run_check "main-squash-touched-release" bash -c "git log origin/main -1 --name-only --format= | grep -qx '.github/workflows/release.yml'"

( cd ".ai/verify/session-38" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 38 Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
