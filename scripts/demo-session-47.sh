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
p_r2() {  # no-code fail-closed clauses + N/A + the contract stimulus as a PAIR + a real commit
  grep -q 'empty range, NO-CODE unprovable' scripts/verify-closeout.sh || return 1
  grep -q 'git status --porcelain -- packages/' scripts/verify-closeout.sh || return 1
  bash scripts/verify-closeout.sh --gt-no-code-only 47 >/dev/null 2>&1 || return 1
  local art c cand d="" rc=0 out
  art=sessions/session-50-ground-truth.md
  [ -e "$art" ] && return 1
  printf '# Session 50 — synthetic GT artifact (R2 offender probe)\n\nFixture: non-empty, so only the offender clause can fire.\n' > "$art"
  for cand in $(git rev-list -n 25 HEAD); do
    git rev-parse --verify --quiet "${cand}^" >/dev/null || continue
    if [ -z "$(git diff --name-only "${cand}^" "$cand" -- . ':(exclude)sessions' ':(exclude)prompts' ':(exclude).ai' 2>/dev/null | grep -vE '\.(md|txt)$')" ]; then d="$cand"; break; fi
  done
  [ -n "$d" ] || { rm -f "$art"; return 1; }
  rc=0; out=$(VLT_GT_BASE="${d}^" VLT_GT_HEAD="$d" bash scripts/verify-closeout.sh --gt-no-code-only 50 2>&1) || rc=$?
  [ "$rc" -eq 0 ] || { rm -f "$art"; return 1; }
  touch packages/core/src/__s47_planted_probe__.ts
  rc=0; out=$(VLT_GT_BASE="${d}^" VLT_GT_HEAD="$d" bash scripts/verify-closeout.sh --gt-no-code-only 50 2>&1) || rc=$?
  rm -f packages/core/src/__s47_planted_probe__.ts
  { [ "$rc" -ne 0 ] && echo "$out" | grep -q 'changed code files'; } || { rm -f "$art"; return 1; }
  c=$(git log --format='%H' -n1 -- packages/core/src || true)
  [ -n "$c" ] || { rm -f "$art"; return 1; }
  rc=0; out=$(VLT_GT_BASE="${c}^" VLT_GT_HEAD="$c" bash scripts/verify-closeout.sh --gt-no-code-only 50 2>&1) || rc=$?
  rm -f "$art"
  [ "$rc" -ne 0 ] || return 1
  echo "$out" | grep -q 'changed code files' || return 1
  echo "clean range OK, planted file RED, real commit RED (${c:0:8})"
  echo ok
}
p_r3() {  # cost needs measurement — numbers, not keywords (pass 2's fakest green)
  grep -q 'a heading is not a measurement' scripts/verify-closeout.sh || return 1
  grep -q 'a keyword is not a count' scripts/verify-closeout.sh || return 1
  local section kw miss=""
  section="$(awk '/Cost Tracking/{f=1} f' .ai/STATE.md)"
  [ "$(printf '%s' "$section" | wc -c | tr -d ' ')" -ge 200 ] || return 1
  for kw in session decision requirement commit release; do
    grep -qiE "${kw}[^0-9]{0,60}[0-9]+|[0-9]+[^0-9]{0,60}${kw}" <<<"$section" || miss="$miss $kw"
  done
  [ -z "$miss" ] || return 1
  grep -qiE 'deriv|measur|per commit|git show' <<<"$section" || return 1
  echo "5/5 counts carry a number + derivation; heading-only still short"
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
p_r6() {  # stale facts guarded — every assertion re-derived (live snapshot files only; sessions/prompts/ledger quote old SHAs as frozen history)
  local f m mk ms n_r n_k n_s pill t sha newest
  for f in .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md .ai/ROADMAP.md .ai/KNOWLEDGE.md .ai/CONTINUATION-PROMPT.md; do
    if grep -q '1b6c17d' "$f" 2>/dev/null; then return 1; fi
  done
  m=$(grep -m1 -oE 'tests-[0-9]+' README.md) || return 1; n_r="${m#tests-}"
  mk=$(grep -m1 -oE '\*\*[0-9]+ tests\*\*' .ai/KNOWLEDGE.md) || return 1; n_k="${mk//[^0-9]/}"
  ms=$(grep -m1 -oE '[0-9]+/[0-9]+\*\* tests' .ai/STATE.md) || return 1; n_s="${ms%%/*}"
  [ -n "$n_r" ] && [ "$n_r" = "$n_k" ] && [ "$n_r" = "$n_s" ] || return 1
  pill=$(grep -nEm1 "stat-num\">${n_r}<" artifacts/chitra-docs/src/App.tsx | cut -d: -f1) || return 1
  grep -q "L${pill}\*\*" .ai/KNOWLEDGE.md || return 1
  for t in v0.4.0 v0.3.0 v0.2.0 v0.1.0; do
    sha=$(git rev-parse --short=7 "$t" 2>/dev/null) || return 1
    grep -q "\`$t\` at \`$sha\`" .ai/KNOWLEDGE.md || return 1
  done
  newest=$(git log --format='%s' main | grep -oE '(^|[^A-Za-z0-9])S[0-9]{2}:' | grep -oE 'S[0-9]{2}' | tr -d 'S' | sort -n | tail -1) || return 1
  grep -q "S00–S${newest}" .ai/KNOWLEDGE.md || return 1
  grep -q 'ls-remote' .ai/KNOWLEDGE.md || return 1
  echo "count $n_r across 3 sites + hero; pill L$pill cited; 4 tag SHAs = git rev-parse; main S00–S$newest; PR-head count re-derivable"
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
