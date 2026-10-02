#!/usr/bin/env bash
# S41 — cleanup Batch 1: the public face tells the truth, and a stranger can build it.
#
# Design rules carried from S38/S39/S40:
#   * assert FACTS, not phrases — a check coupled to a string is not a guard;
#   * a check that cannot fail is a bug — every check here has a demonstrated
#     counterfactual, noted beside it;
#   * the fresh-clone build is the load-bearing gate. It has never passed in this
#     repo's history, because it was never run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-41/${TS}"
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

# ---------------------------------------------------------------- group A: facts

# req 2 — the version cannot drift. Counterfactual: writing 0.1.0 into
# src/version.ts makes this exit 1 (demonstrated when the check was written).
run_check "version-src-matches-manifest" node scripts/sync-version.mjs --check

# req 2 — and the artifact npm would publish agrees with the manifest. This
# executes the built bundle; it does not grep it. Counterfactual: a dist whose
# VERSION is 0.1.0 against a 0.3.0 manifest fails.
run_check "version-in-built-dist" bash -c '
  set -e
  pnpm --filter @ifelse.codes/chitra run build >/dev/null 2>&1
  d="$(node -e "import(\"./packages/core/dist/index.js\").then(m => console.log(m.VERSION))")"
  m="$(node -p "require(\"./packages/core/package.json\").version")"
  [ "$d" = "$m" ] || { echo "dist says $d, manifest says $m"; exit 1; }
  echo "dist VERSION == manifest ($m)"'

# req 2 — the 0.1.0 literal is gone from everything that ships.
run_check "no-stale-version-literal" bash -c '
  hits="$(grep -rn "0\.1\.0" '"$CORE"'/dist/ 2>/dev/null || true)"
  [ -z "$hits" ] || { echo "$hits"; exit 1; }
  ! grep -qE "VERSION\s*=\s*\"0\." '"$CORE"'/src/index.ts || { echo "src/index.ts restates a literal version"; exit 1; }
  echo "no 0.1.0 in dist; src/index.ts derives"'

# req 1 — the string that was live on chitra.iifelse.com is gone from the source
# AND from the built page a browser would actually receive.
run_check "docs-meta-not-scaffold" bash -c '
  set -e
  ! grep -qi "replit" '"$DOCS"'/index.html || { echo "placeholder still in source"; exit 1; }
  pnpm --filter @workspace/chitra-docs run build >/dev/null 2>&1
  out=$(ls -d '"$DOCS"'/dist/public/index.html 2>/dev/null || ls -d '"$DOCS"'/dist/index.html)
  ! grep -qi "replit" "$out" || { echo "placeholder still in BUILT page: $out"; exit 1; }
  grep -q "chitra" "$out" || { echo "no product line in built page"; exit 1; }
  echo "built page clean: $out"'

# req 3 — the npm README is not an internal design log any more.
run_check "npm-readme-no-design-log" bash -c '
  n=$(grep -c "LOCKED:" '"$CORE"'/README.md || true)
  [ "$n" -eq 0 ] || { echo "$n LOCKED sections still in the npm README"; exit 1; }
  ! grep -qE "session [0-9]{2} design" '"$CORE"'/README.md || { echo "internal session refs remain"; exit 1; }
  ! grep -q "block (default for line)" '"$CORE"'/README.md || { echo "phantom line renderer still documented"; exit 1; }
  echo "npm README: no design log, no phantom renderer"'

