#!/usr/bin/env bash
# S46 — the public flip (prompts/46-task-public-flip.md, requirements F1–F6, gates P1–P2).
#
# Design rules carried from S38..S45:
#   * assert FACTS, not phrases — every check below re-derives its reading at run time;
#   * a check that cannot fail is a bug — each one names its counterfactual;
#   * a visibility change leaves NO trace in the tree, so every remote fact is checked
#     against the BEFORE row recorded pre-flip in sessions/session-46-flip.md. A flip
#     with no recorded `before` is narration, not evidence (the contract's own words).
#
# Sequencing, stated rather than hidden: this gate is run TWICE — once before the PR
# (structure, P1, F1–F4) and once after the release lands (F5/F6 evidence cannot exist
# before `npm publish`). The recorded run is the last one, and it must be all green.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SESSION="46"
REPO="ifelse-codes/chitra"
PKG="@ifelse.codes/chitra"

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
# Inherited cost: the suite, the drift build, and the network probes. Every check this
# session OWNS (P1, F1–F6 evidence, the cap, the gate fix) runs in both scopes.
FAST_SKIP="core-suite-and-typecheck chart-drift live-remote-facts"

PASS=0; FAIL=0; RESULTS=()
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
write_summary() {
  { for r in "${RESULTS[@]:-}"; do
      printf '%-34s %s\n' "$(echo "$r" | awk '{print $1}')" "$(echo "$r" | awk '{print $NF}')"
    done; } > "$ARTIFACTS/summary.txt"
}

# ═══════════════════════════════════════ P1 — the home path is out of history

# The rewrite's done-condition, walked rather than sampled: EVERY commit reachable from
# HEAD, plus a tree scan. Counterfactual: without the assembled true-positive below a
# vacuous pattern would pass — which is the defect class S45's audit is about.
p1_history_and_tree_clean() {
  local pat='(/|-)Users[-/][a-z]+' u='Users' c n=0
  if git grep -nE "$pat" -- .; then echo "^ the working tree still carries a home path"; return 1; fi
  if ! printf '/%s/example/rep\n' "$u" | grep -qE "$pat"; then
    echo "pattern fails a true positive — a vacuous pattern would pass this check"; return 1
  fi
  for c in $(git rev-list HEAD); do
    n=$((n+1))
    if git grep -qE "$pat" "$c" -- . 2>/dev/null; then
      echo "commit ${c:0:8} still carries the home path"; return 1
    fi
  done
  echo "0 matches across $n reachable commits (pattern proven true-positive on an assembled sample); tree clean"
}
run_check "p1-history-and-tree-clean" p1_history_and_tree_clean

# The pre-rewrite numbers must still be IN the evidence file: a scrub whose "before"
# was deleted is unfalsifiable. 1001 pairs / 444 commits / 367 tracked files.
p1_before_rows_survive() {
  local f=sessions/session-46-flip.md
  [ -s "$f" ] || { echo "$f missing"; return 1; }
  grep -q '\*\*1001\*\* (commit, file) pairs' "$f" || { echo "before-row for the pair count is gone"; return 1; }
  grep -q '444' "$f" || { echo "pre-rewrite commit count is gone"; return 1; }
  grep -q '8167462a8f21ca400f051635cd6032e233771dbe' "$f" || { echo "pre-rewrite tree SHA is gone"; return 1; }
  grep -q '367' "$f" || { echo "pre-rewrite tracked-file count is gone"; return 1; }
  echo "before-rows present: 1001 pairs, 444 commits, tree 8167462, 367 tracked files"
}
run_check "p1-before-rows-survive" p1_before_rows_survive

# Byte-identity + invariants at the REWRITE TIP — not at HEAD, which has this session's
# own commits on top of it. Steps 2–4 of D-F1's recorded order, with the expected values
# read OUT of the evidence file so a re-derivation in one place moves both.
p1_invariants_held() {
  local f=sessions/session-46-flip.md tree want tip count tcount
  tip=$(grep -oE 'post-rewrite tip[^`]*`[0-9a-f]{40}`' "$f" | grep -oE '[0-9a-f]{40}' | head -1)
  [ -n "$tip" ] || { echo "no post-rewrite tip recorded in $f"; return 1; }
  git cat-file -e "$tip^{commit}" 2>/dev/null || { echo "recorded post-rewrite tip $tip does not exist"; return 1; }
  git merge-base --is-ancestor "$tip" HEAD || { echo "$tip is not an ancestor of HEAD — HEAD is not the rewritten history"; return 1; }
  tree=$(git rev-parse "$tip^{tree}")
  want=$(grep -oE '\*\*[0-9a-f]{40}\*\*' "$f" | head -1 | tr -d '*')
  [ -n "$want" ] || { echo "no pre-rewrite tree SHA to compare against"; return 1; }
  [ "$tree" = "$want" ] || { echo "rewrite tip tree $tree != pre-rewrite $want"; return 1; }
  count=$(git rev-list --count "$tip")
  grep -q "\*\*${count}\*\*" "$f" \
    || { echo "commit count $count is not the recorded pre-rewrite count"; return 1; }
  tcount=$(git ls-tree -r "$tip" | wc -l | tr -d ' ')
  grep -q "\*\*${tcount}\*\*" "$f" \
    || { echo "tracked-file count $tcount is not the recorded pre-rewrite count"; return 1; }
  echo "rewrite tip ${tip:0:8}: tree $tree == pre-rewrite tree; commits $count; tracked files $tcount — all three match"
}
run_check "p1-invariants-held" p1_invariants_held

# S44's gate shipped a counterfactual that P1 made permanently unsatisfiable. Extract
# the fixed function and RUN it: a gate that only exists as text is not a gate.
s44_home_path_gate_green() {
  local fn="$ARTIFACTS/hps.sh"
  awk '/^home_path_scrubbed\(\) \{/,/^\}/' scripts/verify-session-44.sh > "$fn"
  grep -q 'u='"'"'Users'"'"'' "$fn" || { echo "the assembled-sample form is not the one on disk"; return 1; }
  if ! bash -c "source '$fn'; home_path_scrubbed" > "$ARTIFACTS/hps.out" 2>&1; then
    cat "$ARTIFACTS/hps.out"; return 1
  fi
  cat "$ARTIFACTS/hps.out"
}
run_check "s44-home-path-gate-green" s44_home_path_gate_green

# ═══════════════════════════════════════ F1 / F2 / P2 — the remote facts

# Live reading vs the recorded BEFORE row. Counterfactual: before the flip this same
# command returned `true` / `404` / `404` — those rows are what make this evidence.
live_remote_facts() {
  local f=sessions/session-46-flip.md priv pvr code rc=0
  priv=$(gh api "repos/$REPO" --jq .private) || return 1
  [ "$priv" = false ] || { echo "F1: .private reads $priv, not false"; rc=1; }
  grep -q '| F1 | repo private | `gh api repos/ifelse-codes/chitra --jq .private` | `true` |' "$f" \
    || { echo "F1: the pre-flip 'true' row is missing — a flip with no recorded before FAILS"; rc=1; }
  code=$(curl -s -o /dev/null -w '%{http_code}' "https://github.com/$REPO")
  [ "$code" = 200 ] || { echo "F2: repo URL reads $code, not 200"; rc=1; }
  grep -q '| F2 | clone URL | .* | `404` |' "$f" \
    || { echo "F2: the pre-flip 404 row is missing"; rc=1; }
  pvr=$(gh api "repos/$REPO/private-vulnerability-reporting" --jq .enabled 2>/dev/null || echo absent)
  [ "$pvr" = true ] || { echo "P2: private vulnerability reporting reads '$pvr', not true"; rc=1; }
  grep -q '| P2 | vuln reporting | .* | `404` |' "$f" \
    || { echo "P2: the pre-flip 404 row is missing"; rc=1; }
  [ "$rc" -eq 0 ] || return 1
  echo "F1 private=false (before: true) · F2 HTTP 200 (before: 404) · P2 enabled=true (before: 404)"
}
run_check "live-remote-facts" live_remote_facts

# An anonymous client must be able to clone — 200 on the HTML page is not a clone.
anonymous_clone() {
  local d tip
  d=$(mktemp -d)
  if ! git clone -q --depth=1 "https://github.com/$REPO.git" "$d/c" 2>/dev/null; then
    echo "anonymous clone failed"; rm -rf "$d"; return 1
  fi
  tip=$(git -C "$d/c" rev-parse HEAD)
  rm -rf "$d"
  echo "anonymous clone ok, tip $tip"
}
run_check "anonymous-clone" anonymous_clone

# ═══════════════════════════════════════ F3 — the manifest fields were NOT edited

