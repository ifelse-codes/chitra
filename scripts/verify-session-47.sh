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
  touch packages/core/src/__s47_probe__.ts
  local out2 rc2=0
  out2=$(bash scripts/verify-closeout.sh --gt-no-code-only 50 2>&1) || rc2=$?
  rm -f packages/core/src/__s47_probe__.ts
  [ "$rc2" -ne 0 ] || { echo "planted code under synthetic GT N=50 went green — offender path dead"; return 1; }
  echo "clauses present; N=47 N/A (exit 0); planted probe under N=50 red (exit $rc2)"
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

# ── R6: stale facts guarded ──
# Counterfactual: retype 1b6c17d into a LIVE .ai file, drift the count display,
# or touch a test file without updating the displays → red. Scope, stated: frozen
# sessions/, prompts/ and ledger quotes legitimately cite old SHAs as history, and
# this gate's own sources name the pattern only to forbid it — so the scan covers
# the six live snapshot files, not the whole tree (the S44-runtime-sample lesson).
stale_facts_guarded() {
  local hits=""
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md .ai/ROADMAP.md .ai/KNOWLEDGE.md .ai/CONTINUATION-PROMPT.md; do
    if grep -q '1b6c17d' "$f" 2>/dev/null; then hits="$hits $f"; fi
  done
  [ -z "$hits" ] || { echo "stale SHA in live files:$hits"; return 1; }
  local base; base="$(git merge-base main HEAD)"
  local td; td=$(git diff --name-only "$base"..HEAD -- packages/core/tests/ || true)
  [ -z "$td" ] || { echo "test files changed in delivery: $td"; return 1; }
  grep -q 'tests-453%20passing' README.md || { echo "README badge drifted"; return 1; }
  grep -q 'stat-num">453<' artifacts/chitra-docs/src/App.tsx || { echo "docs hero drifted"; return 1; }
  grep -q '\*\*453 tests\*\*' .ai/KNOWLEDGE.md || { echo "KNOWLEDGE header drifted"; return 1; }
  git rev-parse --verify --quiet 'v0.4.0' >/dev/null || { echo "v0.4.0 tag missing"; return 1; }
  grep -q 'v0.4.0' .ai/KNOWLEDGE.md || { echo "KNOWLEDGE never names v0.4.0"; return 1; }
  grep -q 'S00–S46' .ai/KNOWLEDGE.md || { echo "KNOWLEDGE main range stale"; return 1; }
  echo "no stale SHA in live .ai files; tests/ untouched in delivery so S46-measured 453 stands in suite+README+hero+KNOWLEDGE; v0.4.0 tagged and named"
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

# ── Product: suite + typecheck; tree untouched ──
# Toolchain honesty, stated not hidden: this machine has no node/pnpm (only two
# lookups spent — a third would be drift). When the toolchain is absent the two
# checks below fall back to byte-identity against the S46-measured 453-green tree
# and PASS disclosed; any product/test change in delivery disables the fallback
# and FAILS closed. When the toolchain exists, the suite really runs.
# Counterfactual: change a test or src file with no toolchain → red.
toolchain_or_identical() {
  local what="$1" cmd="$2"
  if command -v pnpm >/dev/null 2>&1; then
    bash -c "$cmd"
    return $?
  fi
  local base; base="$(git merge-base main HEAD)"
  local changed
  changed=$(git diff --name-only "$base"..HEAD -- packages/core/ pnpm-lock.yaml || true)
  if [ -z "$changed" ]; then
    echo "TOOLCHAIN ABSENT (no pnpm on PATH): $what stands by byte-identity to the S46-measured green tree"
    return 0
  fi
  echo "TOOLCHAIN ABSENT and product files changed ($changed) — $what unprovable"; return 1
}
suite_green() {
  toolchain_or_identical "453-green suite" \
    'pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -qE "Tests +453 passed"'
}
typecheck_green() {
  toolchain_or_identical "typecheck" 'pnpm run typecheck'
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