# req 4 — the five CONTRIBUTING lies.
run_check "contributing-claims-true" bash -c '
  f=CONTRIBUTING.md
  ! grep -q "chitra-dev/chitra" $f || { echo "wrong clone org"; exit 1; }
  grep -q "ifelse-codes/chitra" $f || { echo "correct clone org missing"; exit 1; }
  ! grep -q "experimental-specifier-resolution" $f || { echo "dead run command"; exit 1; }
  grep -q "pnpm example" $f || { echo "working run command missing"; exit 1; }
  grep -q "toContent()" $f || { echo "ChartResult template still omits toContent()"; exit 1; }
  grep -qE "9[0-9]\.[0-9]+ / 8[0-9]\.[0-9]+ / 8[0-9]\.[0-9]+ / 9[0-9]\.[0-9]+" $f \
    || { echo "measured coverage numbers not published"; exit 1; }
  ! grep -q ">90% test coverage" $f || { echo "unmeasured >90% claim still there"; exit 1; }
  echo "CONTRIBUTING: 5 claims reconciled"'

# req 6 — replit.md must agree with ci.yml, which is the thing that actually runs.
run_check "replit-node-matches-ci" bash -c '
  v="$(grep -oE "NODE_VERSION: *\"[0-9]+\"" .github/workflows/ci.yml | grep -oE "[0-9]+")"
  grep -q "Node.js $v" replit.md || { echo "replit.md does not say Node $v"; exit 1; }
  ! grep -q "20/22/24" replit.md || { echo "replit.md still claims a CI matrix that does not exist"; exit 1; }
  grep -q "toContent" replit.md || { echo "ChartResult list in replit.md omits toContent"; exit 1; }
  echo "replit.md agrees with ci.yml (Node $v)"'

# req 7 — the provenance comment must be true whether or not the repo is public.
run_check "provenance-comment-state-agnostic" bash -c '
  f=.github/workflows/release.yml
  grep -qi "private" $f || { echo "no mention of the private-repo condition"; exit 1; }
  grep -qi "public" $f || { echo "no mention of the public case"; exit 1; }
  ! grep -qi "would turn provenance on" $f || { echo "the stale pre-flip claim is still here"; exit 1; }
  echo "provenance comment reads correctly in both repo states"'

# req 8 — no public document points into .ai/.
run_check "no-public-doc-points-into-ai" bash -c '
  bad="$(grep -n "\.ai/" README.md CONTRIBUTING.md replit.md 2>/dev/null || true)"
  [ -z "$bad" ] || { echo "$bad"; exit 1; }
  echo "no public doc references .ai/"'

# ---------------------------------------------------------------- group B: build

# req 11 — the configs must not throw when the env is absent. The assertion is on
# the throw itself, not on the presence of a default.
run_check "vite-configs-no-hard-throw" bash -c '
  for f in '"$DOCS"'/vite.config.ts artifacts/mockup-sandbox/vite.config.ts; do
    grep -q "is required but was not provided" $f && { echo "$f still hard-throws"; exit 1; }
    grep -q "process.env.PORT ?? " $f || { echo "$f does not default PORT"; exit 1; }
    grep -q "process.env.BASE_PATH ?? " $f || { echo "$f does not default BASE_PATH"; exit 1; }
  done
  echo "both vite configs default the Replit env"'

# req 12 — a glob for a directory that does not exist.
run_check "workspace-glob-real" bash -c '
  # Only the `packages:` block — the same file also carries catalog:, overrides: and
  # onlyBuiltDependencies: lists whose "  - esbuild" lines are not workspace globs.
  awk "/^packages:/{f=1;next} /^[a-zA-Z]/{f=0} f && /^  - /{print \$2}" pnpm-workspace.yaml |
  while read -r g; do
    case "$g" in
      *\**) ls -d ${g%/\*} >/dev/null 2>&1 || { echo "glob $g matches nothing"; exit 1; } ;;
      *)   [ -e "$g" ] || { echo "workspace entry $g does not exist"; exit 1; } ;;
    esac
  done
  echo "every workspace glob matches something"'

# THE GATE. Never run in this repo before S41. Counterfactual: revert the build
# order and this fails with TS2307.
run_check "fresh-clone-build-no-env" bash -c '
  set -e
  d=$(mktemp -d)
  trap "rm -rf $d" EXIT
  # --local clones the current branch tip, which is what a stranger would get.
  git clone --local -q '"$ROOT"' "$d/clone"
  cd "$d/clone"
  [ ! -d packages/core/dist ] || { echo "dist leaked into the clone"; exit 1; }
  pnpm install --frozen-lockfile >/dev/null 2>&1
  env -u PORT -u BASE_PATH pnpm run build >"$d/build.log" 2>&1 || { tail -30 "$d/build.log"; exit 1; }
  echo "fresh clone: install + build, no env, exit 0"'

