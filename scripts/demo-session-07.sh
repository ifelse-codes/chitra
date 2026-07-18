#!/usr/bin/env bash
# Session 07 demo — CI workflow (cumulative).
# Shows: the CI gates wired in .github/workflows/ci.yml, the pinned toolchain,
# a live run of the drift gate, and a green verify-session-07 run.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="07"
WF=".github/workflows/ci.yml"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — CI workflow"

header "1. The CI gates"
label "Every push to main and every PR runs these commands:"
grep -n 'run: pnpm' "$WF" | sed 's/^/  /'
ok "Three jobs — core (test/typecheck/build), docs (typecheck/build), chart drift."

header "2. Pinned toolchain"
label "CI runs the exact versions proven green locally:"
grep -n 'NODE_VERSION\|PNPM_VERSION\|frozen-lockfile' "$WF" | sed 's/^/  /'
ok "Node + pnpm pinned; installs are frozen-lockfile, so CI never drifts from pnpm-lock.yaml."

header "3. Drift gate, live"
label "The same command CI runs — generated chart previews must match the spec source:"
pnpm --filter @workspace/chitra-docs run gen:charts:check >/dev/null
ok "gen:charts:check exits 0 — no drift."

header "4. Green verify run"
label "scripts/verify-session-${SESSION}.sh — all gates, including the 116 core tests:"
bash "scripts/verify-session-${SESSION}.sh"

header "Summary"
printf "\n"
printf "  %-38s %s\n" "Feature" "Status"
printf "  %-38s %s\n" "--------------------------------------" "------"
printf "  %-38s %s\n" "ci.yml — core gates (test/types/build)" "WIRED"
printf "  %-38s %s\n" "ci.yml — docs gates (types/build)"      "WIRED"
printf "  %-38s %s\n" "ci.yml — chart drift gate"              "WIRED"
printf "  %-38s %s\n" "pinned Node 26 + pnpm 9.12.3 + frozen"  "PINNED"
printf "  %-38s %s\n" "verify-session-07"                      "GREEN"
printf "\n"

ok "Session ${SESSION} demo complete."
