#!/usr/bin/env bash
# S44 demo — OSS polish + the founder decisions, answered.
# Cumulative: numbers already true (the suite, 20 charts, 0 deps) are context,
# not claims of new work.
#
# Every LOAD-BEARING number below is DERIVED at run time — the suite count, the
# file counts, the override count, the scrub count, and every per-requirement
# STATE. The prose's before/after figures are context, typed on purpose. The
# suite count is ABSENT from this file: verify-session-44.sh#test-count-propagated
# asserts its absence, and demo-displays-count-at-runtime reads it out of this
# script's own output (a demo that types the count is the rot S41 started killing).
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

printf '\n%s┌─ Session 44 · cleanup Batch 4 ───────────────────────┐%s\n' "$B" "$N"
printf '%s│  the things an OSS repo is expected to have — and     │%s\n' "$B" "$N"
printf '%s│  the six decisions four sessions left unanswered      │%s\n' "$B" "$N"
printf '%s└────────────────────────────────────────────────────────┘%s\n' "$B" "$N"

# ---------------------------------------------------------------- what shipped

hdr "The OSS surface"

case_ "1 · security policy, with a contact that exists"
printf '  %sbefore%s  no SECURITY.md: no supported-versions table, no disclosure\n' "$D" "$N"
printf '        %sroute, no statement of what is and is not promised.%s\n' "$D" "$N"
printf '        %sNow: private reporting through the Security tab, an explicit%s\n' "$D" "$N"
printf '        %sno-SLA / no-bounty / latest-version-only policy, and a scope%s\n' "$D" "$N"
printf '        %sthat names the release pipeline as in-scope.%s\n' "$D" "$N"
if [ -s SECURITY.md ]; then ok "SECURITY.md present and non-empty"; else bad "SECURITY.md missing"; fi
if grep -q "## Reporting a vulnerability" SECURITY.md; then ok "disclosure route documented"; else bad "no disclosure section"; fi

case_ "2 · a code of conduct nobody can hide behind"
printf '  %sContributor Covenant 2.1, plus the four-step enforcement ladder.%s\n' "$D" "$N"
printf '        %sThe project publishes no mailbox, so the file says so and routes%s\n' "$D" "$N"
printf '        %sprivate reports through the one private channel that DOES reach%s\n' "$D" "$N"
printf '        %sthe maintainers. A conduct@ nobody reads is worse than none.%s\n' "$D" "$N"
if [ -s CODE_OF_CONDUCT.md ]; then ok "CODE_OF_CONDUCT.md present"; else bad "CODE_OF_CONDUCT.md missing"; fi
if grep -qE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' CODE_OF_CONDUCT.md
then bad "an email address the project does not own is printed"; else ok "no invented contact address"; fi

case_ "3 · issue forms and a PR template"
printf '  %sA bug form that demands a reproduction, a version, a terminal and%s\n' "$D" "$N"
printf '        %sexpected-vs-actual; a feature form that asks about dependencies%s\n' "$D" "$N"
printf '        %sup front (the package ships zero); blank issues off, with the%s\n' "$D" "$N"
printf '        %sdocs / npm / security routes that actually resolve.%s\n' "$D" "$N"
T=$(git ls-files '.github/ISSUE_TEMPLATE/*' '.github/PULL_REQUEST_TEMPLATE.md' | wc -l | tr -d ' ')
[ "$T" = "4" ] && ok "4 template files tracked" || bad "expected 4 template files, found $T"

case_ "4 · a CI badge that points at the workflow that runs"
printf '  %sBadges are claims. This one resolves to a file in this repo, and%s\n' "$D" "$N"
printf '        %sthe check reads every actions/workflows/*.yml URL out of the README%s\n' "$D" "$N"
printf '        %sand asserts the file exists — on this branch and NOT on main.%s\n' "$D" "$N"
BURL=$(grep -oE 'actions/workflows/[A-Za-z0-9_.-]+\.yml' README.md | head -1)
BFILE=".github/workflows/${BURL#actions/workflows/}"
if [ -n "$BURL" ] && [ -f "$BFILE" ]; then ok "badge -> $BFILE (exists)"; else bad "no resolvable CI badge ($BURL)"; fi

# ---------------------------------------------------------------- the decisions

hdr "The six decisions, answered and recorded"

case_ "5 · D1 / D3-D6 — publish everything, ignore the local demos, strip D5"
printf '  %sD1 = A: all ~146 process files go public, so the closeout gates keep%s\n' "$D" "$N"
printf '        %sworking with no rework. D3/D6: playground/ and the design%s\n' "$D" "$N"
printf '        %smockups stay gitignored and untracked. D5: the overrides go.%s\n' "$D" "$N"
OV=$(git show main:pnpm-workspace.yaml | awk '/^overrides:/{f=1;next} f&&/^  /{n++} END{print n+0}')
OV_NOW=$(awk '/^overrides:/{f=1;next} f&&/^  /{n++} END{print n+0}' pnpm-workspace.yaml)
[ "$OV_NOW" = "0" ] && ok "overrides removed: $OV -> $OV_NOW, lockfile unchanged (zero delta)" \
                     || bad "$OV_NOW override entries still present (main had $OV)"
