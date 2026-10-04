#!/usr/bin/env bash
# S44 — cleanup Batch 4: OSS polish + the founder decisions D1-D6.
#
# Design rules carried from S38..S43:
#   * assert FACTS, not phrases — a check coupled to a string is not a guard;
#   * a check that cannot fail is a bug — every check here has a demonstrated
#     counterfactual, noted beside it;
#   * a DISCOVERED inventory beats an enumerated one.
#
# INHERITANCE. This is a PORT of verify-session-43.sh, not a copy. What this
# session's own changes force to be re-expressed:
#
#   ai-files-describe-s43      -> ai-files-describe-s44   (this session)
#   s42-gate-verbatim-goes-red -> s43-gate-verbatim-goes-red
#   contract-at-head           -> same shape: prompts/44, requirements 1..14
#   charts-format-only         -> charts-untouched (S44 makes no change under
#                                 the LOCKED dirs at all, so "format-only" has
#                                 nothing to judge — the claim becomes byte-
#                                 identity with main, probed by a derived commit)
#
# §4.9 — the gate is expensive. VAJRA_GATE_SCOPE=fast skips ONLY the inherited
# checks that cost the wall clock (fresh clone, browser QA, docs build, the
# duplicate suite/coverage runs) and marks them SKIP; every check this session
# owns still runs. Default is full — which is what `check_verify_demo_scripts`
# asserts, since nothing ever *invokes* this script with a scope (A4) — and the
# elapsed minutes are printed either way. See gate_scope_switch for the measured
# counterfactual.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-44/${TS}"
mkdir -p "$ARTIFACTS"

START=$(date +%s)

# §4.9 (req 10) — scope switch. A skip list that names a check this gate does
# not have, or one that covers the whole gate, is a bug; gate_scope_switch
# proves both directions and reads the MEASURED per-check timings this script
# writes, so "fast is faster" is arithmetic rather than a claim.
# `date +%s` is second-granular on macOS (no %N), which priced every fast-scope
# check at 0s and made gate-scope-switch correctly report that "fast" removed
# nothing. Milliseconds in, whole seconds out.
now_ms() { perl -MTime::HiRes=time -e 'printf("%d", time()*1000)'; }

resolve_scope() { case "${1:-}" in ""|full) echo full ;; fast) echo fast ;; *) return 1 ;; esac; }
SCOPE="$(resolve_scope "${VAJRA_GATE_SCOPE:-}")" \
  || { echo "VAJRA_GATE_SCOPE must be full or fast (got '${VAJRA_GATE_SCOPE:-}')"; exit 2; }

# Inherited checks whose cost is the wall clock: a clone+install, a Playwright
# run, a docs build, and the second/third run of the same suite under coverage.
# core-tests is deliberately NOT here — fast still runs the suite once.
FAST_SKIP="fresh-clone-build-no-env browser-qa-catalog-pages docs-meta-not-scaffold \
coverage-gate-passes contributing-coverage-numbers-real s39-suite-still-green"

