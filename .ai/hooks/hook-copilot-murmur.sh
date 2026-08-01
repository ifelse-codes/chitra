#!/usr/bin/env bash
# UserPromptSubmit: the Varta co-pilot MURMUR — proactive, non-blocking guidance (S47, direction B).
#
# The PreToolUse loader (hook-copilot-loader.sh) surfaces copilot.on context REACTIVELY, by
# BLOCKING the moment the agent touches matching work. The murmur is the missing half:
# each user turn it looks at what is already in play (the working-tree changes) and MURMURS the
# most relevant copilot.on context to stdout — injected into the agent's context so it has the
# right context BEFORE it acts, not only after it trips a guard. Fewer wrong turns = less re-work.
#
# Posture: ADVISORY AT EVERY MATURITY. This hook GUIDES; it never blocks. Always exit 0.
#   (Enforcement is the loader's job — this is the direction-B co-pilot lane. Maturity may tune
#   verbosity later, but the murmur must never block.)
# Signal: files changed in the working tree (git status --porcelain). A user turn carries no
#   tool_input.command, so cmd:* rules are skipped here — only path-glob rules can murmur.
# Per-session debounce: each rule murmurs once per session (keyed by session_id), not every turn.
#
# Test/override knob: VAJRA_COPILOT_STATE_DIR sets the debounce dir (shared base with the loader;
#   murmur markers are prefixed `murmur-` so the two layers never cross-cancel).

set -euo pipefail

# jq preflight — INVERTED from the fail-closed family. The murmur is guidance, and guidance that
# cannot evaluate simply stays quiet (exit 0). It must never block, so a missing jq degrades to
# silence, not a hard stop.
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"
[ -f "$CONSTRAINTS" ] || exit 0

# ── Repo-identity: read the working tree of THIS project only (S94, closes the S52 blindspot) ──
# During a dogfood ROOT (the subject repo) can sit nested inside another git repo. `git status` in
# ROOT walks UP to the nearest .git, so a plain-dir ROOT would list the ENCLOSING repo's changes and
# murmur about the wrong project. Read git only when ROOT is its OWN git top-level; else stay quiet.
ROOT_REAL=$(cd "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")
GIT_TOP=$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null || echo "")
OWN_GIT=""
[ -n "$GIT_TOP" ] && [ "$GIT_TOP" = "$ROOT_REAL" ] && OWN_GIT="$ROOT_REAL"

SID=$(echo "$INPUT" | jq -r '.session_id // "nosession"' 2>/dev/null || echo "nosession")

# Current-work signal: the files already in play this session (working-tree changes), repo-relative.
# `--untracked-files=all` lists individual new files (not a collapsed `dir/`, which would over-match
# a `dir/*` glob on mere existence). Columns are fixed — status in cols 1-2, path from col 4 — so
# `cut -c4-` keeps paths that contain spaces intact (unlike a whitespace split).
CHANGED=""
[ -n "$OWN_GIT" ] && CHANGED=$(git -C "$OWN_GIT" status --porcelain --untracked-files=all 2>/dev/null | cut -c4- || true)
[ -n "$CHANGED" ] || exit 0     # nothing in play (or not this project's own git) — stay quiet

STATE_DIR="${VAJRA_COPILOT_STATE_DIR:-${TMPDIR:-/tmp}/vajra-copilot/$SID}"
mkdir -p "$STATE_DIR" 2>/dev/null || true

# Pull the rules: lines shaped   - "PATTERN => files | why"   (comment lines start with #, never matched).
RULES=$(grep -E '^[[:space:]]*-[[:space:]]*".*=>.*"' "$CONSTRAINTS" 2>/dev/null || true)
[ -n "$RULES" ] || exit 0

# Murmur one rule: advisory (stdout, exit 0), once per session.
murmur() {
  local pattern="$1" includes="$2" why="$3"
  local id marker
  id=$(printf '%s' "$pattern" | cksum | awk '{print $1}')
  marker="$STATE_DIR/murmur-$id"
  [ -e "$marker" ] && return 0           # debounced — already murmured this rule this session
  : > "$marker"

  local list="" f
  local OLDIFS="$IFS"; IFS=','
  for f in $includes; do
    f="$(echo "$f" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -n "$f" ] && list="${list}    - ${f}"$'\n'
  done
  IFS="$OLDIFS"

  echo "[vajra co-pilot · murmur] you're working in ⚡on($pattern) — worth loading now:"
  printf '%s' "$list"
  echo "  why: $why"
}

# `<<<` keeps the loop in the current shell (consistency with the loader; no exit crosses a subshell).
while IFS= read -r line; do
  [ -n "$line" ] || continue
  inner="$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]*"(.*)"[[:space:]]*$/\1/')"
  pattern="$(echo "$inner" | sed -E 's/[[:space:]]*=>.*//')"
  rhs="$(echo "$inner" | sed -E 's/^[^=]*=>[[:space:]]*//')"
  includes="$(echo "$rhs" | sed -E 's/[[:space:]]*\|.*//')"
  why="$(echo "$rhs" | sed -E 's/^[^|]*\|[[:space:]]*//')"

  case "$pattern" in
    cmd:*)
      : ;;   # no command context on a user turn — cmd:* rules stay the loader's job
    *)
      # Murmur if ANY changed file matches this path glob.
      while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        # shellcheck disable=SC2053  # intentional glob match against $pattern
        if [[ "$rel" == $pattern ]]; then
          murmur "$pattern" "$includes" "$why"
          break
        fi
      done <<< "$CHANGED"
      ;;
  esac
done <<< "$RULES"

exit 0
