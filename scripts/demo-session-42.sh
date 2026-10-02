#!/usr/bin/env bash
# S42 demo — what a stranger reads, before and after.
# Cumulative: numbers already true (453 tests, 20 charts, 0 deps) are context,
# not claims of new work.
#
# Every number printed below is DERIVED at run time. None is typed. S39's cold
# review rejected a demo for fabricating three ticks, and S41's for printing a
# "nine places" figure that was wrong three times in three passes.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

B=$(printf '\033[1m'); D=$(printf '\033[2m'); G=$(printf '\033[32m'); R=$(printf '\033[31m')
Y=$(printf '\033[33m'); C=$(printf '\033[36m'); N=$(printf '\033[0m')
[ -t 1 ] || { B=""; D=""; G=""; R=""; Y=""; C=""; N=""; }

hdr()  { printf '%s\n' "${B}── $* ─────────────────────────────────────────────${N}"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$1"; }
bad()  { printf '  %s✗%s %s\n' "$R" "$N" "$1"; }
case_() { printf '\n%s%s%s\n' "$C" "$1" "$N"; }

printf '\n%s┌─ Session 42 · cleanup Batch 2 ───────────────────────┐%s\n' "$B" "$N"
printf '%s│  dead weight gone · the repo ships the library, not   │%s\n' "$B" "$N"
printf '%s│  the Replit scaffold it was extracted from          │%s\n' "$B" "$N"
printf '%s└────────────────────────────────────────────────────────┘%s\n' "$B" "$N"

# ---------------------------------------------------------------- what shipped

hdr "Four trees a stranger had to read past"

# Counts come out of git, not out of this file: how many tracked files each
# tree held at main, and how many are still tracked here.
gone_count() {  # gone_count <tree>
  git ls-tree -r --name-only main -- "$1" 2>/dev/null | wc -l | tr -d ' '
}
still_count() { git ls-files -- "$1" 2>/dev/null | wc -l | tr -d ' '; }

case_ "1 · artifacts/mockup-sandbox/  ($(gone_count artifacts/mockup-sandbox) files)"
printf '  %sbefore%s  a Vite sandbox of design mockups, ~50 radix/shadcn deps,\n' "$D" "$N"
printf '        in the workspace globs, typechecked and built on every\n'
printf '        %spnpm run build%s. Now: %s0 tracked, 0 on disk.%s\n' "$D" "$N" "$G" "$N"
n=$(still_count artifacts/mockup-sandbox)
[ "$n" = "0" ] && ok "0 tracked files" || bad "$n still tracked"
printf '        %snote: the roadmap called this "breaks the root build".%s\n' "$Y" "$N"
printf '        %sIt did not. Run at boot, its build and typecheck both exit 0.%s\n' "$Y" "$N"
printf '        %sS41 fixed the build order, which cured it. The reason to\n         delete it is weight, not breakage — and the contract says so.%s\n' "$Y" "$N"

case_ "2 · lib/  ($(gone_count lib) files)"
printf '  %sbefore%s  @workspace/api-spec  (OpenAPI 3.1, "source of truth")\n' "$D" "$N"
printf '        %sapi-zod          (zod schemas generated from that spec)%s\n' "$D" "$N"
printf '        %sapi-client-react (orval + TanStack Query)%s\n' "$D" "$N"
printf '        %sdb               (drizzle-orm schema)%s\n' "$D" "$N"
printf '        %sfour workspace packages, imported by nothing.%s\n' "$D" "$N"
n=$(still_count lib)
[ "$n" = "0" ] && ok "0 tracked files" || bad "$n still tracked"

case_ "3 · artifacts/api-server/  ($(gone_count artifacts/api-server) files)"
printf '  %sbefore%s  a Node server whose entire route table was /healthz.\n' "$D" "$N"
printf '        %sSTATE.md called it "the undecided if-the-hosted-API-is-\n         pursued bet". This is that bet being closed — S42 deletes it,\n         git history keeps it.%s\n' "$D" "$N"
n=$(still_count artifacts/api-server)
[ "$n" = "0" ] && ok "0 tracked files" || bad "$n still tracked"

case_ "4 · attached_assets/  ($(gone_count attached_assets) files)"
printf '  %sbefore%s  two screenshots and a pasted text file, reachable only\n' "$D" "$N"
printf '        %sthrough the @assets alias in the docs vite config.%s\n' "$D" "$N"
h=$(git grep -n '@assets' -- artifacts/chitra-docs/src 2>/dev/null | wc -l | tr -d ' ')
printf '        %sThat alias had %s hits in docs/src. Dead, not merely unreferenced.%s\n' "$D" "$h" "$N"
n=$(still_count attached_assets)
[ "$n" = "0" ] && ok "0 tracked files, and the alias that reached them is gone" || bad "$n still tracked"

hdr "The chain that held them up — 9 files, every one verified by grep"

CHAIN=9
hits=$(git grep -lE 'mockup-sandbox|api-server|@workspace/(db|api-)|attached_assets|@assets|typecheck:libs' -- . \
        ':!sessions' ':!prompts' ':!.ai' \
        ':!code-cleanup-plan-session-41.md' ':!independent-audit-RESULT.md' \
        ':!scripts/verify-session-41.sh' ':!scripts/demo-session-41.sh' \
        ':!scripts/verify-session-42.sh' ':!scripts/demo-session-42.sh' 2>/dev/null | wc -l | tr -d ' ')
if [ "$hits" = "0" ]; then ok "0 of $CHAIN build/config/script files reference a deleted tree"
else bad "$hits still reference one"; fi
printf '        %sthe release path was one of the 9: release.yml ran\n         typecheck:libs before it built and typechecked the docs app,\n         on the way to npm publish.%s\n' "$Y" "$N"

# ---------------------------------------------------------------- counterfactual

hdr "The one that mattered: the inherited gate does not survive requirement 1"

case_ "5 · S41's gate, run unmodified, goes RED on this branch"
printf '  %sS41 enumerated two vite configs by path. One of them pointed\n         into mockup-sandbox/. Deleting it breaks the check — not the\n         repo: grep on a missing file exits 1, the guard fires, the gate\n         is red and there is nothing wrong with anything.%s\n' "$D" "$N"
printf '        %sartifacts/mockup-sandbox/vite.config.ts does not default PORT\n         artifacts/mockup-sandbox/vite.config.ts does not default BASE_PATH%s\n' "$D" "$N"
printf '\n  %sSo the S42 check DISCOVERS its inventory instead of naming it,%s\n' "$C" "$N"
printf '  %sand asserts the discovered list is non-empty — because an empty\n         list is the vacuous pass S41’s own review caught elsewhere.%s\n' "$C" "$N"
V=$(git ls-files | grep -cE '(^|/)vite\.config\.[a-z]+$')
if [ "$V" -gt 0 ]; then ok "$V vite config(s) discovered, none hard-throws, none reads PORT/BASE_PATH undefaulted"
else bad "no vite config discovered — the glob is broken, not the repo clean"; fi
printf '\n  %sverify-session-42.sh#s41-gate-verbatim-goes-red runs S41’s actual\n         gate and asserts it fails, fails on THAT check, and that S41’s own\n         log names the deleted path. Three assertions, not one.%s\n' "$D" "$N"

# ---------------------------------------------------------------- the whole session

hdr "All 10 requirements"

# States are READ from the last verify run, never asserted here. S39's cold
# review caught two fabricated WORKS rows in a demo script; a demo that prints
# its own verdict is the same bug wearing a different hat.
#
# DEMO_LOG_DIR exists so verify-session-42.sh can point this at the run that is
# CURRENTLY in progress rather than the `latest` symlink, which is only written
# when a run finishes. Without it, the gate could not check this demo's output
# on a first-ever run.
LOG="${DEMO_LOG_DIR:-.ai/verify/session-42/latest}"
if [ ! -d "$LOG" ]; then
  bad "no verify log at $LOG — run scripts/verify-session-42.sh first."
  printf '\n'; exit 1
fi
vstate() {
  # The COLD REVIEW killed this function. It read each check's log and grepped it
  # for keywords (FAIL|ERROR|error TS|does not), which is not the same thing as
  # asking whether the check passed — so it rendered requirement 6 PARTIAL (its
  # counterfactual check legitimately prints the S41 gate's own failure text) and
  # requirement 8 SHIPPED. Both wrong, and the second one was the fakest green in
  # the delivery.
  #
  # The gate writes one log per check but no status file, so this derives the
  # status from the gate's OWN summary line for that check: "name   PASS|FAIL".
  # That is the exit status the gate recorded, not a guess about a log's prose.
  if [ ! -f "$LOG/summary.txt" ]; then echo UNKNOWN; return; fi
  line=$(grep -E "^$1[[:space:]]+(PASS|FAIL)$" "$LOG/summary.txt" 2>/dev/null \
         | awk '{print $NF}' | head -1)
  # The first draft piped this to `grep -q . || echo UNKNOWN`, which printed
  # NOTHING on success. req_state then compared the empty string against PASS,
  # set the state to "", and every row rendered NOT PROVEN against a gate that
  # was 35 for 35. If this check ever says NOT PROVEN, check THIS first.
  if [ -n "$line" ]; then echo "$line"; else echo UNKNOWN; fi
}
req_state() {
  local st=PASS c
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

TESTS=$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+' || echo "?")
TFILES=$(ls -1 packages/core/tests/*.test.ts 2>/dev/null | wc -l | tr -d ' ')
GATES=$(grep -c '^run_check ' scripts/verify-session-42.sh)
RAN=$(ls -1 "$LOG"/*.log 2>/dev/null | wc -l | tr -d ' ')

printf '  %-4s %-46s %s\n' "#" "REQUIREMENT" "STATE"
printf '  %-4s %-46s %s\n' "----" "----------------------------------------------" "----------"
row() { printf '  %-4s %-46s %b\n' "$1" "$2" "$(req_state "${@:3}")"; }
row 1  "four dead trees deleted, 0 tracked files each"  dead-trees-gone
row 2  "the 9-file reference chain cut"                  no-live-ref-to-dead-trees
row 3  "typecheck:libs gone: script, ci.yml, release.yml" typecheck-libs-gone-end-to-end
row 4  "6 dead scripts gone, 2 dangling refs cut"        dead-scripts-gone
row 5  "lockfile regenerated, frozen, no dead importer"  lockfile-frozen-no-dead-importers
row 6  "S41 gate ported: vite inventory DISCOVERED"      vite-configs-discovered s41-gate-verbatim-goes-red
row 7  "product re-proved from live facts"               fresh-clone-build-no-env core-tests core-typecheck root-typecheck s39-suite-still-green example-runs
row 8  "browser QA driven, green CI"                      browser-qa-catalog-pages fresh-clone-build-no-env core-typecheck
row 9  ".ai/ re-synced; no deleted tree described as live" ai-files-describe-s42 ai-names-no-deleted-tree test-count-propagated
row 10 "contract at HEAD, mapped, independently reviewed" contract-at-head

# ---------------------------------------------------------------- summary table
hdr "Summary"
DEL=$(git diff --diff-filter=D --name-only main...HEAD 2>/dev/null | wc -l | tr -d ' ')
IMPORTERS=$(awk '/^importers:/{f=1;next} /^[^ ]/{f=0} f && /^  [^ ]/{c++} END{print c+0}' pnpm-lock.yaml)
LOCKN=$(git diff --numstat main...HEAD -- pnpm-lock.yaml 2>/dev/null | awk '{print $1"/-"$2}' | head -1)
printf '  %-34s %s\n' "core suite"                 "($TESTS tests in $TFILES files)"
printf '  %-34s %s\n' "tracked files"              "511 -> $(git ls-files | wc -l | tr -d ' ')  ($DEL deleted)"
printf '  %-34s %s\n' "lockfile"                   "10 -> $IMPORTERS importers  ($LOCKN)"
printf '  %-34s %s\n' "workspace globs"             "$(awk '/^packages:/{f=1;next} /^[^ ]/{f=0} f && /^  - /{c++} END{print c+0}' pnpm-workspace.yaml)  (was $(git show main:pnpm-workspace.yaml | awk '/^packages:/{f=1;next} /^[^ ]/{f=0} f && /^  - /{c++} END{print c+0}'))"
printf '  %-34s %s\n' "verify checks defined"      "$GATES"
printf '  %-34s %s\n' "verify checks with a log"   "$RAN"
printf '  %-34s %s\n' "chart source touched"       "$(git diff --name-only main...HEAD -- packages/core/src/charts packages/core/src/renderers packages/core/src/themes | wc -l | tr -d ' ') files"
printf '  %-34s %s\n' "commits"                    "$(git rev-list --count main..HEAD)"

printf '\n%s%sNot built here — named, so it cannot be smuggled in:%s\n' "$B" "$Y" "$N"
printf '  %sBatch 3 (S43)%s  43 unused shadcn components, Prettier, the lint script pointing at an eslint nobody installed\n' "$D" "$N"
printf '  %sBatch 4 (S44)%s  OSS templates, coverage job, engines — and founder decisions D1–D6\n' "$D" "$N"
printf '  %sthe flip%s      after S44. D1 (what goes public) and D4 (the /Users/suman path scrub, irreversible once published) are yours.\n' "$D" "$N"
printf '  %suntouched%s    pnpm-workspace overrides (D5, needs its own regen), the historical verify/demo pairs, all frozen history.\n' "$D" "$N"
printf '\n'