gate_skips() {
  [ "$1" = fast ] || return 1
  case " $FAST_SKIP " in *" $2 "*) return 0 ;; esac
  return 1
}

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
  if gate_skips "$SCOPE" "$NAME"; then
    echo "SKIPPED: VAJRA_GATE_SCOPE=$SCOPE does not run this check (full is the default)." > "$LOG"
    RESULTS+=("$(printf '%-38s %s' "$NAME" SKIP)"); write_summary
    return 0
  fi
  local t0 t1 rc=0
  t0=$(now_ms)
  "$@" > "$LOG" 2>&1 || rc=$?
  t1=$(now_ms)
  # Measured, not asserted: gate_scope_switch reads this file to price the skip
  # list. A check nobody times is a check whose cost nobody can see.
  printf '%s %s\n' "$NAME" "$(( (t1 - t0) / 1000 ))" >> "$ARTIFACTS/timings.txt"
  if [ "$rc" -eq 0 ]; then
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
@radix-ui/react-collapsible @radix-ui/react-context-menu @radix-ui/react-dialog \
@radix-ui/react-dropdown-menu @radix-ui/react-hover-card @radix-ui/react-label \
@radix-ui/react-menubar @radix-ui/react-navigation-menu @radix-ui/react-popover \
@radix-ui/react-progress @radix-ui/react-radio-group @radix-ui/react-scroll-area \
@radix-ui/react-select @radix-ui/react-separator @radix-ui/react-slider \
@radix-ui/react-slot @radix-ui/react-switch @radix-ui/react-tabs \
@radix-ui/react-toggle @radix-ui/react-toggle-group @radix-ui/react-tooltip \
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
charts_untouched() {
  local base=main
  git rev-parse --verify --quiet "$base^{commit}" >/dev/null 2>&1 \
    || { echo "base '$base' does not resolve — cannot judge the LOCKED diff"; return 1; }
  local files
  files=$(git diff --name-only "$base"...HEAD -- \
    packages/core/src/charts/ packages/core/src/renderers/ packages/core/src/themes/ || true)
  if [ -n "$files" ]; then
    echo "S44 changed files under the LOCKED dirs (charts/ renderers/ themes/ are LOCKED):"
    echo "$files"; return 1
  fi
  # RE-EXPRESSED from S43's charts-format-only. That check REQUIRES a non-empty
  # diff: S43 reformatted those dirs and had to prove the diff was exactly
  # Prettier's transform. S44 touches none of them, so the format-only premise
  # has nothing to judge and the inherited check called the clean tree
  # "vacuous". The claim here is byte-identity with main.
  #
  # The counterfactual is DERIVED, not typed: take the newest commit in history
  # that did touch those dirs and run the SAME command against it. A diff that
  # could only ever print nothing would pass this check forever.
  local c probe
  c=$(git log --format=%H -1 -- packages/core/src/charts/ || true)
  [ -n "$c" ] || { echo "no commit in history touched the LOCKED dirs — the probe cannot run"; return 1; }
  git rev-parse --verify --quiet "$c^" >/dev/null 2>&1 \
    || { echo "the probe commit ${c:0:8} has no parent — cannot diff it"; return 1; }
  probe=$(git diff --name-only "$c^"...$c -- \
    packages/core/src/charts/ packages/core/src/renderers/ packages/core/src/themes/ || true)
  [ -n "$probe" ] || { echo "the probe found no change at ${c:0:8} either — the diff is broken, not the tree clean"; return 1; }
  echo "LOCKED dirs byte-identical to $base; the same command reports $(echo "$probe" | wc -l | tr -d ' ') file(s) changed at ${c:0:8}"
  return 0
}
run_check "charts-untouched" charts_untouched

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
run_check "ai-files-describe-s44" bash -c '
  want=$(cat .ai/SESSION)
  [ "$want" = "44" ] || { echo ".ai/SESSION reads $want, not 44"; exit 1; }
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md; do
    [ -f "$f" ] || { echo "FILE MISSING: $f"; exit 1; }
    grep -q "session-44-oss-polish" "$f" || { echo "$f does not name the live branch"; exit 1; }
  done
  ab=$(awk "/^## Active Branch/{f=1;next} /^## /{f=0} f" .ai/STATE.md)
  [ -n "$ab" ] || { echo "STATE.md has no Active Branch section"; exit 1; }
  echo "$ab" | grep -q "session-44-oss-polish" || { echo "Active Branch does not name session-44-oss-polish"; exit 1; }
  echo "$ab" | grep -q "session-42-dead-weight" && { echo "Active Branch still names the S42 branch"; exit 1; }
  ip=$(awk "/^## What Is In Progress/{f=1;next} /^## /{f=0} f" .ai/STATE.md)
  [ -n "$ip" ] || { echo "STATE.md has no What Is In Progress section"; exit 1; }
  echo "$ip" | grep -q "S44" || { echo "the In Progress section does not name S44"; exit 1; }
  for s in 44 45; do
    grep -q "Session $s (S$s)" .ai/ROADMAP.md || { echo "ROADMAP.md has no Session $s item"; exit 1; }
  done
  echo ".ai/ describes S44 on this branch; S45 scheduled"'

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
  ! grep -q "$n" scripts/demo-session-44.sh                  || bad="$bad demo-44-typed-the-count"
  grep -q "Tests +$n passed" scripts/verify-session-39.sh    || bad="$bad verify-39"
  [ -z "$bad" ] || { echo "count is $n but these disagree:$bad"; exit 1; }

  # S41 exempts ITS OWN gate from this inventory, because it names the number
  # only to explain the trap. Each port extends the exemption to itself for the
  # same reason: the S44 gate carries those inherited comments verbatim. The frozen demo-41/demo-42 legitimately still
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
          | grep -vE "^scripts/verify-session-4[1234]\.sh$" \
          | LC_ALL=C sort)
  if [ "$found" != "$expected" ]; then
    echo "count is $n; the set of files displaying it changed."
    diff <(echo "$expected" | LC_ALL=C sort) <(echo "$found") || true
    echo "  a new display site must be added to this check, or the stale site removed"
    exit 1
  fi
  echo "canonical count $n: 13 declared sites agree, demo-44 derives it, and no other tracked file outside the exemptions displays it"'

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
# A gate must name the tree it proved deleted in order to prove it, and a demo
# shows before/after. So EVERY scripts/verify-session-*.sh and
# scripts/demo-session-*.sh is exempt -- DISCOVERED from the index rather than
# enumerated. The inherited list was enumerated (41, 42, 43) and it fell over
# the first time a NEW gate appeared: S44 inherited it without itself, so the
# S44 gate was flagged for quoting S42's own check bodies. Exempting by class
# is the fix; the first version of this list omitted demo-session-42.sh and was
# flagged on 12 lines for the same reason. .ai/ is asserted separately by
# ai-names-no-deleted-tree, which carries its own declared list.
#
# A second version used the bare token `lib/`, which the review's replit.md
# finding exposed as uselessly broad: it matched 50 shadcn imports of
# "@/lib/utils", the docs own src/lib/bufferStore, and prose that legitimately
# RECORDS the deletion. The tokens below name the deleted paths specifically —
# the four lib/ packages and the workspace glob line — so a real reference is
# still caught and a path that merely contains "lib" is not.
no_live_ref_to_dead_trees() {
  local hits ex
  ex=$(git ls-files 'scripts/verify-session-*.sh' 'scripts/demo-session-*.sh' \
       | sed 's|^|:!|' | tr '\n' ' ')
  hits=$(git grep -nE 'mockup-sandbox|api-server|@workspace/(db|api-)|attached_assets|@assets|lib/(api-spec|api-zod|api-client-react|db|integrations)|^[[:space:]]*- lib/\*' -- . \
    ':!sessions' ':!prompts' ':!.ai' \
    ':!code-cleanup-plan-session-41.md' ':!independent-audit-RESULT.md' \
    $ex || true)
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
  sp=\$(pnpm --filter \"./scripts\" exec pwd 2>/dev/null || true)
  case \"\$sp\" in
    */scripts) ;;
    *) echo \"the ./scripts filter resolves to no project (got '\$sp')\"; exit 1 ;;
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

# ═══════════════════════════════════════════ inherited from S43 · the deletions

# req 1 — every tracked ui component is reachable from the live set. The live
# set is DISCOVERED: roots are the ui ids referenced from OUTSIDE the ui folder,
# closed transitively over ui->ui imports. This is the check that retires the
# 53 orphans, and it is also the one a future session cannot fool by deleting a
# component that something still imports.
# Counterfactual: restore any of the 53 (e.g. accordion.tsx) -> tracked but not
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
  echo "all 36 removed devDeps are gone from the manifest and imported by nothing"
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

# ═══════════════════════════════════════════ S44 · OSS polish (req 1-6)
#
# Each check runs TWICE: green on this branch, red on `main`, where none of it
# exists. Running the same code against main IS the counterfactual — no
# synthetic state, nothing hand-broken, and it cannot be satisfied by the check
# being weak, because the same code has to fail on the pre-S44 tree.

