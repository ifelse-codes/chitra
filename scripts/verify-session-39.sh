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
# reads must be exported — an unexported `$APP` expands to nothing inside the
# subshell, and `grep -q PATTERN` with no file then reads stdin and fails. This
# is the S38 authoring trap, hit again by the same author; export once, here.
APP=artifacts/chitra-docs/src/App.tsx
export -f publish_body publish_code publish_step wf_code main_name main_field
export PKG REL OLD NEW APP

# ── Req 1 + 2: the package identity, read from the committed file ─────────
run_check "pkg-name-is-chitra"        bash -c 'node -p "require(\"./$PKG\").name" | grep -qx "$NEW"'
run_check "pkg-version-is-0.3.0"      bash -c 'node -p "require(\"./$PKG\").version" | grep -qx 0.3.0'
# Reads the *committed* name out of origin/main, not the working tree: the claim
# is that the rename reached main via a PR, not that it exists in my checkout.
# NB: this must COMPARE. `run_check "…" main_name` alone is green on any value
# the function can print — the function's exit status is `node`'s, not the
# comparison's. That version shipped in the first draft of this script and
# passed against a main that still said `@ifelse.codes/core`.
run_check "main-carries-new-name"     bash -c 'got="$(main_name)"; [ "$got" = "$NEW" ] || { echo "origin/main says: $got  (expected $NEW)"; exit 1; }'
run_check "main-version-is-0.3.0"     bash -c 'got="$(main_field version)"; [ "$got" = "0.3.0" ] || { echo "origin/main version: $got  (expected 0.3.0)"; exit 1; }'
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
  hits="$(git ls-files "*.ts" "*.tsx" "*.mjs" "*.js" "*.json" "*.yml" "*.yaml" "*.html" \
    | grep -vE "^(sessions|prompts/[0-3][0-8]-|scripts/verify-session-|scripts/demo-session-|scripts/workflows/)" \
    | xargs grep -l -- "$OLD" 2>/dev/null || true)"
  [ -z "$hits" ] || { echo "old name still in:"; echo "$hits"; exit 1; }'
run_check "old-name-not-in-installs"  bash -c '
  ! grep -rE "(npm|pnpm|yarn) (install|add) $OLD|from \"$OLD\"|npmjs\.com/package/$OLD|--filter $OLD" \
      README.md packages/core/README.md CONTRIBUTING.md replit.md artifacts/chitra-docs/src 2>/dev/null'
# An ARRAY, and an explicit existence test per entry. Two reasons, both learned
# the hard way writing this session's demo: an unquoted `for f in a b c` word list
# is subject to globbing/splitting and was demonstrably handed a mangled entry
# (once reporting "no new name" for a file that plainly has it), and a MISSING
# file makes grep exit 2 — which a bare `grep -q || exit 1` cannot tell apart
# from "the name is absent". A check that cannot tell those apart reports
# confidently and wrongly.
run_check "new-name-in-every-live-doc" bash -c '
  LIVE=(README.md CONTRIBUTING.md replit.md packages/core/README.md packages/core/CHANGELOG.md
        .github/workflows/ci.yml .github/workflows/release.yml
        artifacts/chitra-docs/package.json)
  for f in "${LIVE[@]}"; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    grep -q -F -- "$NEW" "$f" || { echo "MISSING new name in $f"; exit 1; }
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
# Named "in CI" but read one file. A token reintroduced into ci.yml would have
# passed. Both workflows are in scope; the point of the check is that NO npm
# credential exists anywhere in the automation, not that one file is clean.
run_check "no-npm-secret-in-ci"        bash -c '
  hits="$(cat .github/workflows/*.yml | grep -vE "^[[:space:]]*#" | grep -nE "NODE_AUTH_TOKEN|secrets\." || true)"
  [ -z "$hits" ] || { echo "an npm credential reappeared in CI:"; echo "$hits"; exit 1; }'

# ── Req 4: the honesty fixes ───────────────────────────────────────────
# S38 bumped the real version to 0.2.0 and never touched this pill — it still read
# `v0.1.0 · npm` on the live site. A version pill that lags the manifest is a lie the
# founder's own front door shows.
#
# The first version of this check grepped the literal "v0.3.0 · npm" while its own
# comment claimed it "pins it to the manifest". It pinned it to nothing: bump the
# manifest to 0.4.0, update everything else, forget the pill, and the check still
# passed while the exact drift it exists to catch recurred. A comment that asserts a
# property the code does not have is worse than no comment — so DERIVE the wanted
# string from the manifest and assert the pill is the ONLY version pill present.
run_check "hero-pill-matches-version" bash -c '
  want="v$(node -p "require(\"./$PKG\").version") · npm"
  found="$(grep -oE "v[0-9]+\.[0-9]+\.[0-9]+ · npm" "$APP" | sort -u | tr "\n" "," | sed "s/,$//")"
  [ "$found" = "$want" ] \
    || { echo "hero pill reads [$found]; manifest demands [$want]"; exit 1; }'
