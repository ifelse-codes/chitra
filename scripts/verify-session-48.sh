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
FAST_SKIP="core-suite-green docs-link-live adoption-reading-recorded channel-recorded"

PASS=0; FAIL=0; RESULTS=()
# Set by core-suite-green and consumed by claims-match-truth: the test count the
# suite PRINTED, never a number typed into a badge.
SUITE_N=""
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

# Every occurrence of a claim surface must equal the derived value — `grep -m1`
# and presence checks let a SECOND, disagreeing claim ride along (pass-4 E3–E7).
# Zero matches is not an error here: presence is enforced by the dedicated b_*
# checks above; this one is about contradictions.
every_equals() {
  local exp="$1" label="$2" file="$3" pat="$4" xf="${5:-}" raw v bad=""
  while IFS= read -r raw; do
    [ -n "$raw" ] || continue
    if [ -n "$xf" ]; then v=$(printf '%s' "$raw" | sed -E "$xf"); else v=$(printf '%s' "$raw" | grep -oE '[0-9]+' | sed -n '1p'); fi
    [ "$v" = "$exp" ] || bad="$bad '$v'"
  done < <(grep -oE "$pat" "$file" 2>/dev/null || true)
  [ -z "$bad" ] || { echo "$label disagreeing value(s):$bad (expected $exp)"; return 1; }
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
  local claimed out n
  claimed=$(grep -m1 -oE 'tests-[0-9]+%20passing' README.md | sed -E 's/tests-([0-9]+).*/\1/')
  [ -n "$claimed" ] || { echo "README carries no tests badge to check"; return 1; }
  out=$(pnpm --filter @ifelse.codes/chitra run test 2>&1) \
    || { printf '%s\n' "$out" | tail -25; return 1; }
  printf '%s\n' "$out" | grep -E 'Test Files|Tests ' | tail -3
  n=$(printf '%s\n' "$out" | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+' | sed -n '1p' || true)
  [ -n "$n" ] || { echo "the suite printed no 'Tests N passed' line"; return 1; }
  SUITE_N="$n"
  # Pass-4 E4: every tests badge must equal what the suite printed — a second,
  # false badge is not covered by the first one.
  local v bad=""
  while IFS= read -r v; do
    [ -n "$v" ] || continue
    [ "$v" = "$SUITE_N" ] || bad="$bad '$v'"
  done < <(grep -oE 'tests-[0-9]+%20passing' README.md | sed -E 's/tests-([0-9]+).*/\1/' || true)
  [ -z "$bad" ] || { echo "tests badge disagreeing with the suite:$bad (suite printed $SUITE_N)"; return 1; }
  echo "README tests badge(s) == suite output $SUITE_N"
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

  # Anchored, not substring: pass 2 showed `charts-20` matches inside `charts-200`
  # and `3 renderers` inside `13 renderers`, so a badge could claim 200 charts while
  # the gate reported "all carry the derived values". Each badge and table cell is
  # now EXTRACTED and compared as a value.
  local b_charts b_charts_url b_types b_renderers b_deps b_license bad=""
  b_charts=$(grep -m1 -oE '!\[charts: [0-9]+\]' README.md | sed -E 's/[^0-9]*([0-9]+).*/\1/' || true)
  b_charts_url=$(grep -m1 -oE 'badge/charts-[0-9]+' README.md | sed -E 's#.*charts-##' || true)
  b_types=$(grep -m1 -oE '\| \*\*[0-9]+ chart types\*\* \|' README.md | grep -oE '[0-9]+' || true)
  b_renderers=$(grep -m1 -oE '\| \*\*[0-9]+ renderers\*\* \|' README.md | grep -oE '[0-9]+' || true)
  b_deps=$(grep -m1 -oE '!\[dependencies: [0-9]+\]' README.md | sed -E 's/[^0-9]*([0-9]+).*/\1/' || true)
  b_license=$(grep -m1 -oE '!\[license: [^]]+\]' README.md | sed -E 's/^!\[license: //; s/\]$//' || true)
  [ "$b_charts" = "$charts" ]         || bad="$bad README-badge-alt('${b_charts}'≠${charts})"
  [ "$b_charts_url" = "$charts" ]     || bad="$bad README-badge-url('${b_charts_url}'≠${charts})"
  [ "$b_types" = "$charts" ]          || bad="$bad README-chart-types('${b_types}'≠${charts})"
  [ "$b_renderers" = "$renderers" ]   || bad="$bad README-renderers('${b_renderers}'≠${renderers})"
  [ "$b_deps" = "$deps" ]             || bad="$bad README-deps('${b_deps}'≠${deps})"
  [ "$b_license" = "$license" ]       || bad="$bad README-license('${b_license}'≠${license})"
  # Pass-3 N1/N2: the deps badge's SHIELD URL and README's dependency cell were
  # never extracted (charts had both, deps had neither) — P1g's stimulus, red for
  # two passes, went green in d26a418. Now both are compared as values.
  local b_deps_url deps_cell
  b_deps_url=$(grep -m1 -oE 'badge/dependencies-[0-9]+' README.md | sed -E 's#.*dependencies-##' || true)
  [ "$b_deps_url" = "$deps" ] || bad="$bad README-deps-url('${b_deps_url}'≠${deps})"
  if [ "$deps" -eq 0 ]; then deps_cell="| **Zero dependencies** |"; else deps_cell="| **${deps} dependencies** |"; fi
  grep -qF "$deps_cell" README.md || bad="$bad README-deps-cell(expected '$deps_cell')"
  # Pass-3 N5: `grep -m1` made a second, false badge invisible. EVERY badge must
  # agree with the derived value — one extraction per occurrence, all compared.
  local mismatch
  mismatch=$(grep -oE '!\[charts: [0-9]+\]' README.md | sed -E 's/[^0-9]*([0-9]+).*/\1/' \
             | grep -cv "^${charts}$" || true)
  [ "$mismatch" = "0" ] || bad="$bad README-charts-badge-x${mismatch} disagreeing badge(s)"
  mismatch=$(grep -oE '!\[dependencies: [0-9]+\]' README.md | sed -E 's/[^0-9]*([0-9]+).*/\1/' \
             | grep -cv "^${deps}$" || true)
  [ "$mismatch" = "0" ] || bad="$bad README-deps-badge-x${mismatch} disagreeing badge(s)"
  # Pass-3 N3/N4: R1 names packages/core/README.md's LICENSE and dependency count;
  # only its chart line was checked. Both are extracted from that file.
  local core_lic core_deps
  core_lic=$(awk '/^## License/{f=1;next} f && NF{gsub(/^[ \t]+|[ \t]+$/,""); print; exit}' packages/core/README.md || true)
  [ "$core_lic" = "$license" ] || bad="$bad coreREADME-license('$core_lic'≠$license)"
  if [ "$deps" -eq 0 ]; then core_deps="**Zero Dependencies:**"; else core_deps="**${deps} Dependencies:**"; fi
  grep -qF "$core_deps" packages/core/README.md || bad="$bad coreREADME-deps(expected '$core_deps')"
  grep -qF "all ${charts} charts" README.md        || bad="$bad README-prose"
  grep -qF "all ${charts} charts" .ai/KNOWLEDGE.md || bad="$bad KNOWLEDGE-charts"
  [ -z "$bad" ] || { echo "claim ≠ truth in:$bad (derived values above)"; return 1; }

  # Pass-4 E3/E4/E5/E7: presence checks and `grep -m1` cannot see a SECOND,
  # disagreeing claim. Every occurrence of every count surface is compared.
  local dups=""
  every_equals "$charts"    "README shield URL"        README.md              'badge/charts-[0-9]+'                '' || dups="$dups README-shield-charts"
  every_equals "$deps"      "README deps shield URL"   README.md              'badge/dependencies-[0-9]+'          '' || dups="$dups README-shield-deps"
  every_equals "$SUITE_N"   "README tests badge(s)"    README.md              'tests-[0-9]+%20passing' 's/tests-([0-9]+).*/\1/' || dups="$dups README-tests-badges"
  every_equals "$charts"    "README prose count"       README.md              'all [0-9]+ charts'                  '' || dups="$dups README-prose-count"
  every_equals "$charts"    "KNOWLEDGE prose count"    .ai/KNOWLEDGE.md       'all [0-9]+ charts'                  '' || dups="$dups KNOWLEDGE-prose-count"
  every_equals "$charts"    "core README chart count"  packages/core/README.md '\*\*[0-9]+ Chart Types:\*\*'      '' || dups="$dups coreREADME-chart-types"
  every_equals "$charts"    "README chart-types cell"  README.md              '\| \*\*[0-9]+ chart types\*\* \|'  '' || dups="$dups README-types-cell"
  every_equals "$renderers" "README renderers cell"    README.md              '\| \*\*[0-9]+ renderers\*\* \|'    '' || dups="$dups README-renderers-cell"
  every_equals "$deps"      "README deps cell"         README.md              '\| \*\*[0-9]+ dependencies\*\* \|' '' || dups="$dups README-deps-cell"
  every_equals "$deps"      "core README deps count"   packages/core/README.md '\*\*[0-9]+ Dependencies:\*\*'     '' || dups="$dups coreREADME-deps"
  [ -z "$dups" ] || { echo "contradicting claim(s):$dups"; return 1; }

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
${SUITE_N} Tests passing
${deps} Dependencies"
  if [ "$hero" != "$want" ]; then
    echo "docs hero drifted from the derived values:"
    diff <(printf '%s\n' "$want") <(printf '%s\n' "$hero") || true
    return 1
  fi
  # Pass-1 found two claim surfaces R1 names that nothing checked: the core README
  # (a `20 Chart Types` line) and the license badge's RENDERED value — retyping the
  # alt text alone leaves a stranger reading Apache on an MIT package. The version
  # claim needs a target too: the manifest's version must head the changelog.
  grep -qF "**${charts} Chart Types:**" packages/core/README.md \
    || { echo "packages/core/README.md chart claim ≠ derived ${charts}"; return 1; }
  grep -qF "badge/license-${license}-" README.md \
    || { echo "README's rendered license badge is not ${license} (the alt text can lie)"; return 1; }
  grep -qF "## [${version}]" packages/core/CHANGELOG.md \
    || { echo "CHANGELOG has no heading for the manifest version ${version}"; return 1; }
  echo "README (badges, prose, rendered license URL), packages/core/README.md, docs hero, KNOWLEDGE and CHANGELOG all carry the derived values"
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

# ── R3: benchmarks are measured, not claimed ──────────────────────────────────
# Every figure in the README's benchmark table must equal what gtm-bench.mjs
# prints RIGHT NOW, with the command visible beside them. Timing is compared as a
# budget (the script exits 1 when it is blown) because a millisecond fossilised in
# a README would be false on the next machine — that is why the row cites the
# ceiling and tells the reader to run the script for their own median.
# Counterfactual: change 81.5 KB to 40 KB, drop a row, or delete the command → red.
benchmarks_cited_with_command() {
  command -v node >/dev/null 2>&1 || { echo "node is not on PATH"; return 1; }
  [ -s scripts/gtm-bench.mjs ] || { echo "instrument scripts/gtm-bench.mjs missing"; return 1; }
  local json deps tkb ukb files budget
  json=$(node scripts/gtm-bench.mjs --json 2>&1) || { echo "bench failed: $json"; return 1; }
  read -r deps tkb ukb files budget <<<"$(printf '%s' "$json" | node -e '
    let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
      const j=JSON.parse(s);
      console.log(j.deps, j["tarball-kb"], j["unpacked-kb"], j["pack-files"], j["render-budget-ms"]);
    })')"
  [ -n "$deps" ] && [ -n "$tkb" ] && [ -n "$ukb" ] && [ -n "$files" ] && [ -n "$budget" ] \
    || { echo "could not parse the bench output"; return 1; }

  grep -qF 'node scripts/gtm-bench.mjs' README.md \
    || { echo "README does not show the command that produces these numbers"; return 1; }
  grep -qF "| **Runtime dependencies** | **${deps}** |" README.md \
    || { echo "README deps row ≠ measured ${deps}"; return 1; }
  grep -qF "| **\`npm install\` download** | **${tkb} KB** gzip tarball |" README.md \
    || { echo "README tarball row ≠ measured ${tkb} KB"; return 1; }
  grep -qF "| **Installed footprint** | **${ukb} KB** unpacked, ${files} files |" README.md \
    || { echo "README footprint row ≠ measured ${ukb} KB / ${files} files"; return 1; }
  grep -qF "| **Render a 100-point line chart** | **≤ ${budget} ms**" README.md \
    || { echo "README render row ≠ the ${budget} ms budget the script declares"; return 1; }

  # Pass-3 N11: the contract's counterfactual is "a benchmark number with no
  # command → red", so EVERY value in the Benchmarks table must be one the script
  # prints — not only the four rows this check happens to know about.
  local allowed vals v table_bad=""
  allowed=("${deps}" "${tkb} KB" "${ukb} KB" "${files}" "≤ ${budget} ms")
  vals=$(awk '/^## Benchmarks/{f=1;next} f && /^## /{f=0}
             f && /^\| \*\*/{n=split($0,a,"|"); if(n>=4){c=a[3];
               if(match(c,/\*\*[^*]+\*\*/)) print substr(c,RSTART+2,RLENGTH-4)}}' README.md)
  [ -n "$vals" ] || { echo "the Benchmarks table has no value cells to check"; return 1; }
  while IFS= read -r v; do
    [ -n "$v" ] || continue
    case " ${allowed[*]} " in *" $v "*) : ;; *) table_bad="$table_bad '$v'" ;; esac
  done <<< "$vals"
  [ -z "$table_bad" ] || { echo "Benchmarks table carries value(s) no command prints:$table_bad"; return 1; }

  # Pass-4 E18: values are checked but rows are not bound — `| **Cold start** |
  # **0** |` uses a printed value for a claim no command produces. The table's
  # ROWS must be exactly the rows gtm-bench.mjs declares, in that order.
  local script_rows readme_rows
  script_rows=$(printf '%s' "$json" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>process.stdout.write(JSON.parse(s).rows||""))')
  readme_rows=$(awk '/^## Benchmarks/{f=1;next} f && /^## /{f=0} f && /^\| \*\*/{n=split($0,a,"|"); if(n>=4){c=a[2]; gsub(/[*`]/,"",c); gsub(/^[ \t]+|[ \t]+$/,"",c); if(c!="") print c}}' README.md | paste -sd'|' -)
  [ -n "$script_rows" ] || { echo "gtm-bench.mjs declares no rows"; return 1; }
  if [ "$readme_rows" != "$script_rows" ]; then
    echo "Benchmarks rows ≠ the rows the script declares:"
    echo "  script: $script_rows"
    echo "  README: ${readme_rows:-<none>}"
    return 1
  fi

  # The script's own verdict: if the live render is over budget it exits 1, and
  # that already failed above — say so rather than leaving the reason implicit.
  node scripts/gtm-bench.mjs >/dev/null 2>&1 \
    || { echo "live render is over the ${budget} ms budget the README advertises"; return 1; }
  echo "README cites deps=${deps}, ${tkb} KB, ${ukb} KB / ${files} files, ≤${budget} ms — all printed by gtm-bench.mjs, command shown"
}
run_check "benchmarks-cited-with-command" benchmarks_cited_with_command

