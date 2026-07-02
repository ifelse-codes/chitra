#!/usr/bin/env bash
# PreToolUse(Bash): enforces one-vajra-session-per-chat (AGENTS.md step 10).
#
# The Hard Rule: a new vajra-session starts in a NEW chat. The chat that closed
# session N must NOT begin session N+1's BRANCH/PLAN in the same chat. Until now
# this was convention only (CONSTRAINTS.yaml#session.one_session_per_chat: true);
# this hook makes it real.
#
# Signal: the Claude `session_id` (the chat). We record which chat "owns" each
# vajra-session number the first time it creates that session's branch. When a
# `git checkout -b session-NN-*` crosses the N->N+1 boundary FROM THE SAME CHAT
# that owned N, we block: open a new chat first.
#
# Maturity-gated (same gate as every Vajra hook, S21):
#   L1    -> ADVISE  : warn on stdout, exit 0 (agent may proceed).
#   L2/L3 -> ENFORCE : warn on stderr, exit 2 (branch creation blocked).
# Only active when CONSTRAINTS.yaml#session.one_session_per_chat: true.
#
# Test/override knobs (used by verify-session-26.sh to drive the boundary without
# real chats): VAJRA_SESSION_OWNER_FILE overrides the owner record path;
# VAJRA_GUARD_MATURITY overrides the maturity level read from CONSTRAINTS.yaml.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"
[ -f "$CONSTRAINTS" ] || exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
SID=$(echo "$INPUT" | jq -r '.session_id // "nosession"' 2>/dev/null || echo "nosession")

# Only fire on creation of a vajra-session branch: git checkout -b session-NN-<slug>
NN=$(printf '%s' "$CMD" | grep -oE 'checkout +-b +session-[0-9]+-' | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
[ -n "$NN" ] || exit 0
NN=$((10#$NN))

# Gate: rule must be enabled.
ENABLED=$(grep -E '^[[:space:]]*one_session_per_chat:' "$CONSTRAINTS" 2>/dev/null | grep -oE 'true|false' | head -1 || echo "false")
[ "$ENABLED" = "true" ] || exit 0

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"
OWNER_FILE="${VAJRA_SESSION_OWNER_FILE:-$ROOT/.ai/.session-owner}"

# Read the prior owner record, if any:  <NN>\t<session_id>
OWNER_NN=""; OWNER_SID=""
if [ -f "$OWNER_FILE" ]; then
  OWNER_NN=$(awk 'NR==1{print $1}' "$OWNER_FILE" 2>/dev/null || echo "")
  OWNER_SID=$(awk 'NR==1{print $2}' "$OWNER_FILE" 2>/dev/null || echo "")
  [ -n "$OWNER_NN" ] && OWNER_NN=$((10#$OWNER_NN))
fi

record() { printf '%s\t%s\n' "$NN" "$SID" > "$OWNER_FILE"; }

# Block only the N->N+1 boundary FROM THE SAME CHAT that owned N.
if [ -n "$OWNER_NN" ] && [ "$NN" -eq "$((OWNER_NN + 1))" ] && [ "$SID" = "$OWNER_SID" ]; then
  if [ "$MATURITY" = "L1" ]; then
    echo "[vajra session-guard] one-session-per-chat: this chat owns session $OWNER_NN."
    echo "  Starting session $NN here breaks the rule — open a NEW chat. (L1 advise, not blocking.)"
    record
    exit 0
  fi
  {
    echo "[vajra session-guard] BLOCKED: this chat already owns session $OWNER_NN."
    echo "  One vajra-session per chat (AGENTS.md step 10). Start session $NN in a NEW chat:"
    echo "    open a fresh chat, then run: git checkout -b session-$NN-<slug>"
    echo "  (Set one_session_per_chat: false or maturity: L1 in CONSTRAINTS.yaml to override.)"
  } 1>&2
  exit 2
fi

# Same session re-checkout (same NN, same chat) or a fresh chat: allow + claim ownership.
record
exit 0
