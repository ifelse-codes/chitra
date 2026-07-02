#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit|Bash): the Varta co-pilot loader.
#
# Fires ⚡on(cond) ⚡include "files" from .ai/CONSTRAINTS.yaml#copilot.on the moment the
# agent touches matching work — surfacing the right context at the right corner, not all up front.
#
# Maturity-gated (this is the enforce-vs-advise gate, S21):
#   L1    -> ADVISE  : print the load to stdout, exit 0 (agent may ignore).
#   L2/L3 -> ENFORCE : print the load to stderr, exit 2 (tool blocked until the agent reckons with it).
# Per-session debounce: each rule fires once per session (keyed by session_id), not on every edit.
#
# Test/override knob: VAJRA_COPILOT_STATE_DIR sets the debounce dir (used by verify-session-21.sh).

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"
[ -f "$CONSTRAINTS" ] || exit 0

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' 2>/dev/null || echo "")
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
SID=$(echo "$INPUT" | jq -r '.session_id // "nosession"' 2>/dev/null || echo "nosession")

# Repo-relative path, so rules can be written relative to the project root.
REL="$FILE"
case "$FILE" in
  "$ROOT"/*) REL="${FILE#"$ROOT"/}" ;;
esac

MATURITY=$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")
STATE_DIR="${VAJRA_COPILOT_STATE_DIR:-${TMPDIR:-/tmp}/vajra-copilot/$SID}"
mkdir -p "$STATE_DIR" 2>/dev/null || true

# Pull the rules: lines shaped   - "PATTERN => files | why"   (comment lines start with #, never matched).
RULES=$(grep -E '^[[:space:]]*-[[:space:]]*".*=>.*"' "$CONSTRAINTS" 2>/dev/null || true)
[ -n "$RULES" ] || exit 0

# Fire one rule: emit the include list, honor maturity + debounce.
fire() {
  local pattern="$1" includes="$2" why="$3"
  local id marker
  id=$(printf '%s' "$pattern" | cksum | awk '{print $1}')
  marker="$STATE_DIR/$id"
  [ -e "$marker" ] && return 0           # debounced — this rule already fired this session
  : > "$marker"

  local list="" f
  local OLDIFS="$IFS"; IFS=','
  for f in $includes; do
    f="$(echo "$f" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -n "$f" ] && list="${list}    - ${f}"$'\n'
  done
  IFS="$OLDIFS"

  if [ "$MATURITY" = "L1" ]; then
    echo "[vajra co-pilot] ⚡on($pattern) — consider loading:"
    printf '%s' "$list"
    echo "  why: $why"
    return 0
  fi

  {
    echo "[vajra co-pilot] ⚡on($pattern) fired — load these before continuing:"
    printf '%s' "$list"
    echo "  why: $why"
    echo "  Open them, then retry. (Set maturity: L1 in CONSTRAINTS.yaml for advisory-only.)"
  } 1>&2
  exit 2
}

# `<<<` keeps the loop in the current shell, so `fire`'s `exit 2` exits the hook (not a subshell).
while IFS= read -r line; do
  [ -n "$line" ] || continue
  inner="$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]*"(.*)"[[:space:]]*$/\1/')"
  pattern="$(echo "$inner" | sed -E 's/[[:space:]]*=>.*//')"
  rhs="$(echo "$inner" | sed -E 's/^[^=]*=>[[:space:]]*//')"
  includes="$(echo "$rhs" | sed -E 's/[[:space:]]*\|.*//')"
  why="$(echo "$rhs" | sed -E 's/^[^|]*\|[[:space:]]*//')"

  case "$pattern" in
    cmd:*)
      sub="${pattern#cmd:}"
      [ -n "$CMD" ] && [[ "$CMD" == *"$sub"* ]] && fire "$pattern" "$includes" "$why"
      ;;
    *)
      # shellcheck disable=SC2053  # intentional glob match against $pattern
      [ -n "$REL" ] && [[ "$REL" == $pattern ]] && fire "$pattern" "$includes" "$why"
      ;;
  esac
done <<< "$RULES"

exit 0
