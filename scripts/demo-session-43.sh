#!/usr/bin/env bash
# S43 demo — the docs app ships the components it uses.
# Cumulative: numbers already true (the suite, 20 charts, 0 deps) are context,
# not claims of new work.
#
# Every LOAD-BEARING number below is DERIVED at run time — the suite count, the
# component and devDep counts, and every per-requirement STATE. The before/after
# figures in the prose (55, 53, 36, 64, 26, ~6000 LOC) are context, typed on
# purpose. In particular the suite count is ABSENT from this file, which the
# session's own test-count check asserts (a demo that types the number is the rot
# S43 exists to kill; the S41 demo passed that check on a COMMENT alone).
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

printf '\n%s┌─ Session 43 · cleanup Batch 3 ───────────────────────┐%s\n' "$B" "$N"
printf '%s│  docs weight · the docs app ships the components it    │%s\n' "$B" "$N"
printf '%s│  uses, and the Prettier it never enforced            │%s\n' "$B" "$N"
printf '%s└────────────────────────────────────────────────────────┘%s\n' "$B" "$N"

# ---------------------------------------------------------------- what shipped

hdr "The 53 shadcn components the docs app never rendered"

case_ "1 · 55 components seeded, 2 reachable"
printf '  %sbefore%s  a select, a calendar, a carousel, a chart wrapper, a\n' "$D" "$N"
printf '        %scommand palette — the Replit scaffold shipped a whole UI kit.%s\n' "$D" "$N"
printf '        %sThe live set is the transitive closure of what the docs app%s\n' "$D" "$N"
printf '        %sactually imports: only NOT-FOUND.tsx (card) and use-toast.ts%s\n' "$D" "$N"
printf '        %s(toast). All 53 others have zero inbound references anywhere.%s\n' "$D" "$N"
n=$(git ls-files artifacts/chitra-docs/src/components/ui | wc -l | tr -d ' ')
[ "$n" = "2" ] && ok "2 components tracked (was 55) — 53 gone, ~6000 LOC with them" \
              || bad "expected 2 components tracked, found $n"

case_ "2 · the 36 devDependencies that died with them"
printf '  %s26 @radix-ui primitives, plus cmdk, embla-carousel-react,%s\n' "$D" "$N"
printf '        %sinput-otp, next-themes, react-day-picker, react-hook-form,%s\n' "$D" "$N"
printf '        %srecharts, sonner, vaul and @hookform/resolvers — imported by%s\n' "$D" "$N"
printf '        %snothing that survives. react-resizable-panels is KEPT: the%s\n' "$D" "$N"
printf '        %scatalog page imports it. Lockfile regenerated in its own commit.%s\n' "$D" "$N"
d=$(python3 -c "import json;print(len(json.load(open('artifacts/chitra-docs/package.json'))['devDependencies']))")
ok "docs devDependencies now $d (was 64)"

case_ "3 · the three @replit/* Vite plugins"
printf '  %sbefore%s  runtime-error-modal was in the PRODUCTION plugins list;\n' "$D" "$N"
printf '        %scartographer and dev-banner loaded only under REPL_ID. None is%s\n' "$D" "$N"
printf '        %sload-bearing for a static public build. S42 left its own one-liner%s\n' "$D" "$N"
printf '        %stwo-thirds true because of these. Now it is true.%s\n' "$D" "$N"
if ! grep -q "@replit" artifacts/chitra-docs/vite.config.ts; then ok "no @replit reference in the docs vite config"; else bad "a @replit reference survives"; fi

case_ "4 · the lint script that pointed at nothing"
printf '  %spackages/core ran `eslint src tests`. eslint is installed nowhere%s\n' "$D" "$N"
printf '        %sand has no config — a script that can only fail. Removed.%s\n' "$D" "$N"
if ! grep -q '"lint"' packages/core/package.json; then ok "no lint script in packages/core"; else bad "the lint script is back"; fi

case_ "5 · Prettier — adopted, formatted, enforced (F43-1)"
printf '  %sbefore%s  a root prettier devDependency, NO config file, and 31 core\n' "$D" "$N"
printf '        %sfiles failing --check under bare defaults. Nothing in CI looked.%s\n' "$D" "$N"
printf '        %sNow: .prettierrc + .prettierignore are checked in, the repo is%s\n' "$D" "$N"
printf '        %sformatted, and a CI job runs format:check so it cannot rot back.%s\n' "$D" "$N"
n=$(node_modules/.bin/prettier --list-different . 2>/dev/null | wc -l | tr -d ' ')
[ "$n" = "0" ] && ok "0 files differ from Prettier style" || bad "$n files still differ"
printf '        %sthe LOCKED chart dirs are reformatted too — proven behaviour-neutral\n         by the suite and by charts-format-only (each file == prettier(base)).%s\n' "$Y" "$N"

# ---------------------------------------------------------------- counterfactual

hdr "The counterfactual: S42's gate does not survive the S43 format"

