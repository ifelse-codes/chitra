#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): enforce "No code in Ground Truth" (AGENTS.md Hard Rules).
#
# Until S36 that rule was declared "Hook-enforced" in AGENTS.md but NO hook backed it
# (the S35 ground-truth audit found only a boot reminder in hook-session-start.sh).
# This hook makes the claim true for the Claude Code harness: during a NO-CODE
# ground-truth session (N % 5 == 0) it BLOCKS writes to code, allowing only the
# session's own artifacts (markdown under sessions/, prompts/, and the .ai/ bookkeeping).
#
# Maturity-gated like every Vajra hook (S21): L1 -> ADVISE (exit 0); L2/L3 -> ENFORCE (exit 2).
# Test/override knob: VAJRA_GUARD_MATURITY overrides the maturity read from CONSTRAINTS.yaml.
#
# Best-effort on the harness: opencode does not run .claude/settings.json PreToolUse hooks,
# so in that harness the backstop is the closeout check `check_ground_truth_no_code` in
# scripts/verify-closeout.sh. Two layers; disclose which ran.

set -euo pipefail

# jq preflight — fail-closed (AGENTS.md: a check that cannot evaluate FAILS).
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

# Resolve the session number from the branch of THIS project's own git repo.
ROOT_REAL=$(cd "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")
GIT_TOP=$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null || echo "")
N=""
if [ -n "$GIT_TOP" ] && [ "$GIT_TOP" = "$ROOT_REAL" ]; then
  BRANCH=$(git -C "$ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")
  [[ "$BRANCH" =~ session-([0-9]+)- ]] && N="${BASH_REMATCH[1]}"
fi
if [ -z "$N" ] && [ -f "$ROOT/.ai/SESSION" ]; then
  N=$(tr -dc '0-9' < "$ROOT/.ai/SESSION" 2>/dev/null || true)
fi
[ -n "$N" ] || exit 0
N=$((10#$N))
# Only ground-truth sessions are policed.
[ "$((N % 5))" -eq 0 ] || exit 0

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")
[ -n "$FILE" ] || exit 0

# Normalize to repo-relative.
REL="${FILE#"$ROOT_REAL"/}"

# Allowed in a GT session: the audit artifact + bookkeeping + the prompt.
case "$REL" in
  sessions/*|.ai/*|prompts/*|*.md|*.txt) exit 0 ;;
esac

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"

if [ "$MATURITY" = "L1" ]; then
  echo "[vajra ground-truth-guard] advise (L1): session $N is NO-CODE ground truth — '${REL}' is a code change."
  exit 0
fi

{
  echo "[vajra ground-truth-guard] BLOCKED: session $N is NO-CODE ground truth (N % 5 == 0)."
  echo "  Refusing to write code file: ${REL}"
  echo "  Allowed: sessions/, prompts/, .ai/, and markdown. Report findings; fixing is the next session's job."
  echo "  (Override only via founder direction; maturity: L1 downgrades to advice.)"
} 1>&2
exit 2
# vajra-render-sha: 0000000000000000000000000000000000000000000000000000000000000000
