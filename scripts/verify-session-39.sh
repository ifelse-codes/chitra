#!/usr/bin/env bash
# S39 — rename the package `@ifelse.codes/core` → `@ifelse.codes/chitra`.
#
# Design rule carried from the S38 cold review: **assert facts, not phrases.** A
# check coupled to a string or a commit's position is not a guard (S38 shipped three
# versions of one check that failed three different ways: green on a no-op, green on
# a `Revert`, then red on a perfectly good state). So the load-bearing checks here
# read the *committed* package.json out of `main`, resolve the name from the tarball
# npm would actually publish, and execute the real drift gate.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-39/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-36s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-36s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

PKG=packages/core/package.json
REL=.github/workflows/release.yml
OLD='@ifelse.codes/core'
NEW='@ifelse.codes/chitra'

# `publish` is the last job in release.yml, so its body is "publish: -> EOF".
# NB: do NOT try this as an awk range — the line `  publish:` matches BOTH the
# start pattern and any `^  [a-z-]+:$` end pattern, collapsing the range to one
# line. sed is the honest tool. Same trap S38 paid for.
publish_body()  { sed -n '/^  publish:/,$p' "$REL"; }
publish_code()  { publish_body | grep -vE '^[[:space:]]*#'; }
# The `run:` block of the publish step itself — the only block that publishes.
# Grepping the whole job is hollow: a dead `npm publish` behind an unreachable
# branch makes a check pass while the executed command is something else (S38's
# cold review demonstrated exactly this against the pnpm regression).
publish_step()  { publish_code | sed -n '/name: Publish to npm via Trusted Publishing/,$p'; }
# Everything outside the publish step — jobs/steps that run a filter, a build, a
# `npm view`. A `pnpm --filter <old name>` in a sibling job fails CI, not publish.
wf_code()       { grep -vE '^[[:space:]]*#' "$REL"; }
main_name()     { git show "origin/main:$PKG" | node -p 'JSON.parse(require("fs").readFileSync(0,"utf8")).name'; }
main_field()    { git show "origin/main:$PKG" | node -p "JSON.parse(require('fs').readFileSync(0,'utf8'))[\"$1\"]"; }
# run_check shells out via `bash -c`, so both the function AND any variable it
# reads must be exported. Paths are hardcoded above for that reason.
export -f publish_body publish_code publish_step wf_code main_name main_field
export PKG REL OLD NEW

# ── Req 1 + 2: the package identity, read from the committed file ─────────
run_check "pkg-name-is-chitra"        bash -c 'node -p "require(\"./$PKG\").name" | grep -qx "$NEW"'
run_check "pkg-version-is-0.3.0"      bash -c 'node -p "require(\"./$PKG\").version" | grep -qx 0.3.0'
run_check "main-carries-new-name"     main_name
run_check "main-version-is-0.3.0"     bash -c 'main_field version | grep -qx 0.3.0'
# The tarball npm would actually publish must carry the new name + version.
# `npm pack` resolves the manifest the same way `npm publish` does, so this
# catches a manifest edit that never reached the pack root.
run_check "pack-resolves-new-name"    bash -c 'cd packages/core && npm pack --dry-run --json 2>/dev/null | node -e "let s=\"\";process.stdin.on(\"data\",d=>s+=d).on(\"end\",()=>{const j=JSON.parse(s)[0];process.exit(j.name===\"@ifelse.codes/chitra\"&&j.version===\"0.3.0\"?0:1)})"'
# Req 2 — the `mcp` keyword is a promise in a search index and nothing ships it.
run_check "mcp-keyword-dropped"       bash -c '! node -p "JSON.stringify(require(\"./$PKG\").keywords)" | grep -qw mcp'
# Req 2 — the description leads with the name, so the npm page is identifiable.
run_check "description-leads-name"    bash -c 'node -p "require(\"./$PKG\").description" | grep -q "^chitra"'