if git diff --stat main...HEAD -- pnpm-lock.yaml | grep -q .
then bad "pnpm-lock.yaml moved — A1 records a zero delta"; else ok "pnpm-lock.yaml byte-identical to main"; fi

case_ "6 · D4 — the personal home path, out of the tracked tree"
printf '  %s15 tracked files carried the founder%s\n' "$D" "$N"
printf '        %shome path, including the path-encoded spelling in a handoff.%s\n' "$D" "$N"
printf '        %sOne mechanical commit: every occurrence -> ~ / -home, no line%s\n' "$D" "$N"
printf '        %sadded or removed. History is D4b: rewriting 565 commits moves%s\n' "$D" "$N"
printf '        %severy recorded SHA, so it belongs to the flip session.%s\n' "$D" "$N"
PAT='(/|-)Users[-/][a-z]+'
LEFT=$(git grep -cE "$PAT" -- . 2>/dev/null | wc -l | tr -d ' ')
FOUND=$(for c in $(git rev-list HEAD); do if git grep -qE "$PAT" "$c" -- . 2>/dev/null; then echo "$c"; break; fi; done)
N_HITS=$(git grep -cE "$PAT" "$FOUND" -- . 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
[ "$LEFT" = "0" ] && ok "0 occurrences in the working tree; $N_HITS on the newest pre-scrub commit ${FOUND:0:8}" \
                   || bad "$LEFT tracked files still carry the path"

case_ "7 · N1 — the contract can no longer be rewritten under a live review"
printf '  %sS42 edited its contract between the REJECT and the ACCEPT pass, so the%s\n' "$D" "$N"
printf '        %sattestation was re-bound to a spec carrying its own rebuttal.%s\n' "$D" "$N"
printf '        %sNow: a rule in reviewer/SKILL.md (amend, never rewrite) plus%s\n' "$D" "$N"
printf '        %scontract-freshness in verify-closeout.sh, whose PURE body this%s\n' "$D" "$N"
printf '        %sgate extracts and runs against two real sessions.%s\n' "$D" "$N"
if grep -q "contract_freshness_core" scripts/verify-closeout.sh
then ok "contract-freshness lives in the closeout gate"; else bad "no freshness check in the closeout gate"; fi
if grep -q "## The contract is frozen" reviewer/SKILL.md
then ok "the immutability rule is written into reviewer/SKILL.md"; else bad "no rule in reviewer/SKILL.md"; fi

case_ "8 · §4.9 — the gate finally prices itself"
printf '  %sVAJRA_GATE_SCOPE=fast drops only the inherited checks that cost the%s\n' "$D" "$N"
printf '        %swall clock (clone+install, Playwright, docs build, the repeated%s\n' "$D" "$N"
printf '        %scoverage runs) and marks them SKIP. The suite still runs once.%s\n' "$D" "$N"
printf '        %sEvery check now times itself, so the skip list is arithmetics%s\n' "$D" "$N"
printf '        %srather than an estimate copied out of a review.%s\n' "$D" "$N"
META=$(ls -1t .ai/verify/session-44/*/run-meta.txt 2>/dev/null | head -1)
if [ -n "$META" ]; then ok "last run: $(tr '\n' ' ' < "$META")"; else bad "no run-meta.txt yet"; fi

# ---------------------------------------------------------------- counterfactual

hdr "The counterfactual: S43's gate does not survive the S44 branch"

case_ "9 · S43's ai-files-describe-s43, run from its own gate body, goes RED"
printf '  %sS43 asserted .ai/SESSION reads 43 and STATE.md names%s\n' "$D" "$N"
printf '        %ssession-43-docs-weight — true of exactly one session. S44 re-syncs%s\n' "$D" "$N"
printf '        %sboth, so S43%s own gate fails here for the reason it must.%s\n' "$D" "$N"
printf '        %sThe port re-expresses it as ai-files-describe-s44.%s\n' "$D" "$N"
F=$(grep -c "session-44-oss-polish" .ai/STATE.md .ai/SESSION-BOOT.md .ai/TASK.md 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
[ "$F" -gt 0 ] && ok ".ai/ names session-44-oss-polish in $F place(s) — S43's check cannot pass" \
               || bad ".ai/ does not name the live branch"

# ---------------------------------------------------------------- the whole session

hdr "All 14 requirements"

# States are READ from the verify run, never asserted here. DEMO_LOG_DIR points
# this at the run CURRENTLY in progress, because `latest` is only written when a
# run finishes (N2 — summary.txt is now rewritten after every check).
LOG="${DEMO_LOG_DIR:-.ai/verify/session-44/latest}"
if [ ! -d "$LOG" ]; then
  bad "no verify log at $LOG — run scripts/verify-session-44.sh first."
  printf '\n'; exit 1
fi
vstate() {
  if [ ! -f "$LOG/summary.txt" ]; then echo UNKNOWN; return; fi
  line=$(grep -E "^$1[[:space:]]+(PASS|FAIL|SKIP)$" "$LOG/summary.txt" 2>/dev/null | awk '{print $NF}' | head -1)
  if [ -n "$line" ]; then echo "$line"; else echo UNKNOWN; fi
}
req_state() {
  local st=PASS c s
  for c in "$@"; do
    s="$(vstate "$c")"
    [ "$s" = "PASS" ] || st="$s"
  done
  case "$st" in
    PASS) printf '%sSHIPPED%s' "$G" "$N" ;;
    FAIL) printf '%sPARTIAL%s' "$Y" "$N" ;;
    *)    printf '%sNOT PROVEN%s' "$R" "$N" ;;
  esac
}

printf '  %-4s %-46s %s%s\n' "#" "REQUIREMENT" "STATE"
printf '  %-4s %-46s %s%s\n' "----" "----------------------------------------------" "----------"
row() { printf '  %-4s %-46s %b\n' "$1" "$2" "$(req_state "${@:3}")"; }
row 1  "SECURITY.md: supported versions + disclosure"    oss-surface-present
row 2  "CODE_OF_CONDUCT.md, no invented contact"         oss-surface-present
row 3  "issue forms + PR template"                       oss-surface-present
row 4  "CI badge on the workflow that runs"              oss-surface-present
row 5  "coverage enforced in CI"                         coverage-enforced-in-ci
row 6  "engines where they are provable"                 engines-derived
row 7  "D1-D6 answered and recorded"                     overrides-gone home-path-scrubbed
row 8  "D4 scrub, provably mechanical"                   home-path-scrubbed
row 9  "N1: rule + a gate that can go red"               contract-freshness-teeth
row 10 "§4.9: scope switch, measured"                    gate-scope-switch
row 11 "D5 overrides stripped, own-commit regen"         overrides-gone
row 12 "product re-proved from live facts"               fresh-clone-build-no-env core-tests core-typecheck root-typecheck example-runs
row 13 ".ai/ re-synced; counts derived, not typed"       ai-files-describe-s44 ai-names-no-deleted-tree test-count-propagated
row 14 "contract at HEAD, mapped, independently reviewed" contract-at-head s43-gate-verbatim-goes-red

# ---------------------------------------------------------------- summary table

hdr "Summary"
TESTS=$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+' | head -1 || echo "?")
TFILES=$(ls -1 packages/core/tests/*.test.ts 2>/dev/null | wc -l | tr -d ' ')
GATES=$(grep -c '^run_check ' scripts/verify-session-44.sh)
RAN=$(ls -1 "$LOG"/*.log 2>/dev/null | wc -l | tr -d ' ')
ADDED=$(git diff --diff-filter=A --name-only main...HEAD 2>/dev/null | wc -l | tr -d ' ')
DELETED=$(git diff --diff-filter=D --name-only main...HEAD 2>/dev/null | wc -l | tr -d ' ')
OV=$(git show main:pnpm-workspace.yaml | awk '/^overrides:/{f=1;next} f&&/^  /{n++} END{print n+0}')
SCRUB=$(for c in $(git rev-list HEAD); do if git grep -qE '(/|-)Users[-/][a-z]+' "$c" -- . 2>/dev/null; then echo "$c"; break; fi; done)
N_HITS=$(git grep -cE '(/|-)Users[-/][a-z]+' "$SCRUB" -- . 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
META=$(ls -1t .ai/verify/session-44/*/run-meta.txt 2>/dev/null | head -1)
printf '  %-34s %s%s\n' "core suite"              "($TESTS tests in $TFILES files)"
printf '  %-34s %s%s\n' "files added / deleted"   "$ADDED added, $DELETED deleted"
printf '  %-34s %s%s\n' "workspace overrides"     "$OV removed (lockfile unchanged)"
printf '  %-34s %s%s\n' "home-path occurrences"   "$N_HITS before -> 0 now"
printf '  %-34s %s%s\n' "verify checks defined"   "$GATES"
printf '  %-34s %s%s\n' "verify checks with a log" "$RAN"
printf '  %-34s %s%s\n' "last gate run"           "${META:+$(tr '\n' ' ' < "$META")}${META:-not run yet}"
printf '  %-34s %s%s\n' "prettier: files off-style" "$(node_modules/.bin/prettier --list-different . 2>/dev/null | wc -l | tr -d ' ')"
printf '  %-34s %s%s\n' "commits"                 "$(git rev-list --count main..HEAD)"

printf '\n%s%sNot built here — named, so it cannot be smuggled in:%s\n' "$B" "$Y" "$N"
printf '  %sthe flip%s      S45: README clone URL, npm repository/homepage, provenance, and D4b (the history rewrite).\n' "$D" "$N"
printf '  %sD4b%s           16 of 565 commits still carry the path; rewriting them moves every recorded SHA.\n' "$D" "$N"
printf '  %sdead deps%s     the seven docs dependencies S43 named but did not remove — a weight session, not this one.\n' "$D" "$N"
printf '  %sproduct%s       no file under packages/core/src is touched by this session; charts-format-only proves it.\n' "$D" "$N"

printf '\n'