oss_surface_at() {
  local TREE="${1:-}" sec coc bug feat cfg pr readme urls u wf body bad_line
  rd() { if [ -n "$TREE" ]; then git show "$TREE:$1" 2>/dev/null; else cat "$1" 2>/dev/null; fi; }
  sec=$(rd SECURITY.md); [ -n "$sec" ] || { echo "SECURITY.md missing${TREE:+ at $TREE}"; return 1; }
  echo "$sec" | grep -q "## Reporting a vulnerability" || { echo "SECURITY.md has no disclosure section"; return 1; }
  echo "$sec" | grep -qi "no SLA" \
    || { echo "LABEL, not fact: SECURITY.md no longer says there is no support promise (the wording may change; the disclosure may not)"; return 1; }
  echo "$sec" | grep -q "## Supported versions" || { echo "SECURITY.md has no supported-versions table"; return 1; }
  coc=$(rd CODE_OF_CONDUCT.md); [ -n "$coc" ] || { echo "CODE_OF_CONDUCT.md missing"; return 1; }
  echo "$coc" | grep -q "Contributor Covenant" || { echo "not the Contributor Covenant"; return 1; }
  echo "$coc" | grep -q "## Enforcement" || { echo "no enforcement section"; return 1; }
  # A contact nobody owns is worse than no contact — req 2 forbids a placeholder.
  # Pass 3 (finding 10): this ran on the CoC only, while requirement 1 forbids an
  # invented mailbox just as plainly in SECURITY.md — the file most likely to
  # grow one the day someone wants a security@ route. Both files, one rule.
  for d in CODE_OF_CONDUCT.md SECURITY.md; do
    body=$(rd "$d"); [ -n "$body" ] || continue
    if echo "$body" | grep -qE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'; then
      echo "$d prints an email address this project does not own"; return 1
    fi
  done
  echo "$coc" | grep -qi "private reporting" || { echo "CoC names no private route"; return 1; }
  bug=$(rd .github/ISSUE_TEMPLATE/bug-report.yml); [ -n "$bug" ] || { echo "bug report form missing"; return 1; }
  echo "$bug" | grep -q "label: Reproduction" || { echo "bug form has no reproduction field"; return 1; }
  feat=$(rd .github/ISSUE_TEMPLATE/feature-request.yml); [ -n "$feat" ] || { echo "feature request form missing"; return 1; }
  cfg=$(rd .github/ISSUE_TEMPLATE/config.yml); [ -n "$cfg" ] || { echo "issue template config missing"; return 1; }
  echo "$cfg" | grep -q "blank_issues_enabled: false" || { echo "blank issues are still enabled"; return 1; }
  # Pass 2 found the docs pointing at a channel the repo had closed; pass 3 found
  # that MY fix pointed them at a channel that is also closed, and that the premise
  # behind the clause was wrong. The truth, recorded with the command that re-derives
  # it in .github/REPO-SETTINGS.md: `blank_issues_enabled: false` does NOT close the
  # tracker - it removes only the *blank* template, and the bug/feature forms req 3
  # shipped still accept an outside report. Discussions, on the other hand, are off.
  # So the invariant is not "no doc may mention issues", it is "no reader-facing file
  # may route to a channel the recorded settings say is off". Two clauses, both offline:
  #   (a) with blank issues off, a file that sends the reader to an issue must name a
  #       form/template - the reader cannot open an untemplated one;
  #   (b) if REPO-SETTINGS records has_discussions: false, no reader-facing file may
  #       mention Discussions at all.
  # A sentence that only PROHIBITS a public issue stays legal; the gate must not
  # punish the right advice.
  # SCOPE, stated rather than implied - pass 5 named this comment's "no public doc" a
  # class while the code was four filenames, and then found bug-report.yml doing exactly
  # what the class forbids, unhedged. Every file a reader can see that names a route is
  # now listed: the four public docs plus the three issue-template files. `.ai/` records
  # are excluded deliberately - they name a channel while qualifying it in the same
  # sentence, which is what A8.2 forced them to do. REPO-SETTINGS.md is the record
  # itself and must be able to name a channel in order to record that it is off.
  local sset
  sset=$(rd .github/REPO-SETTINGS.md)
  [ -n "$sset" ] || { echo ".github/REPO-SETTINGS.md is missing - the routes in the public docs have nothing to be checked against"; return 1; }
  local blank="no"
  echo "$cfg" | grep -q "blank_issues_enabled: false" && blank="yes"
  for d in SECURITY.md CODE_OF_CONDUCT.md CONTRIBUTING.md README.md \
           .github/ISSUE_TEMPLATE/config.yml .github/ISSUE_TEMPLATE/bug-report.yml \
           .github/ISSUE_TEMPLATE/feature-request.yml; do
    body=$(rd "$d")
    [ -n "$body" ] || continue
    if [ "$blank" = yes ]; then
      # An issue route is fine as long as it names the form; "open a new issue" is
      # not, because with blank issues off there is no untemplated new-issue page.
      bad_line=$(echo "$body" \
        | grep -niE '(open|file|raise|create|start)(ing|s)? (a |an )?(new |public |github |blank |untemplated )?issue|in a \*\*public\*\* issue' \
        | grep -viE 'do not|don.t|never|cannot|can not|no public issue|bug report|feature request|bug form|ISSUE_TEMPLATE|form|mailbox is' || true)
      [ -z "$bad_line" ] \
        || { echo "$d routes the reader to an issue without naming a form, but blank_issues_enabled is false (an untemplated issue cannot be opened):${TREE:+ at $TREE}"; echo "$bad_line" | sed 's/^/  /'; return 1; }
    fi
    if echo "$sset" | grep -qE '^\| *`has_discussions` \| *\*\*`false`\*\*'; then
      # With the channel off, a reader-facing file has no business naming it: every
      # phrasing ("post it in a discussion", "Discussions are off", a bare link) is
      # either a route to nowhere or noise, and the setting itself is already
      # recorded where it belongs — .github/REPO-SETTINGS.md.
      bad_line=$(echo "$body" | grep -niE 'discussion' || true)
      [ -z "$bad_line" ] \
        || { echo "$d mentions Discussions, which .github/REPO-SETTINGS.md records as has_discussions: false:${TREE:+ at $TREE}"; echo "$bad_line" | sed 's/^/  /'; return 1; }
    fi
    #   (c) the advisories route is a route whose status REPO-SETTINGS records as
    # unknown, so any file that offers it must hedge it in the same file. Pass 5:
    # A8.4 hedged config.yml's contact link and left bug-report.yml's inline link
    # unhedged - the same promise in the place a reporter is most likely to read it.
    if echo "$body" | grep -q 'security/advisories'; then
      echo "$body" | grep -qiE 'does not work|not exist|may not exist|is pending|if private reporting|if this repository has private reporting' \
        || { echo "$d links the private advisories route with no hedge, while .github/REPO-SETTINGS.md records that route's status as unknown — say what to do when the link fails${TREE:+ at $TREE}"; return 1; }
    fi
  done
  pr=$(rd .github/PULL_REQUEST_TEMPLATE.md); [ -n "$pr" ] || { echo "PR template missing"; return 1; }
  readme=$(rd README.md); [ -n "$readme" ] || { echo "README missing"; return 1; }
  urls=$(echo "$readme" | grep -oE 'actions/workflows/[A-Za-z0-9_.-]+\.yml' | LC_ALL=C sort -u)
  [ -n "$urls" ] || { echo "README carries no CI badge"; return 1; }
  for u in $urls; do
    # The badge URL is .../actions/workflows/ci.yml/...; the FILE is
    # .github/workflows/ci.yml. Comparing a bare "ci.yml" against the repo root
    # made this check fail on a badge that was correct all along.
    wf=".github/workflows/${u#actions/workflows/}"
    if [ -n "$TREE" ]; then
      git cat-file -e "$TREE:$wf" 2>/dev/null || { echo "the badge points at $wf, which does not exist at $TREE"; return 1; }
    else
      [ -f "$wf" ] || { echo "the badge points at $wf, which does not exist"; return 1; }
    fi
  done
  echo "security policy, CoC (no invented mailbox), 2 issue forms + config, PR template, CI badge -> $(echo "$urls" | tr '\n' ' ')"
  return 0
}
oss_surface_present() {
  oss_surface_at "" || return 1
  if oss_surface_at main >/dev/null 2>&1; then
    echo "the same check passes on main, where none of this exists — it proves nothing"; return 1
  fi
  echo "counterfactual: the identical check is RED on main (pre-S44)"
}
run_check "oss-surface-present" oss_surface_present