# ── Req 3: every live reference moved ───────────────────────────────────
# Split deliberately. (a) CODE/CONFIG: the old name in anything executable is a
# hard break — a bad `pnpm --filter`, a dead import, a guard aimed at a package
# that no longer receives the publish. (b) INSTALL/IMPORT LINES IN PROSE: a notice
# saying "it *was* @ifelse.codes/core" is correct and required; an install snippet
# still carrying the old name is a bug. Blanket "old name absent" would fail the
# notices; blanket "old name allowed anywhere" would pass the bugs.
run_check "old-name-gone-from-code"   bash -c '
  hits="$(git ls-files "*.ts" "*.tsx" "*.mjs" "*.js" "*.json" "*.yml" "*.yaml" \
    | grep -vE "^(sessions|prompts/[0-3][0-8]-|scripts/verify-session-|scripts/demo-session-|scripts/workflows/)" \
    | xargs grep -l -- "$OLD" 2>/dev/null || true)"
  [ -z "$hits" ] || { echo "old name still in:"; echo "$hits"; exit 1; }'
run_check "old-name-not-in-installs"  bash -c '
  ! grep -rE "(npm|pnpm|yarn) (install|add) $OLD|from \"$OLD\"|npmjs\.com/package/$OLD|--filter $OLD" \
      README.md packages/core/README.md CONTRIBUTING.md replit.md artifacts/chitra-docs/src 2>/dev/null'
run_check "new-name-in-every-live-doc" bash -c '
  for f in README.md CONTRIBUTING.md replit.md packages/core/README.md \
           .github/workflows/ci.yml .github/workflows/release.yml \
           artifacts/chitra-docs/package.json; do
    grep -q -- "$NEW" "$f" || { echo "MISSING new name in $f"; exit 1; }
  done'

# ── Req 3 (the load-bearing one): the release path must target the new package ──
# The idempotency guard is a `npm view` against a package name. Left pointing at
# the old name it still *runs*, still exits 0, and silently checks a package that
# will never receive this publish — the exact "green but hollow" class the S38
# review was built to catch. Scoped to the executed `run:` block.
run_check "release-guard-targets-new"  bash -c 'publish_step | grep -qF "npm view \"$NEW@\${VERSION}\""'
run_check "release-guard-not-old"      bash -c '! publish_step | grep -q -- "$OLD"'
# The rename must not have reached only the publish job: a `--filter <old>` in any
# sibling job fails CI at install time, not at publish time.
run_check "no-old-filter-anywhere-wf"  bash -c '! wf_code | grep -q -- "$OLD"'
run_check "filters-use-new-name"       bash -c '[ "$(wf_code | grep -c -- "filter $NEW")" -ge 5 ]'
# S38 guard, re-asserted after a whole-file rewrite: pnpm cannot exchange an OIDC
# token, so the publish step must still shell out to npm.
run_check "publish-uses-npm-not-pnpm" bash -c 'publish_step | grep -qE "^[[:space:]]*npm publish([[:space:]]|\$)"'
run_check "oidc-permissions-intact"    bash -c 'publish_code | grep -q "id-token: write" && publish_code | grep -q "contents: read"'
run_check "no-npm-secret-in-ci"        bash -c '! grep -vE "^[[:space:]]*#" .github/workflows/release.yml | grep -qE "NODE_AUTH_TOKEN|secrets\."'

# ── Req 4: the honesty fixes ───────────────────────────────────────────
APP=artifacts/chitra-docs/src/App.tsx
# S38 bumped the real version to 0.2.0 and never touched this pill — it still read
# `v0.1.0 · npm` on the live site. A version pill that lags the manifest is a lie
# the founder's own front door shows, so the check pins it to the manifest.
run_check "hero-pill-matches-version"  bash -c 'grep -q "v0.3.0 · npm" $APP && ! grep -q "v0.1.0 · npm" $APP'
run_check "no-stale-types-chitra-note" bash -c "! grep -q '@types/chitra' $APP"
# Req 4 — `charts.ts` is GENERATED. Prove it with the real gate, not a grep: a
# hand-edit that happens to contain the new name would pass any string check and
# then be reverted by the next `gen:charts`.
run_check "charts-generated-not-edited" pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Req 6 + 7: the registry (red until the tag is cut — legitimately) ─────
run_check "new-package-published"      bash -c '[ "$(npm view @ifelse.codes/chitra@0.3.0 version 2>/dev/null)" = "0.3.0" ]'
# The old package must still exist (npm cannot rename) AND point at the new one.
# This IS publicly assertable — no npm auth needed — so it is a real gate, not a
# founder attestation.
run_check "old-package-deprecated"    bash -c 'npm view @ifelse.codes/core deprecated 2>/dev/null | grep -q "@ifelse.codes/chitra"'
run_check "old-version-still-intact"   bash -c '[ "$(npm view @ifelse.codes/core@0.2.0 version 2>/dev/null)" = "0.2.0" ]'

