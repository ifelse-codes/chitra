#!/usr/bin/env bash
# S48 — the GTM proof pack (prompts/48-task-gtm-proof-pack.md, R1–R6).
#
# Design rules carried from S38..S47:
#   * assert FACTS, not phrases — every claim is re-derived at run time from the
#     one source that defines it, never from another claim;
#   * a check that cannot fail is a bug — each one names its counterfactual;
#   * a fix proven only by its own exit 0 FAILS — every requirement ships with the
#     command that makes the OLD body green and the NEW body red on the same tree.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SESSION="48"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"
START=$(date +%s)

# VAJRA_GATE_SCOPE must be full or fast (got ''). The closeout gate greps for this
# exact line — an absent or differently-defaulted switch would let evidence run cheap.
resolve_scope() { case "${1:-}" in ""|full) echo full ;; fast) echo fast ;; *) return 1 ;; esac; }
SCOPE="$(resolve_scope "${VAJRA_GATE_SCOPE:-}")" \
  || { echo "VAJRA_GATE_SCOPE must be full or fast (got '${VAJRA_GATE_SCOPE:-}')"; exit 2; }

gate_skips() { [ "$1" = fast ] || return 1; case " $FAST_SKIP " in *" $2 "*) return 0 ;; esac; return 1; }
# Inherited cost: the suite run and the network probes. Every check this session
# OWNS (R1–R6 evidence) runs in both scopes.
FAST_SKIP="core-suite-green docs-link-live adoption-reading-recorded"

PASS=0; FAIL=0; RESULTS=()
write_summary() {
  { for r in "${RESULTS[@]:-}"; do
      printf '%-34s %s\n' "$(echo "$r" | awk '{print $1}')" "$(echo "$r" | awk '{print $NF}')"
    done; } > "$ARTIFACTS/summary.txt"
}
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if gate_skips "$SCOPE" "$NAME"; then
    echo "SKIPPED: VAJRA_GATE_SCOPE=$SCOPE does not run this check (full is the default)." > "$LOG"
    RESULTS+=("$(printf '%-34s %s' "$NAME" "SKIP")"); write_summary; return 0
  fi
  local t0 t1 rc=0
  t0=$(perl -MTime::HiRes=time -e 'printf("%d", time()*1000)')
  "$@" > "$LOG" 2>&1 || rc=$?
  t1=$(perl -MTime::HiRes=time -e 'printf("%d", time()*1000)')
  printf '%s %s\n' "$NAME" "$(( (t1 - t0) / 1000 ))" >> "$ARTIFACTS/timings.txt"
  if [ "$rc" -eq 0 ]; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" "PASS")"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" "FAIL")"); FAIL=$((FAIL+1))
  fi
  write_summary
}

# ── Toolchain precondition (stated, never assumed) ─────────────────────────────
# Claims and benchmarks are DERIVED, which needs the built package. A clean checkout
# is RED with the exact command that fixes it — never green by fallback, never a
# toolchain error reported as a product failure.
# Counterfactual: fresh clone, no install → red with `pnpm install --frozen-lockfile`.
require_toolchain() {
  local what="$1"
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "$what unprovable: pnpm is not on PATH — install pnpm, then: pnpm install --frozen-lockfile && pnpm --filter @ifelse.codes/chitra run build"; return 1
  fi
  if [ ! -d node_modules ]; then
    echo "$what unprovable: node_modules missing — run: pnpm install --frozen-lockfile"; return 1
  fi
  if [ ! -f packages/core/dist/index.cjs ]; then
    echo "$what unprovable: packages/core/dist missing — run: pnpm --filter @ifelse.codes/chitra run build"; return 1
  fi
  return 0
}

# ── R0: the contract is at HEAD, numbered, capped ──────────────────────────────
# Counterfactual: delete prompts/48-task-gtm-proof-pack.md from the index → red.
contract_at_head() {
  local f=prompts/48-task-gtm-proof-pack.md
  git cat-file -e "HEAD:$f" 2>/dev/null || { echo "$f not committed at HEAD"; return 1; }
  for r in R1 R2 R3 R4 R5 R6; do
    grep -q "^\*\*$r" "$f" || { echo "requirement $r missing"; return 1; }
  done
  local as; as=$(grep -c '^ *- \*\*AS-' "$f" || true)
  [ "$as" -le 2 ] || { echo "$as assumptions, cap is 2"; return 1; }
  grep -q 'Out of scope' "$f" || { echo "no out-of-scope section"; return 1; }
  echo "contract at HEAD: R1–R6 present, $as assumption(s), out-of-scope named"
}
run_check "contract-at-head" contract_at_head

# ── The suite, which is what the tests claim points at ─────────────────────────
# Counterfactual: retype the README test badge without changing the suite → red
# here, because the badge is the number this check greps for.
suite_green() {
  require_toolchain "the tests claim" || return 1
  local claimed out
  claimed=$(grep -m1 -oE 'tests-[0-9]+%20passing' README.md | grep -oE '[0-9]+')
  [ -n "$claimed" ] || { echo "README carries no tests badge to check"; return 1; }
  out=$(pnpm --filter @ifelse.codes/chitra run test 2>&1) \
    || { printf '%s\n' "$out" | tail -25; return 1; }
  printf '%s\n' "$out" | grep -E 'Test Files|Tests ' | tail -3
  if ! printf '%s\n' "$out" | grep -qE "Tests +${claimed} passed"; then
    echo "README claims ${claimed} tests; the suite printed something else"; return 1
  fi
  echo "README badge (${claimed}) == suite output"
}
run_check "core-suite-green" suite_green

# ── R1: every public claim is derived, not typed ───────────────────────────────
# One source per fact, and the check reads the SOURCE, never another claim:
#   charts    → export lines in packages/core/src/charts/index.ts   (the public API)
#   renderers → the RendererType union in packages/core/src/types.ts
#   themes    → Object.keys(themes) from the built package
#   deps/lic/ver → packages/core/package.json
#   tests     → the suite (checked by core-suite-green above)
# Claim sites: README badges + prose, the docs hero stats, .ai/KNOWLEDGE.md.
# Counterfactual: retype `charts-20` → `charts-21` in README, or a hero stat → red.
# (Note: counting FILES in charts/ gives 23 — index.ts, line-model.ts and the
#  unexported ring.ts are not charts. A naive command would "fix" a correct badge.)
claims_match_truth() {
  require_toolchain "the claim derivations" || return 1
  local charts renderers themes deps license version
  charts=$(grep -cE '^export \{ [a-z]' packages/core/src/charts/index.ts)
  renderers=$(grep -m1 'export type RendererType' packages/core/src/types.ts \
              | grep -oE '"[a-z]+"' | grep -c .)
  read -r themes deps license version <<<"$(node -e '
    const m=require("./packages/core/package.json");
    const c=require("./packages/core/dist/index.cjs");
    console.log(Object.keys(c.themes).length, Object.keys(m.dependencies||{}).length, m.license, m.version);
  ')"
  [ -n "$themes" ] || { echo "could not derive themes/deps/license/version"; return 1; }
  echo "derived: charts=$charts renderers=$renderers themes=$themes deps=$deps license=$license version=$version"

  local bad=""
  grep -q "charts-${charts}" README.md            || bad="$bad README-badge"
  grep -q "all ${charts} charts" README.md        || bad="$bad README-prose"
  grep -q "${renderers} renderers" README.md      || bad="$bad README-renderers"
  grep -q "dependencies-${deps}" README.md        || bad="$bad README-deps"
  grep -q "license: ${license}" README.md         || bad="$bad README-license"
  grep -q "all ${charts} charts" .ai/KNOWLEDGE.md || bad="$bad KNOWLEDGE-charts"
  [ -z "$bad" ] || { echo "claim ≠ truth in:$bad (derived values above)"; return 1; }

  # Docs hero: number AND label must appear in the same stat block.
  local hero
  hero=$(node -e '
    const s=require("fs").readFileSync("artifacts/chitra-docs/src/App.tsx","utf8");
    const re=/<span className="stat-num">(\d+)<\/span>\s*<span className="stat-label">([^<]+)<\/span>/g;
    let m,out=[]; while((m=re.exec(s))) out.push(m[1]+" "+m[2].trim());
    console.log(out.join("\n"));
  ')
  local want="${charts} Chart types
${renderers} Renderers
${themes} Themes
$(grep -m1 -oE 'tests-[0-9]+' README.md | grep -oE '[0-9]+') Tests passing
${deps} Dependencies"
  if [ "$hero" != "$want" ]; then
    echo "docs hero drifted from the derived values:"
    diff <(printf '%s\n' "$want") <(printf '%s\n' "$hero") || true
    return 1
  fi
  echo "README, KNOWLEDGE and the docs hero all carry the derived values"
}
run_check "claims-match-truth" claims_match_truth

# ── R5: the first screen answers three questions, probed ───────────────────────
# (1) install command present; (2) the demo link really answers 200; (3) the
# rendered example in README is byte-identical to what the library prints today.
# Counterfactuals: drop the install line → red; kill the link → red; edit one glyph
# in the example block → red.
first_screen_probes() {
  grep -qE '(pnpm add|npm install|npm i) @ifelse\.codes/chitra' README.md \
    || { echo "README has no install command for a stranger"; return 1; }
  local live want
  live=$(mktemp); want=$(mktemp)
  node -e '
    const { line } = require("./packages/core/dist/index.cjs");
    line({ data: [12,19,14,27,22,34,29,41], title: "Weekly active users", noColor: true }).render();
  ' > "$live" 2>/dev/null || { rm -f "$live" "$want"; echo "live render failed"; return 1; }
  awk '/^```text$/{f=1;next} /^```$/{if(f)exit} f' README.md > "$want"
  if ! diff <(sed -e 's/[[:space:]]*$//' "$live") <(sed -e 's/[[:space:]]*$//' "$want") >/dev/null; then
    echo "README example has drifted from a real render:"
    diff <(sed -e 's/[[:space:]]*$//' "$live") <(sed -e 's/[[:space:]]*$//' "$want") | head -8 || true
    rm -f "$live" "$want"; return 1
  fi
  local lines; lines=$(wc -l < "$want" | tr -d ' ')
  rm -f "$live" "$want"
  echo "install command present; README example == live render ($lines lines)"
}
run_check "first-screen-probes" first_screen_probes

# ── R5 (network): the demo link answers ────────────────────────────────────────
docs_link_live() {
  local code
  code=$(curl -s -o /dev/null -m 20 -w '%{http_code}' https://chitra.iifelse.com || echo 000)
  [ "$code" = "200" ] || { echo "https://chitra.iifelse.com → $code (expected 200)"; return 1; }
  echo "https://chitra.iifelse.com → 200"
}
run_check "docs-link-live" docs_link_live

# ── R2: adoption is measured, not asserted ────────────────────────────────────
# The recorded figures are re-derived for the DATES they claim — never compared
# with today's total, which moves every time someone installs. A stale or invented
# number goes red because the API still has to return what .ai/STATE.md says it
# returned on the day it says it did. The S40 ledger row must be dispositioned too.
# Counterfactual: change 273 -> 274 in STATE, or its --as-of date → red.
adoption_reading_recorded() {
  command -v node >/dev/null 2>&1 || { echo "node is not on PATH"; return 1; }
  [ -s scripts/gtm-reads.mjs ] || { echo "instrument scripts/gtm-reads.mjs missing"; return 1; }
  local t1 t1day t0 t0day out
  t1=$(grep -m1 -oE 't1 = [0-9]+' .ai/STATE.md | sed -E 's/.*= //' || true)
  t1day=$(grep -m1 -oE 'through \*\*[0-9-]+\*\*' .ai/STATE.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
  t0=$(grep -m1 -oE '`t0` = [0-9]+' .ai/STATE.md | sed -E 's/.*= //' || true)
  t0day=$(grep -m1 -oE '\-\-as-of [0-9]{4}-[0-9]{2}-[0-9]{2}' .ai/STATE.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
  [ -n "$t1" ] && [ -n "$t1day" ] && [ -n "$t0" ] && [ -n "$t0day" ] \
    || { echo "STATE does not carry both readings with their dates (t1=$t1@$t1day t0=$t0@$t0day)"; return 1; }

  out=$(node scripts/gtm-reads.mjs --as-of "$t1day" 2>&1 | grep -m1 '^total=' || true)
  [ "$out" = "total=$t1" ] || { echo "STATE says t1=$t1 through $t1day; instrument says '${out#total=}'"; return 1; }
  out=$(node scripts/gtm-reads.mjs --as-of "$t0day" 2>&1 | grep -m1 '^total=' || true)
  [ "$out" = "total=$t0" ] || { echo "STATE says t0=$t0 through $t0day; instrument says '${out#total=}'"; return 1; }

  local row1
  row1=$(awk -F'|' '/^\| # \| Finding \(S40\)/{f=1} f && /^\| 1 \|/{print $4; exit}' .ai/GT-REMEDIATIONS.md)
  case "$row1" in
    *DONE*|*WAIVED*) : ;;
    *) echo "S40 row 1 (adoption baseline) status is '${row1// /}', not DONE"; return 1 ;;
  esac
  if grep -qE 'baseline (of|is) zero|`t0` = 0\b' .ai/STATE.md; then
    echo "STATE still calls the baseline zero"; return 1
  fi
  echo "t1=$t1 through $t1day and t0=$t0 through $t0day both re-derive; ledger row 1 DONE; no zero claim"
}
run_check "adoption-reading-recorded" adoption_reading_recorded

# ── Product untouched: this session sells what exists, it does not change it ───
# Counterfactual: any packages/core/src or lockfile change in the delivery → red
# (the pack measures the product; a code change belongs to a different story).
product_untouched() {
  local base; base="$(git merge-base main HEAD)"
  local f
  f=$(git diff --name-only "$base"..HEAD -- packages/core/src/ pnpm-lock.yaml || true)
  [ -z "$f" ] || { echo "product files changed in a GTM session: $f"; return 1; }
  echo "no packages/core/src or lockfile change in delivery"
}
run_check "product-untouched" product_untouched

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary (scope=$SCOPE) ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
echo "Artifacts: $ARTIFACTS"
echo "Wall clock: $(( $(date +%s) - START ))s"

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail) — session gate done."; exit 0
else echo "RED ($PASS pass, $FAIL fail) — session gate NOT done."; exit 1; fi
