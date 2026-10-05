#!/usr/bin/env bash
# S47 — make the governance gates able to fail (prompts/47-task-gate-truth.md, R1–R9).
#
# Design rules carried from S38..S46:
#   * assert FACTS, not phrases — every check re-derives its reading at run time;
#   * a check that cannot fail is a bug — each one names its counterfactual;
#   * a fix proven only by its own exit 0 FAILS — each fix states the command that
#     makes the OLD body green and the NEW body red on the same tree.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SESSION="47"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"
START=$(date +%s)

now_ms() { perl -MTime::HiRes=time -e 'printf("%d", time()*1000)'; }

# VAJRA_GATE_SCOPE must be full or fast (got ''). The closeout gate greps for this
# exact line — an absent or differently-defaulted switch would let evidence run cheap.
resolve_scope() { case "${1:-}" in ""|full) echo full ;; fast) echo fast ;; *) return 1 ;; esac; }
SCOPE="$(resolve_scope "${VAJRA_GATE_SCOPE:-}")" \
  || { echo "VAJRA_GATE_SCOPE must be full or fast (got '${VAJRA_GATE_SCOPE:-}')"; exit 2; }

gate_skips() { [ "$1" = fast ] || return 1; case " $FAST_SKIP " in *" $2 "*) return 0 ;; esac; return 1; }
# Inherited cost: the suite run and the second typecheck pass. Every check this
# session OWNS (R1–R9 evidence, the cap, the guards) runs in both scopes.
FAST_SKIP="core-suite-green product-typecheck"

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
    RESULTS+=("$(printf '%-34s %s' "$NAME" SKIP)"); write_summary; return 0
  fi
  local t0 t1 rc=0
  t0=$(now_ms)
  "$@" > "$LOG" 2>&1 || rc=$?
  t1=$(now_ms)
  printf '%s %s\n' "$NAME" "$(( (t1 - t0) / 1000 ))" >> "$ARTIFACTS/timings.txt"
  if [ "$rc" -eq 0 ]; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
  write_summary
}

# ── R0: the contract is at HEAD, numbered, capped ──
# Counterfactual: delete prompts/47-task-gate-truth.md from the index → red.
contract_at_head() {
  local f=prompts/47-task-gate-truth.md
  git cat-file -e "HEAD:$f" 2>/dev/null || { echo "$f not committed at HEAD"; return 1; }
  for r in R1 R2 R3 R4 R5 R6 R7 R8 R9; do
    grep -q "^\*\*$r" "$f" || { echo "requirement $r missing"; return 1; }
  done
  local as; as=$(grep -c '^ *- \*\*AS-' "$f" || true)
  [ "$as" -le 2 ] || { echo "$as assumptions, cap is 2"; return 1; }
  grep -q 'Out of scope' "$f" || { echo "no out-of-scope section"; return 1; }
  echo "contract at HEAD: R1–R9 present, $as assumption(s), out-of-scope named"
}
run_check "contract-at-head" contract_at_head

# ── R1: coverage sees squash merges ──
# Counterfactual, measured on this tree: merge-only newest == S37 while the union
# newest == S46 — the old body stayed green where S40 had no summary; the new body
# went red until the backfill below.
coverage_new_sees_squash() {
  local merge_newest union_newest
  merge_newest=$(git log --merges --format='%s' main 2>/dev/null \
    | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p' | sort -n | tail -1)
  union_newest=$( { git log --merges --format='%s' main 2>/dev/null \
      | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p'
    git log --format='%s' main 2>/dev/null | grep -oE 'S[0-9]{2}:' | grep -oE '[0-9]+'; } \
    | sort -n -u | tail -1)
  [ "$merge_newest" = "37" ] || { echo "merge-only newest is S$merge_newest, expected the S37 blindness"; return 1; }
  [ "$((10#$union_newest))" -ge 46 ] || { echo "union newest is S$union_newest, expected >= S46"; return 1; }
  grep -q 'squash' scripts/verify-closeout.sh || { echo "closeout has no squash-union logic"; return 1; }
  [ -s sessions/session-40-summary.md ] || { echo "S40 backfill missing — the gap this fix exists for"; return 1; }
  local missing=0 n
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    n=$((10#$n)); [ "$n" -ge 17 ] || continue
    [ -f "sessions/session-$(printf '%02d' "$n")-summary.md" ] || { echo "MISSING S$n"; missing=1; }
  done < <( { git log --merges --format='%s' main 2>/dev/null \
      | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p'
    git log --format='%s' main 2>/dev/null | grep -oE 'S[0-9]{2}:' | grep -oE '[0-9]+'; } | sort -n -u)
  [ "$missing" -eq 0 ] || return 1
  echo "merge-only newest S37 (blind) vs union newest S$union_newest; zero MISSING after S40 backfill"
}
run_check "coverage-new-sees-squash" coverage_new_sees_squash

# ── R2: no-code fails closed; offender path executes ──
# Counterfactual: the old body diffed merge-base..HEAD and read OK on an empty range;
# the new body BLOCKS there and requires the GT artifact. Exercised: a planted code
# file under synthetic GT N=50 goes red (proves the path executes, not N/A).
gt_no_code_fails_closed() {
  grep -q 'GT artifact present' scripts/verify-closeout.sh \
    || { echo "no GT-artifact requirement in closeout"; return 1; }
  grep -q 'empty range, NO-CODE unprovable' scripts/verify-closeout.sh \
    || { echo "no empty-range fail-closed clause in closeout"; return 1; }
  local out rc=0
  out=$(bash scripts/verify-closeout.sh --gt-no-code-only 47 2>&1) || rc=$?
  echo "$out" | grep -q 'N/A: session 47 is not a ground truth' \
    || { echo "N=47 should be N/A (code session), got: $out"; return 1; }
  [ "$rc" -eq 0 ] || { echo "N/A path should exit 0, got $rc"; return 1; }
  # Offender clause, exercised against a REAL committed code change: point the
  # check at the newest commit that touched packages/core/src, with a synthetic
  # NON-EMPTY GT artifact so the artifact clause is satisfied and the offender
  # clause alone can produce the red. An untracked probe is invisible to
  # `git diff base HEAD` — that was this session's first, weaker proof.
  # Counterfactual: delete the offender grep from closeout → this goes green.
  local c art rc3=0 out3
  c=$(git log --format='%H' -n1 -- packages/core/src || true)
  [ -n "$c" ] || { echo "no commit touches packages/core/src — offender clause unexerciseable"; return 1; }
  art="sessions/session-50-ground-truth.md"
  if [ -e "$art" ]; then echo "$art already exists — refusing to clobber it"; return 1; fi
  printf '# Session 50 — synthetic GT artifact (R2 offender probe)\n\nFixture: non-empty, so the artifact clause passes and the OFFENDER clause alone must fire.\n' > "$art"
  out3=$(VLT_GT_BASE="${c}^" VLT_GT_HEAD="$c" bash scripts/verify-closeout.sh --gt-no-code-only 50 2>&1) || rc3=$?
  rm -f "$art"
  [ "$rc3" -ne 0 ] || { echo "offender clause stayed green on a real committed code change — path dead"; return 1; }
  echo "$out3" | grep -q 'changed code files' \
    || { echo "red for the wrong reason (artifact/range clause, not the offender): $out3"; return 1; }
  echo "clauses present; N=47 N/A (exit 0); offender clause RED on real commit ${c:0:8} with the GT artifact satisfied"
}
run_check "gt-no-code-fails-closed" gt_no_code_fails_closed

# ── R3: cost tracking needs a measurement ──
# Counterfactual: a heading-only fixture passes the old grep and fails the new
# predicate; the live STATE.md passes the new predicate.
cost_tracking_needs_measurement() {
  grep -q 'a heading is not a measurement' scripts/verify-closeout.sh \
    || { echo "no measurement clause in closeout"; return 1; }
  local section; section="$(awk '/Cost Tracking/{f=1} f' .ai/STATE.md)"
  [ "${#section}" -ge 200 ] || { echo "live Cost Tracking too short (${#section})"; return 1; }
  for w in decision commit deriv; do
    grep -qiE "$w" <<<"$section" || { echo "live Cost Tracking lacks '$w'"; return 1; }
  done
  local d; d=$(mktemp -d)
  printf '# X\n\n## Cost Tracking\n- one honest line, no numbers.\n' > "$d/STATE.md"
  local fix; fix="$(awk '/Cost Tracking/{f=1} f' "$d/STATE.md")"
  rm -rf "$d"
  [ "${#fix}" -lt 200 ] || { echo "fixture unexpectedly long — not heading-only"; return 1; }
  echo "live section ${#section} chars with decisions+counts+derivation; heading-only fixture ${#fix} chars correctly short"
}
run_check "cost-tracking-needs-measurement" cost_tracking_needs_measurement

# ── R4: S44 REJECT disclosed ──
# Counterfactual: STATE/ROADMAP calling S44 COMPLETE with no REJECT → red.
s44_verdict_disclosed() {
  local v; v=$(grep -cE '^\*\*Verdict:\*\* REJECT' sessions/session-44-review.md || true)
  [ "$v" -eq 1 ] || { echo "S44 review canonical REJECT line missing (found $v)"; return 1; }
  grep -q 'REJECT' .ai/STATE.md || { echo "STATE.md never says REJECT"; return 1; }
  grep -q 'PR #66' .ai/STATE.md || { echo "STATE.md omits the follow-up PR #66"; return 1; }
  grep -q 'REJECT' .ai/ROADMAP.md || { echo "ROADMAP.md never says REJECT"; return 1; }
  grep -qE 'never COMPLETE|not COMPLETE' .ai/STATE.md || { echo "STATE.md lacks the never-COMPLETE guard phrase"; return 1; }
  echo "canonical REJECT ($v line) disclosed in STATE + ROADMAP with PR #66"
}
run_check "s44-verdict-disclosed" s44_verdict_disclosed

# ── R5: delivery cap derived per commit ──
# Counterfactual: a 4-file delivery commit in merge-base..HEAD → red. (The 17/60 on
# main are squash merges — disclosed history, not this delivery.)
commit_cap_respected() {
  local base; base="$(git merge-base main HEAD)"
  local c n max=0 commits=0 bad=""
  for c in $(git rev-list "$base"..HEAD); do
    commits=$((commits+1))
    n=$(git show --numstat --format='' "$c" | grep -c . || true)
    [ "$n" -gt "$max" ] && max="$n"
    [ "$n" -gt 3 ] && bad="$bad ${c:0:8}($n)"
  done
  [ "$commits" -gt 0 ] || { echo "empty delivery — nothing attested"; return 1; }
  [ -z "$bad" ] || { echo "over-cap delivery commits:$bad"; return 1; }
  echo "$commits delivery commits, max $max file(s) per commit (cap 3)"
}
run_check "commit-cap-respected" commit_cap_respected

# ── Product: precondition stated, then suite + typecheck; tree untouched ──
# Runs BEFORE R6 because R6 asserts the test count the suite PRINTS (SUITE_N) —
# the number is derived once, here, never typed into four display sites.
#
# Precondition, stated instead of assumed (S47 fix — replaces S47's byte-identity
# fallback, which could pass a gate it had not run): a clean checkout is RED with
# the exact command that fixes it. No silent downgrade, and a missing toolchain can
# never be reported as a product failure or as a green it did not earn.
# Counterfactuals: fresh clone, no install → red with `pnpm install --frozen-lockfile`;
# installed but unbuilt → red with the build command; installed+built → the suite runs.
SUITE_N=""
require_toolchain() {
  local what="$1"
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "$what unprovable: pnpm is not on PATH — install pnpm, then: pnpm install --frozen-lockfile && pnpm --filter @ifelse.codes/chitra run build"; return 1
  fi
  if [ ! -d node_modules ]; then
    echo "$what unprovable: node_modules missing — run: pnpm install --frozen-lockfile"; return 1
  fi
  if [ ! -f packages/core/dist/index.cjs ]; then
    echo "$what unprovable: packages/core/dist missing — run: pnpm --filter @ifelse.codes/chitra run build (artifacts/chitra-docs typechecks against it)"; return 1
  fi
  return 0
}
suite_green() {
  require_toolchain "453-green suite" || return 1
  local out n
  out=$(pnpm --filter @ifelse.codes/chitra run test 2>&1) \
    || { printf '%s\n' "$out" | tail -25; return 1; }
  n=$(printf '%s\n' "$out" | grep -oE 'Tests +[0-9]+ passed' | head -1 | grep -oE '[0-9]+' || true)
  [ -n "$n" ] || { echo "no 'Tests N passed' line in suite output — the count cannot be derived"; return 1; }
  SUITE_N="$n"
  printf '%s\n' "$out" | grep -E 'Test Files|Tests ' | tail -3
  echo "suite derived count: $n"
}
typecheck_green() {
  require_toolchain "typecheck" || return 1
  pnpm run typecheck
}
run_check "core-suite-green" suite_green
run_check "product-typecheck" typecheck_green

product_untouched() {
  local base; base="$(git merge-base main HEAD)"
  local f
  f=$(git diff --name-only "$base"..HEAD -- packages/core/src/ pnpm-lock.yaml || true)
  [ -z "$f" ] || { echo "product files changed: $f"; return 1; }
  echo "no packages/core/src or lockfile change in delivery"
}
run_check "product-untouched" product_untouched

# ── R6: stale facts guarded ──
# Counterfactual, each one executed (not asserted): retype a tag SHA in
# KNOWLEDGE → red; drift the pill's line citation → red; move a display count →
# red (and red against SUITE_N when the suite ran); retype main's range → red;
# retype 1b6c17d into a LIVE .ai file → red. Scope, stated: frozen sessions/,
# prompts/ and ledger quotes legitimately cite old SHAs as history, and this
# gate's own sources name the pattern only to forbid it — so the scan covers the
# six live snapshot files, not the whole tree (the S44-runtime-sample lesson).
stale_facts_guarded() {
  local hits=""
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md .ai/ROADMAP.md .ai/KNOWLEDGE.md .ai/CONTINUATION-PROMPT.md; do
    if grep -q '1b6c17d' "$f" 2>/dev/null; then hits="$hits $f"; fi
  done
  [ -z "$hits" ] || { echo "stale SHA in live files:$hits"; return 1; }
  local base; base="$(git merge-base main HEAD)"
  local td; td=$(git diff --name-only "$base"..HEAD -- packages/core/tests/ || true)
  [ -z "$td" ] || { echo "test files changed in delivery: $td"; return 1; }

  # Test count: one canonical number, carried by every display site, and equal to
  # the count the suite printed when the toolchain ran (SUITE_N). Fast scope skips
  # the suite → cross-site agreement only, stated in the line below.
  # Extraction is grep -m1 + bash parameter expansion — no `| head`, which under
  # pipefail dies of SIGPIPE the moment a file repeats the pattern. The docs hero
  # carries several stat-num pills (the first is not the test count), so its line
  # is found BY the canonical count below, not used to invent one.
  local m_readme m_know m_state n_readme n_know n_state v
  m_readme=$(grep -m1 -oE 'tests-[0-9]+' README.md || true)
  n_readme="${m_readme#tests-}"
  m_know=$(grep -m1 -oE '\*\*[0-9]+ tests\*\*' .ai/KNOWLEDGE.md || true)
  n_know="${m_know//[^0-9]/}"
  m_state=$(grep -m1 -oE '[0-9]+/[0-9]+\*\* tests' .ai/STATE.md || true)
  n_state="${m_state%%/*}"
  for v in "$n_readme" "$n_know" "$n_state"; do
    [ -n "$v" ] || { echo "a display site lost its test count (README=$n_readme KNOWLEDGE=$n_know STATE=$n_state)"; return 1; }
    [ "$v" = "$n_readme" ] || { echo "display sites disagree: README=$n_readme vs $v"; return 1; }
  done
  local count_mode="cross-site agreement (suite not run in this scope)"
  if [ -n "$SUITE_N" ]; then
    [ "$SUITE_N" = "$n_readme" ] \
      || { echo "display sites say $n_readme but the suite printed $SUITE_N"; return 1; }
    count_mode="equals the suite-derived $SUITE_N"
  fi

  # Pill line: the docs hero must carry a stat-num with that count, and the
  # citation must name the line it actually lives on.
  local pill_line; pill_line=$(grep -nEm1 "stat-num\">${n_readme}<" artifacts/chitra-docs/src/App.tsx | cut -d: -f1 || true)
  [ -n "$pill_line" ] || { echo "docs hero carries no stat-num for $n_readme tests"; return 1; }
  grep -q "L${pill_line}\*\*" .ai/KNOWLEDGE.md \
    || { echo "KNOWLEDGE's pill citation is stale: live pill is L$pill_line"; return 1; }

  # Tag SHAs: run the very command KNOWLEDGE tells the reader to run
  # (`git rev-parse <tag>` → short) and require the cited bytes to equal it.
  local t sha
  for t in v0.4.0 v0.3.0 v0.2.0 v0.1.0; do
    sha=$(git rev-parse --short=7 "$t" 2>/dev/null) || { echo "tag $t missing — release evidence gone"; return 1; }
    grep -q "\`$t\` at \`$sha\`" .ai/KNOWLEDGE.md \
      || { echo "KNOWLEDGE's $t SHA is stale: live \`$sha\` (derive: git rev-parse --short=7 $t)"; return 1; }
  done

  # Main range: the same derivation KNOWLEDGE hands the reader, executed here.
  local newest
  newest=$(git log --format='%s' main | grep -oE '(^|[^A-Za-z0-9])S[0-9]{2}:' | grep -oE 'S[0-9]{2}' | tr -d 'S' | sort -n | tail -1 || true)
  [ -n "$newest" ] || { echo "cannot derive main's newest session"; return 1; }
  grep -q "S00–S${newest}" .ai/KNOWLEDGE.md \
    || { echo "KNOWLEDGE main range stale: live newest is S$newest, file says otherwise (derive: git log --format='%s' main | grep -oE 'S[0-9]{2}:' ...)"; return 1; }

  echo "no stale SHA in live .ai files; test count $count_mode; pill L$pill_line cited; 4 tag SHAs equal git rev-parse; main range S00–S$newest"
}
run_check "stale-facts-guarded" stale_facts_guarded

# ── R7: roadmap re-pointed, crew honest ──
# Counterfactual: ROADMAP assigning open crew work to completed S44 → red.
roadmap_crew_repointed() {
  grep -q 'this is S47 work' .ai/ROADMAP.md || { echo "crew row still points at S44 alone"; return 1; }
  grep -q 'waiver-or-green recorded honestly' .ai/ROADMAP.md || { echo "no S47 done-condition on the crew row"; return 1; }
  grep -q 'Session 47' .ai/ROADMAP.md || { echo "ROADMAP never names Session 47"; return 1; }
  echo "crew row owned by S47 with a done-condition; Session 47 on the board"
}
run_check "roadmap-crew-repointed" roadmap_crew_repointed

# ── R9: cadence named where agents must read ──
# Counterfactual: BOOT/TASK/ROADMAP without N % 5 → red. AGENTS.md governed body
# untouched: the contract diff must not contain it (disclosed, not smuggled).
cadence_named() {
  for f in .ai/SESSION-BOOT.md .ai/TASK.md .ai/ROADMAP.md prompts/47-task-gate-truth.md; do
    grep -q '% 5' "$f" || { echo "$f never names the cadence"; return 1; }
  done
  grep -q 'S50' .ai/ROADMAP.md || { echo "next ground truth S50 not named"; return 1; }
  if git diff --name-only main...HEAD -- .ai/AGENTS.md | grep -q .; then
    echo "AGENTS.md touched — the vajra-owned body is off-limits"; return 1
  fi
  echo "cadence in BOOT+TASK+ROADMAP+contract; S50 named; AGENTS.md untouched"
}
run_check "cadence-named" cadence_named

# ── R8: ticket evidence ──
# Counterfactual: no ticket file, or a file without the 422 proof → red.
support_ticket_evidence() {
  local f=sessions/session-47-support-ticket.md
  [ -s "$f" ] || { echo "$f missing"; return 1; }
  grep -q '422' "$f" || { echo "no 422 proof in $f"; return 1; }
  grep -q 'DELETE' "$f" || { echo "no DELETE command in $f"; return 1; }
  grep -q 'GitHub Support' "$f" || { echo "no filing path in $f"; return 1; }
  echo "ticket text + 422 evidence + filing path in $f"
}
run_check "support-ticket-evidence" support_ticket_evidence

# ── Ledger: S45 rows 1–6 DONE ──
# Counterfactual: any of rows 1–6 still DEFERRED → red (proves the session closed
# what it claimed, via the same parser closeout uses).
ledger_dispositioned() {
  local bad=0 r
  for r in 1 2 3 4 5 6; do
    awk -F'|' -v id="$r" '
      /^## S45 / {in45=1; next}
      /^## S40 / {in45=0}
      in45 && /^\|/ {
        n=split($0, a, "|"); if (n < 5) next
        gsub(/^[ \t]+|[ \t]+$/, "", a[2]); gsub(/^[ \t]+|[ \t]+$/, "", a[4])
        if (a[2] == id && a[4] != "DONE") { print "row " id " is " a[4]; exit 1 }
      }' .ai/GT-REMEDIATIONS.md || { echo "S45 row $r not DONE"; bad=1; }
  done
  [ "$bad" -eq 0 ] || return 1
  bash scripts/verify-closeout.sh --integrity-only "$SESSION" >/dev/null 2>&1 \
    || { echo "closeout integrity gates red"; return 1; }
  echo "S45 rows 1–6 DONE; integrity gates green"
}
run_check "ledger-dispositioned" ledger_dispositioned

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