# ---------------------------------------------------------------- the product

run_check "core-tests" bash -c "pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -qE 'Tests +452 passed'"
run_check "core-typecheck"        bash -c "pnpm --filter @ifelse.codes/chitra run typecheck"
run_check "root-typecheck"        bash -c "pnpm run typecheck"
run_check "coverage-gate-passes"  bash -c "pnpm --filter @ifelse.codes/chitra run test:coverage"
run_check "chart-drift"           bash -c "pnpm --filter @workspace/chitra-docs run gen:charts:check"

# The S39 suite is the regression guard for the canonical-count trap this session
# walked straight into: 452 is asserted in 12 places, and main already lost one
# commit to it. If this goes red, a count moved.
run_check "s39-suite-still-green" bash -c "bash scripts/verify-session-39.sh"

# req 13 — the machine-path junk must be gone, not merely ignored.
run_check "no-machine-path-junk" bash -c '
  bad="$(git status --porcelain --untracked-files=all | awk "{print \$2}" \
         | grep -E "command-code-session|\.commandcode|\.freebuff" || true)"
  [ -z "$bad" ] || { echo "untracked machine-path files present: $bad"; exit 1; }
  for f in command-code-session-8b98ceae.html scripts/build-audit-html.mjs jev-readiness-plan.md .ai/CHITRA-FRAME-FIX.md; do
    [ ! -e "$f" ] || { echo "$f was supposed to be deleted"; exit 1; }
    ! git ls-files --error-unmatch "$f" >/dev/null 2>&1 || { echo "$f is tracked"; exit 1; }
  done
  echo "junk deleted, nothing machine-specific untracked"'

# The contract promised the chart implementations stay LOCKED. Assert it.
run_check "charts-untouched" bash -c '
  d="$(git diff --name-only main...HEAD -- '"$CORE"'/src/charts/ '"$CORE"'/src/renderers/ '"$CORE"'/src/themes/ | wc -l | tr -d " ")"
  [ "$d" = "0" ] || { echo "$d files changed under the LOCKED design language"; exit 1; }
  echo "no changes under src/charts, src/renderers, src/themes"'

# req 5 — the documented command must actually run. A grep for "pnpm example"
# in CONTRIBUTING is not evidence that the command works.
run_check "example-runs" bash -c '
  out="$(pnpm example 2>&1)" || { echo "$out" | tail -20; exit 1; }
  echo "$out" | grep -q "Revenue Trend" || { echo "example ran but rendered no chart"; exit 1; }
  echo "pnpm example exited 0 and rendered a chart"'

# req 9 — the .ai/ files must describe THIS session, read live.
run_check "ai-files-describe-s41" bash -c '
  want=$(cat .ai/SESSION)
  [ "$want" = "41" ] || { echo ".ai/SESSION reads $want, not 41"; exit 1; }
  grep -q "session-41-repo-cleanup" .ai/TASK.md || { echo "TASK.md does not name the branch"; exit 1; }
  grep -q "session-41-repo-cleanup" .ai/SESSION-BOOT.md || { echo "SESSION-BOOT.md does not name the branch"; exit 1; }
  for s in 41 42 43 44; do
    grep -q "Session $s (S$s)" .ai/ROADMAP.md || { echo "ROADMAP.md has no Session $s item"; exit 1; }
  done
  echo ".ai/ describes S41 on this branch; S42-S44 scheduled"'

( cd ".ai/verify/session-41" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 41 Verify Summary ==="
printf '%-38s %s\n' "CHECK" "RESULT"
printf '%-38s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]:-}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