case_ "6 · S42's charts-untouched, run from its own gate body, goes RED"
printf '  %sS42 asserted `git diff main...HEAD -- <LOCKED dirs>` was empty. S43%s\n' "$D" "$N"
printf '        %sformats those dirs, so the check reports changed files and exits 1 —%s\n' "$D" "$N"
printf '        %son a change that changes no behaviour. It also PASSED VACUOUSLY when%s\n' "$D" "$N"
printf '        %smain did not resolve (N6). The S43 check replaces it: every changed%s\n' "$D" "$N"
printf '        %sfile under those dirs must be EXACTLY the Prettier transform of main.%s\n' "$D" "$N"
F=$(git diff --name-only main...HEAD -- packages/core/src/charts packages/core/src/renderers packages/core/src/themes | wc -l | tr -d ' ')
ok "$F changed files under the LOCKED dirs — each proven to be the Prettier transform of main"
printf '  %sverify-session-43.sh#s42-gate-verbatim-goes-red extracts S42'\''s REAL\n         charts-untouched body and asserts it exits non-zero on the format.%s\n' "$D" "$N"

# ---------------------------------------------------------------- the whole session

hdr "All 10 requirements"

# States are READ from the verify run, never asserted here. DEMO_LOG_DIR points
# this at the run CURRENTLY in progress, because `latest` is only written when a
# run finishes (N2 — summary.txt is now rewritten after every check).
LOG="${DEMO_LOG_DIR:-.ai/verify/session-43/latest}"
if [ ! -d "$LOG" ]; then
  bad "no verify log at $LOG — run scripts/verify-session-43.sh first."
  printf '\n'; exit 1
fi
vstate() {
  if [ ! -f "$LOG/summary.txt" ]; then echo UNKNOWN; return; fi
  line=$(grep -E "^$1[[:space:]]+(PASS|FAIL)$" "$LOG/summary.txt" 2>/dev/null | awk '{print $NF}' | head -1)
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
row 1  "53 unused ui components deleted (2 live)"     ui-components-shipped
row 2  "36 dead devDeps gone; lockfile regenerated"     docs-dead-deps-gone lockfile-frozen-no-dead-importers
row 3  "3 @replit/* Vite plugins stripped"              replit-plugins-gone
row 4  "dead lint script removed"                       lint-script-gone
row 5  "Prettier adopted, formatted, CI-enforced"       prettier-adopted charts-format-only
row 6  "S42 gate ported: inventories DISCOVERED"        vite-configs-discovered s42-gate-verbatim-goes-red
row 7  "N2-N9 fixed, each with a counterfactual"        browser-qa-catalog-pages replit-globs-match-workspace dead-scripts-gone demo-displays-count-at-runtime
row 8  "product re-proved from live facts"              fresh-clone-build-no-env core-tests core-typecheck root-typecheck example-runs
row 9  ".ai/ re-synced; counts derived, not typed"      ai-files-describe-s43 ai-names-no-deleted-tree test-count-propagated
row 10 "contract at HEAD, mapped, independently reviewed" contract-at-head

# ---------------------------------------------------------------- summary table

hdr "Summary"
TESTS=$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | grep -oE '[0-9]+' | head -1 || echo "?")
TFILES=$(ls -1 packages/core/tests/*.test.ts 2>/dev/null | wc -l | tr -d ' ')
UI=$(git ls-files artifacts/chitra-docs/src/components/ui | wc -l | tr -d ' ')
DEPS=$(python3 -c "import json;print(len(json.load(open('artifacts/chitra-docs/package.json'))['devDependencies']))")
GATES=$(grep -c '^run_check ' scripts/verify-session-43.sh)
RAN=$(ls -1 "$LOG"/*.log 2>/dev/null | wc -l | tr -d ' ')
DEL=$(git diff --diff-filter=D --name-only main...HEAD 2>/dev/null | wc -l | tr -d ' ')
printf '  %-34s %s%s\n' "core suite"              "($TESTS tests in $TFILES files)"
printf '  %-34s %s%s\n' "docs ui components"      "55 -> $UI"
printf '  %-34s %s%s\n' "docs devDependencies"    "64 -> $DEPS"
printf '  %-34s %s%s\n' "tracked files deleted"   "$DEL files (the unused components)"
printf '  %-34s %s%s\n' "verify checks defined"   "$GATES"
printf '  %-34s %s%s\n' "verify checks with a log" "$RAN"
printf '  %-34s %s%s\n' "prettier: files off-style" "$(node_modules/.bin/prettier --list-different . 2>/dev/null | wc -l | tr -d ' ')"
printf '  %-34s %s%s\n' "commits"                 "$(git rev-list --count main..HEAD)"

printf '\n%s%sNot built here — named, so it cannot be smuggled in:%s\n' "$B" "$Y" "$N"
printf '  %sBatch 4 (S44)%s  OSS templates, coverage job, engines — and founder decisions D1–D6\n' "$D" "$N"
printf '  %sthe flip%s      after S44. D1 (what goes public) and D4 (the /Users/suman path scrub, irreversible once published) are yours.\n' "$D" "$N"
printf '  %suntouched%s    pnpm-workspace overrides (D5, needs its own regen), the historical verify/demo pairs, all frozen history.\n' "$D" "$N"
printf '  %sproduct%s      every file under packages/core/src/charts, renderers and themes is reformat-only; charts-format-only proves it.\n' "$D" "$N"

printf '\n'
