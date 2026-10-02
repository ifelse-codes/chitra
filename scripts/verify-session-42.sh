#!/usr/bin/env bash
# S42 — cleanup Batch 2: dead weight. The repo ships the library, not the
# scaffold it came from.
#
# Design rules carried from S38/S39/S40/S41:
#   * assert FACTS, not phrases — a check coupled to a string is not a guard;
#   * a check that cannot fail is a bug — every check here has a demonstrated
#     counterfactual, noted beside it;
#   * a DISCOVERED inventory beats an enumerated one. This session exists
#     because S41's gate enumerated two vite configs by path, and deleting
#     one of them turned the gate red.
#
# INHERITANCE. This is a PORT of verify-session-41.sh, not a copy. Exactly two
# of the 24 inherited checks are re-expressed, and both re-expressions are
# forced by requirement 1:
#
#   vite-configs-no-hard-throw -> vite-configs-discovered   (named a deleted path)
#   ai-files-describe-s41      -> ai-files-describe-s42    (this session)
#
# The third inherited check that referenced a deleted path,
# test-count-propagated, exempted attached_assets/ — a directory this session
# deletes. The exemption is dropped rather than left as dead prose, and the
# script's own path is exempted in its place.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-42/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

CORE=packages/core
DOCS=artifacts/chitra-docs

# The four trees requirement 1 deletes, named once so the deletion checks and
# the reference check cannot drift apart.
DEAD_TREES="artifacts/mockup-sandbox lib artifacts/api-server attached_assets"
DEAD_SCRIPTS="scripts/post-merge.sh scripts/check-hero-dims.py \
scripts/ring-polish-handoff.mjs scripts/workflows/15-qacheck.sh \
scripts/src/hello.ts scripts/src/demo09-donut.ts"

# ═══════════════════════════════════════════════ inherited from S41 · group A: facts

run_check "version-src-matches-manifest" node scripts/sync-version.mjs --check

run_check "version-in-built-dist" bash -c '
  set -e
  pnpm --filter @ifelse.codes/chitra run build >/dev/null 2>&1
  d="$(node -e "import(\"./packages/core/dist/index.js\").then(m => console.log(m.VERSION))")"
  m="$(node -p "require(\"./packages/core/package.json\").version")"
  [ "$d" = "$m" ] || { echo "dist says $d, manifest says $m"; exit 1; }
  echo "dist VERSION == manifest ($m)"'

run_check "no-stale-version-literal" bash -c '
  hits="$(grep -rn "0\.1\.0" '"$CORE"'/dist/ 2>/dev/null || true)"
  [ -z "$hits" ] || { echo "$hits"; exit 1; }
  ! grep -qE "VERSION\s*=\s*\"0." '"$CORE"'/src/index.ts || { echo "src/index.ts restates a literal version"; exit 1; }
  echo "no 0.1.0 in dist; src/index.ts derives"'

run_check "docs-meta-not-scaffold" bash -c '
  set -e
  ! grep -qi "replit" '"$DOCS"'/index.html || { echo "placeholder still in source"; exit 1; }
  pnpm --filter @workspace/chitra-docs run build >/dev/null 2>&1
  out=$(ls -d '"$DOCS"'/dist/public/index.html 2>/dev/null || ls -d '"$DOCS"'/dist/index.html)
  ! grep -qi "replit" "$out" || { echo "placeholder still in BUILT page: $out"; exit 1; }
  grep -q "chitra" "$out" || { echo "no product line in built page"; exit 1; }
  echo "built page clean: $out"'

run_check "npm-readme-no-design-log" bash -c '
  n=$(grep -c "LOCKED:" '"$CORE"'/README.md || true)
  [ "$n" -eq 0 ] || { echo "$n LOCKED sections still in the npm README"; exit 1; }
  ! grep -qE "session [0-9]{2} design" '"$CORE"'/README.md || { echo "internal session refs remain"; exit 1; }
  ! grep -q "block (default for line)" '"$CORE"'/README.md || { echo "phantom line renderer still documented"; exit 1; }
  echo "npm README: no design log, no phantom renderer"'

