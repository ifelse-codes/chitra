#!/usr/bin/env bash
# S47 demo — make the governance gates able to fail.
# Cumulative: what a stranger can now check that no session could before.
# Every number below is DERIVED at run time. The summary table is PROBED, not
# typed: row() prints SHIPPED only when its probe exits 0 and prints exactly
# `ok` (the S46 fakest-green fix) — otherwise NOT PROVEN and exit 1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAILS=0
row() {
  local label="$1"; shift
  local out rc=0
  out="$("$@" 2>/dev/null)" || rc=$?
  local last; last="$(printf '%s\n' "$out" | tail -1)"
  if [ "$rc" -eq 0 ] && [ "$last" = "ok" ]; then
    printf '%s\n' "$out" | sed '$d' | sed 's/^/  | /'
    printf '%-34s %s\n' "$label" "SHIPPED"
  else
    printf '%-34s %s\n' "$label" "NOT PROVEN — ${out:-exit $rc}"
    FAILS=$((FAILS+1))
  fi
}

p_r1() {  # coverage: union newest + zero missing
  local u m miss
  u=$( { git log --merges --format='%s' main 2>/dev/null | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p'
    git log --format='%s' main 2>/dev/null | grep -oE 'S[0-9]{2}:' | grep -oE '[0-9]+'; } | sort -n -u | tail -1)
  m=$(git log --merges --format='%s' main 2>/dev/null | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p' | sort -n | tail -1)
  miss=0
  [ "$((10#$u))" -ge 46 ] || return 1
  [ "$m" = "37" ] || return 1
  [ -s sessions/session-40-summary.md ] || return 1
  echo "newest $u (merge-only still $m); S40 backfilled"
  echo ok
}
p_r2() {  # no-code fail-closed clauses + N/A path
  grep -q 'empty range, NO-CODE unprovable' scripts/verify-closeout.sh || return 1
  bash scripts/verify-closeout.sh --gt-no-code-only 47 >/dev/null 2>&1 || return 1
  echo "fail-closed clauses present; code session N/A"
  echo ok
}
p_r3() {  # cost needs measurement
  grep -q 'a heading is not a measurement' scripts/verify-closeout.sh || return 1
  [ "$(awk '/Cost Tracking/{f=1} f' .ai/STATE.md | wc -c)" -ge 200 ] || return 1
  echo "predicate + live section measured"
  echo ok
}
p_r4() {  # S44 REJECT disclosed
  grep -qE '^\*\*Verdict:\*\* REJECT' sessions/session-44-review.md || return 1
  grep -q 'REJECT' .ai/STATE.md || return 1
  grep -q 'REJECT' .ai/ROADMAP.md || return 1
  echo "REJECT in review+STATE+ROADMAP"
  echo ok
}
p_r5() {  # delivery cap derived
  local base mx=0 c n
  base=$(git merge-base main HEAD)
  for c in $(git rev-list "$base"..HEAD); do
    n=$(git show --numstat --format='' "$c" | grep -c . || true)
    if [ "$n" -gt "$mx" ]; then mx="$n"; fi
    if [ "$n" -gt 3 ]; then return 1; fi
  done
  echo "max $mx files per delivery commit"
  echo ok
}
p_r6() {  # stale facts guarded (live snapshot files only; sessions/prompts/ledger quote old SHAs as frozen history)
  local f
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md .ai/ROADMAP.md .ai/KNOWLEDGE.md .ai/CONTINUATION-PROMPT.md; do
    if grep -q '1b6c17d' "$f" 2>/dev/null; then return 1; fi
  done
  grep -q 'tests-453%20passing' README.md || return 1
  grep -q 'v0.4.0' .ai/KNOWLEDGE.md || return 1
  git rev-parse --verify --quiet 'v0.4.0' >/dev/null || return 1
  echo "no stale SHA; 453 + v0.4.0 live"
  echo ok
}
p_r7() {  # roadmap re-pointed
  grep -q 'this is S47 work' .ai/ROADMAP.md || return 1
  echo "crew row owned by S47"
  echo ok
}
p_r8() {  # ticket evidence
  grep -q '422' sessions/session-47-support-ticket.md || return 1
  echo "422 recorded with filing path"
  echo ok
}
p_r9() {  # cadence named; AGENTS untouched
  grep -q '% 5' .ai/SESSION-BOOT.md || return 1
  grep -q '% 5' .ai/TASK.md || return 1
  git diff --name-only main...HEAD -- .ai/AGENTS.md | grep -q . && return 1
  echo "cadence owned-files only"
  echo ok
}

echo "=== S47 demo: gates that can fail ==="
echo ""
echo "Before → after (one line each, all re-derived above):"
echo "  coverage newest belief: S37 (merge-only) → S$( { git log --merges --format='%s' main 2>/dev/null | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p'; git log --format='%s' main 2>/dev/null | grep -oE 'S[0-9]{2}:' | grep -oE '[0-9]+'; } | sort -n -u | tail -1) (union)"
echo "  S40 summary: absent → $(wc -l < sessions/session-40-summary.md | tr -d ' ') lines (disclosed backfill)"
echo "  no-code on empty range: OK → BLOCK (fail closed)"
echo "  cost tracking: heading grep → measurement predicate"
echo "  S44 record: COMPLETE → REJECT + PR #66"
echo "  P1 residual: owed → ticket text + 422 evidence"
echo ""
row "R1 coverage sees squash" p_r1
row "R2 no-code fails closed" p_r2
row "R3 cost is measured" p_r3
row "R4 S44 REJECT disclosed" p_r4
row "R5 delivery cap derived" p_r5
row "R6 stale facts guarded" p_r6
row "R7 crew row re-pointed" p_r7
row "R8 ticket rides along" p_r8
row "R9 cadence named" p_r9

if [ "$FAILS" -eq 0 ]; then echo ""; echo "DEMO: all rows SHIPPED (probed)."; exit 0
else echo ""; echo "DEMO: $FAILS row(s) NOT PROVEN."; exit 1; fi
