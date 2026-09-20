#!/usr/bin/env bash
# demo-session-29.sh — S29: family-wide footer pass (B-diet+).
# Cumulative: plain-words takeaway footers + one rule separator across all 20
# locked charts (S09–S28 family), founder-picked from real-render ballots.
#
# Every case runs the REAL chart and prints observed output (no stderr/
# exit-code swallowing), and the lock claims are FALSIFIABLE checks that go red
# on regression.
# NOTE: when a user asks to SEE the demo, present it as a terminal-styled HTML slide deck
# (auto-play, PASS/FAIL colouring, scorecard). This bash form is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="29"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }

DEMO_FAIL=0
scorecard=()
record() { # name  PASS|FAIL
  scorecard+=("$(printf '%-40s %s' "$1" "$2")")
  [ "$2" = "PASS" ] || DEMO_FAIL=1
}

render() {
  local body="$1"
  local tmp="packages/core/src/__demo_s29_tmp.ts"
  printf '%s\n' "$body" > "$tmp"
  local out rc
  out="$( cd packages/core && NODE_NO_WARNINGS=1 npx tsx "src/__demo_s29_tmp.ts" 2>&1 )" && rc=0 || rc=$?
  rm -f "$tmp"
  printf '%s\n' "$out"
  return $rc
}

header "Session ${SESSION} Demo — family-wide footer pass (B-diet+)"
printf "${DIM}  (plain-words takeaway foot · one rule · accent still once · toJSON intact)${RESET}\n"

# ── BEFORE → AFTER ──────────────────────────────────────────────────────────
label "BEFORE (jargon footers, 2 rules — timeline + sparkline)"
cat <<'EOF'
  │ n 3 · 0..8 · span Build              │   (n? span? range repeats the scale row)
  │ n 5 · min 1 · max 5 · last 4 · peak 5 │   (min/max/last bury the takeaway)
EOF

label "AFTER (live renders through the real charts)"
AFTER_T="$(render 'import { timeline } from "./charts/timeline.js";
console.log(timeline({ events: [{label:"Build",start:0,end:8},{label:"Test",start:2,end:5}], noColor: true }).toString());')" || true
printf '%s\n' "$AFTER_T"
AFTER_S="$(render 'import { sparkline } from "./charts/sparkline.js";
console.log(sparkline({ data: [1,3,2,5,4], noColor: true }).toString());')" || true
printf '%s\n' "$AFTER_S"

label "Check: takeaway footers (timeline longest · spark readings·peak)"
take_ok=1
printf '%s' "$AFTER_T" | grep -q "2 events · longest Build" || take_ok=0
printf '%s' "$AFTER_S" | grep -q "5 readings · peak 5" || take_ok=0
if [ "$take_ok" = "1" ]; then ok "plain takeaways on both panels"; record "takeaway-foot" PASS
else no "takeaway footers missing"; record "takeaway-foot" FAIL; fi

label "Check: exactly 1 rule separator per panel (was 2)"
rule_ok=1
[ "$(printf '%s' "$AFTER_T" | grep -c "^│ ╌* │$")" = "1" ] || rule_ok=0
[ "$(printf '%s' "$AFTER_S" | grep -c "^│ ╌* │$")" = "1" ] || rule_ok=0
if [ "$rule_ok" = "1" ]; then ok "1 rule on both panels"; record "one-rule" PASS
else no "rule count wrong"; record "one-rule" FAIL; fi

label "Check: accent still spent once (takeaway accented)"
CENSUS="$(render 'import { sparkline } from "./charts/sparkline.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = sparkline({ data: [1,3,2,5,4] }).toString();
const foot = raw.split("\n").find((l) => l.includes("peak "))!;
console.log(foot.includes(theme.accent!) ? "yes" : "no");')" || true
if [ "$CENSUS" = "yes" ]; then ok "peak foot accented"; record "accent-once" PASS
else no "takeaway accent missing"; record "accent-once" FAIL; fi

label "Check: empty panels speak plain nouns (0 events / 0 readings)"
DEGEN="$(render 'import { timeline } from "./charts/timeline.js";
import { sparkline } from "./charts/sparkline.js";
const t = timeline({ events: [], noColor: true }).toPlain();
const s = sparkline({ data: [], noColor: true }).toPlain();
console.log(JSON.stringify({ t: t.includes("0 events · (no data)"), s: s.includes("0 readings · (no data)") }));')" || true
if [ "$DEGEN" = '{"t":true,"s":true}' ]; then ok "empty panels plain + safe"; record "empty-plain" PASS
else no "empty panels gap ($DEGEN)"; record "empty-plain" FAIL; fi

# ── Summary scorecard ─────────────────────────────────────────────────────────
header "Summary"
printf "\n  %-40s %s\n" "Capability" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
for r in "${scorecard[@]}"; do echo "  $r"; done
printf "  %-40s %s\n" "core tests + typecheck" "see verify-session-29.sh"
printf "  %-40s %s\n" "README LOCKED block"   "see verify-session-29.sh"
printf "\n"

header "This demo does NOT show"
printf "${DIM}  · it does not run the acceptance test suite (that is verify-session-29.sh)\n"
printf "  · it does not prove the README lock block landed or that verify is green\n"
printf "  · a green demo is evidence, not a passing delivery — the gates decide that${RESET}\n\n"

if [ "$DEMO_FAIL" -eq 0 ]; then
  ok "Session ${SESSION} demo complete — every live check PASS."
  exit 0
else
  no "Session ${SESSION} demo — one or more live checks FAILED."
  exit 1
fi