run_check "no-stale-types-chitra-note" bash -c "! grep -q '@types/chitra' $APP"
# Req 4 — `charts.ts` is GENERATED. Prove it with the real gate, not a grep: a
# hand-edit that happens to contain the new name would pass any string check and
# then be reverted by the next `gen:charts`.

# ── Req 6 + 7: the registry (red until the tag is cut — legitimately) ─────
run_check "new-package-published"      bash -c '[ "$(npm view @ifelse.codes/chitra@0.3.0 version 2>/dev/null)" = "0.3.0" ]'
# The old package must still exist (npm cannot rename) AND point at the new one.
# This IS publicly assertable — no npm auth needed — so it is a real gate, not a
# founder attestation.
# Founder decision 2026-09-29: do NOT deprecate the old package (no public release,
# no external user to redirect). An earlier version of this check asserted the
# deprecation WAS present, which would have gone permanently red against a
# deliberate decision — pressuring a revert of a sound call.
#
# What is worth guarding: a reader-facing surface must not claim a registry state we
# have not observed. The rename notices added earlier this session said "deprecated
# on npm"; the deprecate was then dropped, and those sentences would have shipped.
#
# SCOPE — reader-facing surfaces ONLY. A first cut also swept the contract and the
# live `.ai/` files, and went red on sixteen lines, all of them legitimate: those
# files are the *record of the decision not to deprecate*, and they have to be able
# to say so. A claim in a record is not a lie; a claim on the npm page is. Silencing
# the record to satisfy a check is how a check gets quietened until it guards nothing.
# The internal record is covered by `no-rename-notice-shipped` instead, which
# constrains what a reader is shown, not what we are allowed to write down.
#
# PATTERN — pair a deprecation word with OUR old package name, and drop negated
# lines ("is NOT deprecated", "Do NOT deprecate") so the check does not fire on the
# very documents that record the decision. `\b` guards stop "Note:" reading as "no".
run_check "no-false-deprecation-claim" bash -c '
  hits="$(grep -rniE "deprecat" \
      README.md CONTRIBUTING.md replit.md \
      packages/core/README.md packages/core/CHANGELOG.md packages/core/package.json \
      artifacts/chitra-docs/index.html artifacts/chitra-docs/src \
      2>/dev/null \
    | grep -E "@ifelse\.codes/core|@chitra/core" \
    | grep -viE "\b(not|never|no|non)\b[^.]{0,24}deprecat" \
    || true)"
  [ -z "$hits" ] || { echo "a reader-facing surface claims the old package is deprecated; it never was:"; echo "$hits"; exit 1; }'
# The founder's decision was not "reword the notice", it was: *the docs point at
# @ifelse.codes/chitra and nothing else*. So do not try to enumerate the phrasings a
# migration banner might use — the first cut regexed for "renamed (at|to)|formerly|
# was ...core" and a cold review showed it goes green on the three most natural
# forms ("@ifelse.codes/core → @ifelse.codes/chitra", "is now", "Update your
# imports"). Phrase-matching a rule this absolute is whack-a-mole. The rule IS the
# absence: the old name must not appear in a reader-facing surface at all.
#
# packages/core/CHANGELOG.md is deliberately excluded — it is a record of what a
# release changed, not a notice to a user, and it must be able to say what the old
# name was.
run_check "no-rename-notice-shipped" bash -c '
  # artifacts/chitra-docs/index.html is in scope for a reason a cold review pointed out:
  # it is the Vite entry carrying the <title> and meta description a search engine
  # actually indexes — the most reader-facing surface in the repo. A guard that stops
  # at src/ while claiming "a reader-facing surface at all" is a comment lying about
  # its own code, which is the exact defect class this session exists to remove.
  hits="$(grep -rnF -- "$OLD" \
      README.md CONTRIBUTING.md replit.md \
      packages/core/README.md \
      artifacts/chitra-docs/index.html \
      artifacts/chitra-docs/src \
      2>/dev/null || true)"
  [ -z "$hits" ] || { echo "the old name is still in a reader-facing surface:"; echo "$hits"; exit 1; }'