# req 5 — coverage is enforced, not merely configured. vitest.config.ts has had
# four thresholds since S41 that nothing ran; ci.yml#core now runs them, as the
# ONE suite run rather than a sixth job (assumption 2 — §4.9 must not worsen).
coverage_enforced_in_ci() {
  grep -q "run test:coverage" .github/workflows/ci.yml \
    || { echo "ci.yml does not run test:coverage"; return 1; }
  if grep -qE 'run: .* run test$' .github/workflows/ci.yml; then
    echo "ci.yml still runs a plain uncovered Test step"; return 1
  fi
  grep -q '"test:coverage"' packages/core/package.json || { echo "core has no test:coverage script"; return 1; }
  local th; th=$(grep -cE '(statements|branches|functions|lines): [0-9]+' packages/core/vitest.config.ts || true)
  [ "$th" -eq 4 ] || { echo "expected 4 coverage thresholds in vitest.config.ts, found $th"; return 1; }
  if grep -qiE 'codecov|coveralls' .github/workflows/ci.yml; then
    echo "a coverage SERVICE was wired up — that is new recurring infrastructure"; return 1
  fi
  if git show main:.github/workflows/ci.yml 2>/dev/null | grep -q "test:coverage"; then
    echo "main already runs test:coverage — this check proves nothing"; return 1
  fi
  echo "ci.yml runs test:coverage under 4 live thresholds; no coverage service; main runs neither"
}
run_check "coverage-enforced-in-ci" coverage_enforced_in_ci

# req 6 — engines are DERIVED from what CI pins, not chosen. The repo floor is
# ci.yml's own NODE_VERSION/PNPM_VERSION; the package floor is policy and
# CONTRIBUTING says so in those words, because no suite has ever run on it.
engines_derived() {
  local node_v pnpm_v rnode rpnpm cnode
  node_v=$(grep -oE 'NODE_VERSION: *"[0-9]+"' .github/workflows/ci.yml | grep -oE '[0-9]+')
  pnpm_v=$(grep -oE 'PNPM_VERSION: *"[0-9.]+"' .github/workflows/ci.yml | grep -oE '[0-9.]+')
  [ -n "$node_v" ] && [ -n "$pnpm_v" ] || { echo "ci.yml pins no versions"; return 1; }
  rnode=$(node -p "require('./package.json').engines.node" 2>/dev/null) \
    || { echo "root package.json declares no engines.node"; return 1; }
  rpnpm=$(node -p "require('./package.json').engines.pnpm" 2>/dev/null) \
    || { echo "root package.json declares no engines.pnpm"; return 1; }
  cnode=$(node -p "require('./packages/core/package.json').engines.node" 2>/dev/null) \
    || { echo "packages/core declares no engines.node"; return 1; }
  [ "$rnode" = ">=$node_v" ] || { echo "root engines.node is $rnode, ci.yml pins $node_v"; return 1; }
  [ "$rpnpm" = ">=$pnpm_v" ] || { echo "root engines.pnpm is $rpnpm, ci.yml pins $pnpm_v"; return 1; }
  # Pass 2 (cold review, finding 9) on a pattern worth naming: these checks mix
  # FACT assertions (the floor equals the pin) with LABEL assertions (the doc says
  # out loud that the number is policy, not a measurement). Mixed, a rewording can
  # turn the check red while the fact is untouched, and the message then blames the
  # wrong thing. Keep the label assertions, but say plainly that only the wording
  # moved.
  grep -q "support policy, not a test result" CONTRIBUTING.md \
    || { echo "LABEL, not fact: CONTRIBUTING no longer discloses that the package floor is a support policy (the number can stay as it is)"; return 1; }
  grep -q "$cnode" CONTRIBUTING.md || { echo "CONTRIBUTING does not state the package floor ($cnode)"; return 1; }
  # F1 (S44 cold review): README claimed "Requires Node.js 18+" while the repo pins 26,
  # so the public repo carried two consumer floors at once. The README's own floor must
  # be the engines floor — same number, not merely not-lower.
  local rdnode
  rdnode=$(grep -oE 'Node\.js [0-9]+' README.md | head -1 | grep -oE '[0-9]+')
  [ -n "$rdnode" ] || { echo "README states no Node.js floor at all"; return 1; }
  [ "$rdnode" = "$node_v" ] || { echo "README claims Node.js $rdnode+ while engines and ci.yml say >=$node_v — two floors in the public repo"; return 1; }
  if grep -q '"packageManager"' package.json; then
    echo "packageManager was added — pnpm/action-setup already takes version from ci.yml (and would reject both)"; return 1
  fi
  if git show main:package.json 2>/dev/null | grep -q '"engines"'; then
    echo "main already declares engines — this check proves nothing"; return 1
  fi
  echo "repo floor >=$node_v / >=$pnpm_v derived from ci.yml; package floor $cnode disclosed as policy"
}
run_check "engines-derived" engines_derived

# ═══════════════════════════════════════ S44 · the decisions (req 7-8, 11)

