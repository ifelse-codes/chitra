#!/usr/bin/env bash
# Session 08 demo — release.yml publish workflow (cumulative).
# Shows: the v* tag trigger, the four jobs (3 CI gates + publish),
# the NODE_AUTH_TOKEN wiring, and a green verify-session-08 run.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="08"
WF=".github/workflows/release.yml"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — release.yml publish workflow"

header "1. Trigger"
label "Fires on a v* tag push — never on a branch push or PR:"
grep -n 'tags\|"v\*"' "$WF" | sed 's/^/  /'
ok "Only tag pushes matching v* start a release."

header "2. Jobs wired"
label "Four jobs — three CI gates first, then publish:"
node -e "
const fs = require('node:fs'), path = require('node:path');
function loadYaml() {
  try { return require('yaml'); } catch {}
  const store = path.resolve('node_modules/.pnpm');
  const hit = fs.readdirSync(store).find((d) => /^yaml@\d/.test(d));
  if (!hit) throw new Error('no yaml parser found');
  return require(path.join(store, hit, 'node_modules/yaml'));
}
const doc = loadYaml().parse(fs.readFileSync('$WF', 'utf8'));
for (const [name, job] of Object.entries(doc.jobs)) {
  const needs = job.needs ? '(needs: ' + [].concat(job.needs).join(', ') + ')' : '';
  console.log('  ' + name + ' — ' + (job.name || name) + ' ' + needs);
}
"
ok "publish runs only after core + docs + chart-drift all pass."

header "3. NODE_AUTH_TOKEN"
label "Publish step uses the npm token secret:"
grep -n 'NODE_AUTH_TOKEN\|registry-url\|access public' "$WF" | sed 's/^/  /'
ok "Token injected from secrets.NODE_AUTH_TOKEN; registry set to npmjs.org."

header "4. Toolchain pins (same as ci.yml)"
label "Identical Node + pnpm pins and frozen install:"
grep -n 'NODE_VERSION\|PNPM_VERSION\|frozen-lockfile' "$WF" | head -6 | sed 's/^/  /'
ok "Node 26, pnpm 9.12.3, frozen lockfile — consistent with S07 ci.yml."

header "5. Green verify run"
label "scripts/verify-session-${SESSION}.sh — all gates:"
bash "scripts/verify-session-${SESSION}.sh"

header "Summary"
printf "\n"
printf "  %-45s %s\n" "Feature" "Status"
printf "  %-45s %s\n" "---------------------------------------------" "------"
printf "  %-45s %s\n" "release.yml — v* tag trigger"                 "WIRED"
printf "  %-45s %s\n" "release.yml — core gate (test/types/build)"   "WIRED"
printf "  %-45s %s\n" "release.yml — docs gate (types/build)"        "WIRED"
printf "  %-45s %s\n" "release.yml — chart-drift gate"               "WIRED"
printf "  %-45s %s\n" "release.yml — publish (pnpm publish --access public)" "WIRED"
printf "  %-45s %s\n" "NODE_AUTH_TOKEN secret wiring"                "WIRED"
printf "  %-45s %s\n" "pinned Node 26 + pnpm 9.12.3 + frozen"       "PINNED"
printf "  %-45s %s\n" "verify-session-08"                            "GREEN"
printf "\n"

ok "Session ${SESSION} demo complete."