# The same idea for the live .ai/ snapshots — but NOT "never mention the old name".
# That version was wrong: STATE.md is *supposed* to say the old package is not
# deprecated, and to note that frozen files still name it. Zero-occurrence there
# would force deleting true, useful statements — which is how a guard gets
# quietened until it guards nothing. The rule is the opposite: each live file must
# NAME THE NEW PACKAGE, so a reader landing there cannot come away thinking the old
# name is current.
# `.ai/CONTINUATION-PROMPT.md` was left out of this list by a cold review: the contract
# names seven .ai/ files and this one had no check, while `old-name-gone-from-code` globs
# only code/config extensions and can never see a .md. It is in now.
#
# `.ai/GT-REMEDIATIONS.md` is deliberately EXCLUDED, and that is a decision rather than an
# oversight. It is the ledger of what the S35 ground truth found — its row 2 records that
# S37 published `@ifelse.codes/core@0.1.0`. A record has to be able to say what was true
# then; making it name the current package would rewrite history to satisfy a check. Same
# reasoning as no-rename-notice-shipped excluding the CHANGELOG. That is the third time
# this pattern has bitten in one session, which is why it is written down here.
#
# [ -f ] first: a missing file is a different failure from a stale one, and an earlier
# version of this very check recorded that lesson in its comment while omitting it.
run_check "live-ai-files-state-the-present" bash -c '
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md .ai/ROADMAP.md \
           .ai/KNOWLEDGE.md .ai/CONTINUATION-PROMPT.md; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    grep -qF -- "$NEW" "$f" \
      || { echo "$f never names $NEW — a reader would take the old name as current"; exit 1; }
  done'
run_check "knowledge-header-is-current" bash -c '
  grep -qF -- "$NEW" .ai/KNOWLEDGE.md \
    || { echo "KNOWLEDGE.md never names $NEW in its permanent-facts header"; exit 1; }
  head -12 .ai/KNOWLEDGE.md | grep -qF -- "$NEW" \
    || { echo "KNOWLEDGE.md \"What chitra is\" still names the old package"; exit 1; }'
# The old package still resolves, and that is the *only* registry fact about it we
# assert. It is true, observable without auth, and worth pinning: if the old name ever
# disappears, the story in CHANGELOG ("shipped as @ifelse.codes/core through 0.2.0")
# becomes unfalsifiable.
run_check "old-version-still-intact"   bash -c '[ "$(npm view @ifelse.codes/core@0.2.0 version 2>/dev/null)" = "0.2.0" ]'

npm_epoch() {
  local t="${1%%.*}"
  date -j -u -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null \
    || date -u -d "${1%Z}" +%s 2>/dev/null \
    || echo ""
}
export -f npm_epoch   # run_check uses `bash -c`; unexported functions are invisible there
# ── WHO published 0.3.0? The honest answer is "not CI", and that must be
# ASSERTED rather than left to a check that quietly goes green.
#
# S38's `published-after-run-start` compared npm's publish time to the run's
# start. For 0.3.0 that comparison PASSES — 13:30:46Z >= 09:06:11Z — while being
# completely false: the publish job FAILED at 09:07:31Z and a human published
# 13:30:46Z. The check cannot distinguish "CI published 2 min into the run" from
# "CI died and a human published 4 h later". Keeping it would have been a falsely
# green gate inside the very session whose review exists to kill that class.
#
# Three observable facts pin the truth instead, and all three must hold:
#   (1) attempt 1's publish job FAILED  -> CI never published on the first pass
#   (2) attempt 2's publish job SKIPPED -> CI never published on the retry
#   (3) npm's publish time PRECEDES attempt 2's publish-job start
#       -> the version was already on npm before CI's only successful attempt
#          began, so neither attempt can have produced it
# Falsifiable in both directions: if a future run really did publish 0.3.0, (1)
# and (3) break and this goes red.
RUN_ID=36546969338
attempt_job() {  # attempt_job <n> -> "<conclusion> <started_at> <completed_at>"
  gh api "repos/ifelse-codes/chitra/actions/runs/$RUN_ID/attempts/$1/jobs" \
    --jq '.jobs[] | select(.name | startswith("publish")) | "\(.conclusion) \(.started_at) \(.completed_at)"' | head -1
}
npm_published_at() {
  npm view @ifelse.codes/chitra time --json 2>/dev/null \
    | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(JSON.parse(s)["0.3.0"]||"")}catch(e){}})'
}
export -f attempt_job npm_published_at npm_epoch
export RUN_ID

run_check "ci-attempt1-publish-failed"  bash -c '
  set -- $(attempt_job 1); [ "$1" = "failure" ] \
    || { echo "attempt 1 publish job: $1 (expected failure)"; exit 1; }'
run_check "ci-attempt2-publish-skipped" bash -c '
  set -- $(attempt_job 2); [ "$1" = "success" ] \
    || { echo "attempt 2 publish job: $1 (expected success via skip)"; exit 1; }
  log="$(gh run view $RUN_ID --repo ifelse-codes/chitra --log 2>/dev/null)"
  echo "$log" | grep -qF "is already on npm — skipping publish" \
    || { echo "no skip notice in the log — attempt 2 may have really published"; exit 1; }
  echo "$log" | grep -qF "Publishing to https://registry.npmjs.org/" \
    && { echo "attempt 2 DID publish — 0.3.0 would be a CI publish after all"; exit 1; }
  exit 0'
run_check "publish-not-from-ci"          bash -c '
  set -- $(attempt_job 2); a2_started="$2"
  pub="$(npm_published_at)"; [ -n "$pub" ] && [ -n "$a2_started" ] || exit 1
  P="$(npm_epoch "$pub")"; A="$(npm_epoch "$a2_started")"
  [ -n "$P" ] && [ -n "$A" ] || exit 1
  [ "$P" -lt "$A" ] \
    || { echo "publish=$pub is NOT before attempt-2 start=$a2_started — CI may have published"; exit 1; }'
run_check "release-run-green"           bash -c "gh run view $RUN_ID --repo ifelse-codes/chitra --json conclusion --jq .conclusion | grep -qx success"
# The idempotency guard is the load-bearing S39 release change: it had to be
# repointed from the old package to the new one. Attempt 2 taking the skip path
# is the behavioural proof that it aims at @ifelse.codes/chitra — a grep over
# the workflow text would not survive a dead branch (S38's hollow-check class).
run_check "idempotency-guard-behaved"   bash -c '
  gh run view $RUN_ID --repo ifelse-codes/chitra --log 2>/dev/null \
    | grep -qF "@ifelse.codes/chitra@0.3.0 is already on npm"'

# ── Req 9: session invariants ──────────────────────────────────────────
# THE GAP THIS SESSION SHIPPED PAST, then found. The rename was merged and the
# package was live on npm while the public front door still told users to run
# `npm install @chitra/core` — the name from BEFORE S37, under an npm org S37
# established the account does not own. Nothing failed: CI was green, verify was
# green, the package was on npm. A deploy is a manual step, so the site simply
# drifts, silently, until someone happens to look at it.
#
# So assert the deployed site actually carries the current name. Network-dependent
# by nature, and it FAILS CLOSED: no network or no match is red, never green.
run_check "live-site-serves-current-name" bash -c '
  html="$(curl -s --max-time 30 "https://chitra.iifelse.com/?cb=$RANDOM" 2>/dev/null || true)"
  asset="$(printf "%s" "$html" | grep -oE "/assets/index-[A-Za-z0-9_-]+\\.js" | head -1 || true)"
  [ -n "$asset" ] || { echo "could not read the live docs shell (offline, or the bundle moved)"; exit 1; }
  js="$(curl -s --max-time 30 "https://chitra.iifelse.com${asset}?cb=$RANDOM" 2>/dev/null || true)"
  [ -n "$js" ] || { echo "could not read $asset"; exit 1; }
  if printf "%s" "$js" | grep -qF -- "$NEW"; then :; else
    echo "the live site does not serve $NEW — it is stale; redeploy:"
    echo "  wrangler pages deploy dist/public --project-name=chitra --branch=main"
    exit 1
  fi
  # And the old names must be GONE, not merely outnumbered. A stale bundle
  # containing @chitra/core is exactly the failure this check exists to catch.
  for stale in "@chitra/core" "$OLD"; do
    printf "%s" "$js" | grep -qF -- "$stale" \
      && { echo "the live site still advertises $stale"; exit 1; }
  done
  exit 0'
