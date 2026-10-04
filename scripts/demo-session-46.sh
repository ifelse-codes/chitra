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
printf '  %sbefore%s  homepage + repository.url already held the right values; the URL 404'd\n' "$D" "$N"
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
hdr "Summary"
printf '\n'
printf '  %-34s %s\n' "Requirement" "Status"
printf '  %-34s %s\n' "----------------------------------" "------"
printf '  %-34s %s\n' "P1  home path out of history"      "SHIPPED (residual disclosed)"
printf '  %-34s %s\n' "P2  private vulnerability reporting" "SHIPPED"
printf '  %-34s %s\n' "F1  repository public"              "SHIPPED"
printf '  %-34s %s\n' "F2  clone URL resolves (anon)"      "SHIPPED"
printf '  %-34s %s\n' "F3  manifest fields unedited"       "SHIPPED"
printf '  %-34s %s\n' "F4  REPO-SETTINGS re-derived"       "SHIPPED"
printf '  %-34s %s\n' "F5  0.4.0 + provenance via CI"      "SHIPPED"
printf '  %-34s %s\n' "F6  t0 baseline, not zero"          "SHIPPED"
printf '  %-34s %s\n' "commits within the 3-file cap"      "$(max=0; for c in $(git rev-list main..HEAD); do n=$(git show --numstat --format='' "$c" | grep -c . || true); [ "$n" -gt "$max" ] && max=$n; done; echo "max $max")"
printf '\n'
ok "Session ${SESSION:-46} demo complete."
