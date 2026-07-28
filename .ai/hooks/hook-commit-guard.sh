#!/usr/bin/env bash
# PreToolUse(Bash): the un-forgeable teeth on `git commit` (S93 — no-autonomous-commit ENFORCED).
#
# The gap (S76 + S92 dogfoods): the agent self-stops at `commit.autonomous: false` only because
# it CHOOSES to — no hook checks for approval. The L2 `.githooks/pre-commit` belt does check
# (VAJRA_ALLOW_COMMIT==NN), but an agent controlling the command line can inline that env prefix,
# and `git commit --no-verify` skips the git hook entirely. This PreToolUse guard closes both:
#   - It reads its OWN launch environment for the approval marker. An inline
#     `VAJRA_ALLOW_COMMIT=NN git commit` typed by the agent never reaches this hook's env
#     (a child shell can't mutate the parent's env, and PreToolUse fires BEFORE the command
#     runs) — the same un-forgeability the publish-guard relies on (S37).
#   - It fires on the `git commit` tool call regardless of `--no-verify` (that flag skips git's
#     own hooks, not Claude Code's PreToolUse). So a bypass must beat BOTH layers.
#
# Approval signal: VAJRA_ALLOW_COMMIT must equal the current session number (parsed from the
# session-NN-* branch), set by the founder at launch (e.g. `VAJRA_ALLOW_COMMIT=93 vajra claude`).
# Session-scoped, mirroring VAJRA_CLOSEOUT_WAIVER (S56).
#
# Maturity-gated like every Vajra hook (S21): L1 -> ADVISE (exit 0); L2/L3 -> ENFORCE (exit 2).
# Test/override knob: VAJRA_GUARD_MATURITY overrides the maturity read from CONSTRAINTS.yaml.

set -euo pipefail

# ── Opt-in gate (mirrors the S47 publish-guard switch) ───────────────────────────────────────
# The guard ENFORCES only when EITHER VAJRA_ENFORCE_COMMIT=1 is set (explicit re-arm), OR
# .ai/CONSTRAINTS.yaml does NOT carry `commit_guard: off`. The vajra repo sets `commit_guard: off`
# because a live L3 block would brick the build agent's own commits (it cannot set its launch env
# mid-session) — the L2 belt governs this repo, and L3 is proven by payload test. The `vajra init`
# scaffold ships NO such line — the SAME byte-identical hook, gated by config — so every NEW
# project gets the un-forgeable guard ON. The switch lives in CONSTRAINTS, not the code: no drift.
_VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
_CG=$(grep -m1 '^[[:space:]]*commit_guard:[[:space:]]' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "")
if [ "${VAJRA_ENFORCE_COMMIT:-}" != "1" ] && [ "$_CG" = "off" ]; then
  exit 0
fi

# jq preflight — fail-closed (AGENTS.md L147: a check that cannot evaluate FAILS).
if ! command -v jq >/dev/null 2>&1; then
  _VMAT="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo L2)}"
  [ "$_VMAT" = "L1" ] && { echo "[vajra] jq not on PATH — enforcement degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"

# ── Repo-identity: govern only the project this hook belongs to (S94, closes the S52 blindspot) ─
# ROOT is the project this hook was scaffolded into. During a dogfood the agent runs `vajra claude`
# with cwd = a SUBJECT repo that may sit nested inside another git repo (e.g. a subject tree checked
# out under Vajra, which itself is on a session-NN-* branch). `git -C "$ROOT"` walks UP to the
# nearest .git, so when ROOT has no .git of its own it would read the ENCLOSING repo's branch and
# derive the wrong session number — authorizing (or mis-labelling) a commit against the wrong repo.
# Derive git facts from the project's OWN git repo only: require ROOT to BE the git top-level.
ROOT_REAL=$(cd "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")
GIT_TOP=$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null || echo "")
OWN_GIT=""
[ -n "$GIT_TOP" ] && [ "$GIT_TOP" = "$ROOT_REAL" ] && OWN_GIT="$ROOT_REAL"
# Human-readable identity, surfaced on every advise/block (AC2): a nested mis-fire is visible.
if [ -n "$OWN_GIT" ]; then
  GOVERNS="project $ROOT_REAL"
elif [ -n "$GIT_TOP" ]; then
  GOVERNS="project $ROOT_REAL (nested inside git repo $GIT_TOP — its branch is NOT this project's)"
else
  GOVERNS="project $ROOT_REAL (no git repo of its own)"
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
[ -n "$CMD" ] || exit 0

# Classify against the command with QUOTED SPANS REMOVED (the S39 over-block fix), so a trigger
# phrase buried in a message/arg (`echo "git commit"`, `--body "then git commit"`) can't
# false-block. A real invocation always places the command name OUTSIDE quotes.
SCAN=$(sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g" <<<"$CMD")

# Only `git commit` is guarded (not commit-tree, not status/log/diff). Here-string, not a pipe,
# so a short-circuiting grep -q can never SIGPIPE a producer under `set -o pipefail` (S32 gotcha).
grep -qE '(^|[^[:alnum:]_])git[[:space:]]+commit([^[:alnum:]]|$)' <<<"$SCAN" || exit 0

# Session number for this launch (from the session-NN-* branch OF THIS PROJECT'S OWN git repo —
# never an enclosing one, per the repo-identity block above). A commit off a session branch in the
# project's OWN repo is already policed elsewhere (pre-commit blocks main); if we can't resolve one
# THERE, fail-closed by requiring the marker to be simply non-empty below. A project with NO git of
# its own is a distinct, harder case handled by the cannot-evaluate gate.
BRANCH=""
[ -n "$OWN_GIT" ] && BRANCH=$(git -C "$OWN_GIT" symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")
SESS=""
[[ "$BRANCH" =~ ^session-([0-9]+)- ]] && SESS="${BASH_REMATCH[1]}"

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"

# Defend the "jurisdiction-self-granted" fakest-green (S69): if the agent tries to inline the
# marker in the command itself, that assignment sets the CHILD's env, never this hook's — but
# call it out explicitly rather than letting it look like it might have worked.
if grep -qE '(^|[^[:alnum:]_])VAJRA_ALLOW_COMMIT=' <<<"$SCAN"; then
  {
    echo "[vajra commit-guard] BLOCKED: VAJRA_ALLOW_COMMIT set INLINE in the command."
    echo "  Approval cannot be self-granted. This hook reads its OWN launch environment, which an"
    echo "  inline prefix never reaches. The founder must launch with the marker in the env."
  } 1>&2
  exit 2
fi

# Cannot-evaluate → fail-CLOSED (AGENTS.md: a check that cannot evaluate FAILS; never silently
# pass). If this project has NO git repo of its own (nested inside a different repo, S94), a
# `git commit` issued here mutates the ENCLOSING repo, and no marker can be bound to THIS project's
# session. Refuse regardless of marker — do NOT fall through to the "any non-empty marker" path
# below (which is only meant for the own-repo, non-session-branch case). The subject must run from
# its own git repo. This closes the S94 fail-open: pre-fix a foreign marker could authorize here.
if [ -z "$OWN_GIT" ]; then
  if [ "$MATURITY" = "L1" ]; then
    echo "[vajra commit-guard] git commit — L1 advise (not blocking). Governing $GOVERNS."
    echo "  This project has no git repo of its own; a commit here would mutate the enclosing repo."
    exit 0
  fi
  {
    echo "[vajra commit-guard] BLOCKED: no git repo of this project's own to approve against."
    echo "  Governing $GOVERNS."
    echo "  A 'git commit' here would mutate the ENCLOSING repo, and the founder marker cannot be"
    echo "  bound to this project's session — fail-closed. Run vajra from the subject's own git repo."
  } 1>&2
  exit 2
fi

# Explicit founder approval for this launch: the marker in THIS hook's env, session-scoped.
if [ -n "${VAJRA_ALLOW_COMMIT:-}" ] && { [ -z "$SESS" ] || [ "${VAJRA_ALLOW_COMMIT}" = "$SESS" ]; }; then
  echo "[vajra commit-guard] ALLOWED (git commit) — VAJRA_ALLOW_COMMIT=${VAJRA_ALLOW_COMMIT}. Governing $GOVERNS."
  exit 0
fi

if [ "$MATURITY" = "L1" ]; then
  echo "[vajra commit-guard] git commit — L1 advise (not blocking). Governing $GOVERNS."
  echo "  no-autonomous-commit: confirm explicit founder approval per .ai/AGENTS.md."
  exit 0
fi

{
  echo "[vajra commit-guard] BLOCKED: git commit without approval evidence."
  echo "  Governing $GOVERNS."
  echo "  no-autonomous-commit is ENFORCED (S93). A commit needs explicit founder approval,"
  echo "  supplied as an un-forgeable env marker set at launch (mirrors VAJRA_CLOSEOUT_WAIVER):"
  echo "      VAJRA_ALLOW_COMMIT=${SESS:-NN} vajra claude"
  echo "  To downgrade to advice: set maturity: L1 in .ai/CONSTRAINTS.yaml."
} 1>&2
exit 2