npm_epoch() {
  local t="${1%%.*}"
  date -j -u -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null \
    || date -u -d "${1%Z}" +%s 2>/dev/null \
    || echo ""
}
export -f npm_epoch   # run_check uses `bash -c`; unexported functions are invisible there
# "Unattended" is a claim about *who* published, so it needs a falsifier, not an
# assumption. npm's authoritative publish time is `time[<version>]` in the
# packument; the workflow's start is the run's `createdAt`. Require publish >=
# run-start: a human publishing locally first would show the reverse.
# (Read the whole time map and index the key — `npm view pkg time.0.3.0` parses
# the dots as a nested field path and silently yields nothing. S38's lesson.)
run_check "published-after-run-start"  bash -c '
  NPM_T="$(npm view @ifelse.codes/chitra time --json 2>/dev/null | node -e "let s=\"\";process.stdin.on(\"data\",d=>s+=d).on(\"end\",()=>{try{process.stdout.write(JSON.parse(s)[\"0.3.0\"]||\"\")}catch(e){}})")"
  RUN_T="$(gh run list --repo ifelse-codes/chitra --workflow release.yml --limit 30 --json headBranch,createdAt \
            --jq ".[] | select(.headBranch==\"v0.3.0\") | .createdAt" | head -1)"
  [ -n "$NPM_T" ] && [ -n "$RUN_T" ] || exit 1
  N="$(npm_epoch "$NPM_T")"; R="$(npm_epoch "$RUN_T")"
  [ -n "$N" ] && [ -n "$R" ] || exit 1
  [ "$N" -ge "$R" ]'
run_check "run-actually-succeeded"     bash -c "gh run list --repo ifelse-codes/chitra --workflow release.yml --limit 30 --json headBranch,conclusion --jq '.[] | select(.headBranch==\"v0.3.0\") | .conclusion' | grep -q success"

# ── Req 9: session invariants ──────────────────────────────────────────
run_check "prompt-exists"             test -f prompts/39-task-rename-chitra.md
run_check "core-tests-452"            bash -c "pnpm --filter $NEW run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"            pnpm --filter @ifelse.codes/chitra run typecheck
run_check "core-build"                pnpm --filter @ifelse.codes/chitra run build
run_check "docs-typecheck"            pnpm --filter @workspace/chitra-docs run typecheck
run_check "lockfile-frozen"           pnpm install --frozen-lockfile
# The MCP server is founder-DEFERRED. A keyword claiming it ships is a promise
# nobody kept, so assert the absence of the thing, not the presence of a note.
run_check "mcp-server-still-not-built" bash -c "! ls packages | grep -qi mcp"
# The rule this guards: the work happened on a session branch and reached main via
# PR, never a direct commit. Derived, not hardcoded to a PR number (rot), and
# squash-merge makes the branch tip a non-ancestor, so ancestry is the wrong test.
run_check "pr-from-session-branch"    bash -c "[ -n \"\$(gh pr list --repo ifelse-codes/chitra --state merged --limit 50 --json headRefName --jq '.[] | select(.headRefName | startswith(\"session-39-\")) | .headRefName' | head -1)\" ]"

( cd ".ai/verify/session-39" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 39 Verify Summary ==="
printf '%-36s %s\n' "CHECK" "RESULT"
printf '%-36s %s\n' "------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
