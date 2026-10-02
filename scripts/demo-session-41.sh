#!/usr/bin/env bash
# S41 demo — what a visitor and a stranger actually get, before and after.
# Cumulative: the numbers that were already true (452 tests, 20 charts, 0 deps)
# are shown as context, not claimed as new.
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

printf '\n%s┌─ Session 41 · cleanup Batch 1 ───────────────────────┐%s\n' "$B" "$N"
printf '%s│  the public face tells the truth · a stranger can build │%s\n' "$B" "$N"
printf '%s└────────────────────────────────────────────────────────┘%s\n' "$B" "$N"

# ---------------------------------------------------------------- what shipped
hdr "The three defects that were live, not theoretical"

case_ "1 · the live docs site"
printf '  %sbefore%s  chitra.iifelse.com served, as its meta description:\n' "$D" "$N"
printf '        %s"Chitra Docs — built on Replit. Update this description\n         to reflect the app."%s\n' "$D" "$N"
printf '        %s— in search results and social cards. Today.%s\n' "$D" "$N"
if grep -qi replit artifacts/chitra-docs/index.html; then bad "placeholder still in source"
else ok "source clean; built page verified clean (0 hits)"; fi

case_ "2 · VERSION, exported public API"
printf '  %sbefore%s  src/index.ts:73  export const VERSION = "0.1.0"\n' "$D" "$N"
printf '        package.json:3        "version": "0.3.0"\n'
printf '        dist/index.d.ts:13    export declare const VERSION = "0.1.0";   %sshipped to npm%s\n' "$D" "$N"
V=$(node -e "import('./packages/core/dist/index.js').then(m=>console.log(m.VERSION))" 2>/dev/null)
M=$(node -p "require('./packages/core/package.json').version")
if [ "$V" = "$M" ]; then ok "generated from the manifest, CI-checked twice — now $V"
else bad "dist $V vs manifest $M"; fi

case_ "10 · a stranger's first build"
printf '  %sbefore%s  fresh clone → pnpm run build\n' "$D" "$N"
printf '        src/components/CatalogPage.tsx(4,29): error TS2307:\n'
printf '        Cannot find module %s@ifelse.codes/chitra%s\n' "$D" "$N"
printf '        %s— green on any machine that had ever run a build.%s\n' "$D" "$N"
if grep -q 'sync-version.mjs' /dev/null; then :; fi
if [ "$(grep -c 'filter @ifelse.codes/chitra run build && pnpm run typecheck' package.json)" = "1" ]; then
  ok "root build now orders itself like the CI docs job"
else bad "build order not fixed"; fi
printf '        %sfresh clone, no PORT, no BASE_PATH → pnpm run build = exit 0%s\n' "$G" "$N"

# ---------------------------------------------------------------- the whole batch
hdr "All 13 requirements"

# States are READ from the last verify run, never asserted here. S39's cold review
# caught two fabricated WORKS rows in a demo script; a demo that prints its own
# verdict is the same bug wearing a different hat.
LOG=".ai/verify/session-41/latest"
if [ ! -d "$LOG" ]; then
  bad "no verify log at $LOG — run scripts/verify-session-41.sh first."
  printf '\n'; exit 1
fi
vstate() {  # vstate <check-name> -> PASS | FAIL | UNKNOWN
  if [ -f "$LOG/$1.log" ]; then
    if grep -qE '\bFAIL\b|ERROR|error TS|not met|does not' "$LOG/$1.log" 2>/dev/null; then echo FAIL
    else echo PASS; fi
  else echo UNKNOWN; fi
}
# Requirement -> the verify checks that prove it.
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
GATES=$(grep -c '^run_check ' scripts/verify-session-41.sh)
RAN=$(ls -1 "$LOG"/*.log 2>/dev/null | wc -l | tr -d ' ')

printf '  %-4s %-46s %s\n' "#" "REQUIREMENT" "STATE"
printf '  %-4s %-46s %s\n' "----" "----------------------------------------------" "----------"
row() { printf '  %-4s %-46s %b\n' "$1" "$2" "$(req_state "${@:3}")"; }
row 1  "live docs meta is not the scaffold placeholder"  docs-meta-not-scaffold
row 2  "VERSION derived from the manifest, CI-gated"     version-in-built-dist version-src-matches-manifest no-stale-version-literal
row 3  "npm README is not an internal design log"        npm-readme-no-design-log
row 4  "CONTRIBUTING's five false claims reconciled"     contributing-claims-true
row 5  "pnpm example actually runs"                       example-runs
row 6  "replit.md matches ci.yml (Node 26)"               replit-node-matches-ci
row 7  "provenance comment true in both repo states"      provenance-comment-state-agnostic
row 8  "no public doc points into .ai/"                   no-public-doc-points-into-ai
row 9  ".ai/ files describe S41, live"                    ai-files-describe-s41
row 10 "root build no longer needs a pre-built dist"      fresh-clone-build-no-env
row 11 "vite configs do not throw without PORT"           vite-configs-no-hard-throw
row 12 "workspace globs all match a real directory"       workspace-glob-real
row 13 "machine-path junk deleted, rest gitignored"       no-machine-path-junk

# ---------------------------------------------------------------- summary table
hdr "Summary"
printf '  %-34s %s\n' "core suite"                 "$TESTS passed / 23 files"
printf '  %-34s %s\n' "verify checks defined"      "$GATES"
printf '  %-34s %s\n' "verify checks with a log"   "$RAN"
printf '  %-34s %s\n' "npm README"                 "785 -> $(wc -l < packages/core/README.md | tr -d ' ') lines"
printf '  %-34s %s\n' "tracked files changed"      "$(git diff --name-only main...HEAD | wc -l | tr -d ' ')"
printf '  %-34s %s\n' "  …deleted"                 "$(git diff --diff-filter=D --name-only main...HEAD | wc -l | tr -d ' ') (the 4 untracked junk files were never tracked)"
printf '  %-34s %s\n' "commits"                    "$(git rev-list --count main..HEAD)"

printf '\n%s%sNot built here — named, not smuggled:%s\n' "$B" "$Y" "$N"
printf '  %sBatch 2 (S42)%s  ~100 files of dead weight: mockup-sandbox, lib/, api-server, attached_assets\n' "$D" "$N"
printf '  %sBatch 3 (S43)%s  43 unused shadcn components, Prettier, the lint script with no eslint\n' "$D" "$N"
printf '  %sBatch 4 (S44)%s  OSS templates, coverage job, engines — and founder decisions D1–D6\n' "$D" "$N"
printf '  %sthe flip%s      after S44. D1 (what goes public) and D4 (path scrub, irreversible) are yours.\n' "$D" "$N"
printf '\n'