# req 8 — D4. The same command, run twice: clean on the live tree, and matching
# on the NEWEST commit that still carries the path — which is derived by walking
# history, not typed. A pattern that matches nothing anywhere is a broken
# pattern, not a clean tree; that is the counterfactual.
home_path_scrubbed() {
  local pat='(/|-)Users[-/][a-z]+' c found=""
  if git grep -nE "$pat" -- .; then
    echo "^ a personal home path is still tracked"; return 1
  fi
  for c in $(git rev-list HEAD); do
    if git grep -qE "$pat" "$c" -- . 2>/dev/null; then found="$c"; break; fi
  done
  [ -n "$found" ] || { echo "no commit in history matches the pattern — the pattern is broken, not the tree clean"; return 1; }
  local n; n=$(git grep -cE "$pat" "$found" -- . | awk -F: '{s+=$NF} END {print s+0}')
  [ "$n" -gt 0 ] || { echo "the pattern matched nothing even on ${found:0:8}"; return 1; }
  echo "tree clean; the same command finds $n occurrences on the newest pre-scrub commit ${found:0:8}"
}
run_check "home-path-scrubbed" home_path_scrubbed

# req 11 + amendment A1 — D5. All 81 overrides are gone, main still has them,
# and the lockfile did not move: that zero delta IS the regen's result, which is
# why there is no lockfile commit of its own to separate from the manifest one.
overrides_gone() {
  if grep -q "^overrides:" pnpm-workspace.yaml; then
    echo "the overrides block is still in pnpm-workspace.yaml"; return 1
  fi
  if grep -qE "ngrok|esm-loader|@expo/" pnpm-workspace.yaml; then
    echo "an override target survives outside the overrides block"; return 1
  fi
  git show main:pnpm-workspace.yaml 2>/dev/null | grep -q "^overrides:" \
    || { echo "main has no overrides — this check proves nothing"; return 1; }
  local d; d=$(git diff --stat main...HEAD -- pnpm-lock.yaml || true)
  [ -z "$d" ] || { echo "pnpm-lock.yaml changed on this branch, but A1 records a zero delta:"; echo "$d"; return 1; }
  pnpm install --frozen-lockfile >/dev/null 2>&1 \
    || { echo "--frozen-lockfile fails with the overrides gone"; return 1; }
  echo "no overrides key, main had one, lockfile byte-identical to main, frozen install green"
}
run_check "overrides-gone" overrides_gone

# req 7 — D1, D2, D3/D6 are ANSWERED, and the answer must be the state of the
# tree. Only D4 and D5 had a gate until the cold review (N1): four decisions were
# recorded that no check could contradict, and the one that mattered was FALSE —
# main still tracks 11 files under playground/ and design-reference/ while the
# record said the flip publishes neither.
#
# Every assertion is run twice: against the working tree (must pass) and against
# `main` (must FAIL — main still half-tracks both directories and has no
# '## Git hooks (opt-in)' section). A check that also passed on main would prove
# nothing about this session.
founder_decisions_at() {
  local TREE="${1:-}" d l con gi hits=""
  rd() { if [ -n "$TREE" ]; then git show "$TREE:$1" 2>/dev/null; else cat "$1" 2>/dev/null; fi; }
  lsat() { if [ -n "$TREE" ]; then git ls-tree -r --name-only "$TREE" -- "$1"; else git ls-files -- "$1"; fi; }

  # D1 = keep all: the six process dirs stay in the index — the closeout's own
  # check_session_coverage / check_task_ref read them, so losing one is not
  # cosmetic.
  for d in .ai sessions prompts .claude reviewer darshan; do
    [ -n "$(lsat "$d")" ] || { echo "D1 broken: $d is not tracked${TREE:+ at $TREE}"; return 1; }
  done

  # D2 = documented: CONTRIBUTING must say the hooks are opt-in AND hand over the
  # one-line install, and .claude/settings.json must still declare its hooks.
  # NOTE: every test below is a HERE-STRING, not `printf | grep -q`. This gate runs
  # under `set -o pipefail`, and `grep -q` exits the moment it matches — so the
  # printf on the left of the pipe can take SIGPIPE and the pipeline reports 141,
  # which the `||` reads as "no match". That is exactly how this check first failed
  # on a settings.json that does contain "hooks".
  con=$(rd CONTRIBUTING.md)
  [ -n "$con" ] || { echo "D2 broken: CONTRIBUTING.md unreadable (cwd $(pwd), TREE='${TREE}')"; return 1; }
  grep -q '^## Git hooks (opt-in)' <<<"$con" \
    || { echo "D2 broken: CONTRIBUTING has no '## Git hooks (opt-in)' section${TREE:+ at $TREE}"; return 1; }
  grep -q 'git config core.hooksPath .githooks' <<<"$con" \
    || { echo "D2 broken: CONTRIBUTING gives no hooks install line"; return 1; }
  local js; js=$(rd .claude/settings.json)
  [ -n "$js" ] || { echo "D2 broken: .claude/settings.json is unreadable (cwd $(pwd), TREE='${TREE}')"; return 1; }
  grep -q '"hooks"' <<<"$js" \
    || { echo "D2 broken: .claude/settings.json declares no hooks (${#js} bytes read)"; return 1; }

  # D3/D6 = ignore: nothing under playground/ or design-reference/ may be in the
  # index, and .gitignore must ignore both directories WHOLE — the five partial
  # patterns that were there before are exactly how they ended up half-tracked.
  # Append with an explicit newline — but ONLY when there is something to append:
  # `$( )` strips the trailing one, so plain concatenation fused the two listings
  # and reported 10 instead of 11, while appending unconditionally left a bare
  # newline when both were empty and reported "still tracked" with no files.
  for d in playground design-reference; do
    l=$(lsat "$d")
    if [ -n "$l" ]; then hits+="$l"$'\n'; fi
  done
  [ -z "$hits" ] || { echo "D3/D6 broken: still tracked${TREE:+ at $TREE}:"; echo "$hits" | sed 's/^/  /'; return 1; }
  gi=$(rd .gitignore)
  for d in design-reference/ playground/; do
    grep -qx "$d" <<<"$gi" \
      || { echo "D3/D6 broken: .gitignore has no whole-directory rule '$d'${TREE:+ at $TREE}"; return 1; }
  done
  if [ -z "$TREE" ]; then
    # The live form: git honours an ignore rule only for a file it does not track,
    # so each probe fails for EITHER half of the bug — tracked, or not ignored.
    git check-ignore -q design-reference/mudra-chart.html \
      || { echo "D3/D6 broken: design-reference/mudra-chart.html is not ignored+untracked"; return 1; }
    git check-ignore -q playground/sre-dashboard/sre-server.ts \
      || { echo "D3/D6 broken: playground/sre-dashboard/sre-server.ts is not ignored+untracked"; return 1; }
  fi
  return 0
}
founder_decisions_covered() {
  founder_decisions_at "" || return 1
  local out rc=0 hits="" d l
  out=$(founder_decisions_at main 2>&1) || rc=$?
  [ "$rc" -ne 0 ] || { echo "the identical check passes on main, where none of this exists — it proves nothing"; return 1; }
  # Name BOTH halves main fails, not just the first one to fire: D3/D6 is the
  # decision THIS session changed, so the counterfactual has to show that one red
  # too. (Same branch-scoped shape as oss-surface-present: on main after the merge
  # this gate is historical and no longer run, like every prior session's.)
  for d in playground design-reference; do
    l=$(git ls-tree -r --name-only main -- "$d")
    if [ -n "$l" ]; then hits+="$l"$'\n'; fi
  done
  [ -n "$hits" ] || { echo "main tracks nothing under playground/ or design-reference/ — nothing here is being changed, so the counterfactual is a claim"; return 1; }
  echo "counterfactual: RED on main twice over — $(head -1 <<<"$out"); plus $(grep -c . <<<"$hits") files still tracked under playground/ or design-reference/"
}
run_check "founder-decisions-covered" founder_decisions_covered