run_check "contributing-claims-true" bash -c '
  f=CONTRIBUTING.md
  ! grep -q "chitra-dev/chitra" $f || { echo "wrong clone org"; exit 1; }
  grep -q "ifelse-codes/chitra" $f || { echo "correct clone org missing"; exit 1; }
  ! grep -q "experimental-specifier-resolution" $f || { echo "dead run command"; exit 1; }
  grep -q "pnpm example" $f || { echo "working run command missing"; exit 1; }
  grep -q "toContent()" $f || { echo "ChartResult template still omits toContent()"; exit 1; }
  ! grep -q ">90% test coverage" $f || { echo "unmeasured >90% claim still there"; exit 1; }
  echo "CONTRIBUTING: 5 claims reconciled"'

run_check "replit-node-matches-ci" bash -c '
  v="$(grep -oE "NODE_VERSION: *\"[0-9]+\"" .github/workflows/ci.yml | grep -oE "[0-9]+")"
  grep -q "Node.js $v" replit.md || { echo "replit.md does not say Node $v"; exit 1; }
  ! grep -q "20/22/24" replit.md || { echo "replit.md still claims a CI matrix that does not exist"; exit 1; }
  grep -q "toContent" replit.md || { echo "ChartResult list in replit.md omits toContent"; exit 1; }
  echo "replit.md agrees with ci.yml (Node $v)"'

run_check "provenance-comment-state-agnostic" bash -c '
  f=.github/workflows/release.yml
  grep -qi "private" $f || { echo "no mention of the private-repo condition"; exit 1; }
  grep -qi "public" $f || { echo "no mention of the public case"; exit 1; }
  ! grep -qi "would turn provenance on" $f || { echo "the stale pre-flip claim is still here"; exit 1; }
  echo "provenance comment reads correctly in both repo states"'

run_check "no-public-doc-points-into-ai" bash -c '
  bad="$(grep -n "\.ai/" README.md CONTRIBUTING.md replit.md 2>/dev/null || true)"
  [ -z "$bad" ] || { echo "$bad"; exit 1; }
  echo "no public doc references .ai/"'

# ═══════════════════════════════════════════════ inherited from S41 · group B: build

# RE-EXPRESSED (was: vite-configs-no-hard-throw).
#
# S41 enumerated two paths in a `for` loop, one of them
# artifacts/mockup-sandbox/vite.config.ts. Requirement 1 deleted it, and the
# inherited check then exits 1:
#
#   grep: artifacts/mockup-sandbox/vite.config.ts: No such file or directory
#   artifacts/mockup-sandbox/vite.config.ts does not default PORT
#
# So the inventory is DISCOVERED. Two counterfactuals, both demonstrated when
# this check was written:
#   1. restore a vite config that hard-throws the Replit env  -> fails
#   2. rename every vite.config.ts out of the way               -> fails
# Counterfactual 2 is the one that matters: an empty discovered list is the
# vacuous pass the S41 cold review caught in a different check.
run_check "vite-configs-discovered" bash -c '
  files=$(git ls-files | grep -E "(^|/)vite\.config\.[a-z]+$" | grep -v node_modules)
  [ -n "$files" ] || { echo "no vite config discovered — the glob is broken, not the repo clean"; exit 1; }
  n=0
  for f in $files; do
    n=$((n+1))
    # (1) the hard throw itself. Asserted on the string because that is the
    # defect: the config refused to load without the Replit env.
    if grep -q "is required but was not provided" "$f"; then
      echo "$f still hard-throws on the Replit env"; exit 1
    fi
    # (2) an undefaulted read of PORT or BASE_PATH. Conditional on the config
    # reading it at all, so a config that does not use the Replit env is not
    # forced to pretend it does — and the conditional cannot go vacuous,
    # because counterfactual 1 removes the string entirely.
    for v in PORT BASE_PATH; do
      if grep -qE "process\.env\.$v\b" "$f"; then
        grep -qE "process\.env\.$v\s*\?\?" "$f" \
          || { echo "$f reads $v with no default"; exit 1; }
      fi
    done
  done
  echo "$n vite config(s) discovered; none hard-throws, no undefaulted env read"'