# ── R6: the record says what happened, not what we hope ───────────────────────
# The roadmap must point at the instruments that delivered its pack, and every
# downloads figure in the LIVE record must be one the instrument prints (119 = t0,
# 273 = t1) — across all seven files a reader trusts, not just STATE + ROADMAP
# (pass-1 planted `999 downloads` in KNOWLEDGE and it stayed green). Quoted
# stimuli are exempt: a counterfactual table showing `500 downloads` in backticks
# is evidence, an unquoted sentence is a claim (pass-1's P14). And the "baseline
# is zero" phrase may stand only beside a superseding marker — it has been false
# since S45 (t0 = 119).
# Counterfactuals: 500 downloads into KNOWLEDGE or the summary; a bare
# "adoption baseline is zero"; the evidence pointer removed → red.
record_honest() {
  grep -q 'GTM proof pack' .ai/ROADMAP.md || { echo "roadmap no longer names the pack"; return 1; }
  grep -A3 'GTM proof pack' .ai/ROADMAP.md | grep -qE 'gtm-reads|gtm-bench|session-48-summary' \
    || { echo "roadmap's pack row has no evidence pointer"; return 1; }
  local files=(.ai/STATE.md .ai/ROADMAP.md .ai/KNOWLEDGE.md .ai/TASK.md
               .ai/SESSION-BOOT.md .ai/CONTINUATION-PROMPT.md .ai/GT-REMEDIATIONS.md
               sessions/session-48-summary.md)
  local f line hits h n bad=""
  for f in "${files[@]}"; do
    # Fail CLOSED on a missing file: pass 2 deleted CONTINUATION-PROMPT and the
    # check printed an OK line about a file it never read.
    [ -f "$f" ] || { echo "live file missing: $f"; return 1; }
    # Quoted figures are exempt ONLY on a table row that also carries a
    # counterfactual marker — a counterfactual table shows its own stimulus as
    # evidence (pass-3 N8 planted one in an unrelated table row).
    hits=$(grep -hiE 'downloads|installs|stars|signups' "$f" 2>/dev/null \
           | awk '/^\|/ && /(counterfactual|stimulus|→|red|FAIL|instrument prints|probe)/{gsub(/`[^`]*`/,"")} {print}' \
           | grep -oE '[0-9][0-9,.]*[kKmM]?([[:space:]][a-z]+){0,3}[[:space:]]downloads|[0-9][0-9,.]*[kKmM]?([[:space:]][a-z]+){0,3}[[:space:]]installs|[0-9][0-9,.]*[kKmM]?([[:space:]][a-z]+){0,3}[[:space:]]stars|downloads[^/0-9]{0,15}[0-9][0-9,.]*[kKmM]?' || true)
    while IFS= read -r h; do
      [ -n "$h" ] || continue
      case "$h" in */*) continue ;; esac      # a path (downloads/range/2026-…) is not a figure
      # Normalise: strip separators, expand k/M suffixes (pass-4 E10: `0.8k
      # downloads` must read 800, not slip through because it has a dot).
      n=$(printf '%s' "$h" | grep -oE '[0-9][0-9,.]*[kKmM]?' | sed -n '1p' \
          | awk '{ v=$0; gsub(/,/,"",v);
                  if (v ~ /[kKmM]$/) { s=substr(v,length(v),1); v=substr(v,1,length(v)-1)+0;
                    if (s=="k"||s=="K") v*=1000; else v*=1000000 }
                  printf "%d", v }')
      [ -n "$n" ] || continue
      if [ "$f" = ".ai/GT-REMEDIATIONS.md" ]; then
        # The ledger quotes its own audit history: a finite, explicit set of
        # figures it has evidence for. Anything else is a fresh claim — pass-4 N7
        # planted `⚠ 888 downloads` and the marker used to make it a free pass.
        # 0 is always allowed: a zero can never be inflated traction.
        case "$n" in 0|89|119|181|273|304|318) : ;; *) bad="$bad $f:'$h'" ;; esac
      else
        case "$n" in 0|119|273) : ;; *) bad="$bad $f:'$h'" ;; esac
      fi
    done <<< "$hits"
    # Traction language with no instrument behind it (pass-3 N9): claiming success
    # needs a derived number beside it. Negated/conditional lines pass, assertions
    # do not. Scoped to the summary — R6's counterfactual names that file.
    if [ "$f" = "sessions/session-48-summary.md" ]; then
      while IFS= read -r line; do
        [ -n "$line" ] || continue
        # Pass-4 E15/E16: a finite keyword list plus a one-word negation escape let
        # `Milestone reached: our first user…` and `The channel is working, no ads`
        # through. The exemption is now an explicit list of this record's OWN guard
        # sentences — not any line containing `no`.
        case "$line" in
          *'none organic'*|*'no organic'*|*'never cite'*|*'never as traction'*|*'no traction'*|*'not traction'*|*'flat zero'*|*'stays at zero'*|*'not the product'*|*'if the days'*|*'no signal'*|*'no users'*) : ;;
          *) bad="$bad $f:(traction claim with no derived number: ${line:0:60})" ;;
        esac
      done < <(grep -iE 'taking off|is working|worked|grew|growth|surging|exploding|popular|demand|milestone|first user|traction|organic|signups' "$f" 2>/dev/null || true)
    fi
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      case "$line" in
        *superseded*|*false*|*"not zero"*|*must\ not*|*FALSIFIED*|*⚠*) : ;;
        *) bad="$bad $f:(zero-claim with no superseding marker)" ;;
      esac
    done < <(awk '
      function flush() { if (buf != "") { print buf; buf = "" } }
      /baseline (of|is) zero/ { flush(); buf = $0; pending = 2; next }
      pending > 0 { buf = buf " " $0; pending--; if (pending == 0) flush(); next }
      END { flush() }' "$f" 2>/dev/null || true)
  done
  [ -z "$bad" ] || { echo "figure or claim no instrument prints:$bad"; return 1; }
  grep -qi 'never cite' .ai/STATE.md || { echo "STATE lost the 'never cite as traction' guard"; return 1; }
  echo "roadmap points at its instruments; all 8 live files carry only 119/273 (table-quoted stimuli stripped; ledger history needs its evidence marker); zero-claims marked superseded; traction guard present"
}
run_check "record-honest" record_honest

# ── R4: one channel, one link, attributable ───────────────────────────────────
# The post must be recorded in STATE with its date, it must actually answer 200
# (LinkedIn returns 404 for a deleted post; a bot-wall is not a 404), and the
# record must point at the reader so the days after it can be read against the
# days before.
# Counterfactual: delete the URL, the date, or the reader pointer → red.
channel_recorded() {
  local url
  url=$(grep -m1 -oE 'https://www\.linkedin\.com/posts/[A-Za-z0-9_/-]+' .ai/STATE.md || true)
  [ -n "$url" ] || { echo "STATE records no post URL"; return 1; }
  grep -q 'published 2026-10-06' .ai/STATE.md || { echo "STATE records no publish date for the post"; return 1; }
  grep -A7 -i 'one channel is live' .ai/STATE.md | grep -q 'gtm-reads' \
    || { echo "the post record does not point at the reader that measures it"; return 1; }
  local code
  code=$(curl -s -o /dev/null -m 20 -L \
           -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36' \
           -w '%{http_code}' "$url" || echo 000)
  [ "$code" = "200" ] || { echo "$url → $code (expected 200)"; return 1; }
  echo "$url → 200; published 2026-10-06; window read with gtm-reads"
}
run_check "channel-recorded" channel_recorded

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