# ══════════════════════════════════ S44 · the carried findings (req 9-10)

# req 9 — N1. Extract the PURE core out of the live closeout gate and run it in
# both directions against real history: S43 (contract untouched since its review)
# green, S42 (contract rewritten after its review, by this session's own D4
# scrub) red, naming a commit which must then be shown to touch the contract.
freshness_teeth() {
  local body rc=0 out h
  # Everything between the first PURE helper and check_contract_freshness: the
  # two helpers plus the core, so clause (b) can be driven directly (S44 N2).
  body=$(awk '/^contract_freshness_declared_mismatch\(\) \{/{f=1} f && /^check_contract_freshness\(\) \{/{exit} f{print}' scripts/verify-closeout.sh)
  [ -n "$body" ] || { echo "contract_freshness_core not found in scripts/verify-closeout.sh"; return 1; }
  eval "$body"
  type contract_freshness_core >/dev/null 2>&1 || { echo "the extracted body defined nothing"; return 1; }
  type contract_freshness_declared_change >/dev/null 2>&1 \
    || { echo "the clause-(b) helper was not extracted"; return 1; }
  out=$(N=43 contract_freshness_core 2>&1) || rc=$?
  [ "$rc" -eq 0 ] || { echo "S43 should be GREEN (contract untouched since its review), got: $out"; return 1; }
  rc=0; out=$(N=42 contract_freshness_core 2>&1) || rc=$?
  [ "$rc" -ne 0 ] || { echo "S42 should be RED — the D4 scrub rewrote its contract after its review — and it passed"; return 1; }
  echo "$out" | grep -q "CONTRACT REWRITTEN AFTER THE REVIEW" \
    || { echo "S42 failed for an unrelated reason: $out"; return 1; }
  h=$(echo "$out" | grep -oE '[0-9a-f]{40}' | head -1)
  [ -n "$h" ] || { echo "the failure names no commit"; return 1; }
  git log -1 --format=%H "$h" -- "prompts/42-task-*.md" | grep -q "^$h" \
    || { echo "the commit the check blames does not touch the contract: $h"; return 1; }
  echo "green on S43's untouched contract, red + commit-named on S42's rewritten one ($h)"

  # Clause (b), which clause (a) cannot reach: `first..HEAD` deliberately skips
  # the commit that ADDS the review, so the case reviewer/SKILL.md's own
  # "Honest limit" names — a contract edit carried by that very commit — is
  # defended here alone. It must work in EITHER line order: N2's defect was that
  # the final hash was matched unanchored, so a Pass-1 line printed first made
  # the two hashes compare equal and this clause returned 0 where the contract
  # demands 1. Synthetic reviews, so no historical file is touched.
  if ! (
    set -u
    t=$(mktemp) || { echo "mktemp failed"; exit 1; }
    trap 'rm -f "$t"' EXIT
    H1=$(printf '%064d' 1); H2=$(printf '%064d' 2)
    noamd="prompts/43-task-docs-weight.md"   # really has no amendments section
    amd="prompts/44-task-oss-polish.md"       # really has one
    [ -s "$noamd" ] || { echo "$noamd missing"; exit 1; }
    [ -s "$amd" ]   || { echo "$amd missing"; exit 1; }
    for v in first last; do
      if [ "$v" = first ]; then
        printf '**Review-Inputs-SHA-Pass-1:** %s\n**Review-Inputs-SHA:** %s\n' "$H1" "$H2" > "$t"
      else
        printf '**Review-Inputs-SHA:** %s\n**Review-Inputs-SHA-Pass-1:** %s\n' "$H2" "$H1" > "$t"
      fi
      rc=0; o=$(contract_freshness_declared_change "$t" "$noamd") || rc=$?
      [ "$rc" -eq 1 ] || { echo "clause (b) went GREEN with Pass-1 $v and a contract with no amendments (rc=$rc): $o"; exit 1; }
      grep -q "no '## Contract amendments' section" <<<"$o" \
        || { echo "clause (b) failed for the wrong reason on Pass-1 $v: $o"; exit 1; }
    done
    printf '**Review-Inputs-SHA-Pass-1:** %s\n**Review-Inputs-SHA:** %s\n' "$H1" "$H2" > "$t"
    rc=0; o=$(contract_freshness_declared_change "$t" "$amd") || rc=$?
    [ "$rc" -eq 0 ] || { echo "a declared change WITH an amendments section must be accepted, got rc=$rc: $o"; exit 1; }
    printf '**Review-Inputs-SHA-Pass-1:** %s\n**Review-Inputs-SHA:** %s\n' "$H1" "$H1" > "$t"
    contract_freshness_declared_change "$t" "$noamd" >/dev/null \
      || { echo "two identical hashes were read as a declared change"; exit 1; }
    printf '**Review-Inputs-SHA:** %s\n' "$H1" > "$t"
    contract_freshness_declared_change "$t" "$noamd" >/dev/null \
      || { echo "a review with no Pass-1 declaration was read as a declared change"; exit 1; }
    echo "clause (b): RED with Pass-1 first AND Pass-1 last when no amendments section exists, accepted when one does, green on matching/absent hashes"
    exit 0
  ); then return 1; fi
}
run_check "contract-freshness-teeth" freshness_teeth