run_check "workspace-glob-real" bash -c '
  globs=$(awk "/^packages:/{f=1;next} /^[a-zA-Z]/{f=0} f && /^  - /{print \$2}" pnpm-workspace.yaml)
  [ -n "$globs" ] || { echo "no workspace globs parsed — the parser is broken"; exit 1; }
  for g in $globs; do
    case "$g" in
      *\**) ls -d ${g%/\*} >/dev/null 2>&1 || { echo "glob $g matches nothing"; exit 1; } ;;
      *)   [ -e "$g" ] || { echo "workspace entry $g does not exist"; exit 1; } ;;
    esac
  done
  echo "every workspace glob matches something ($globs)"'

run_check "fresh-clone-build-no-env" bash -c '
  set -e
  d=$(mktemp -d)
  trap "rm -rf $d" EXIT
  git clone --local -q '"$ROOT"' "$d/clone"
  cd "$d/clone"
  [ ! -d packages/core/dist ] || { echo "dist leaked into the clone"; exit 1; }
  pnpm install --frozen-lockfile >/dev/null 2>&1
  env -u PORT -u BASE_PATH pnpm run build >"$d/build.log" 2>&1 || { tail -30 "$d/build.log"; exit 1; }
  echo "fresh clone: install + build, no env, exit 0"'

# ═══════════════════════════════════════════════ inherited from S41 · the product

run_check "core-tests" bash -c "pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -qE 'Tests +45[0-9] passed'"
run_check "core-typecheck"        bash -c "pnpm --filter @ifelse.codes/chitra run typecheck"
run_check "root-typecheck"        bash -c "pnpm run typecheck"
run_check "coverage-gate-passes"  bash -c "pnpm --filter @ifelse.codes/chitra run test:coverage"
run_check "chart-drift"           bash -c "pnpm --filter @workspace/chitra-docs run gen:charts:check"
run_check "s39-suite-still-green" bash -c "bash scripts/verify-session-39.sh"

run_check "no-machine-path-junk" bash -c '
  bad="$(git status --porcelain --untracked-files=all | awk "{print \$2}" \
         | grep -E "command-code-session|\.commandcode|\.freebuff" || true)"
  [ -z "$bad" ] || { echo "untracked machine-path files present: $bad"; exit 1; }
  for f in command-code-session-8b98ceae.html scripts/build-audit-html.mjs jev-readiness-plan.md .ai/CHITRA-FRAME-FIX.md; do
    [ ! -e "$f" ] || { echo "$f was supposed to be deleted"; exit 1; }
    ! git ls-files --error-unmatch "$f" >/dev/null 2>&1 || { echo "$f is tracked"; exit 1; }
  done
  echo "junk deleted, nothing machine-specific untracked"'

run_check "charts-untouched" bash -c '
  d="$(git diff --name-only main...HEAD -- '"$CORE"'/src/charts/ '"$CORE"'/src/renderers/ '"$CORE"'/src/themes/ | wc -l | tr -d " ")"
  [ "$d" = "0" ] || { echo "$d files changed under the LOCKED design language"; exit 1; }
  echo "no changes under src/charts, src/renderers, src/themes"'

run_check "example-runs" bash -c '
  out="$(pnpm example 2>&1)" || { echo "$out" | tail -20; exit 1; }
  echo "$out" | grep -q "Revenue Trend" || { echo "example ran but rendered no chart"; exit 1; }
  echo "pnpm example exited 0 and rendered a chart"'

# CONTRIBUTING publishes four coverage figures. Those are the last hand-written
# public numbers in the repo, and this session's whole thesis is that hand-written
# numbers rot. So they are computed and compared, not pattern-matched.
#
# PORTED VERBATIM from verify-session-41.sh. An earlier draft of this file
# rewrote the measurement to read coverage-summary.json through node. That was
# unnecessary and wrong: the S41 cold review spent passes hardening this check,
# and a port that silently changes how a check measures is how a gate rots
# without anybody noticing. The implementation below is S41's, unchanged.
#
# Honest note on stability, carried from S41: branch coverage is genuinely
# BIMODAL at ±0.01, so this compares to one hundredth and CONTRIBUTING
# publishes the range. Exact equality made this a coin flip.
run_check "contributing-coverage-numbers-real" bash -c '
  set -e
  out=$(pnpm --filter @ifelse.codes/chitra run test:coverage 2>&1)
  row=$(echo "$out" | grep -E "^All files" | head -1)
  [ -n "$row" ] || { echo "no All files row in the coverage output"; exit 1; }
  # Read the four numeric cells after the first "|". Parsing by field position was
  # wrong once already (the row is "All files | a | b | c | d").
  nums=$(echo "$row" | sed "s/^[^|]*|//" | tr "|" "\n" | tr -d " " \
         | grep -E "^[0-9]+(\\.[0-9]+)?$" | head -4 | tr "\n" " ")
  set -- $nums
  [ "$#" -eq 4 ] || { echo "could not read four coverage numbers from: $row"; exit 1; }

  # What CONTRIBUTING publishes: four figures, each optionally a range "a-b".
  # NOTE: the measured values must be captured into named variables BEFORE the
  # published ones overwrite "$@" — the first version of this check did it the
  # other way round, so it compared each published figure against ITSELF and
  # passed no matter what was written. Found by running the counterfactual.
  set -- $nums
  e1=$1; e2=$2; e3=$3; e4=$4
  pub=$(grep -oE "[0-9]{2}\\.[0-9]{2}(–[0-9]{2}\\.[0-9]{2})?" CONTRIBUTING.md | head -4 | tr "\n" " ")
  set -- $pub
  [ "$#" -eq 4 ] || { echo "could not read four published figures from CONTRIBUTING.md"; exit 1; }

  i=0
  for p in "$@"; do
    i=$((i+1))
    lo="${p%%–*}"; hi="${p##*–}"
    m=$(eval echo \$e$i)
    ok=1
    for v in "$lo" "$hi"; do
      d=$(awk -v a="$v" -v b="$m" "BEGIN{d=a-b; if(d<0)d=-d; printf \"%.4f\", d}")
      awk -v d="$d" "BEGIN{exit !(d <= 0.0101)}" || ok=0
    done
    if [ "$ok" -ne 1 ]; then
      echo "CONTRIBUTING figure $i ($p) does not match the measured ${m}."
      exit 1
    fi
  done
  echo "CONTRIBUTING publishes figures within one hundredth of measured ($nums)"'

# ═══════════════════════════════════════════════ inherited, re-expressed

# RE-EXPRESSED (was: ai-files-describe-s41). Same shape, this session's number
# and branch. STATE.md is IN the list because requirement 9 names it — the S41
# version's first cut omitted the file its author deferred to closeout, and so
# could not see that it still narrated S40. A guard that enumerates only the
# files its author happened to touch is not a guard.
run_check "ai-files-describe-s42" bash -c '
  want=$(cat .ai/SESSION)
  [ "$want" = "42" ] || { echo ".ai/SESSION reads $want, not 42"; exit 1; }
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    grep -q "session-42-dead-weight" "$f" || { echo "$f does not name the live branch"; exit 1; }
  done
  # The S41 clause for "STATE.md must not narrate the previous session" was a
  # bare substring test for the words "cleanup Batch 1". It is REMOVED here, not
  # kept alongside: a phrase standing in for a structural claim, and wrong the
  # moment the milestones list mentions Batch 1 in the PAST tense, which it must
  # -- so it was asserting on prose, and would have forced STATE.md to stop
  # recording history. These two assert on the SECTIONS instead: the live branch
  # section names this session, and the In Progress section names S42.
  ab=$(awk "/^## Active Branch/{f=1;next} /^## /{f=0} f" .ai/STATE.md)
  [ -n "$ab" ] || { echo "STATE.md has no Active Branch section"; exit 1; }
  echo "$ab" | grep -q "session-42-dead-weight" || { echo "Active Branch does not name session-42-dead-weight"; exit 1; }
  echo "$ab" | grep -q "session-41-repo-cleanup" && { echo "Active Branch still names the S41 branch"; exit 1; }
  ip=$(awk "/^## What Is In Progress/{f=1;next} /^## /{f=0} f" .ai/STATE.md)
  [ -n "$ip" ] || { echo "STATE.md has no What Is In Progress section"; exit 1; }
  echo "$ip" | grep -q "S42" || { echo "the In Progress section does not name S42"; exit 1; }
  for s in 42 43 44; do
    grep -q "Session $s (S$s)" .ai/ROADMAP.md || { echo "ROADMAP.md has no Session $s item"; exit 1; }
  done
  echo ".ai/ describes S42 on this branch; S43-S44 scheduled"'

# INHERITED with one amendment: S41 exempted attached_assets/ here, a directory
# this session deletes. That exemption is dropped rather than kept as dead
# prose, and this script is exempted in its place for the same reason S41
# exempted itself — it names the canonical count only to explain the trap.
run_check "test-count-propagated" bash -c '
  n=$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE "Tests +[0-9]+ passed" | grep -oE "[0-9]+")
  [ -n "$n" ] || { echo "could not derive the count from the suite"; exit 1; }
  # PORTED from verify-session-41.sh with demo-41 -> demo-42. The first version
  # of this port INVENTED three idioms instead of copying them: it grepped
  # README and CONTRIBUTING for "(453 tests" and App.tsx for "**453 green**".
  # None of those three strings exists anywhere in this repo, so the check
  # failed on three files nobody had touched. The real idioms are a README
  # badge, a stat-num span, and a bolded figure PER FILE -- and a per-file idiom
  # is precisely the thing that cannot be guessed. Four guards S41 had were also
  # missing here (replit, ci.yml, KNOWLEDGE header, ROADMAP guardrail); a port
  # that quietly drops checks is not a port.
  bad=""
  grep -q "tests-$n%20passing" README.md                     || bad="$bad README-badge"
  grep -q "stat-num\">$n<" artifacts/chitra-docs/src/App.tsx || bad="$bad docs-hero"
  grep -q "($n tests)" replit.md                             || bad="$bad replit"
  grep -q "test ($n)" .github/workflows/ci.yml               || bad="$bad ci-header-comment"
  grep -q "\*\*$n tests\*\*" .ai/KNOWLEDGE.md               || bad="$bad KNOWLEDGE-header"
  grep -q "\*\*$n tests green\*\*" .ai/ROADMAP.md           || bad="$bad ROADMAP-guardrail"
  grep -q "\*\*$n green\*\*" .ai/CONTINUATION-PROMPT.md      || bad="$bad CONTINUATION-PROMPT"
  grep -q "$n/$n" .ai/SESSION-BOOT.md                        || bad="$bad SESSION-BOOT"
  grep -q "$n/$n" .ai/STATE.md                               || bad="$bad STATE"
  grep -q "($n tests" scripts/demo-session-42.sh             || bad="$bad demo-42"
  grep -q "Tests +$n passed" scripts/verify-session-39.sh    || bad="$bad verify-39"
  [ -z "$bad" ] || { echo "count is $n but these disagree:$bad"; exit 1; }

  expected=".ai/CONTINUATION-PROMPT.md
.ai/KNOWLEDGE.md
.ai/ROADMAP.md
.ai/SESSION-BOOT.md
.ai/STATE.md
.github/workflows/ci.yml
README.md
artifacts/chitra-docs/src/App.tsx
replit.md
scripts/demo-session-42.sh
scripts/verify-session-39.sh"
  found=$(git grep -lE "(^|[^0-9])$n([^0-9]|$)" -- . \
          | grep -vE "^\.ai/(GT-REMEDIATIONS|handoffs|CHITRA)" \
          | grep -vE "^sessions/" \
          | grep -vE "^prompts/" \
          | grep -vE "^scripts/verify-session-4[12]\.sh$" \
          | LC_ALL=C sort)
  if [ "$found" != "$expected" ]; then
    echo "count is $n; the set of files displaying it changed."
    diff <(echo "$expected" | LC_ALL=C sort) <(echo "$found") || true
    echo "  a new display site must be added to this check, or the stale site removed"
    exit 1
  fi
  echo "canonical count $n: 11 declared sites agree, and no other tracked file outside the exemptions displays it"'

# ═══════════════════════════════════════════════ S42 · group C: the deletions

# req 1 — the four trees are gone from the index, and nothing untracked and
# unignored survives under them.
#
# NOT "the directory is absent from disk". A first draft asserted that, and it
# is a BAD gate: mockup-sandbox/dist/ is gitignored build output, so the
# assertion is green on a fresh clone and red on the machine that happened to
# run `pnpm --filter @workspace/mockup-sandbox run build` before deleting it.
# A gate whose result depends on what the developer last ran is a coin flip.
# So this asserts the invariant instead — nothing tracked, and any surviving
# on-disk content is ignored output rather than source.
run_check "dead-trees-gone" bash -c "
  for d in $DEAD_TREES; do
    git ls-files --error-unmatch -- \"\$d\" >/dev/null 2>&1 \
      && { echo \"\$d is still tracked in git\"; exit 1; }
    n=\$(git ls-files -- \"\$d\" | wc -l | tr -d ' ')
    [ \"\$n\" = \"0\" ] || { echo \"\$n tracked files survive under \$d\"; exit 1; }
    if [ -e \"\$d\" ]; then
      stray=\$(git status --porcelain --untracked-files=all -- \"\$d\" | grep -v '^!!' || true)
      [ -z \"\$stray\" ] || { echo \"\$d holds untracked, NON-ignored files:\"; echo \"\$stray\"; exit 1; }
    fi
  done
  echo \"all 4 dead trees: 0 tracked files, no untracked source\""

# req 2 — nothing that builds, resolves or publishes names a deleted tree.
# Scoped to build/config/script files on purpose. sessions/, prompts/ and the
# two S41 audit documents are FROZEN: they record what past sessions found.
# The four excluded scripts are the two gates and the two demos that must NAME
# a deleted tree to do their job -- S41's gate hard-codes the path (that is the
# coupling this session exists to prove), and the demos show before/after.
# .ai/ is asserted separately by ai-names-no-deleted-tree, which carries its own
# declared list.
#
# The first version of this list omitted demo-session-42.sh, which the gate then
# flagged on 12 lines. The demo legitimately names every deleted tree; the
# exclusion was the bug, not the demo.
run_check "no-live-ref-to-dead-trees" bash -c "
  hits=\$(git grep -nE 'mockup-sandbox|api-server|@workspace/(db|api-)|attached_assets|@assets' -- . \
    ':!sessions' ':!prompts' ':!.ai' \
    ':!code-cleanup-plan-session-41.md' ':!independent-audit-RESULT.md' \
    ':!scripts/verify-session-41.sh' ':!scripts/demo-session-41.sh' \
    ':!scripts/verify-session-42.sh' ':!scripts/demo-session-42.sh' || true)
  [ -z \"\$hits\" ] || { echo \"\$hits\"; exit 1; }
  echo \"no build, config or script file references a deleted tree\""

# req 3 — typecheck:libs is gone from the script, from the chain, from CI, and
# from the release path. Four files asserted separately because the release
# step is the one whose silent removal ships a broken package.
run_check "typecheck-libs-gone-end-to-end" bash -c '
  ! grep -q "typecheck:libs" package.json || { echo "the root script survives"; exit 1; }
  grep -q "typecheck:libs" .github/workflows/ci.yml && { echo "a CI step survives"; exit 1; }
  grep -q "typecheck:libs" .github/workflows/release.yml && { echo "a RELEASE step survives"; exit 1; }
  grep -q "typecheck:libs" .github/workflows/*.yml && { echo "a workflow still calls it"; exit 1; }
  # And the chain it hung off must still be a real chain, not an empty script.
  grep -q "run typecheck" package.json || { echo "root typecheck is gone entirely"; exit 1; }
  [ ! -e tsconfig.json ] || { echo "the tsc --build solution file survives"; exit 1; }
  [ -e tsconfig.base.json ] || { echo "tsconfig.base.json was deleted; docs and scripts extend it"; exit 1; }
  echo "typecheck:libs absent from the script, ci.yml, release.yml and disk"'

# req 4 — the six dead scripts, plus the two references that deletion exposed.
run_check "dead-scripts-gone" bash -c "
  for f in $DEAD_SCRIPTS; do
    [ ! -e \"\$f\" ] || { echo \"\$f still exists\"; exit 1; }
    git ls-files --error-unmatch -- \"\$f\" >/dev/null 2>&1 \
      && { echo \"\$f is still tracked\"; exit 1; }
  done
  # The dangling references, which is where this check earns its keep: deleting
  # src/ left tsc failing TS18003 until the config was fixed.
  grep -q '\"hello\"' scripts/package.json && { echo \"the hello script dangles\"; exit 1; }
  grep -q 'demo09-donut' scripts/tsconfig.json && { echo \"a dead exclude entry survives\"; exit 1; }
  # And the package must still typecheck rather than quietly do nothing.
  pnpm --filter @workspace/scripts run typecheck >/dev/null 2>&1 \
    || { echo \"@workspace/scripts typecheck is red (TS18003: empty include)\"; exit 1; }
  echo \"6 dead scripts gone, 2 dangling refs cut, scripts package still green\""

# req 5 — the lockfile is in sync AND carries no dead importer. Both halves:
# a lockfile with dead importers fails --frozen-lockfile, and a lockfile that
# merely happens to be in sync with a stale workspace would pass it.
run_check "lockfile-frozen-no-dead-importers" bash -c '
  pnpm install --frozen-lockfile >/dev/null 2>&1 || { echo "--frozen-lockfile is red"; exit 1; }
  for i in artifacts/mockup-sandbox artifacts/api-server lib/api-client-react lib/api-spec lib/api-zod lib/db; do
    grep -qE "^  $i:" pnpm-lock.yaml && { echo "dead importer still in the lockfile: $i"; exit 1; }
  done
  n=$(awk "/^importers:/{f=1;next} /^[^ ]/{f=0} f && /^  [^ ]/{c++} END{print c+0}" pnpm-lock.yaml)
  echo "lockfile frozen, no dead importer, $n importers remain"'

# ═══════════════════════════════════════════════ S42 · the counterfactuals

# THE counterfactual requirement 6 asks for, and the one that proves the whole
# re-expression was necessary rather than tidy.
#
# It does NOT hand-copy S41's check body. It extracts the body from
# verify-session-41.sh and runs it, so if that file is ever edited the test
# follows the edit instead of a stale transcription of it. If the extraction
# fails the check FAILS — a guard that cannot evaluate does not pass.
#
# Expected: S41's check exits 1, because it names a path requirement 1 deleted.
# THE counterfactual requirement 6 asks for, and the one that proves the whole
# re-expression was necessary rather than tidy.
#
# It runs S41's gate UNMODIFIED — the real script, not a reconstruction. An
# earlier draft extracted the check body and eval'd it, which was wrong twice:
# the body relies on the OUTER shell expanding '"$DOCS"', an expansion lost the
# moment the text is lifted out of its quoting; and eval'ing it in-process put
# it under this script's `set -e`, where its own `grep -q ... && exit 1`
# guards kill the caller on a plain non-match. That draft exited 1 with zero
# output. Running the actual gate needs neither escape hatch.
#
# Three assertions, not one: S41 is red, it is red ON THIS CHECK, and S41's own
# log names the path requirement 1 deleted. A gate that merely failed for
# some other reason would otherwise satisfy the check.
s41_gate_goes_red() {
  local out rc log
  # set +e around the call: the gate is EXPECTED to exit 1 here, and the whole
  # point of the function is to observe that exit rather than be killed by it.
  set +e
  out=$(bash scripts/verify-session-41.sh 2>&1)
  rc=$?
  set -e
  echo "$out" | grep -E 'PASS$|FAIL$|GREEN|^RED' || true
  echo "--- S41 gate exit: $rc (expected non-zero on this branch) ---"

  [ "$rc" -ne 0 ] || { echo "S41's gate is GREEN here — the coupling claim is false"; return 1; }
  echo "$out" | grep -qE '^vite-configs-no-hard-throw[[:space:]]+FAIL' \
    || { echo "S41 is red, but NOT on vite-configs-no-hard-throw — wrong cause"; return 1; }

  # It must fail for the RIGHT reason. Reading S41's own check log is stronger
  # than asserting on our transcription of it.
  log=$(ls -1t .ai/verify/session-41/*/vite-configs-no-hard-throw.log 2>/dev/null | head -1)
  [ -n "$log" ] || { echo "S41 wrote no vite-configs-no-hard-throw log"; return 1; }
  echo "--- S41's log: $log ---"
  cat "$log"
  grep -q "mockup-sandbox/vite.config.ts" "$log" \
    || { echo "S41 failed on vite-configs for an UNRELATED reason"; return 1; }
  echo "S41's gate, run unmodified, exits $rc naming the path requirement 1 deleted"
  return 0
}
run_check "s41-gate-verbatim-goes-red" s41_gate_goes_red

# ═══════════════════════════════════════════════ S42 · the .ai/ truth (req 9)

run_check "ai-names-no-deleted-tree" bash -c '
  # The first version of this check tried to judge semantics: for each mention
  # it required a qualifier (deleted|gone|Batch 2|S42|no longer) ON THE SAME
  # LINE. It failed on STATE.md own bullet, because the qualifier sits two
  # lines below the mention. A check that demands the right word appear in the
  # right PLACE is a check on prose, and the fix would have been to reword
  # STATE.md until it passed, which is backwards.
  #
  # So it asserts what is mechanically true: the SET of .ai/ files that mention
  # a dead tree, against a declared list. A new mention site fails the gate and
  # a human decides whether it is history or a live claim. Same pattern as
  # test-count-propagated, which the S41 review forced into existence for the
  # same reason.
  tok="mockup-sandbox|api-server|api-client-react|api-zod|api-spec|attached_assets"
  found=$(git grep -lE "$tok" -- .ai 2>/dev/null \
          | grep -vE "^.ai/(GT-REMEDIATIONS|handoffs)/" \
          | LC_ALL=C sort)
  expected=".ai/KNOWLEDGE.md
.ai/ROADMAP.md
.ai/SESSION-BOOT.md
.ai/STATE.md
.ai/TASK.md"
  if [ "$found" != "$expected" ]; then
    echo "the set of .ai/ files mentioning a deleted tree changed."
    diff <(echo "$expected") <(echo "$found") || true
    echo "  add the file to this list with a reason, or remove the mention."
    exit 1
  fi
  # And the permanent-facts file must actually record the deletion, so a reader
  # of KNOWLEDGE.md is not left thinking the trees are still there.
  grep -q "Deleted in S42" .ai/KNOWLEDGE.md \
    || { echo "KNOWLEDGE.md does not record the S42 deletion"; exit 1; }
  grep -q "4893683" .ai/KNOWLEDGE.md \
    || { echo "KNOWLEDGE.md does not say where the files still live"; exit 1; }
  echo ".ai/: 5 declared mention sites, and KNOWLEDGE.md records the deletion"'

# ═══════════════════════════════════════════════ S42 · the contract (req 10)

run_check "contract-at-head" bash -c '
  c=prompts/42-task-dead-weight.md
  [ -f "$c" ] || { echo "the contract is missing"; exit 1; }
  # review-inputs-attested hashes the contract; S40 failed that gate for
  # committing no contract, so it must be in the tree, not merely on disk.
  git ls-files --error-unmatch -- "$c" >/dev/null 2>&1 || { echo "the contract is untracked"; exit 1; }
  # Every numbered requirement the gate asserts against must exist in it.
  grep -q "10 numbered requirements" "$c" || { echo "the contract does not state its requirement count"; exit 1; }
  echo "contract tracked, 10 requirements"'

# The inherited test-count-propagated check asserts the demo "displays" the
# canonical count by grepping the demo FILE for "(453 tests". That grep is
# satisfied by the string appearing in a COMMENT, which is not displaying
# anything — the same "hollow guard" shape S41's cold review rejected once.
# S41's demo passed on its comment alone.
#
# So this runs the demo and greps its OUTPUT. Non-vacuous in both directions:
# strip the runtime printf and it fails; leave a stale literal in a comment and
# it still passes, because it is reading what a reader would actually see.
run_check "demo-displays-count-at-runtime" bash -c "
  out=\$(DEMO_LOG_DIR='$ARTIFACTS' bash scripts/demo-session-42.sh 2>&1) \
    || { echo \"\$out\" | tail -10; echo 'the demo did not exit 0'; exit 1; }
  echo \"\$out\" | grep -qE '\([0-9]+ tests in [0-9]+ files\)' \
    || { echo 'the demo prints no (N tests in M files) line'; exit 1; }
  n=\$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+')
  echo \"\$out\" | grep -q \"(\$n tests in\" \
    || { echo \"the demo displays a count that is not the suite's (\$n)\"; exit 1; }
  echo \"the demo's OUTPUT carries the suite's live count (\$n tests)\""

( cd ".ai/verify/session-42" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 42 Verify Summary ==="
printf '%-38s %s\n' "CHECK" "RESULT"
printf '%-38s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]:-}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi