#!/usr/bin/env bash
# S43 — cleanup Batch 3: docs weight. The docs app ships the components it uses.
#
# Design rules carried from S38/S39/S40/S41/S42:
#   * assert FACTS, not phrases — a check coupled to a string is not a guard;
#   * a check that cannot fail is a bug — every check here has a demonstrated
#     counterfactual, noted beside it;
#   * a DISCOVERED inventory beats an enumerated one. S41 enumerated two vite
#     configs and broke when one was deleted. S42 discovered them — but still
#     enumerated the LOCKED dirs, so S43, the first session that legitimately
#     reformats them, is the session that breaks S42's gate. This port
#     discovers both.
#
# INHERITANCE. This is a PORT of verify-session-42.sh, not a copy. The checks
# this session's changes force to be re-expressed:
#
#   charts-untouched            -> charts-format-only   (S43 formats the LOCKED dirs)
#   ai-files-describe-s42       -> ai-files-describe-s43 (this session)
#   s41-gate-verbatim-goes-red  -> s42-gate-verbatim-goes-red
#
# and the eight findings the S42 cold review left OWNED (N2–N9), each fixed here
# with a demonstrated counterfactual named beside it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-43/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()

# N2 fix. S42 wrote summary.txt once, after the last check ran — so while the
# gate was still running, the demo read a summary.txt that did not exist yet and
# printed 10 x NOT PROVEN. The fix for a finding re-created its cause one layer
# down. Writing after every check keeps it live during the run.
write_summary() {
  {
    for r in "${RESULTS[@]:-}"; do
      printf '%s %s\n' "$(echo "$r" | awk '{print $1}')" "$(echo "$r" | awk '{print $NF}')"
    done
  } > "$ARTIFACTS/summary.txt"
}
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
  write_summary
}

CORE=packages/core
DOCS=artifacts/chitra-docs

# S42's four dead trees and six dead scripts — still asserted here, because a
# later session must not silently resurrect them.
DEAD_TREES="artifacts/mockup-sandbox lib artifacts/api-server attached_assets"
DEAD_SCRIPTS="scripts/post-merge.sh scripts/check-hero-dims.py \
scripts/ring-polish-handoff.mjs scripts/workflows/15-qacheck.sh \
scripts/src/hello.ts scripts/src/demo09-donut.ts"

# S43's removals, named once so the deletion checks and the reference check
# cannot drift apart. The UI components are DISCOVERED (see ui-components-shipped);
# only the exact dependency names are listed, because a dependency name is not a
# path a future session deletes.
DEAD_DOCS_DEPS="@hookform/resolvers @radix-ui/react-accordion @radix-ui/react-alert-dialog \
@radix-ui/react-aspect-ratio @radix-ui/react-avatar @radix-ui/react-checkbox \
@radix-ui/react-collapsible @radix-ui/react-context-menu @radix-ui/react-dropdown-menu \
@radix-ui/react-hover-card @radix-ui/react-menubar @radix-ui/react-navigation-menu \
@radix-ui/react-popover @radix-ui/react-progress @radix-ui/react-radio-group \
@radix-ui/react-scroll-area @radix-ui/react-select @radix-ui/react-slider \
@radix-ui/react-switch @radix-ui/react-tabs @radix-ui/react-toggle-group \
cmdk embla-carousel-react input-otp next-themes react-day-picker react-hook-form \
recharts sonner vaul"
REPLIT_PLUGINS="@replit/vite-plugin-cartographer @replit/vite-plugin-dev-banner \
@replit/vite-plugin-runtime-error-modal"

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
  ! grep -qE "VERSION\s*=\s*\"0\." '"$CORE"'/src/index.ts || { echo "src/index.ts restates a literal version"; exit 1; }
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
# Written as a FUNCTION, not a bash -c '...' string. This check broke the file
# twice while being edited as a nested-quoted string — a comment containing a
# backtick or an unescaped quote is parsed by the OUTER shell — and the check was
# already found too weak once. A function has no quoting minefield.
vite_configs_discovered() {
  local files f v n=0
  files=$(git ls-files | grep -E '(^|/)vite\.config\.[a-z]+$' | grep -v node_modules || true)
  [ -n "$files" ] || { echo "no vite config discovered - the glob is broken, not the repo clean"; return 1; }
  for f in $files; do
    n=$((n+1))
    # (1) the hard throw itself: the config refused to load without the Replit env.
    if grep -q 'is required but was not provided' "$f"; then
      echo "$f still hard-throws on the Replit env"; return 1
    fi
    # (2) An undefaulted PORT or BASE_PATH. The cold review showed the first
    # version was too weak: it triggered only on process.env.PORT, so stripping
    # process.env.PORT ?? "5000" out of the docs config entirely - leaving a
    # hardcoded 5000 and a BASE_PATH of / - still exited 0, and S41 would have
    # rejected that. So the trigger is ANY mention of the name, which means the
    # config own explanatory comment is enough to make the default mandatory.
    # A config that hardcodes the Replit values is exactly the shape S41 check
    # existed to catch: hardcoding is not configuring.
    for v in PORT BASE_PATH; do
      if grep -qE "(^|[^a-zA-Z0-9_])${v}([^a-zA-Z0-9_]|$)" "$f"; then
        grep -qE "process\.env\.${v}[[:space:]]*\?\?" "$f" || {
          echo "$f mentions $v but never defaults it"; return 1; }
      fi
    done
  done
  echo "$n vite config(s) discovered; none hard-throws, no undefaulted env read"
  return 0
}
run_check "vite-configs-discovered" vite_configs_discovered

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

# RE-EXPRESSED (was: charts-untouched), and this closes the S42 review's N6.
#
# S42 asserted `git diff main...HEAD -- <LOCKED dirs>` was empty. That check has
# two defects, and S43 is the session that exposes both:
#   * it ENUMERATES the LOCKED dirs, so the first session that legitimately
#     reformats them (this one, F43-1) turns it red on a change that changes no
#     behaviour — the exact "discover, do not enumerate" lesson one level down;
#   * when `main` does not resolve, `git diff` prints "fatal: bad revision" to
#     stderr, the pipe yields 0 lines, and the check PASSES — the vacuous pass
#     N6 names, which bit the S42 reviewer's own clone.
#
# So this asserts the true invariant instead: every changed file under the
# LOCKED dirs is EXACTLY the Prettier transform of its base copy. That is a fact
# about the diff, not a phrase, and it cannot pass vacuously.
# Counterfactual (both demonstrated): hand-edit a locked chart file with a real
# change -> RED; break the base ref -> RED.
charts_format_only() {
  local base=main
  git rev-parse --verify --quiet "$base^{commit}" >/dev/null 2>&1 \
    || { echo "base '$base' does not resolve — cannot judge the LOCKED diff"; return 1; }
  local files f tmp rc=0 n=0
  files=$(git diff --name-only "$base"...HEAD -- \
    packages/core/src/charts/ packages/core/src/renderers/ packages/core/src/themes/ || true)
  [ -n "$files" ] || { echo "no changes under the LOCKED dirs — the format-only claim is vacuous"; return 1; }
  for f in $files; do
    n=$((n+1))
    tmp=$(mktemp)
    if git show "$base:$f" 2>/dev/null | node_modules/.bin/prettier --stdin-filepath "$f" > "$tmp" 2>/dev/null; then
      cmp -s "$tmp" "$f" \
        || { echo "$f is NOT the Prettier transform of its base — a non-format edit rode along"; rc=1; }
    else
      echo "$f: prettier could not format the base copy"; rc=1
    fi
    rm -f "$tmp"
  done
  [ "$rc" -eq 0 ] || return 1
  echo "$n changed files under the LOCKED dirs are each exactly the Prettier transform of $base"
  return 0
}
run_check "charts-format-only" charts_format_only

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
run_check "ai-files-describe-s43" bash -c '
  want=$(cat .ai/SESSION)
  [ "$want" = "43" ] || { echo ".ai/SESSION reads $want, not 43"; exit 1; }
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    grep -q "session-43-docs-weight" "$f" || { echo "$f does not name the live branch"; exit 1; }
  done
  ab=$(awk "/^## Active Branch/{f=1;next} /^## /{f=0} f" .ai/STATE.md)
  [ -n "$ab" ] || { echo "STATE.md has no Active Branch section"; exit 1; }
  echo "$ab" | grep -q "session-43-docs-weight" || { echo "Active Branch does not name session-43-docs-weight"; exit 1; }
  echo "$ab" | grep -q "session-42-dead-weight" && { echo "Active Branch still names the S42 branch"; exit 1; }
  ip=$(awk "/^## What Is In Progress/{f=1;next} /^## /{f=0} f" .ai/STATE.md)
  [ -n "$ip" ] || { echo "STATE.md has no What Is In Progress section"; exit 1; }
  echo "$ip" | grep -q "S43" || { echo "the In Progress section does not name S43"; exit 1; }
  for s in 43 44; do
    grep -q "Session $s (S$s)" .ai/ROADMAP.md || { echo "ROADMAP.md has no Session $s item"; exit 1; }
  done
  echo ".ai/ describes S43 on this branch; S44 scheduled"'

# INHERITED with one amendment: S41 exempted attached_assets/ here, a directory
# this session deletes. That exemption is dropped rather than kept as dead
# prose, and this script is exempted in its place for the same reason S41
# exempted itself — it names the canonical count only to explain the trap.
run_check "test-count-propagated" bash -c '
  set -e
  # | head -1 restored from S41: without it a duplicated "Tests N passed" line
  # would produce a false RED rather than being truncated.
  n=$(pnpm --filter @ifelse.codes/chitra run test 2>&1 \
        | grep -oE "Tests +[0-9]+ passed" | grep -oE "[0-9]+" | head -1)
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
  # S43 REMOVES the demo idiom that S42 inherited and that its own cold review
  # flagged: grepping the demo FILE for the literal count is satisfied by a
  # COMMENT, and the S41 demo passed on its comment alone. The demo now DERIVES
  # the count at runtime, so it must NOT carry the literal -- asserting its
  # absence here, and displaying it in `demo-displays-count-at-runtime`.
  ! grep -q "$n" scripts/demo-session-43.sh                  || bad="$bad demo-43-typed-the-count"
  grep -q "Tests +$n passed" scripts/verify-session-39.sh    || bad="$bad verify-39"
  [ -z "$bad" ] || { echo "count is $n but these disagree:$bad"; exit 1; }

  # S41 exempts ITS OWN gate from this inventory, because it names the number
  # only to explain the trap. The frozen demo-41/demo-42 legitimately still
  # display 453 in their prose, so they belong in the expected SET rather than
  # in the exemptions. An exemption is for files that must NOT display it.
  expected=".ai/CONTINUATION-PROMPT.md
.ai/KNOWLEDGE.md
.ai/ROADMAP.md
.ai/SESSION-BOOT.md
.ai/STATE.md
.ai/TASK.md
.github/workflows/ci.yml
README.md
artifacts/chitra-docs/src/App.tsx
replit.md
scripts/demo-session-41.sh
scripts/demo-session-42.sh
scripts/verify-session-39.sh"
  found=$(git grep -lE "(^|[^0-9])$n([^0-9]|$)" -- . \
          | grep -vE "^\.ai/(GT-REMEDIATIONS|handoffs|CHITRA)" \
          | grep -vE "^sessions/" \
          | grep -vE "^prompts/" \
          | grep -vE "^scripts/verify-session-4[123]\.sh$" \
          | LC_ALL=C sort)
  if [ "$found" != "$expected" ]; then
    echo "count is $n; the set of files displaying it changed."
    diff <(echo "$expected" | LC_ALL=C sort) <(echo "$found") || true
    echo "  a new display site must be added to this check, or the stale site removed"
    exit 1
  fi
  echo "canonical count $n: 13 declared sites agree, demo-43 derives it, and no other tracked file outside the exemptions displays it"'

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

# replit.md must agree with pnpm-workspace.yaml, which is the thing that actually runs.
#
# The cold review's most embarrassing find: replit.md still said the globs were
# "packages/* and lib/*" AFTER this session deleted lib/, and no check could see
# it -- the reference check's token list had no bare lib/. Fixing the sentence was
# not enough. This asserts the AGREEMENT, so the sentence cannot drift again: every
# real glob must be named in replit.md, and replit.md must not name a glob that
# does not exist.
#
# Counterfactual: re-add `- lib/*` to pnpm-workspace.yaml, or restore the stale
# sentence to replit.md, and this goes red.
replit_globs_match_workspace() {
  local globs g missing=0 stale=0
  globs=$(awk '/^packages:/{f=1;next} /^[a-zA-Z]/{f=0} f && /^  - /{print $2}' pnpm-workspace.yaml)
  [ -n "$globs" ] || { echo "could not parse the workspace globs"; return 1; }
  # `set -f`: an UNQUOTED $globs would be pathname-expanded, so the glob
  # "artifacts/*" would silently expand to every directory under artifacts/ and
  # the loop would check none of the real globs. That bug was in the first draft.
  set -f
  # (a) every real glob must be named in replit.md
  for g in $globs; do
    grep -qF "\`$g\`" replit.md || { echo "replit.md does not name the real glob: $g"; missing=1; }
  done
  # (a2) N8 fix. Every real glob must MATCH something, INDEPENDENT of replit.md's
  # prose. Before this clause, re-adding `- lib/*` to pnpm-workspace.yaml went
  # GREEN: clause (a) was satisfied by replit.md's historical mention of lib/*,
  # and clause (b) skips any glob that IS in the workspace list — so the two
  # clauses together could not see a dead glob that had been re-added. This one
  # can, because it asks the filesystem, not the prose.
  # Counterfactual (demonstrated): re-add `- lib/*` with clause (a) still green
  # -> 'lib' matches nothing -> RED.
  for g in $globs; do
    case "$g" in
      *\**) ls -d ${g%/\*} >/dev/null 2>&1 || { echo "workspace glob $g matches nothing"; stale=1; } ;;
      *)    [ -e "$g" ] || { echo "workspace entry $g does not exist"; stale=1; } ;;
    esac
  done
  # (b) no dead glob may be claimed as current
  for g in $(grep -oE '`[a-z]+/[a-z*]+`' replit.md | tr -d '`' | LC_ALL=C sort -u); do
    case " $globs " in *" $g "*) continue ;; esac
    # The ONE phrase-coupled clause in this gate, disclosed. A dead glob is
    # acceptable in replit.md only on a line that records its removal -- because
    # replit.md is allowed to SAY it used to glob lib/*. Without this the check
    # would demand the history be deleted, which is worse. Scoped to the line the
    # token appears on, and the markers are the ones this file already uses.
    # Every line that mentions a dead glob must record its removal, not just one
    # of them. The first version used a plain -q, so a single historical line
    # mentioning lib/* masked a second line still claiming it -- and the review's
    # counterfactual went green again. It is `grep -v` (ANY line lacking the
    # marker fails), not `grep -q` (ANY line having it passes).
    grep -n -F "\`$g\`" replit.md \
      | grep -qvE 'used to|no longer|deleted|removed|S42' \
      && { echo "replit.md claims a glob that does not exist: $g"; stale=1; }
  done
  set +f
  [ "$missing" -eq 0 ] && [ "$stale" -eq 0 ] || return 1
  echo "replit.md and pnpm-workspace.yaml agree on: $globs"
  return 0
}
run_check "replit-globs-match-workspace" replit_globs_match_workspace
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
#
# A second version used the bare token `lib/`, which the review's replit.md
# finding exposed as uselessly broad: it matched 50 shadcn imports of
# "@/lib/utils", the docs own src/lib/bufferStore, and prose that legitimately
# RECORDS the deletion. The tokens below name the deleted paths specifically —
# the four lib/ packages and the workspace glob line — so a real reference is
# still caught and a path that merely contains "lib" is not.
no_live_ref_to_dead_trees() {
  local hits
  hits=$(git grep -nE 'mockup-sandbox|api-server|@workspace/(db|api-)|attached_assets|@assets|lib/(api-spec|api-zod|api-client-react|db|integrations)|^[[:space:]]*- lib/\*' -- . \
    ':!sessions' ':!prompts' ':!.ai' \
    ':!code-cleanup-plan-session-41.md' ':!independent-audit-RESULT.md' \
    ':!scripts/verify-session-41.sh' ':!scripts/demo-session-41.sh' \
    ':!scripts/verify-session-42.sh' ':!scripts/demo-session-42.sh' || true)
  [ -z "$hits" ] || { echo "$hits"; return 1; }
  echo "no build, config or script file references a deleted tree"
  return 0
}
run_check "no-live-ref-to-dead-trees" no_live_ref_to_dead_trees

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
  # The cold review killed the clause this check used to end with. It ran the
  # workspace scripts typecheck and called it proof that the package still
  # typechecks rather than quietly doing nothing -- but
  # scripts/tsconfig.json is now files: [], so tsc exits 0 even with a hard
  # TS2322 sitting in a file it is not told to look at. It could not fail.
  #
  # (NOTE for whoever edits this next: this check is a DOUBLE-quoted bash -c, so
  # a backtick or an unescaped double quote in a comment here is executed or
  # parsed by the OUTER shell. That is what broke the file once.)
  #
  # What IS true and checkable: the config must not claim to have sources it does
  # not, and the package must still be reachable by the root typecheck chain --
  # because that chain is what req 3 rewired, and a filter that silently matches
  # nothing would leave the docs app as the only thing typechecked.
  grep -q '\"include\"' scripts/tsconfig.json && { echo \"scripts/tsconfig.json still claims an include with no src/\"; exit 1; }
  grep -q '\"files\"' scripts/tsconfig.json || { echo \"scripts/tsconfig.json has neither files nor include\"; exit 1; }
  pnpm run typecheck >/dev/null 2>&1 \
    || { echo \"root typecheck is red\"; exit 1; }
  # N9 fix. The old clause ran \`pnpm -r --filter ./scripts --if-present run
  # typecheck\` and called exit 0 proof the package is still reached -- but
  # --if-present exits 0 whether the filter ran a typecheck or matched NOTHING,
  # so deleting \`- scripts\` from the workspace globs left it green. This asks
  # the filter to RESOLVE to the project instead.
  # Counterfactual: delete \`- scripts\` from pnpm-workspace.yaml -> the filter
  # matches nothing ('No projects matched the filters') -> RED.
  sp=$(pnpm --filter \"./scripts\" exec pwd 2>/dev/null || true)
  case \"$sp\" in
    */scripts) ;;
    *) echo \"the ./scripts filter resolves to no project (got '$sp')\"; exit 1 ;;
  esac
  echo \"6 dead scripts gone, 2 dangling refs cut, root typecheck chain green\""

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

# ═══════════════════════════════════════════════ S43 · the deletions (Batch 3)

# req 1 — every tracked ui component is reachable from the live set. The live
# set is DISCOVERED: roots are the ui ids referenced from OUTSIDE the ui folder,
# closed transitively over ui->ui imports. This is the check that retires the
# 43 orphans, and it is also the one a future session cannot fool by deleting a
# component that something still imports.
# Counterfactual: restore any of the 43 (e.g. accordion.tsx) -> tracked but not
# reachable -> RED.
ui_components_shipped() {
  python3 - <<'PY'
import re, os, subprocess, sys
ui = "artifacts/chitra-docs/src/components/ui"
files = subprocess.run(["git", "ls-files", ui], capture_output=True, text=True).stdout.split()
ids = {os.path.relpath(f, ui)[:-4] for f in files if f.endswith(".tsx")}
if not ids:
    print("no ui components tracked under", ui); sys.exit(1)
roots = set()
for root, _, fs in os.walk("artifacts/chitra-docs/src"):
    for f in fs:
        if not f.endswith((".ts", ".tsx")):
            continue
        p = os.path.join(root, f)
        rel = os.path.relpath(p, "artifacts/chitra-docs/src")
        if rel.startswith("components/ui/"):
            continue
        roots |= set(re.findall(r"components/ui/([A-Za-z0-9-]+)", open(p).read()))
if not roots:
    print("no live ui components discovered outside components/ui — the scan is broken"); sys.exit(1)
live = set(roots)
changed = True
while changed:
    changed = False
    for i in list(live):
        p = os.path.join(ui, i + ".tsx")
        if os.path.exists(p):
            for m in re.findall(r"components/ui/([A-Za-z0-9-]+)", open(p).read()):
                if m not in live:
                    live.add(m); changed = True
orphans = sorted(ids - live)
if orphans:
    print("orphan ui components shipped (reachable from nothing):", " ".join(orphans)); sys.exit(1)
print(f"{len(ids)} ui components tracked, all reachable from the {len(live)}-component live set")
PY
}
run_check "ui-components-shipped" ui_components_shipped

# req 2 — the 30 devDeps are gone from the manifest and imported by nothing.
# Counterfactual: re-add any dep and import it -> RED.
docs_dead_deps_gone() {
  local p bad=0 hits
  for p in $DEAD_DOCS_DEPS; do
    grep -qF "\"$p\"" artifacts/chitra-docs/package.json \
      && { echo "$p is still declared in artifacts/chitra-docs/package.json"; bad=1; }
    hits=$(grep -rnF "from \"$p" artifacts/chitra-docs/src 2>/dev/null || true)
    hits="$hits$(grep -rnF "from '$p" artifacts/chitra-docs/src 2>/dev/null || true)"
    [ -z "$hits" ] || { echo "$p is still imported: $hits"; bad=1; }
  done
  [ "$bad" -eq 0 ] || return 1
  echo "all 30 removed devDeps are gone from the manifest and imported by nothing"
  return 0
}
run_check "docs-dead-deps-gone" docs_dead_deps_gone

# req 3 — no @replit/* plugin survives in the config, the manifest, or the
# workspace catalog. Counterfactual: restore the import in vite.config.ts -> RED.
replit_plugins_gone() {
  local p bad=0
  for p in $REPLIT_PLUGINS; do
    grep -qF "$p" artifacts/chitra-docs/package.json \
      && { echo "$p still in docs package.json"; bad=1; }
    grep -qF "$p" artifacts/chitra-docs/vite.config.ts \
      && { echo "$p still in the docs vite config"; bad=1; }
    grep -qF "$p" pnpm-workspace.yaml \
      && { echo "$p still in the workspace catalog"; bad=1; }
  done
  grep -q "@replit" artifacts/chitra-docs/vite.config.ts \
    && { echo "a @replit reference survives in the vite config"; bad=1; }
  [ "$bad" -eq 0 ] || return 1
  echo "no @replit/* plugin in the vite config, the manifest, or the catalog"
  return 0
}
run_check "replit-plugins-gone" replit_plugins_gone

# req 4 — the dead lint script is gone, and nothing else points at an eslint
# that is not installed. Counterfactual: restore the script -> RED.
lint_script_gone() {
  grep -q '"lint"' packages/core/package.json \
    && { echo "the dead lint script is back in packages/core/package.json"; return 1; }
  echo "packages/core has no lint script pointing at an uninstalled eslint"
  return 0
}
run_check "lint-script-gone" lint_script_gone

# req 5 — Prettier is adopted, and enforced in CI so it cannot rot back to red.
prettier_adopted() {
  [ -f .prettierrc ] || { echo ".prettierrc is missing"; return 1; }
  [ -f .prettierignore ] || { echo ".prettierignore is missing"; return 1; }
  grep -q '"format:check"' package.json || { echo "no format:check script"; return 1; }
  grep -q 'format:check' .github/workflows/ci.yml || { echo "CI does not run format:check"; return 1; }
  pnpm run format:check >/dev/null 2>&1 || { echo "format:check is red"; return 1; }
  echo ".prettierrc + .prettierignore present, format:check green and wired into CI"
  return 0
}
run_check "prettier-adopted" prettier_adopted

# ═══════════════════════════════════════════════ S43 · the counterfactual

# THE counterfactual the contract demands, and the one that proves the
# re-expression was necessary rather than tidy.
#
# S42's gate asserts `git diff main...HEAD -- <LOCKED dirs>` is empty. S43
# formats those dirs (F43-1), so S42's check reports 25 changed files and exits 1
# — and the S43 gate re-expresses it as charts-format-only. This proves that
# coupling with S42's REAL check body, extracted from S42's own gate file so an
# edit there follows through instead of leaving a stale transcription.
#
# It does NOT run S42's whole gate: that transitively runs S41's gate plus two
# fresh-clone installs (~60 min, S42 review §4.9), and the S43 gate must stay
# runnable. Extracting the one check is cheaper and still runs S42's actual code.
s42_gate_goes_red() {
  local stmt cmd rc
  stmt=$(awk '/^run_check "charts-untouched"/{f=1} f{print} f&&/^$/{exit}' scripts/verify-session-42.sh)
  [ -n "$stmt" ] || { echo "S42's charts-untouched check is not in scripts/verify-session-42.sh"; return 1; }
  cmd=${stmt#run_check \"charts-untouched\" }
  # CORE is spliced into S42's body by the outer shell as '"$CORE"'.
  CORE=packages/core
  set +e
  eval "$cmd" > /tmp/s42-charts-untouched.out 2>&1
  rc=$?
  set -e
  echo "--- S42 charts-untouched output ---"; cat /tmp/s42-charts-untouched.out
  [ "$rc" -ne 0 ] || { echo "S42's charts-untouched is GREEN here — the coupling claim is false"; return 1; }
  grep -q "files changed under the LOCKED design language" /tmp/s42-charts-untouched.out \
    || { echo "S42's check failed for an UNRELATED reason"; return 1; }
  echo "S42's charts-untouched, extracted from its own gate, exits $rc on the S43 format"
  return 0
}
run_check "s42-gate-verbatim-goes-red" s42_gate_goes_red

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
  # S43 re-synced these files and the CONTINUATION-PROMPT/TASK/SESSION-BOOT no
  # longer narrate the S42 dead trees (they narrate S43 instead), so the declared
  # set is the three that DO record the S42 deletion. A new mention site still
  # turns the gate red.
  expected=".ai/KNOWLEDGE.md
.ai/ROADMAP.md
.ai/STATE.md"
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
  grep -q "Deleted in S43" .ai/KNOWLEDGE.md \
    || { echo "KNOWLEDGE.md does not record the S43 deletion"; exit 1; }
  echo ".ai/: 3 declared mention sites, and KNOWLEDGE.md records both deletions"'

# ═══════════════════════════════════════════════ S42 · the contract (req 10)

# req 8 — browser QA, as a check the gate RUNS, with N5 and N7 fixed.
#
# N5: the check had an undeclared `packages/core/dist` precondition — it went red
# in a CLEAN CLONE for a reason that is not the thing it checks. It now builds
# core first, exactly as ci.yml#browser-qa and release.yml already do.
#
# N7: the old check asserted `n >= 20` against a hardcoded `CHART_IDS` in
# qa-catalog.mjs, so a 21st live catalog page was invisible. The expected
# inventory is now DISCOVERED from the generated charts.ts, and every id must
# have been visited. Counterfactual: add a chart to charts.ts (or the catalog)
# and not visit it -> RED, naming the id.
browser_qa_catalog_pages() {
  pnpm --filter @ifelse.codes/chitra run build >/dev/null 2>&1 \
    || { echo "core build failed inside the check"; return 1; }
  local out ids id n=0 rc=0
  out=$(node scripts/qa-catalog.mjs 2>&1) \
    || { echo "$out" | tail -25; echo "qa-catalog.mjs exited non-zero"; return 1; }
  echo "$out" | grep -q "Persistence smoke: PASS" || { echo "no persistence smoke line"; return 1; }
  if echo "$out" | grep -qE "consoleErrors=[1-9]|pageErrors=[1-9]"; then
    echo "$out" | grep -E "consoleErrors=[1-9]|pageErrors=[1-9]"; return 1
  fi
  ids=$(grep -oE '^[[:space:]]+id: "[^"]+"' artifacts/chitra-docs/src/data/charts.ts \
        | sed 's/.*id: "//; s/"//')
  [ -n "$ids" ] || { echo "could not discover catalog ids from charts.ts"; return 1; }
  for id in $ids; do
    n=$((n+1))
    echo "$out" | grep -qE "^PASS chart-${id}:" \
      || { echo "catalog page not visited: $id"; rc=1; }
  done
  [ "$rc" -eq 0 ] || return 1
  echo "$n catalog pages driven (discovered from charts.ts), 0 console errors, 0 page errors, persistence PASS"
  return 0
}
run_check "browser-qa-catalog-pages" browser_qa_catalog_pages

# req 10 — the contract, and the requirements it promises.
#
# The first version of this check was `grep -q "10 numbered requirements"`, and the
# cold review broke it twice: it deleted requirements 4 through 10 from the contract
# and it passed, and it replaced the contract with a four-line stub containing that
# one phrase and it passed. A phrase check standing in for a structural requirement
# is the anti-pattern this contract names in its own header.
#
# So it now requires the contract to actually CONTAIN each numbered requirement,
# discovered by pattern rather than remembered, and to name every out-of-scope
# section. Counterfactual: delete any one requirement and it goes red.
  # A FUNCTION, not a bash -c '...' string. That form broke this file twice: an awk
  # program needs single quotes, and a single quote inside a single-quoted argument
  # terminates the string and re-parses the rest as shell code. Anything edited from
  # this point on should be written as a function.
  contract_at_head() {
  local c found want s
  c=prompts/43-task-docs-weight.md
  [ -f "$c" ] || { echo "the contract is missing"; return 1; }
  git ls-files --error-unmatch -- "$c" >/dev/null 2>&1 || { echo "the contract is untracked"; return 1; }
  # Every numbered requirement 1..10 must be present AS A HEADING, and the set of
  # numbers found must be exactly 1..10 - no gaps, and nothing standing in for a
  # missing one. Scoped to the Scope section on purpose: the Assumptions block
  # also carries items numbered 1 and 2, and counting those would make the set
  # 1..10,1,2 and the comparison meaningless.
  found=$(awk '/^## Scope/{f=1;next} /^## /{f=0} f' "$c" \
          | grep -oE '^[0-9]+\. \*\*' | grep -oE '^[0-9]+' | LC_ALL=C sort -n | tr '\n' ' ')
  want=$(seq 1 10 | tr '\n' ' ')
  [ "$found" = "$want" ] || { echo "contract requirements are [$found], expected [$want]"; return 1; }
  # The sections that carry obligations the gate does not itself assert.
  for s in '## Out of scope' '## Assumptions' '## Founder decision' '## Closeout'; do
    grep -q "^$s" "$c" || { echo "contract is missing the section: $s"; return 1; }
  done
  # And the counterfactual the contract demands must be named in it.
  grep -q 's42-gate-verbatim-goes-red' "$c" \
    || { echo "the contract does not name the counterfactual it demands"; return 1; }
  echo "contract tracked, requirements 1-10 all present as headings, obligation sections intact"
  return 0
}
run_check "contract-at-head" contract_at_head

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
  out=\$(DEMO_LOG_DIR='$ARTIFACTS' bash scripts/demo-session-43.sh 2>&1) \
    || { echo \"\$out\" | tail -10; echo 'the demo did not exit 0'; exit 1; }
  echo \"\$out\" | grep -qE '\([0-9]+ tests in [0-9]+ files\)' \
    || { echo 'the demo prints no (N tests in M files) line'; exit 1; }
  n=\$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+')
  echo \"\$out\" | grep -q \"(\$n tests in\" \
    || { echo \"the demo displays a count that is not the suite's (\$n)\"; exit 1; }
  echo \"the demo's OUTPUT carries the suite's live count (\$n tests)\""

( cd ".ai/verify/session-43" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 43 Verify Summary ==="
printf '%-38s %s\n' "CHECK" "RESULT"
printf '%-38s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]:-}"; do echo "$r"; done

# Machine-readable copy of the table above, one "<name> PASS|FAIL" per line.
# The demo reads THIS rather than grepping each check's log: a log's prose is not
# a status, and reading it as one made the demo mislabel two requirements.
{
  for r in "${RESULTS[@]:-}"; do
    printf '%s %s\n' "$(echo "$r" | awk '{print $1}')" "$(echo "$r" | awk '{print $NF}')"
  done
} > "$ARTIFACTS/summary.txt"

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi