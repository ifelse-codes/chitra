#!/usr/bin/env bash
# Fail-closed closeout gate. Exit 0 = closeout done.
# Single source of truth: .ai/SESSION (one integer).

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/closeout/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
ok()  { RESULTS+=("$(printf '%-34s %s' "$1" PASS)"); PASS=$((PASS+1)); }
bad() { RESULTS+=("$(printf '%-34s %s' "$1" FAIL)"); FAIL=$((FAIL+1)); }

N=""
check_session_file() {
  local NAME="session-file-valid"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ ! -f .ai/SESSION ]; then echo "BLOCK: .ai/SESSION missing" > "$LOG"; bad "$NAME"; return; fi
  local raw; raw="$(tr -d ' \t\n\r' < .ai/SESSION)"
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    N="$((10#$raw))"; echo "OK: $raw (N=$N)" > "$LOG"; ok "$NAME"
  else
    echo "BLOCK: not an integer: '$raw'" > "$LOG"; bad "$NAME"
  fi
}

check_required_files() {
  local NAME="required-files-exist"; local LOG="$ARTIFACTS/${NAME}.log"
  : > "$LOG"
  local missing=0
  for f in .ai/AGENTS.md .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md \
           .ai/STATE.md .ai/CONSTRAINTS.yaml .ai/KNOWLEDGE.md .ai/ROADMAP.md; do
    if [ -f "$f" ] && [ -s "$f" ]; then echo "OK: $f" >> "$LOG"
    else echo "MISSING/empty: $f" >> "$LOG"; missing=$((missing+1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_session_boot() {
  local NAME="session-boot-current"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/SESSION-BOOT.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local num; num="$(grep -m1 -E '\*\*Number:\*\*' "$F" | grep -oE '[0-9]+' | head -1)"
  if [ -z "$num" ]; then echo "BLOCK: no **Number:** integer in $F" > "$LOG"; bad "$NAME"; return; fi
  if [ "$((10#$num))" -eq "$N" ]; then
    echo "OK: SESSION-BOOT Number=$num == N=$N" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: SESSION-BOOT Number=$num != .ai/SESSION N=$N" > "$LOG"; bad "$NAME"
  fi
}

check_task_ref() {
  local NAME="task-ref-current"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/TASK.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  if grep -qiE "Session 0*${N}\b" "$F" || grep -qiE "Session ${padded}\b" "$F" \
     || grep -qiE "between sessions" "$F"; then
    echo "OK: TASK.md references Session $N (or 'between sessions')" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: TASK.md does not reference Session $N nor 'between sessions'" > "$LOG"; bad "$NAME"
  fi
}

check_state_sections() {
  local NAME="state-required-sections"; local LOG="$ARTIFACTS/${NAME}.log"
  local F=".ai/STATE.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  : > "$LOG"
  local missing=0
  for h in "What Currently Works" "What Is Broken" "What Is In Progress"; do
    if grep -q "$h" "$F"; then echo "OK: $h" >> "$LOG"
    else echo "MISSING section: $h" >> "$LOG"; missing=$((missing+1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_session_pair() {
  local NAME="session-prompt-summary-pair"; local LOG="$ARTIFACTS/${NAME}.log"
  shopt -s nullglob
  local summaries=(sessions/session-*-summary.md)
  local prompts=(prompts/[0-9]*-task-*.md)
  : > "$LOG"
  local missing=0
  if (( ${#summaries[@]} == 0 )); then echo "MISSING: no session summaries" >> "$LOG"; missing=$((missing+1)); fi
  if (( ${#prompts[@]} == 0 )); then echo "MISSING: no session prompts" >> "$LOG"; missing=$((missing+1)); fi
  for s in "${summaries[@]}"; do
    local base; base=$(basename "$s" -summary.md); local nn="${base#session-}"
    local matches=(prompts/${nn}-task-*.md)
    if (( ${#matches[@]} == 0 )); then
      echo "MISSING prompt for $s (expected prompts/${nn}-task-*.md)" >> "$LOG"
      missing=$((missing+1))
    else
      echo "OK: $s ↔ ${matches[0]}" >> "$LOG"
    fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_roadmap_current() {
  local NAME="roadmap-references-N"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/ROADMAP.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  if grep -qiE "Session 0*${N}\b" "$F" || grep -qiE "Session ${padded}\b" "$F"; then
    echo "OK: ROADMAP.md references Session $N" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: ROADMAP.md does not reference Session $N" > "$LOG"; bad "$NAME"
  fi
}

check_cost_tracking() {
  local NAME="cost-tracking-present"; local LOG="$ARTIFACTS/${NAME}.log"
  local F=".ai/STATE.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  if grep -q "Cost Tracking" "$F"; then
    echo "OK: STATE.md has Cost Tracking section" > "$LOG"; ok "$NAME"
  else
    echo "MISSING: STATE.md lacks Cost Tracking section" > "$LOG"; bad "$NAME"
  fi
}

# --- Execution-sha placeholder guard (S81) -----------------------------------
# Catches the S79 failure mode: a CODE session that closes with `step N — done: <sha>`
# placeholders still in its `## Execution` section. The Coder gate (src/coder/mod.rs)
# blocks a running session, but only if the closing `--advance` is invoked; verify-closeout.sh
# is the last line of defence for the session's own prompt file.
#
# Pattern: the literal string 'done: <sha>' (angle-bracket placeholder from the session
# template). Absent section → WARN only (backward-compat with pre-S68 prompts). Respects
# `VAJRA_CLOSEOUT_WAIVER` (same escape hatch as the fidelity gate — GT/NO-CODE sessions
# intentionally leave ## Execution unfilled).
check_execution_shas() {
  local NAME="execution-shas-filled"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  shopt -s nullglob
  local prompts; prompts=(prompts/${padded}-task-*.md)
  : > "$LOG"

  if (( ${#prompts[@]} == 0 )); then
    echo "N/A: no prompt file prompts/${padded}-task-*.md" >> "$LOG"; ok "$NAME"; return
  fi

  local F="${prompts[0]}"
  echo "prompt: $F" >> "$LOG"

  # Walk the prompt; collect lines in ## Execution that still say 'done: <sha>'.
  local in_exec=0 has_exec=0
  local bad_lines=() count=0
  while IFS= read -r line; do
    local lline; lline="$(echo "$line" | tr '[:upper:]' '[:lower:]')"
    if [[ "$lline" =~ ^#{1,6}[[:space:]] ]]; then
      local first_word; first_word="$(echo "$lline" | sed 's/^#* *//' | awk '{print $1}')"
      if [ "$first_word" = "execution" ]; then
        in_exec=1; has_exec=1
      else
        in_exec=0
      fi
      continue
    fi
    if [[ "$in_exec" -eq 1 ]]; then
      if echo "$line" | grep -qF 'done: <sha>'; then
        bad_lines+=("  $line"); count=$((count+1))
      fi
    fi
  done < "$F"

  if [[ "$has_exec" -eq 0 ]]; then
    echo "WARN: no ## Execution section (pre-S68 prompt — backward-compat WARN only, not a block)" >> "$LOG"
    ok "$NAME"; return
  fi

  if [[ "$count" -eq 0 ]]; then
    echo "OK: no 'done: <sha>' placeholders in ## Execution" >> "$LOG"; ok "$NAME"; return
  fi

  for bl in "${bad_lines[@]}"; do echo "PLACEHOLDER:$bl" >> "$LOG"; done
  echo "BLOCK: $count step(s) in $F still have 'done: <sha>' placeholder(s)" >> "$LOG"

  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"
    ok "$NAME"
  else
    echo "FAIL: fill every 'done: <sha>' in ## Execution with the landing commit sha," >> "$LOG"
    echo "      or set VAJRA_CLOSEOUT_WAIVER=$N (GT / NO-CODE sessions only)." >> "$LOG"
    bad "$NAME"
  fi
}

# --- Verify/Demo script-presence guard (S98 follow-up — the step-5 gap) ------
# Catches the S98 miss: a CODE session that closes WITHOUT its own
# scripts/verify-session-NN.sh + demo-session-NN.sh. Every CODE session carries
# both (Session Loop step 5, VERIFY + DEMO). The QA / Demo-er gates in `vajra next`
# only RE-RUN them at the FOLLOWING --advance and merely WARN when absent (legacy /
# NO-CODE pass), so a forgotten script slips through a green closeout unnoticed —
# which is exactly how S98 shipped scriptless. This is the last line of defence for
# the session's OWN scripts, at its own close.
#
# Exempt (both mirror how the exec-sha + fidelity gates already treat non-CODE work):
#   * NO-CODE ground-truth (N % 5 == 0) — no code, no scripts — passes N/A.
#   * DOGFOOD / founder-waived (VAJRA_CLOSEOUT_WAIVER=N) — a dogfood produces no
#     session scripts; the same escape hatch the other gates use — passes WAIVED.
# Everything else is a CODE session and must have BOTH scripts (non-empty).
check_verify_demo_scripts() {
  local NAME="verify-demo-scripts-present"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  : > "$LOG"

  if [ "$((N % 5))" -eq 0 ]; then
    echo "N/A: session $N is a NO-CODE ground-truth (N % 5 == 0) — no session scripts expected." >> "$LOG"
    ok "$NAME"; return
  fi

  local V="scripts/verify-session-${N}.sh"
  local D="scripts/demo-session-${N}.sh"
  local missing=()
  { [ -f "$V" ] && [ -s "$V" ]; } || missing+=("$V")
  { [ -f "$D" ] && [ -s "$D" ]; } || missing+=("$D")

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "OK: $V + $D both present and non-empty." >> "$LOG"; ok "$NAME"; return
  fi

  for m in "${missing[@]}"; do echo "MISSING: $m" >> "$LOG"; done
  echo "BLOCK: session $N is a CODE session but is missing the step-5 script(s) above." >> "$LOG"
  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>} (DOGFOOD / NO-CODE — no scripts)." >> "$LOG"
    ok "$NAME"
  else
    echo "FAIL: add scripts/verify-session-${N}.sh + scripts/demo-session-${N}.sh (step 5, VERIFY + DEMO)," >> "$LOG"
    echo "      or set VAJRA_CLOSEOUT_WAIVER=$N for a DOGFOOD / NO-CODE session that produces none." >> "$LOG"
    bad "$NAME"
  fi
}

# --- Fidelity gate (S56 — DECISION-002 teeth) -------------------------------
# Un-forgeable waiver: a founder-controlled env var, NOT a text marker the agent
# can Write into a tracked file. Mirrors VAJRA_ALLOW_PUBLISH (S37). Session-scoped:
# VAJRA_CLOSEOUT_WAIVER must equal N (a stale waiver for another session does not apply).
waiver_ok() { [ -n "${VAJRA_CLOSEOUT_WAIVER:-}" ] && [ "${VAJRA_CLOSEOUT_WAIVER}" = "$N" ]; }

# Closeout structurally requires an INDEPENDENT fidelity review (reviewer/SKILL.md).
# It must (1) exist, (2) be real — a per-requirement verdict table (SHIPPED/PARTIAL/
# NOT-BUILT) + a canonical "**Verdict:** ACCEPT|REJECT" line — not merely present, and
# (3) resolve to ACCEPT. Missing / incomplete / REJECT FAILS closeout unless waived.
check_fidelity_review() {
  local NAME="fidelity-review-accept"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F="sessions/session-${N}-review.md"
  : > "$LOG"

  # (1) Require the artifact.
  if [ ! -f "$F" ] || [ ! -s "$F" ]; then
    echo "MISSING: $F — an independent fidelity review is required (DECISION-002)." >> "$LOG"
    if waiver_ok; then
      echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
    else
      echo "FAIL: supply sessions/session-${N}-review.md (cold pass) or a founder waiver (VAJRA_CLOSEOUT_WAIVER=$N)." >> "$LOG"; bad "$NAME"
    fi
    return
  fi

  # (2) Real, not present: per-requirement verdict TABLE + a canonical overall verdict.
  # Count verdict tokens only inside table rows (lines containing '|') so three verdict
  # WORDS scattered in prose don't fake a table — the gate must not ship the soft-proxy
  # disease it exists to kill (S56 self-review finding).
  local tokens overall complete=1
  tokens=$(grep -E '\|' "$F" | grep -oiE 'SHIPPED|PARTIAL|NOT-BUILT' | wc -l | tr -d ' ') || true
  overall=$(grep -iE '^[*_[:space:]]*(overall[[:space:]]+|final[[:space:]]+)?verdict[*_[:space:]]*:' "$F" \
            | grep -ioE 'ACCEPT|REJECT' | head -1 | tr '[:lower:]' '[:upper:]') || true
  echo "per-requirement verdict rows (in-table): ${tokens:-0}" >> "$LOG"
  echo "canonical overall verdict: ${overall:-<none>}" >> "$LOG"

  if [ "${tokens:-0}" -lt 3 ]; then
    echo "INCOMPLETE: fewer than 3 in-table per-requirement verdicts — not a real acceptance table." >> "$LOG"; complete=0
  fi
  if [ -z "$overall" ]; then
    echo "INCOMPLETE: no canonical '**Verdict:** ACCEPT|REJECT' line (heading-grep is not a verdict)." >> "$LOG"; complete=0
  fi

  # (3) ACCEPT passes; missing verdict, incomplete table, or REJECT fails unless waived.
  if [ "$complete" -eq 1 ] && [ "$overall" = "ACCEPT" ]; then
    echo "OK: independent review present, complete (${tokens} verdicts), Verdict=ACCEPT." >> "$LOG"; ok "$NAME"; return
  fi
  [ "$complete" -eq 0 ] && echo "BLOCK: review is present but incomplete (not real, only present)." >> "$LOG"
  [ "$overall" = "REJECT" ] && echo "BLOCK: review Verdict=REJECT — delivery does not match the prompt." >> "$LOG"
  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
  else
    echo "FAIL: closeout blocked — ship an ACCEPT review (fix the gaps) or record a founder waiver (VAJRA_CLOSEOUT_WAIVER=$N)." >> "$LOG"; bad "$NAME"
  fi
}

# --- Verdict-authorship attestation (S58 — DECISION-003) --------------------
# check_fidelity_review proves the review's SHAPE + the WAIVER's authorship, but not
# the VERDICT's authorship: a builder can hand-write its own `**Verdict:** ACCEPT`.
# The attestation binds an ACCEPT to a hash of the exact COLD INPUTS the reviewer is
# fed — the contract prompt + the delivery diff — recomputed here from the repo. A
# stale / recycled / delivery-decoupled ACCEPT no longer matches and FAILS.
#
# HONEST LIMIT (do NOT overclaim): the same agent can run `--inputs-sha` and paste the
# hash, so this is BAR-RAISING, not tamper-proof. It kills a review recycled from
# another session, one written against an earlier diff (freshness), and one decoupled
# from what actually shipped — it does NOT prove a different mind authored the verdict.

# Portable SHA-256 (Linux `sha256sum` / macOS `shasum -a 256`). Empty => uncomputable.
_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum | awk '{print $1}'
  elif command -v shasum   >/dev/null 2>&1; then shasum -a 256 | awk '{print $1}'
  else return 1; fi
}

# The canonical cold inputs, hashed by ONE function used by BOTH the emit side
# (`--inputs-sha`, what the reviewer embeds) and the verify side (check_review_
# attestation) — so normalization can never drift between them.
#   inputs = <prompt file bytes> \0 <delivery diff bytes>
# Delivery diff = committed changes vs the branch point (merge-base with main),
# EXCLUDING everything authored/synced at or after the review (so the hash is stable
# from emit-time to closeout-time): sessions/, the closeout-synced .ai/* files, and
# the gate's own timestamped verify artifacts. Prints the hash, or nothing if it
# cannot be computed (no prompt / no git / no sha tool) — the caller fails closed.
canonical_inputs_sha() {
  [ -n "$N" ] || return 1
  local padded; padded="$(printf '%02d' "$N")"
  shopt -s nullglob
  local prompts=(prompts/${padded}-task-*.md)
  (( ${#prompts[@]} == 1 )) || return 1          # 0 or >1 contract => uncomputable
  local base
  base="$(git merge-base main HEAD 2>/dev/null)" || return 1
  [ -n "$base" ] || return 1
  local diff
  diff="$(git diff --no-color --no-ext-diff "$base" HEAD -- \
            ':(exclude)sessions' ':(exclude)prompts' \
            ':(exclude).ai/STATE.md' ':(exclude).ai/SESSION-BOOT.md' \
            ':(exclude).ai/SESSION' ':(exclude).ai/TASK.md' \
            ':(exclude).ai/ROADMAP.md' ':(exclude).ai/KNOWLEDGE.md' \
            ':(exclude).ai/verify' ':(exclude).ai/.session-owner' 2>/dev/null)" || return 1
  # Read the prompt as COMMITTED at HEAD (`git show`), never the live working-tree file
  # (`cat`) — an uncommitted stray edit to the prompt must not silently change the hash about
  # to be embedded/verified (S88). Pre-check existence with `cat-file -e` so a missing blob
  # fails closed via `return 1`, same as every other guard in this function; only then stream
  # `git show` directly into the hash pipe (not through `$(...)`, which would strip the
  # blob's trailing newline and desync from the Rust side's byte-exact preimage).
  git cat-file -e "HEAD:${prompts[0]}" 2>/dev/null || return 1
  { git show "HEAD:${prompts[0]}"; printf '\0'; printf '%s' "$diff"; } | _sha256
}

# Require + verify the input-attestation on an ACCEPT review. Orthogonal to
# check_fidelity_review: a missing / non-ACCEPT review is N/A here (that outcome is
# owned by the fidelity check — no double-jeopardy). An ACCEPT with a missing, forged,
# or uncomputable-and-mismatched attestation FAILS, behind the same founder waiver.
check_review_attestation() {
  local NAME="review-inputs-attested"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F="sessions/session-${N}-review.md"
  : > "$LOG"

  if [ ! -f "$F" ] || [ ! -s "$F" ]; then
    echo "N/A: no review file — outcome owned by fidelity-review-accept." >> "$LOG"; ok "$NAME"; return
  fi
  local overall
  overall=$(grep -iE '^[*_[:space:]]*(overall[[:space:]]+|final[[:space:]]+)?verdict[*_[:space:]]*:' "$F" \
            | grep -ioE 'ACCEPT|REJECT' | head -1 | tr '[:lower:]' '[:upper:]') || true
  if [ "$overall" != "ACCEPT" ]; then
    echo "N/A: verdict is ${overall:-<none>} (attestation only gates an ACCEPT)." >> "$LOG"; ok "$NAME"; return
  fi

  local claimed expected
  claimed=$(grep -m1 -iE '^[*_[:space:]]*Review-Inputs-SHA[*_[:space:]]*:' "$F" \
            | grep -oiE '[0-9a-f]{64}' | head -1 | tr '[:upper:]' '[:lower:]') || true
  expected=$(canonical_inputs_sha 2>/dev/null) || true
  echo "claimed:  ${claimed:-<none>}" >> "$LOG"
  echo "expected: ${expected:-<uncomputable>}" >> "$LOG"

  if [ -n "$claimed" ] && [ -n "$expected" ] && [ "$claimed" = "$expected" ]; then
    echo "OK: ACCEPT attestation matches the canonical cold-input hash." >> "$LOG"; ok "$NAME"; return
  fi
  [ -z "$claimed" ]   && echo "BLOCK: ACCEPT with no **Review-Inputs-SHA:** attestation." >> "$LOG"
  [ -z "$expected" ]  && echo "BLOCK: canonical input hash uncomputable (a check that cannot evaluate FAILS)." >> "$LOG"
  { [ -n "$claimed" ] && [ -n "$expected" ] && [ "$claimed" != "$expected" ]; } \
    && echo "BLOCK: attestation MISMATCH — the ACCEPT is stale/recycled/decoupled from the delivered diff." >> "$LOG"
  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
  else
    echo "FAIL: re-run the cold review and embed a matching **Review-Inputs-SHA:** (\`verify-closeout.sh --inputs-sha $N\`), or record a founder waiver." >> "$LOG"; bad "$NAME"
  fi
}

# --- The attested-verdict delta ledger (S59 — DECISION-004) -----------------
# A DERIVED, regenerable view over sessions/session-*-review.md + git — NOT a new
# source of truth (feedback-distill-no-drift). Each session that carries a review
# contributes one record; records are hash-chained so a SINGLE head hash fingerprints
# the entire ordered verdict history. Editing any past verdict moves the head, and the
# worktree chain stops matching the committed chain → detectable.
#
# HONEST LIMIT (do NOT overclaim): tamper-EVIDENT, not tamper-PROOF. A change is
# *detectable* (the head moves; git shows the file diff), but a determined in-repo
# editor can flip a verdict AND recompute every downstream record_hash AND rewrite
# committed history (force-push). Nothing here is an out-of-band anchor — closing that
# needs a signer (S59-C). The ledger's verdict/sha extraction uses the SAME patterns as
# the fidelity gate (check_fidelity_review / check_review_attestation) — hand-synced,
# byte-identical today, not yet a single shared helper (a future refactor): a review with
# no canonical `**Verdict:**` line records verdict=NONE, an un-attested one records attested=no.

LEDGER_GENESIS="0000000000000000000000000000000000000000000000000000000000000000"
LEDGER_HEAD=""

# Canonical verdict from a review's content on stdin — the SAME strict pattern the
# fidelity gate uses (heading-greps are not verdicts). Prints ACCEPT|REJECT (empty=NONE).
_ledger_verdict_of() {
  grep -iE '^[*_[:space:]]*(overall[[:space:]]+|final[[:space:]]+)?verdict[*_[:space:]]*:' \
    | grep -ioE 'ACCEPT|REJECT' | head -1 | tr '[:lower:]' '[:upper:]'
}
# Attested input-sha from a review's content on stdin — same pattern as check_review_attestation.
_ledger_sha_of() {
  grep -m1 -iE '^[*_[:space:]]*Review-Inputs-SHA[*_[:space:]]*:' \
    | grep -oiE '[0-9a-f]{64}' | head -1 | tr '[:upper:]' '[:lower:]'
}
# Session numbers (ascending) whose review is COMMITTED at HEAD / present in the WORKTREE.
_ledger_committed_sessions() {
  git ls-tree -r --name-only HEAD -- sessions 2>/dev/null \
    | sed -n 's#^sessions/session-\([0-9][0-9]*\)-review\.md$#\1#p' | sort -n -u
}
_ledger_worktree_sessions() {
  ls sessions/session-*-review.md 2>/dev/null \
    | sed -n 's#^sessions/session-\([0-9][0-9]*\)-review\.md$#\1#p' | sort -n -u
}
# Read one review's content from a source: "committed" (blob at HEAD) | worktree (file).
# A missing source (a committed review DELETED from the worktree, or a not-yet-committed
# review) yields EMPTY, never a failure — so under `set -e` the caller keeps going and a
# deletion surfaces as verdict=NONE (a divergent record), not a silent mid-loop crash.
_ledger_read() {
  case "$1" in
    committed) git show "HEAD:sessions/session-$2-review.md" 2>/dev/null || true ;;
    *)         cat "sessions/session-$2-review.md" 2>/dev/null || true ;;
  esac
}
# record_hash = sha256( prior_hash \0 N \0 verdict \0 input_sha ). NUL-separated preimage
# (unambiguous concatenation). prior_hash of the first record is LEDGER_GENESIS.
_ledger_record_hash() { printf '%s\0%s\0%s\0%s' "$1" "$2" "$3" "$4" | _sha256; }

# Build + print the ledger table from a source over a newline session list; sets LEDGER_HEAD.
build_ledger() {
  local source="$1" list="$2" prior="$LEDGER_GENESIS" n content v s att rec
  printf '%-5s  %-7s  %-8s  %s\n' "SESS" "VERDICT" "ATTESTED" "RECORD-HASH (chained)"
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    content="$(_ledger_read "$source" "$n")"
    v="$(printf '%s' "$content" | _ledger_verdict_of || true)"; v="${v:-NONE}"
    s="$(printf '%s' "$content" | _ledger_sha_of || true)"
    if [ -n "$s" ]; then att="yes"; else att="no"; fi
    rec="$(_ledger_record_hash "$prior" "$n" "$v" "$s")" || return 1
    printf '%-5s  %-7s  %-8s  %s\n' "S$n" "$v" "$att" "$rec"
    prior="$rec"
  done <<< "$list"
  LEDGER_HEAD="$prior"
}

# Print the canonical cold-input hash the reviewer must embed. `--inputs-sha [N]`.
if [ "${1:-}" = "--inputs-sha" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file >/dev/null 2>&1; fi
  if H=$(canonical_inputs_sha); then echo "$H"; exit 0; else
    echo "ERROR: canonical input hash uncomputable (need a single prompts/NN-task-*.md, git, and a sha tool)." >&2; exit 1
  fi
fi

# Focused entry point: run ONLY the fidelity gate against an explicit or resolved N.
# Used by verify-session-56.sh and the S54 dogfood (`--fidelity-only 54`).
# S58: --fidelity-only keeps its S56 meaning (shape/verdict/waiver only) so prior
# harnesses stay green; the attestation has its own focused entry (`--attest-only`).
if [ "${1:-}" = "--fidelity-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_fidelity_review
  echo ""
  echo "=== Fidelity gate (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/fidelity-review-accept.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "FIDELITY: PASS"; exit 0; else echo "FIDELITY: FAIL"; exit 1; fi
fi

# Focused entry point: run ONLY the execution-sha placeholder check (S81). `--check-exec-shas [N]`.
if [ "${1:-}" = "--check-exec-shas" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_execution_shas
  echo ""
  echo "=== Execution-sha check (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/execution-shas-filled.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "EXEC-SHAS: PASS"; exit 0; else echo "EXEC-SHAS: FAIL"; exit 1; fi
fi

# Focused entry point: run ONLY the verify/demo script-presence check (S98). `--scripts-only [N]`.
if [ "${1:-}" = "--scripts-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_verify_demo_scripts
  echo ""
  echo "=== Verify/Demo script-presence check (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/verify-demo-scripts-present.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "SCRIPTS: PASS"; exit 0; else echo "SCRIPTS: FAIL"; exit 1; fi
fi

# Focused entry point: run ONLY the verdict-attestation check (S58). `--attest-only [N]`.
if [ "${1:-}" = "--attest-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_review_attestation
  echo ""
  echo "=== Attestation gate (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/review-inputs-attested.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "ATTEST: PASS"; exit 0; else echo "ATTEST: FAIL"; exit 1; fi
fi

# Build + print the ledger as a glanceable table (derived view). `--ledger`.
if [ "${1:-}" = "--ledger" ]; then
  list="$(_ledger_worktree_sessions)"
  echo "=== Vajra attested-verdict delta ledger (derived view over sessions/*-review.md + git) ==="
  build_ledger worktree "$list"
  echo "------------------------------------------------------------------------------------------"
  echo "chain head : ${LEDGER_HEAD:-<empty>}"
  echo "genesis    : $LEDGER_GENESIS"
  echo "records    : $(printf '%s\n' "$list" | grep -c . || true)"
  echo "guarantee  : tamper-EVIDENT (edit any past verdict → head moves; git shows the diff),"
  echo "             NOT tamper-proof (a determined editor rewrites the chain + history). DECISION-004"
  exit 0
fi

# Recompute the chain over COMMITTED sessions from (a) the worktree and (b) the blobs
# at HEAD; the first record that differs is a tampered/edited/deleted past review.
# `--ledger-verify` — exits 0 (intact) / 1 (tamper detected).
if [ "${1:-}" = "--ledger-verify" ]; then
  csess="$(_ledger_committed_sessions)"
  prior_wt="$LEDGER_GENESIS"; prior_ct="$LEDGER_GENESIS"; diverged=""
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    wt="$(_ledger_read worktree "$n")"; ct="$(_ledger_read committed "$n")"
    vwt="$(printf '%s' "$wt" | _ledger_verdict_of || true)"; vwt="${vwt:-NONE}"
    swt="$(printf '%s' "$wt" | _ledger_sha_of || true)"
    vct="$(printf '%s' "$ct" | _ledger_verdict_of || true)"; vct="${vct:-NONE}"
    sct="$(printf '%s' "$ct" | _ledger_sha_of || true)"
    rwt="$(_ledger_record_hash "$prior_wt" "$n" "$vwt" "$swt")"
    rct="$(_ledger_record_hash "$prior_ct" "$n" "$vct" "$sct")"
    if [ "$rwt" != "$rct" ] && [ -z "$diverged" ]; then diverged="$n"; fi
    prior_wt="$rwt"; prior_ct="$rct"
  done <<< "$csess"
  echo "=== Ledger chain-verify (worktree vs committed HEAD) ==="
  echo "committed head : ${prior_ct}"
  echo "worktree  head : ${prior_wt}"
  if [ "$prior_wt" = "$prior_ct" ]; then
    echo "LEDGER: INTACT — every committed verdict record matches the worktree."; exit 0
  else
    echo "LEDGER: TAMPER DETECTED — first divergent session: S${diverged:-?} (a past verdict/attestation changed)."; exit 1
  fi
fi

check_session_file
check_required_files
check_session_boot
check_task_ref
check_state_sections
check_session_pair
check_roadmap_current
check_cost_tracking
check_execution_shas
check_verify_demo_scripts
check_fidelity_review
check_review_attestation

( cd ".ai/verify/closeout" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Closeout Verify Summary (N=${N:-?}) ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
echo "Artifacts: $ARTIFACTS"

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail) — closeout is done."; exit 0
else
  echo "RED ($PASS pass, $FAIL fail) — closeout NOT done."; exit 1
fi
