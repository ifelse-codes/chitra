#!/usr/bin/env bash
# SessionStart hook: prints mandatory load-order files. Non-blocking.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "=== Vajra Agent Boot (per .ai/AGENTS.md) ==="
echo ""

# Darshan enforcement (S32): surface the speaking skill IN the boot packet so it
# loads every session (was only a prose row in AGENTS.md the agent skipped — S31 #1).
# The one rule is inlined so it governs even if the file is never opened; speak-back
# makes it stick (mirrors Varta's read->internalize->speak ritual). Advised -> enforced.
echo "┌─ SPEAKING SKILL · DARSHAN (default human output, every reply) ─┐"
echo "│ ONE RULE: render the richest visual this surface can handle ·  │"
echo "│ always glanceable · never drop meaning.                       │"
echo "│ Tiers: rich chat (HTML/SVG) · terminal (ANSI/box) · plain md.  │"
echo "│ Full skill: darshan/SKILL.md                                   │"
echo "│ ▶ ACK NOW: open your FIRST reply in Darshan form (a glance /   │"
echo "│   verdict / table), not a wall of prose.                      │"
echo "└───────────────────────────────────────────────────────────────┘"
echo ""

for f in .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md .ai/STATE.md .ai/CONSTRAINTS.yaml; do
  if [ -f "$ROOT/$f" ]; then
    echo "----- $f -----"
    cat "$ROOT/$f"
    echo ""
  else
    echo "[hook warn] missing: $f" >&2
  fi
done

BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
echo "Current branch: $BRANCH"

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo ""
  echo "[REMINDER] On $BRANCH. Branch session-NN-<slug> before any work."
fi

case "$BRANCH" in
  *-closeout|*-enforcement) : ;;
  *)
    SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SESSION_NUM" =~ ^[0-9]+$ ]] && [ "$((10#$SESSION_NUM))" -gt 0 ]; then
      if [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
        echo ""
        echo "[REMINDER] Session $SESSION_NUM is GROUND TRUTH. No code, no commits, no PRs."
      fi
    fi
  ;;
esac

exit 0