# The NEWEST run's timings file that actually prices the skip list. Prints the
# path, or nothing + rc 1 if none qualifies. $1 = directory to scan (defaults to
# the real artifacts dir) so the caller can drive it over a fixture — that is how
# `gate-scope-switch` proves the selection is newest-first instead of asserting it.
# A candidate must ALSO be COMPLETE — one line per check this gate declares.
# Without that, the run in progress is "the newest" while it is still being written,
# and the ratio it yields depends on how many checks happened to finish before this
# one (measured: 80% mid-run against 73% for the finished run beside it).
pick_timings_file() {
  local root="${1:-.ai/verify/session-44}" f want
  want=$(grep -c '^run_check ' "$0")
  local files=("$root"/*/timings.txt) i
  for (( i = ${#files[@]} - 1; i >= 0; i-- )); do
    f="${files[i]}"
    [ -f "$f" ] || continue
    case "$f" in */latest/*) continue ;; esac
    [ "$(wc -l < "$f" | tr -d ' ')" -eq "$want" ] || continue
    awk -v names="$FAST_SKIP" 'BEGIN{n=split(names,a," ")} {for(i=1;i<=n;i++) if($1==a[i]) c++} END{exit (c==0)}' "$f" \
      || continue
    printf '%s\n' "$f"
    return 0
  done
  return 1
}

# req 10 — §4.9. The switch resolves three ways (an invalid scope is rejected),
# the skip list names only checks this gate really runs, it never covers a check
# this session owns, and — the counterfactual — the measured seconds it removes
# are > 0 and < the whole gate, read out of the timings this script just wrote.
gate_scope_switch() {
  local s tf="" total=0 skipped=0 name secs lines=0 f
  [ "$(resolve_scope)" = full ] || { echo "the default scope is not full"; return 1; }
  [ "$(resolve_scope fast)" = fast ] || { echo "fast does not resolve"; return 1; }
  resolve_scope bogus >/dev/null 2>&1 && { echo "an invalid scope is accepted"; return 1; }
  [ -n "$FAST_SKIP" ] || { echo "the skip list is empty"; return 1; }
  for s in $FAST_SKIP; do
    grep -q "run_check \"$s\"" "$0" \
      || { echo "FAST_SKIP names '$s', which is not a check in this gate"; return 1; }
  done
  for s in oss-surface-present coverage-enforced-in-ci engines-derived home-path-scrubbed \
           overrides-gone founder-decisions-covered contract-freshness-teeth \
           s43-gate-verbatim-goes-red contract-at-head; do
    if gate_skips fast "$s"; then echo "fast would skip $s, which this session owns"; return 1; fi
  done
  # The timings have to come from a FULL run: fast never runs a check it skips,
  # so a fast run's file contains none of these names and prices nothing. Three
  # traps, all found by running it —
  #  (a) picking by line count alone tied 41 = 41 between the current run and the
  #      previous fast one, and `sort -rn`'s last-resort comparison put "latest/"
  #      above a timestamp, so it read the OLD run and reported 0;
  #  (b) `latest` is a symlink, so it can name a run that is not the one in
  #      progress;
  #  (c) taking the file with the MOST lines and keeping the old one on a tie
  #      froze the figure at the FIRST full run ever made — every full run writes
  #      the same number of lines, so `[ "$cnt" -gt "$best" ]` can never replace
  #      the oldest. A cold review measured 73% on a later full run while this
  #      line still printed 86%: a number that cannot move, describing a run
  #      nobody was looking at. That is the fakest green of the whole delivery.
  # Selection is now newest-first (pick_timings_file), the figure is printed with
  # its source, and the fixtures below drive that function so "newest wins" is a
  # fact the check can lose on rather than a comment.
  local fx="$ARTIFACTS/scope-selftest" got d want skip1 k
  rm -rf "$fx"; mkdir -p "$fx"/{20000101T000000Z,20100101T000000Z,20100101T000001Z,20100101T000002Z,latest}
  # Two COMPLETE full runs with the SAME line count — the exact tie that froze the
  # figure at the oldest one — plus, newer than both, a run that prices nothing and a
  # half-written one, neither of which may be used, plus a `latest` directory, which is
  # not a run at all. Each of the four rejections is exercised by its own guard; pass 3
  # noted that two of them were previously caught by the completeness test instead, so
  # the message named guards the fixture never reached.
  want=$(grep -c '^run_check ' "$0"); set -- $FAST_SKIP; skip1="$1"
  for d in 20000101T000000Z 20100101T000000Z; do
    : > "$fx/$d/timings.txt"
    for k in $(seq 1 "$want"); do
      if [ "$k" -eq 1 ]; then printf '%s 5\n' "$skip1" >> "$fx/$d/timings.txt"
      else printf 'core-tests 1\n' >> "$fx/$d/timings.txt"; fi
    done
  done
  head -3 "$fx/20100101T000000Z/timings.txt" > "$fx/20100101T000002Z/timings.txt"
  # 20100101T000001Z: COMPLETE length but no fast-skipped check in it — a fast run
  # can never be that long, but the guard that rejects it is the "prices nothing"
  # one, and the fixture should exercise that guard rather than the completeness one.
  { local k2=0; while [ "$k2" -lt "$want" ]; do printf 'core-tests 1\n'; k2=$((k2+1)); done; } > "$fx/20100101T000001Z/timings.txt"
  : > "$fx/latest/timings.txt"
  got=$(pick_timings_file "$fx" 2>/dev/null || true)
  case "$got" in
    */20100101T000000Z/timings.txt) : ;;
    *) echo "selection is wrong: got '${got:-<none>}' — expected the NEWEST COMPLETE run that prices the skip list; a file that prices nothing, is half-written, or sits under latest/ must be passed over"; rm -rf "$fx"; return 1 ;;
  esac
  rm -rf "$fx"
  tf=$(pick_timings_file || true)
  [ -n "$tf" ] || { echo "no COMPLETE full run's timings yet — finish one with VAJRA_GATE_SCOPE=full"; return 1; }
  # If this run's own file is NOT the one being priced, say so next to the number
  # instead of letting an older run's timings stand in for it silently.
  local src="the newest COMPLETE full run on disk (this run is still being written)"
  [ "$tf" = "$ARTIFACTS/timings.txt" ] && src="this run"
  while read -r name secs; do
    [ -n "$name" ] || continue
    total=$((total + secs)); lines=$((lines + 1))
    if gate_skips fast "$name"; then skipped=$((skipped + secs)); fi
  done < "$tf"
  [ "$lines" -gt 0 ] || { echo "$tf records no checks"; return 1; }
  # (lines counts what was READ below; cnt/best are the selection loop's own —
  # sharing one variable there reported 41+47=88 "checks" on the second run.)
  [ "$skipped" -gt 0 ] || { echo "the skip list costs 0 measured seconds — fast would not be faster"; return 1; }
  [ "$skipped" -lt "$total" ] || { echo "the skip list covers the entire gate"; return 1; }
  # The percentage is of THIS GATE's measured check time, not of the wall clock it
  # prints at the end (which includes gate setup and the summary rewrite) — so say
  # "measured check time" and name the run, rather than letting 86% stand as a claim
  # about a two-minute wall clock that includes everything else.
  echo "fast removes ${skipped}s ($((skipped / 60))m$((skipped % 60))s) of ${total}s ($((total / 60))m$((total % 60))s) measured across $lines checks — $((skipped * 100 / (total > 0 ? total : 1)))% of this gate's measured check time (priced from $src: $(basename "$(dirname "$tf")"))"
}
run_check "gate-scope-switch" gate_scope_switch

# ═══════════════════════════════════════════ S44 · the counterfactual (req 14)

# THE counterfactual the contract demands: S43's gate, run unmodified on this
# branch, must exit non-zero — and the reason must be DISCOVERABLE, not asserted.
#
# The check that breaks is ai-files-describe-s43. It hard-codes what only one
# session can be true of: `.ai/SESSION` must read 43 and STATE.md must name
# `session-43-docs-weight`. S44 re-syncs both, so S43's own gate fails on S44's
# tree for the same reason S42's failed on S43's — a gate coupled to this
# session's identity. The port re-expresses it as ai-files-describe-s44.
#
# It does NOT run S43's whole gate (a fresh clone install plus browser QA), so
# this stays cheap: the real check body is EXTRACTED from S43's gate file, so an
# edit there follows through instead of leaving a stale transcription.
s43_gate_goes_red() {
  local stmt cmd rc
  stmt=$(awk '/^run_check "ai-files-describe-s43"/{f=1} f{print} f&&/^$/{exit}' scripts/verify-session-43.sh)
  [ -n "$stmt" ] || { echo "S43's ai-files-describe-s43 check is not in scripts/verify-session-43.sh"; return 1; }
  cmd=${stmt#run_check \"ai-files-describe-s43\" }
  set +e
  eval "$cmd" > /tmp/s44-ai-files-s43.out 2>&1
  rc=$?
  set -e
  echo "--- S43 ai-files-describe-s43 output ---"; cat /tmp/s44-ai-files-s43.out
  [ "$rc" -ne 0 ] || { echo "S43's ai-files-describe-s43 is GREEN here — the re-expression claim is false"; return 1; }
  grep -qE "not 43|does not name the live branch" /tmp/s44-ai-files-s43.out \
    || { echo "S43's check failed for an UNRELATED reason, so this proves nothing"; return 1; }
  echo "S43's ai-files-describe-s43, extracted from its own gate, exits $rc on the S44 tree"
  return 0
}
run_check "s43-gate-verbatim-goes-red" s43_gate_goes_red

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
  c=prompts/44-task-oss-polish.md
  [ -f "$c" ] || { echo "the contract is missing"; return 1; }
  git ls-files --error-unmatch -- "$c" >/dev/null 2>&1 || { echo "the contract is untracked"; return 1; }
  # Every numbered requirement 1..10 must be present AS A HEADING, and the set of
  # numbers found must be exactly 1..10 - no gaps, and nothing standing in for a
  # missing one. Scoped to the Scope section on purpose: the Assumptions block
  # also carries items numbered 1 and 2, and counting those would make the set
  # 1..10,1,2 and the comparison meaningless.
  found=$(awk '/^## Scope/{f=1;next} /^## /{f=0} f' "$c" \
          | grep -oE '^[0-9]+\. \*\*' | grep -oE '^[0-9]+' | LC_ALL=C sort -n | tr '\n' ' ')
  want=$(seq 1 14 | tr '\n' ' ')
  [ "$found" = "$want" ] || { echo "contract requirements are [$found], expected [$want]"; return 1; }
  # The sections that carry obligations the gate does not itself assert.
  for s in '## Out of scope' '## Assumptions' '## Founder decision' '## Closeout' '## Contract amendments'; do
    grep -q "^$s" "$c" || { echo "contract is missing the section: $s"; return 1; }
  done
  # And the counterfactual the contract demands must be named in it.
  grep -qi 's43-gate-verbatim-goes-red' "$c" \
    || { echo "the contract does not name the counterfactual it demands"; return 1; }
  # A1 amended requirement 11 after it was written; the amendments section is how
  # that is declared rather than silently folded into the requirement text (N1).
  grep -q '^### A1' "$c" || { echo "the amendments section has no A1"; return 1; }
  echo "contract tracked, requirements 1-14 all present as headings, obligation + amendments sections intact"
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
  out=\$(DEMO_LOG_DIR='$ARTIFACTS' bash scripts/demo-session-44.sh 2>&1) \
    || { echo \"\$out\" | tail -10; echo 'the demo did not exit 0'; exit 1; }
  echo \"\$out\" | grep -qE '\([0-9]+ tests in [0-9]+ files\)' \
    || { echo 'the demo prints no (N tests in M files) line'; exit 1; }
  n=\$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+')
  echo \"\$out\" | grep -q \"(\$n tests in\" \
    || { echo \"the demo displays a count that is not the suite's (\$n)\"; exit 1; }
  echo \"the demo's OUTPUT carries the suite's live count (\$n tests)\""

( cd ".ai/verify/session-44" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

ELAPSED_SEC=$(( $(date +%s) - START ))
ELAPSED_MIN=$(( ELAPSED_SEC / 60 ))
echo "=== Session 44 Verify Summary (scope=$SCOPE, ${ELAPSED_MIN}m$(( ELAPSED_SEC % 60 ))s) ==="
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

# §4.9: the number this gate costs, printed whatever the scope, so the ~60 min
# claim is measurable by whoever runs it next instead of repeated from a review.
printf 'scope=%s checks=%s pass=%s fail=%s elapsed_min=%s elapsed_sec=%s\n' \
  "$SCOPE" "$((PASS + FAIL))" "$PASS" "$FAIL" "$ELAPSED_MIN" "$ELAPSED_SEC" | tee "$ARTIFACTS/run-meta.txt"
if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail, scope=$SCOPE, ${ELAPSED_MIN}m$(( ELAPSED_SEC % 60 ))s)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi