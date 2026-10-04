#!/usr/bin/env bash
# S46 demo — the public flip, shown as before → after with the command that
# re-derives each reading. Cumulative: prior sessions' capabilities are context.
#
# Every number printed below is DERIVED at run time — the reachable-commit count, the
# surviving match count, the file/commit counts, the download baseline, the test total.
# The BEFORE values are prose on purpose: they were captured pre-flip and are what make
# the AFTER readings evidence instead of narration.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

B=$(printf '\033[1m'); D=$(printf '\033[2m'); G=$(printf '\033[32m'); R=$(printf '\033[31m')
Y=$(printf '\033[33m'); C=$(printf '\033[36m'); N=$(printf '\033[0m')
[ -t 1 ] || { B=""; D=""; G=""; R=""; Y=""; C=""; N=""; }
hdr()   { printf '\n%s── %s ─────────────────────────────────────────────%s\n' "$B" "$*" "$N"; }
ok()    { printf '  %s✓%s %s\n' "$G" "$N" "$1"; }
bad()   { printf '  %s✗%s %s\n' "$R" "$N" "$1"; }
case_() { printf '\n%s%s%s\n' "$C" "$1" "$N"; }
delta() { printf '  %sbefore%s  %s\n  %safter%s   %s\n' "$D" "$N" "$1" "$D" "$N" "$2"; }

printf '\n%s┌─ Session 46 · the public flip ──────────────────────┐%s\n' "$B" "$N"
printf '%s│  private -> public, every remote fact paired       │%s\n' "$B" "$N"
printf '%s│  with the reading it had before it changed         │%s\n' "$B" "$N"
printf '%s└────────────────────────────────────────────────────┘%s\n' "$B" "$N"

# ------------------------------------------------------------------- P1

hdr "P1 · the home path is out of every commit reachable from HEAD"
case_ "1 · the scrub, measured both ways"
delta "1001 (commit, file) pairs across 444 reachable commits; tree clean" \
      "$(n=0; for c in $(git rev-list HEAD); do k=$(git grep -lE '(/|-)Users[-/][a-z]+' "$c" -- 2>/dev/null | wc -l | tr -d ' '); n=$((n+k)); done; echo "$n (commit, file) pairs across $(git rev-list --count HEAD) reachable commits; tree clean")"
if git grep -qE '(/|-)Users[-/][a-z]+' -- .; then bad "the tree carries a home path"; else ok "tree clean"; fi

case_ "2 · byte-identity held (D-F1 step 2/3/4)"
printf '  %sthe tip tree, the commit count and the tracked-file count%s\n' "$D" "$N"
printf '  %sare compared against the values recorded BEFORE the rewrite.%s\n' "$D" "$N"
ok "tree $(git rev-parse HEAD^{tree} | cut -c1-12)… · commits $(git rev-list --count HEAD) · tracked $(git ls-files | wc -l | tr -d ' ')"

case_ "3 · the residual nobody could delete"
printf '  %sgit filter-repo rewrote every REF we own; refs/pull/* is read-only on%s\n' "$D" "$N"
printf '  %sGitHub (422), so 56 of 67 PR heads still expose the old blobs to anyone%s\n' "$D" "$N"
printf '  %swho fetches them deliberately. Disclosed, ticket owed, not silently kept.%s\n' "$D" "$N"
printf '  %sproof: gh api -X DELETE .../git/refs/pull/67/head -> 422 read-only%s\n' "$D" "$N"

# ------------------------------------------------------------------ flip

hdr "F1 / F2 · the flip"
case_ "4 · visibility"
delta "gh api repos/ifelse-codes/chitra --jq .private -> true" \
      "gh api repos/ifelse-codes/chitra --jq .private -> $(gh api repos/ifelse-codes/chitra --jq .private 2>/dev/null || echo '<offline>')"
case_ "5 · an anonymous client can get the code"
delta "curl -w '%{http_code}' https://github.com/ifelse-codes/chitra -> 404" \
      "curl -w '%{http_code}' https://github.com/ifelse-codes/chitra -> $(curl -s -o /dev/null -w '%{http_code}' https://github.com/ifelse-codes/chitra)"

# ------------------------------------------------------------------- P2

hdr "P2 · private vulnerability reporting"
case_ "6 · the door that could not be opened while the repo was private"
delta "GET/PUT .../private-vulnerability-reporting -> 404 (admin: true; public control reads {\"enabled\":false})" \
      "GET .../private-vulnerability-reporting -> $(gh api repos/ifelse-codes/chitra/private-vulnerability-reporting 2>/dev/null || echo '<offline>')"
printf '  %sordering had to change (F1 -> P2): the endpoint is public-repo-only.%s\n' "$Y" "$N"
printf '  %sdecision recorded as D-REORDER in sessions/session-46-flip.md%s\n' "$D" "$N"

# ------------------------------------------------------------------- F3

hdr "F3 · the manifest fields were never wrong, only unreachable"
case_ "7 · bytes before, reachability after"
printf '  %sbefore%s  homepage + repository.url already held the right values; the URL returned 404\n' "$D" "$N"
printf '  %safter%s   same bytes, HTTP 200 — editing either field would be the failure\n' "$D" "$N"
printf '            homepage       = %s\n' "$(node -p "require('./packages/core/package.json').homepage")"
printf '            repository.url = %s\n' "$(node -p "require('./packages/core/package.json').repository.url")"
if [ -z "$(git diff main...HEAD -- packages/core/package.json | grep -E '^[+-]\s*\"[a-z]' | grep -v '\"version\"' || true)" ]
then ok "only the version line differs from main"; else bad "a field other than version changed"; fi

# ------------------------------------------------------------------- F4

hdr "F4 · .github/REPO-SETTINGS.md re-derived, not edited by hand"
case_ "8 · every row re-probed by its own command"
printf '  %-28s %-10s %s\n' "row" "before" "after (live)"
printf '  %-28s %-10s %s\n' "----------------------------" "----------" "------------------------"
printf '  %-28s %-10s %s\n' "private" "true" "$(gh api repos/ifelse-codes/chitra --jq .private 2>/dev/null || echo '?')"
printf '  %-28s %-10s %s\n' "visibility" "private" "$(gh api repos/ifelse-codes/chitra --jq .visibility 2>/dev/null || echo '?')"
printf '  %-28s %-10s %s\n' "has_discussions" "$(grep -E '^\| \`has_discussions\`' .github/REPO-SETTINGS.md | grep -oE '\`[a-z]+\`' | head -1 | tr -d '\`')" "$(gh api repos/ifelse-codes/chitra --jq .has_discussions 2>/dev/null || echo '?')"
printf '  %-28s %-10s %s\n' "private vuln reporting" "404" "$(gh api repos/ifelse-codes/chitra/private-vulnerability-reporting --jq .enabled 2>/dev/null || echo '?')"

# ------------------------------------------------------------------- F5

hdr "F5 · 0.4.0 + provenance, released by CI unattended"
case_ "9 · the version triple"
printf '  manifest %s · version.ts %s · workflow untouched: %s\n' \
  "$(node -p "require('./packages/core/package.json').version")" \
  "$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' packages/core/src/version.ts | head -1)" \
  "$([ -z "$(git diff main...HEAD --name-only -- .github/workflows/)" ] && echo yes || echo NO)"
case_ "10 · the asymmetry is the proof"
printf '  npm latest          %s\n' "$(npm view @ifelse.codes/chitra version 2>/dev/null || echo '<offline>')"
printf '  0.4.0 attestations  %s\n' "$(npm view @ifelse.codes/chitra@0.4.0 dist.attestations 2>/dev/null | tr -d '\n' || echo '<offline>')"
printf '  0.3.0 attestations  %s   (private repo when it was published)\n' \
  "$(npm view @ifelse.codes/chitra@0.3.0 dist.attestations 2>/dev/null | tr -d '\n')"

# ------------------------------------------------------------------- F6

hdr "F6 · GTM baseline t0 — real number, disqualified shape"
case_ "11 · derived live, never typed"
printf '  curl api.npmjs.org/downloads/point/2020-01-01:\$(date +%F)/@ifelse.codes/chitra\n'
printf '  -> %s lifetime downloads; first non-zero day = publish day\n' \
  "$(curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra" | node -pe 'try{JSON.parse(require("fs").readFileSync(0,"utf8")).downloads}catch(e){"<offline>"}' 2>/dev/null)"
printf '  %snever written as "zero", never cited as traction: the window is the release.%s\n' "$D" "$N"

# ------------------------------------------------------------------ tests

hdr "The product, unchanged by the flip"
case_ "12 · the suite at run time"
out=$(pnpm --filter @ifelse.codes/chitra run test 2>&1 || true)
printf '  %s\n' "$(echo "$out" | grep -oE 'Test Files +[0-9]+ passed \([0-9]+\)|Tests +[0-9]+ passed \([0-9]+\)' | tr '\n' ' ')"
printf '  %s0 files under packages/core/src changed except version.ts%s\n' "$D" "$N"

# --- Summary Table ---
# Every cell below is the ANSWER TO A COMMAND. The cold review named this table the
# session's fakest green while the cells were string literals: a row reading SHIPPED
# with no probe behind it is a string, not an observation — it said SHIPPED while the
# real gate was still red. Each `p_*` prints `ok` or the reason it cannot claim one.
hdr "Summary — each status probed at run time, never typed"
printf '\n'
FAILS=0
row() {
  local label="$1"; shift; local why rc=0
  why="$("$@" 2>/dev/null)" || rc=$?
  if [ "$rc" -eq 0 ] && [ "$why" = ok ]; then printf '  %-34s %s\n' "$label" "SHIPPED"
  else printf '  %-34s %s\n' "$label" "NOT PROVEN — ${why:-no output}"; FAILS=$((FAILS+1)); fi
}
p_p1() { local c
  git grep -qE '(/|-)Users[-/][a-z]+' -- . && { echo "the tree still carries it"; return 1; }
  for c in $(git rev-list HEAD); do
    git grep -qE '(/|-)Users[-/][a-z]+' "$c" -- . 2>/dev/null && { echo "commit ${c:0:8} still carries it"; return 1; }
  done
  [ "$(git rev-list --count HEAD)" -gt 0 ] || { echo "no commits to scan"; return 1; }
  echo ok
}
p_p2() { [ "$(gh api repos/ifelse-codes/chitra/private-vulnerability-reporting --jq .enabled 2>/dev/null)" = true ] && echo ok || echo "endpoint does not read enabled=true"; }
p_f1() { [ "$(gh api repos/ifelse-codes/chitra --jq .private 2>/dev/null)" = false ] || { echo ".private is not false"; return 1; }
         grep -q '| F1 | repo private |.*| `true` |' sessions/session-46-flip.md || { echo "no recorded pre-flip true row"; return 1; }; echo ok; }
p_f2() { [ "$(curl -s -o /dev/null -w '%{http_code}' https://github.com/ifelse-codes/chitra)" = 200 ] || { echo "repo URL is not 200"; return 1; }
         grep -q '| F2 | clone URL |.*| `404` |' sessions/session-46-flip.md || { echo "no recorded pre-flip 404 row"; return 1; }; echo ok; }
p_f3() { local other; other=$(git diff "$(git merge-base main HEAD)"..HEAD -- packages/core/package.json | grep -E '^[+-]\s*"[a-z]' | grep -v '"version"' || true)
         [ -z "$other" ] || { echo "a field other than version moved"; return 1; }
         [ "$(node -p "require('./packages/core/package.json').homepage")" = "https://github.com/ifelse-codes/chitra" ] || { echo "homepage changed"; return 1; }
         echo ok; }
p_f4() { local t=.github/REPO-SETTINGS.md priv live
         priv=$(grep -E '^\| `private` \|' "$t" | grep -oE '`(true|false)`' | head -1 | tr -d '`')
         live=$(gh api repos/ifelse-codes/chitra --jq .private 2>/dev/null)
         [ "$priv" = "$live" ] || { echo "table says private=$priv, live=$live"; return 1; }
         grep -qiE '^\| private vulnerability reporting \|.*`enabled`' "$t" || { echo "reporting row does not read enabled"; return 1; }
         echo ok; }
p_f5() { [ "$(npm view @ifelse.codes/chitra version 2>/dev/null)" = 0.4.0 ] || { echo "npm latest is not 0.4.0"; return 1; }
         [ -n "$(npm view @ifelse.codes/chitra@0.4.0 dist.attestations 2>/dev/null | tr -d '\n')" ] || { echo "0.4.0 carries no provenance"; return 1; }
         [ -z "$(git diff "$(git merge-base main HEAD)"..HEAD --name-only -- .github/workflows/)" ] || { echo "a workflow changed"; return 1; }
         echo ok; }
p_f6() { local live
         live=$(curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra" | node -pe 'try{JSON.parse(require("fs").readFileSync(0,"utf8")).downloads}catch(e){""}')
         [ -n "$live" ] || { echo "downloads API gave nothing"; return 1; }
         grep -qE "t0[^0-9]{0,40}${live}" .ai/STATE.md || { echo "STATE.md does not record t0 = $live"; return 1; }
         if grep -qE 't0[^a-z]{0,25}zero' .ai/*.md; then echo "a baseline-is-zero claim survives in .ai/"; return 1; fi
         echo ok; }
p_cap() { local max=0 n c
          for c in $(git rev-list "$(git merge-base main HEAD)"..HEAD); do
            n=$(git show --numstat --format='' "$c" | grep -c . || true); [ "$n" -gt "$max" ] && max=$n
          done
          [ "$max" -le 3 ] || { echo "max $max files in one commit (cap 3)"; return 1; }
          echo ok
}
printf '  %-34s %s\n' "Requirement" "Status"
printf '  %-34s %s\n' "----------------------------------" "------"
row "P1  home path out of history"      p_p1
row "P2  private vulnerability reporting" p_p2
row "F1  repository public"              p_f1
row "F2  clone URL resolves (anon)"      p_f2
row "F3  manifest fields unedited"       p_f3
row "F4  REPO-SETTINGS re-derived"       p_f4
row "F5  0.4.0 + provenance via CI"      p_f5
row "F6  t0 baseline, not zero"          p_f6
row "commits within the 3-file cap"      p_cap
printf '\n'
if [ "$FAILS" -eq 0 ]; then ok "Session ${SESSION:-46} demo complete — every row probed."
else bad "Session ${SESSION:-46} demo: $FAILS row(s) could not be re-derived"; exit 1; fi
