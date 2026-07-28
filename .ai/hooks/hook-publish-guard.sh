#!/usr/bin/env bash
# PreToolUse(Bash): guards outward/irreversible actions (S37 — close the S36 enforcement leak).
#
# The S36 dogfood finding: at maturity L3, in ONE chat, the agent pushed to a real
# remote and created + merged two real PRs — Vajra's hooks stopped none of it.
# hook-pre-bash.sh only *warns* on `git push`; nothing watched `gh pr create`/`gh pr merge`.
# This hook turns the outward/irreversible actions into a real, maturity-gated BLOCK
# unless the founder has explicitly authorized publishing for this launch.
#
# Guarded actions: git push (any form), gh pr create, gh pr merge, glab mr create/merge.
#
# Approval signal: the environment variable VAJRA_ALLOW_PUBLISH=1, set by the founder at
# launch (e.g. `VAJRA_ALLOW_PUBLISH=1 vajra claude`). An env var — NOT a token file —
# because the agent can `touch` a file itself but CANNOT mutate this hook's launch
# environment from inside a Bash tool call (a child shell can't change the parent's env,
# and PreToolUse fires *before* the command runs, so an inline `VAJRA_ALLOW_PUBLISH=1 git
# push` typed by the agent never reaches this hook's own environment). Escape hatch mirrors
# VAJRA_SKIP_AUTH_CHECK (S34).
#
# When enforcing (see the S47 opt-in gate below), maturity-gated like every Vajra hook (S21):
#   L1    -> ADVISE  : warn on stdout, exit 0 (agent may proceed).
#   L2/L3 -> ENFORCE : warn on stderr, exit 2 (action blocked).
# NOTE (S47): no longer always-on — this repo DISABLED it (`publish_guard: off` in CONSTRAINTS);
# re-arm with VAJRA_ENFORCE_PUBLISH=1. The `vajra init` scaffold still ships it on. See the gate
# right after `set -euo pipefail`.
#
# Test/override knob: VAJRA_GUARD_MATURITY overrides the maturity read from CONSTRAINTS.yaml.

set -euo pipefail

# ── S47 founder directive: the publish-guard is OPT-IN now ───────────────────────────────────
# The enforcement arc (S37→S44) is complete + LIVE-VERIFIED (S46) and direction is B, so the
# founder disabled the always-on block in THIS repo. The guard ENFORCES only when EITHER the env
# var VAJRA_ENFORCE_PUBLISH=1 is set (explicit re-arm), OR .ai/CONSTRAINTS.yaml does NOT carry
# `publish_guard: off`. This repo sets `publish_guard: off`, so publishing is allowed with no env
# var. The scaffold ships NO such line — the SAME byte-identical hook, gated by config — so every
# NEW project still gets the guard ON. The switch lives in CONSTRAINTS, not the code: no drift.
_VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
_PG=$(grep -m1 '^[[:space:]]*publish_guard:[[:space:]]' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "")
if [ "${VAJRA_ENFORCE_PUBLISH:-}" != "1" ] && [ "$_PG" = "off" ]; then
  exit 0
fi

# jq preflight — fail-closed (AGENTS.md L147: a check that cannot evaluate FAILS).
if ! command -v jq >/dev/null 2>&1; then
  _VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
  _VMAT="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo L2)}"
  [ "$_VMAT" = "L1" ] && { echo "[vajra] jq not on PATH — enforcement degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
[ -n "$CMD" ] || exit 0

# S39 (story B — fix the over-block): classify against the command with QUOTED SPANS
# REMOVED, so a trigger phrase buried inside an argument/message no longer false-blocks
# (`git commit -m "…git push…"`, `--body "…gh pr create…"`, `echo "gh pr merge"`). A real
# invocation always places the command name OUTSIDE quotes, so stripping quoted spans can
# never hide a genuine push/PR — fail-safe: anything unquoted still matches and blocks.
# Unbalanced quotes / heredocs leave text in place -> over-block, the safe direction.
SCAN=$(sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g" <<<"$CMD")

# Classify the command as an outward/irreversible action. Here-strings (not pipes) so a
# short-circuiting `grep -q` can never SIGPIPE a producer under `set -o pipefail` (S32 gotcha).
ACTION=""
if grep -qE '(^|[^[:alnum:]_])git[[:space:]]+push([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="git push (publishing commits to a remote)"
elif grep -qE '(^|[^[:alnum:]_])gh[[:space:]]+pr[[:space:]]+create([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="gh pr create (opening a pull request)"
elif grep -qE '(^|[^[:alnum:]_])gh[[:space:]]+pr[[:space:]]+merge([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="gh pr merge (merging a pull request)"
elif grep -qE '(^|[^[:alnum:]_])glab[[:space:]]+mr[[:space:]]+create([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="glab mr create (opening a merge request)"
elif grep -qE '(^|[^[:alnum:]_])glab[[:space:]]+mr[[:space:]]+merge([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="glab mr merge (merging a merge request)"
fi
[ -n "$ACTION" ] || exit 0

# Explicit founder approval for this launch — allow through.
if [ "${VAJRA_ALLOW_PUBLISH:-}" = "1" ]; then
  echo "[vajra publish-guard] ALLOWED ($ACTION) — VAJRA_ALLOW_PUBLISH=1."
  exit 0
fi

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"

if [ "$MATURITY" = "L1" ]; then
  echo "[vajra publish-guard] $ACTION — L1 advise (not blocking)."
  echo "  Outward/irreversible action; confirm explicit founder approval per .ai/AGENTS.md."
  exit 0
fi

{
  echo "[vajra publish-guard] BLOCKED: $ACTION"
  echo "  Outward/irreversible actions need explicit founder approval (S37 — the S36 leak)."
  echo "  To allow this launch: relaunch with VAJRA_ALLOW_PUBLISH=1"
  echo "    (e.g. VAJRA_ALLOW_PUBLISH=1 vajra claude)."
  echo "  To downgrade to advice: set maturity: L1 in .ai/CONSTRAINTS.yaml."
} 1>&2
exit 2