# F3 is "the fields already resolved; only reachability was missing", so the failure
# mode is someone editing package.json to look busy. The values must equal the bytes
# recorded pre-flip AND the published npm metadata, and the diff may touch only version.
f3_manifest_fields_unedited() {
  local hp url rc=0
  hp=$(node -p "require('./packages/core/package.json').homepage")
  url=$(node -p "require('./packages/core/package.json').repository.url")
  [ "$hp" = "https://github.com/$REPO" ] || { echo "homepage is now '$hp' — edited"; rc=1; }
  [ "$url" = "https://github.com/$REPO.git" ] || { echo "repository.url is now '$url' — edited"; rc=1; }
  # Only the version line may have changed in this file.
  local changed
  changed=$(git diff main...HEAD -- packages/core/package.json | grep -E '^[+-]\s*"[a-z]' | grep -v '"version"' || true)
  [ -z "$changed" ] || { echo "a field other than version changed in package.json:$changed"; rc=1; }
  local npm_hp npm_url
  npm_hp=$(npm view "$PKG" homepage); npm_url=$(npm view "$PKG" repository.url)
  [ "$npm_hp" = "$hp" ] || { echo "npm says homepage '$npm_hp', manifest says '$hp'"; rc=1; }
  # npm normalises repository.url by prefixing git+ — strip it before comparing, or the
  # check reports an edit that never happened.
  [ "${npm_url#git+}" = "$url" ] || { echo "npm says repository.url '$npm_url', manifest says '$url'"; rc=1; }
  [ "$rc" -eq 0 ] || return 1
  echo "homepage + repository.url unchanged (manifest == published metadata); only 'version' differs from main"
}
run_check "f3-manifest-fields-unedited" f3_manifest_fields_unedited

# ═══════════════════════════════════════ F4 — the settings table matches the remote

f4_repo_settings_rows_match() {
  local t=.github/REPO-SETTINGS.md priv pvr_word live_priv live_pvr rc=0
  priv=$(grep -E '^\| `private` \|' "$t" | grep -oE '`(true|false)`' | head -1 | tr -d '`')
  pvr_word=$(grep -iE '^\| private vulnerability reporting \|' "$t" | grep -oE '`[a-z]+`' | head -1 | tr -d '`')
  case "$pvr_word" in enabled) pvr_word=true ;; disabled|unknown) pvr_word=false ;; esac
  live_priv=$(gh api "repos/$REPO" --jq .private)
  live_pvr=$(gh api "repos/$REPO/private-vulnerability-reporting" --jq .enabled 2>/dev/null || echo absent)
  [ -n "$priv" ] || { echo "no \`private\` row in $t"; rc=1; }
  [ "$priv" = "$live_priv" ] || { echo "table says private=$priv, live says $live_priv"; rc=1; }
  [ "$pvr_word" = "$live_pvr" ] || { echo "table says reporting=$pvr_word, live says $live_pvr"; rc=1; }
  grep -q 'no offline gate can read remote state' "$t" || { echo "the 'what the gate does not read' paragraph was dropped"; rc=1; }
  [ "$rc" -eq 0 ] || return 1
  echo "private=$priv, private-reporting=$pvr_word, both equal to the live readings"
}
run_check "f4-repo-settings-rows-match" f4_repo_settings_rows_match

# ═══════════════════════════════════════ F5 — 0.4.0 + provenance, by CI unattended

f5_version_triple_agrees() {
  node scripts/sync-version.mjs --check >/dev/null || { echo "src/version.ts disagrees with the manifest"; return 1; }
  local m v
  m=$(node -p "require('./packages/core/package.json').version")
  v=$(grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' packages/core/src/version.ts | head -1 | tr -d '"')
  [ -n "$v" ] || { echo "no version literal in src/version.ts"; return 1; }
  [ "$m" = "$v" ] || { echo "manifest $m != version.ts $v"; return 1; }
  [ "$m" = 0.4.0 ] || { echo "manifest says $m, expected 0.4.0"; return 1; }
  grep -q '^## \[0.4.0\]' packages/core/CHANGELOG.md || { echo "no 0.4.0 CHANGELOG section"; return 1; }
  echo "manifest == version.ts == $m; CHANGELOG has a 0.4.0 section"
}
run_check "f5-version-triple-agrees" f5_version_triple_agrees

# The asymmetry IS the proof: 0.4.0 published from a public repo carries provenance,
# 0.3.0 (private repo) does not. Counterfactual: a workflow edit would show up as a
# diff in release.yml — see the next check.
f5_provenance_asymmetry() {
  local now a40 a30
  now=$(npm view "$PKG" version)
  [ "$now" = 0.4.0 ] || { echo "npm latest is $now, expected 0.4.0 (release not out?)"; return 1; }
  a40=$(npm view "$PKG@0.4.0" dist.attestations 2>/dev/null | tr -d '\n')
  a30=$(npm view "$PKG@0.3.0" dist.attestations 2>/dev/null | tr -d '\n')
  [ -n "$a40" ] && [ "$a40" != "null" ] || { echo "0.4.0 has NO provenance: '$a40'"; return 1; }
  [ -z "$a30" ] || [ "$a30" = null ] || { echo "0.3.0 unexpectedly has attestations: '$a30' — the asymmetry proves nothing"; return 1; }
  echo "0.4.0 carries provenance; 0.3.0 does not — the asymmetry holds"
}
run_check "f5-provenance-asymmetry" f5_provenance_asymmetry

# F5 changes no workflow: npm attaches provenance automatically once the repo is public.
f5_no_workflow_edit() {
  local d
  d=$(git diff main...HEAD --name-only -- .github/workflows/)
  [ -z "$d" ] || { echo "release/CI workflow changed in this session:$d"; return 1; }
  echo "no file under .github/workflows/ changed"
}
run_check "f5-no-workflow-edit" f5_no_workflow_edit

# ═══════════════════════════════════════ F6 — the GTM baseline is t0, not zero

# The number must be DERIVED live and matched against the recorded baseline, and the
# record must say the shape disqualifies it (119 inside a 6-day window starting on the
# publish day = release-runner traffic, never organic traction).
f6_t0_baseline_recorded() {
  local live
  live=$(curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/$PKG" | node -pe 'try{JSON.parse(require("fs").readFileSync(0,"utf8")).downloads}catch(e){""}')
  [ -n "$live" ] || { echo "downloads API returned nothing"; return 1; }
  grep -qE "t0[^0-9]{0,40}${live}" .ai/STATE.md \
    || { echo "STATE.md records no t0 = ${live} — re-derive, do not type"; return 1; }
  grep -qiE 'none organic' .ai/STATE.md \
    || { echo "the baseline does not disclose that the downloads are not organic"; return 1; }
  if grep -nE 't0[^a-z]{0,25}zero' .ai/*.md; then
    echo "^ a t0 written as zero survives in .ai/ — falsified by the API itself"; return 1
  fi
  echo "t0 = $live downloads recorded in STATE.md; non-organic shape disclosed; no 'zero' claim anywhere in .ai/"
}
run_check "f6-t0-baseline-recorded" f6_t0_baseline_recorded

# ═══════════════════════════════════════ the session's own discipline

# Scope of the diff: the flip touches docs, gates and version metadata — never src.
diff_scope_is_the_flip() {
  local src other lock
  src=$(git diff main...HEAD --name-only -- packages/core/src | grep -v '^packages/core/src/version.ts$' || true)
  [ -z "$src" ] || { echo "source changed beyond version.ts:$src"; return 1; }
  lock=$(git diff main...HEAD --name-only -- pnpm-lock.yaml)
  [ -z "$lock" ] || { echo "the lockfile changed: $lock"; return 1; }
  other=$(git diff main...HEAD --name-only | grep -vE '^(sessions/|\.ai/|prompts/|scripts/|\.github/|SECURITY\.md|CODE_OF_CONDUCT\.md|packages/core/(package\.json|CHANGELOG\.md|src/version\.ts)|README\.md|CONTRIBUTING\.md|\.githooks/)' || true)
  [ -z "$other" ] || { echo "file outside the flip's scope changed:$other"; return 1; }
  echo "src untouched except version.ts; lockfile untouched; every changed file in scope"
}
run_check "diff-scope-is-the-flip" diff_scope_is_the_flip

# Derived, never typed: max files in any commit of this session (cap = 3).
commit_cap_respected() {
  local max=0 n c
  for c in $(git rev-list main..HEAD); do
    n=$(git show --numstat --format='' "$c" | grep -c . || true)
    [ "$n" -gt "$max" ] && max=$n
  done
  [ "$max" -le 3 ] || { echo "a commit carries $max files (cap 3)"; return 1; }
  echo "max files per commit: $max (cap 3), across $(git rev-list --count main..HEAD) commits"
}
run_check "commit-cap-respected" commit_cap_respected

# The product, re-observed: suite, typecheck, drift. Count derived at run time.
core_suite_and_typecheck() {
  local out n
  out=$(pnpm --filter @ifelse.codes/chitra run test 2>&1) || { echo "$out" | tail -20; return 1; }
  n=$(echo "$out" | grep -oE 'Tests +[0-9]+ passed \([0-9]+\)' | head -1)
  [ -n "$n" ] || { echo "no test summary in output"; return 1; }
  pnpm --filter @ifelse.codes/chitra run typecheck >/dev/null 2>&1 || { echo "typecheck failed"; return 1; }
  pnpm run format:check >/dev/null 2>&1 || { echo "prettier check failed"; return 1; }
  echo "$n; typecheck clean; prettier clean"
}
run_check "core-suite-and-typecheck" core_suite_and_typecheck

chart_drift() {
  pnpm --filter @workspace/chitra-docs run gen:charts:check 2>&1 | tail -5
}
run_check "chart-drift" chart_drift

# ═══════════════════════════════════════ summary

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true
ELAPSED=$(( $(date +%s) - START ))

echo ""
echo "=== Session ${SESSION} Verify Summary (scope=${SCOPE}, $((ELAPSED/60))m$((ELAPSED%60))s) ==="
printf '%-34s %s\n' "CHECK" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