# S38 put an "MCP tool handler — not shipped yet" rider on the README. S39's gap
# audit found the DOCS SITE never got it: the AI Agent Support page rendered a
# working-looking `server.tool("render_chart", …)` sample under a plain
# "<h2>MCP tool handler</h2>" heading, to anyone who visited. The rider is a promise
# that both surfaces keep, so assert both — a check on one file is a check that
# drifts the moment the other is edited.
run_check "mcp-rider-on-every-surface" bash -c '
  for f in README.md artifacts/chitra-docs/src/App.tsx; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    grep -qiE "not shipped yet" "$f" \
      || { echo "$f shows an MCP handler with no \"not shipped yet\" rider — nothing ships it"; exit 1; }
  done'
run_check "prompt-exists"             test -f prompts/39-task-rename-chitra.md
run_check "core-tests-452"            bash -c "pnpm --filter $NEW run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"            pnpm --filter @ifelse.codes/chitra run typecheck
run_check "core-build"                pnpm --filter @ifelse.codes/chitra run build

# Must come AFTER core-build: gen:charts:check renders through the real library,
# which resolves via packages/core/dist/ — gitignored, exactly as both workflows
# document ("Build @ifelse.codes/chitra (docs imports it)"). A cold review caught
# this running first, which made it go red on a fresh clone for the wrong reason.
run_check "charts-generated-not-edited" pnpm --filter @workspace/chitra-docs run gen:charts:check
run_check "docs-typecheck"            pnpm --filter @workspace/chitra-docs run typecheck
run_check "lockfile-frozen"           pnpm install --frozen-lockfile
# The MCP server is founder-DEFERRED. A keyword claiming it ships is a promise
# nobody kept, so assert the absence of the thing, not the presence of a note.
# Named "mcp-server-still-not-built" but implemented as `ls packages`. A stub under
# artifacts/ or lib/ would have passed. Scan the whole workspace for an MCP server
# artefact by name, and keep the "nothing ships it" claim honest in both directions.
run_check "mcp-server-still-not-built" bash -c '
  # `mcp` anywhere in a path segment, not just at a boundary: an earlier version
  # used (^|/)mcp and a cold review showed `src/server-mcp.ts` walks straight past it.
  hits="$(git ls-files | grep -iE "mcp" || true)"
  [ -z "$hits" ] || { echo "an MCP artefact exists in the tree:"; echo "$hits"; exit 1; }'
# ...and the keyword must stay dropped, which is the promise a search index reads.
run_check "mcp-not-advertised" bash -c \
  '! node -p "JSON.stringify(require(\"./$PKG\").keywords)" | grep -qiw mcp' 
# What this ACTUALLY proves: a PR whose head branch matched session-39-* was merged.
# What it does NOT prove, and a comment here once wrongly claimed: that the work
# reached main *only* that way. A direct commit of the whole rename would satisfy
# this check. Squash-merge also makes the branch tip a non-ancestor, so ancestry is
# the wrong test — hence the headRefName query. Derived, never a hardcoded PR number.
# The builder hand-typed "37/37" into five .ai/ documents; the script then grew to 40
# checks and every one of those numbers went stale. That is the same defect as the
# demo's hardcoded WORKS rows, committed as prose. A number a human maintains across
# files is a number that will be wrong, so assert it instead of trusting it: any
# "N/N" score quoted in a live .ai/ file must have N == the script's real check count.
run_check "ai-docs-quote-real-score" bash -c '
  want="$(grep -c "^run_check " scripts/verify-session-39.sh)"
  for f in .ai/STATE.md .ai/TASK.md .ai/SESSION-BOOT.md .ai/ROADMAP.md .ai/CONTINUATION-PROMPT.md; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    # Only scores on lines that name the script. "4/4" (release jobs) and "452/452"
    # (tests) are real scores that have nothing to do with this gate, and a first cut
    # that scanned every "N/N" in the file flagged both.
    bad="$(grep -F "verify-session-39.sh" "$f" 2>/dev/null \
             | grep -oE "[0-9]+/[0-9]+" | grep -vE "^$want/$want$" || true)"
    [ -z "$bad" ] || { echo "$f quotes a verify score that is not $want/$want:"; echo "$bad"; exit 1; }
  done'
run_check "pr-from-session-branch"    bash -c "[ -n \"\$(gh pr list --repo ifelse-codes/chitra --state merged --limit 50 --json headRefName --jq '.[] | select(.headRefName | startswith(\"session-39-\")) | .headRefName' | head -1)\" ]"

( cd ".ai/verify/session-39" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 39 Verify Summary ==="
printf '%-36s %s\n' "CHECK" "RESULT"
printf '%-36s %s\n' "------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
