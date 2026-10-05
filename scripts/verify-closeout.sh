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
  if ! grep -q "Cost Tracking" "$F"; then
    echo "MISSING: STATE.md lacks Cost Tracking section" > "$LOG"; bad "$NAME"; return
  fi
  # S47 (S40 row 8, S45 H2): a heading is not a measurement — and neither is a
  # keyword. Pass 2's fakest green was a 633-char block with ZERO digits that
  # passed on `decision|commit|deriv` word-presence while the OK line claimed
  # counts it had never read. The contract names five counts, so each must have a
  # NUMBER within 60 chars of the word, and the OK line says only what was read.
  # Counterfactuals: heading-only → red (length); zero-digit prose → red (this).
  local section
  section="$(awk '/Cost Tracking/{f=1} f' "$F")"
  if [ "${#section}" -lt 200 ]; then
    echo "BLOCK: Cost Tracking section is a heading with no measurement (${#section} chars)." >> "$LOG"; bad "$NAME"; return
  fi
  local has_derived=0 kw missing=""
  if grep -qiE 'deriv|measur|per commit|git show' <<<"$section"; then has_derived=1; fi
  for kw in session decision requirement commit release; do
    grep -qiE "${kw}[^0-9]{0,60}[0-9]+|[0-9]+[^0-9]{0,60}${kw}" <<<"$section" || missing="$missing $kw"
  done
  if [ -n "$missing" ]; then
    echo "BLOCK: Cost Tracking names no NUMBER beside:$missing — a keyword is not a count." >> "$LOG"
    bad "$NAME"; return
  fi
  if [ "$has_derived" -ne 1 ]; then
    echo "BLOCK: Cost Tracking has numbers but no derivation (deriv|measur|per commit|git show)." >> "$LOG"
    bad "$NAME"; return
  fi
  echo "OK: Cost Tracking carries a number beside each of session/decision/requirement/commit/release, plus a derivation." > "$LOG"
  ok "$NAME"
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

  local V="scripts/verify-session-$(printf '%02d' "$N").sh"
  local D="scripts/demo-session-$(printf '%02d' "$N").sh"
  local missing=()
  { [ -f "$V" ] && [ -s "$V" ]; } || missing+=("$V")
  { [ -f "$D" ] && [ -s "$D" ]; } || missing+=("$D")

  if [ "${#missing[@]}" -eq 0 ]; then
    # A4 (S44 cold review M3): requirement 10 says "the closeout still runs full",
    # which was true only by default — nothing invoked the gate at all. What is
    # actually enforceable here is the DEFAULT: the switch resolves "" and "full"
    # to full and rejects anything else, so no value can quietly make the
    # evidence run cheap.
    grep -qF 'resolve_scope() { case "${1:-}" in ""|full) echo full' "$V" \
      || { echo "FAIL: $V no longer defaults VAJRA_GATE_SCOPE to full." >> "$LOG"; bad "$NAME"; return; }
    echo "OK: $V + $D both present and non-empty; the gate's scope default is full." >> "$LOG"; ok "$NAME"; return
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
  local PADDED; PADDED="$(printf '%02d' "$N")"
  local F="sessions/session-${PADDED}-review.md"
  : > "$LOG"

  # (1) Require the artifact.
  if [ ! -f "$F" ] || [ ! -s "$F" ]; then
    echo "MISSING: $F — an independent fidelity review is required (DECISION-002)." >> "$LOG"
    if waiver_ok; then
      echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
    else
      echo "FAIL: supply sessions/session-${PADDED}-review.md (cold pass) or a founder waiver (VAJRA_CLOSEOUT_WAIVER=$N)." >> "$LOG"; bad "$NAME"
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
  local PADDED; PADDED="$(printf '%02d' "$N")"
  local F="sessions/session-${PADDED}-review.md"
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

# --- Contract freshness (S44 req. 9, the S42 cold review's N1) ------------------
# The contract is a COLD INPUT: `check_review_attestation` hashes whatever
# prompts/NN-*.md says NOW, so an edit made between a REJECT pass and the ACCEPT
# pass rebinds the attestation to a spec that already contains its own rebuttal
# and the gate goes on agreeing. Two observable failures:
#   (a) POST-ACCEPTANCE rewrite — some commit after the one that first added the
#       review file changes the contract. The verdict was cast against bytes
#       that no longer exist.
#   (b) MID-CYCLE rewrite laundered by re-attesting — the review carries a
#       first-feed inputs hash (`Review-Inputs-SHA-Pass-1:`) that differs from
#       the final one while the contract shows no amendments section explaining
#       the change.
# PURE on purpose: no ok/bad, no $ARTIFACTS. The S44 gate extracts this body and
# runs it against another session to prove it can go green AND red — a check only
# its own author can run is a check nobody can audit.
# PURE (S44 cold review N2): does the review DECLARE a first-feed inputs hash
# that differs from the final one? The final hash must be matched with the same
# ANCHORED pattern `check_review_attestation` uses — an unanchored
# 'Review-Inputs-SHA' also matches 'Review-Inputs-SHA-Pass-1:', so a review that
# prints the Pass-1 line FIRST made `final` equal `pass1`, the two compared
# equal, and clause (b) never fired: it went green exactly where the contract
# says it must go red. Whether a gate passes must not depend on which of two
# lines was typed first.
contract_freshness_declared_mismatch() {
  local review="${1:-}" pass1 final
  [ -s "$review" ] || return 1
  pass1="$(grep -m1 'Review-Inputs-SHA-Pass-1' "$review" 2>/dev/null | grep -oE '[0-9a-f]{64}' | head -1 || true)"
  final="$(grep -m1 -iE '^[*_[:space:]]*Review-Inputs-SHA[*_[:space:]]*:' "$review" 2>/dev/null | grep -oE '[0-9a-f]{64}' | head -1 || true)"
  [ -n "$pass1" ] || return 1
  [ -n "$final" ]  || return 1
  [ "$pass1" != "$final" ]
}

# PURE: clause (b) exactly as requirement 9 words it — a declared first-feed
# change is acceptable only when the contract carries a '## Contract amendments'
# section that explains it. Returns 0 (fresh) / 1 (stale) and prints why.
contract_freshness_declared_change() {
  local review="${1:-}" prompt="${2:-}"
  contract_freshness_declared_mismatch "$review" || return 0
  grep -q '^## Contract amendments' "$prompt" 2>/dev/null || {
    echo "the review declares a first-feed inputs hash that differs from the final one,"
    echo "but ${prompt:-the contract} has no '## Contract amendments' section explaining the change."
    echo "A mid-cycle rewrite that is neither appended nor declared is the N1 defect."
    return 1; }
  echo "mid-cycle correction declared (Pass-1 != final) and explained by an amendments section"
  return 0
}

contract_freshness_core() {
  local n="${N:-}"
  [ -n "$n" ] || { echo "N unresolved"; return 1; }
  local padded; padded="$(printf '%02d' "$n")"
  shopt -s nullglob
  local prompts=(prompts/${padded}-task-*.md)
  (( ${#prompts[@]} == 1 )) || { echo "prompts/${padded}-task-*.md matches ${#prompts[@]} files, need exactly 1"; return 1; }
  local prompt="${prompts[0]}" review="sessions/session-${padded}-review.md"
  # No review yet => nothing has been attested against; the fidelity gate owns
  # that outcome (no double-jeopardy), same N/A shape as check_review_attestation.
  [ -s "$review" ] || { echo "N/A: no review file yet - nothing to be stale about"; return 0; }
  git cat-file -e "HEAD:${prompt}" 2>/dev/null || { echo "the contract is not committed at HEAD"; return 1; }
  local first after
  # The commit that FIRST added the review, not the one that last touched it —
  # a rewritten review must not move the goalpost.
  first="$(git log --diff-filter=A --format=%H -- "$review" 2>/dev/null | tail -1)"
  [ -n "$first" ] || { echo "no commit in history adds $review - freshness cannot be evaluated (fail closed)"; return 1; }
  # Deliberately EXCLUDES `first` itself: that commit is the merge carrying the
  # whole branch, contract included, so counting it would fail every session.
  after="$(git log --format=%H "${first}..HEAD" -- "$prompt" 2>/dev/null || true)"
  if [ -n "$after" ]; then
    echo "CONTRACT REWRITTEN AFTER THE REVIEW: $(echo "$after" | tr '\n' ' ')"
    echo "  rule: prompts/${padded}-task-*.md is frozen from the first cold feed to closeout."
    echo "  corrections are APPENDED under '## Contract amendments' (see reviewer/SKILL.md);"
    echo "  the requirement they failed is never rewritten in place."
    return 1
  fi
  # Clause (b), extracted into two PURE functions above so the teeth check can
  # drive it with synthetic reviews in either line order (S44 cold review N2).
  contract_freshness_declared_change "$review" "$prompt" || return 1
  echo "contract untouched since the commit that added the review ($first)"
  return 0
}

check_contract_freshness() {
  local NAME="contract-freshness"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  if contract_freshness_core > "$LOG" 2>&1; then ok "$NAME"; else bad "$NAME"; fi
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

# --- Required-crew gate (S139) — added MANUALLY by Vajra S144 dogfood ---------------------
# WORKAROUND for two Vajra findings surfaced by this dogfood, both to be fixed in a follow-up
# Vajra session:
#   FINDING 1 — `vajra init --sync-fleet` upgrades roles + hooks + the constitution body, but
#     NOT scripts/verify-closeout.sh (not a sync target). A brownfield adopter's close-gate is
#     frozen at whatever `vajra init` scaffolded when it adopted; chitra adopted pre-S139, so it
#     never received check_required_crew via the upgrade loop.
#   FINDING 2 — the canonical gate hardcodes BIN="target/release/vajra" (Vajra's own Rust build
#     output). chitra is a TypeScript project with no such path, so even a fresh scaffold's
#     binary-backed gates could never run. Here BIN is resolved to the INSTALLED vajra on PATH.
# Canonical S139 logic otherwise; requires a real tech-lead handoff + a handoff for every role
# the tech-lead marked `required`, or the close cannot go green (behind the same founder waiver).
check_required_crew() {
  local NAME="required-crew"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  : > "$LOG"
  local BIN; BIN="$(command -v vajra || true)"
  if [ -z "$BIN" ] || [ ! -x "$BIN" ]; then
    echo "BLOCK: vajra not found on PATH — this check cannot evaluate the Crew gate." >> "$LOG"
    if waiver_ok; then
      echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
    else
      echo "FAIL: install vajra so this check can run, or record a founder waiver." >> "$LOG"; bad "$NAME"
    fi
    return
  fi
  local out code
  out="$("$BIN" next --check-crew "$N" 2>&1)" && code=0 || code=$?
  echo "$out" >> "$LOG"; echo "exit=$code" >> "$LOG"
  if ! grep -q "=== crew: tech-lead for session" <<<"$out"; then
    echo "BLOCK: the binary produced no Crew-gate output — this build does not carry the gate." >> "$LOG"
    if waiver_ok; then
      echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
    else
      echo "FAIL: \`vajra next --check-crew $N\` did not run the gate." >> "$LOG"; bad "$NAME"
    fi
    return
  fi
  if [ "$code" -eq 0 ]; then
    echo "OK: session $N has a real tech-lead handoff and every role it marked \`required\` produced a governed handoff." >> "$LOG"
    ok "$NAME"; return
  fi
  echo "BLOCK: session $N is missing its tech-lead handoff, or a role the tech-lead marked \`required\` produced no governed handoff." >> "$LOG"
  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
  else
    echo "FAIL: dispatch the tech-lead and each \`required\` role and run \`vajra next --role <name> --from <findings>\`, or record a founder waiver." >> "$LOG"; bad "$NAME"
  fi
}

# --- Session artifact-coverage gate (S36 — closes the S17/S32 hole) -----------
# check_session_pair only iterates summaries that EXIST, so a session that shipped
# and merged with NO summary at all (S17 PR #19, S32 PR #38) is invisible to it.
# This scans the merge history of `main` for every merged `session-NN-*` branch and
# requires a `sessions/session-NN-summary.md`. Legacy sessions below the prompt-file
# convention (NN < 17) are exempt; NN >= 17 must carry a record.
check_session_coverage() {
  local NAME="merged-sessions-have-records"; local LOG="$ARTIFACTS/${NAME}.log"
  : > "$LOG"
  if ! git rev-parse --verify main >/dev/null 2>&1; then
    echo "N/A: no main ref to scan." >> "$LOG"; ok "$NAME"; return
  fi
  # S47 (S45 G1): the S36 body read ONLY merge subjects + session-NN-slug, so every
  # squash-merged session since S38 was invisible (newest belief S37) and S40's missing
  # summary went unseen. Population is now the UNION of merge subjects and squash
  # subjects; an empty population FAILS; newest belief is recorded. Counterfactual:
  # the old body stays green on the live tree where S40 has no summary.
  local merge_list squash_list all_list
  merge_list="$(git log --merges --format='%s' main 2>/dev/null \
              | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p' || true)"
  squash_list="$(git log --format='%s' main 2>/dev/null \
              | grep -oE 'S[0-9]{2}:' | grep -oE '[0-9]+' || true)"
  all_list="$(printf '%s\n%s\n' "$merge_list" "$squash_list" | grep -E '^[0-9]+$' | sort -n -u || true)"
  if [ -z "$all_list" ]; then
    echo "BLOCK: empty session population - nothing derived, nothing proven." >> "$LOG"
    bad "$NAME"; return
  fi
  local newest; newest="$(printf '%s\n' "$all_list" | tail -1)"
  echo "population: merge-subjects + squash-subjects, newest belief S$newest" >> "$LOG"
  local missing=0 seen=0 n
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    n=$((10#$n)); [ "$n" -ge 17 ] || continue
    seen=$((seen+1))
    if [ -f "sessions/session-$(printf '%02d' "$n")-summary.md" ]; then
      echo "OK: S$n has a summary" >> "$LOG"
    else
      echo "MISSING: S$n merged but sessions/session-$(printf '%02d' "$n")-summary.md absent" >> "$LOG"
      missing=$((missing+1))
    fi
  done <<< "$all_list"
  echo "scanned $seen merged session(s) >= S17, newest S$newest" >> "$LOG"
  if [ "$seen" -eq 0 ]; then
    echo "BLOCK: population derived but no session >= S17 - vacuous green refused." >> "$LOG"
    bad "$NAME"; return
  fi
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

# --- Ground-truth NO-CODE gate (S36 — backs the AGENTS.md claim) --------------
# AGENTS.md says "No code in Ground Truth — Hook-enforced"; the Claude harness hook
# (.ai/hooks/hook-ground-truth-guard.sh) enforces it at write time, but opencode does
# not run those hooks. This is the harness-agnostic backstop: for a GT session
# (N % 5 == 0), the committed diff vs the branch point must touch NO code — only
# sessions/, prompts/, .ai/, and markdown.
check_ground_truth_no_code() {
  local NAME="ground-truth-no-code"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  if [ "$((N % 5))" -ne 0 ]; then
    echo "N/A: session $N is not a ground truth." >> "$LOG"; ok "$NAME"; return
  fi
  : > "$LOG"
  # S47 (S40 row 10, S45 Method): the old body diffed merge-base..HEAD and an empty
  # range read OK - a GT session that committed nothing passed vacuously, and a planted
  # code file under an empty range still read OK. Fail closed: the GT artifact must
  # exist and be non-empty, and an empty/unresolvable range BLOCKS instead of passing.
  # Counterfactual: plant packages/core/src/x.ts under an empty range - old OK, new red.
  local PADDED; PADDED="$(printf '%02d' "$N")"
  local GT="sessions/session-${PADDED}-ground-truth.md"
  if [ ! -s "$GT" ]; then
    echo "BLOCK: GT artifact $GT missing or empty - NO-CODE unproven." >> "$LOG"
    bad "$NAME"; return
  fi
  echo "GT artifact present: $GT ($(wc -l < "$GT" | tr -d ' ') lines)" >> "$LOG"
  # S47 R2: the range is overridable so a caller can exercise the OFFENDER clause
  # against a real committed change (VLT_GT_BASE/VLT_GT_HEAD) instead of an
  # untracked probe, which `git diff base HEAD` cannot see. Defaults unchanged.
  local base; base="${VLT_GT_BASE:-$(git merge-base main HEAD 2>/dev/null || true)}"
  local head_ref; head_ref="${VLT_GT_HEAD:-HEAD}"
  if [ -z "$base" ]; then
    echo "BLOCK: no merge-base with main - empty range proves nothing (fail closed)." >> "$LOG"
    bad "$NAME"; return
  fi
  if [ "$(git rev-parse "$head_ref" 2>/dev/null || true)" = "$(git rev-parse "$base" 2>/dev/null || true)" ]; then
    echo "BLOCK: range is empty ($base == $head_ref) - empty range, NO-CODE unprovable here; run on the session branch." >> "$LOG"
    bad "$NAME"; return
  fi
  local offenders wt
  offenders="$(git diff --name-only --no-color "$base" "$head_ref" -- . \
                 ':(exclude)sessions' ':(exclude)prompts' ':(exclude).ai' 2>/dev/null \
               | grep -vE '\.(md|txt)$' || true)"
  # S47 R2, third conjunct of the contract's done-condition: a PLANTED
  # `packages/core/src/*.ts` must go red. `git diff base HEAD` cannot see an
  # untracked file (pass 2 proved both bodies read OK on that stimulus), so the
  # worktree is scanned too — a GT session that leaves code in its tree fails
  # closed whether or not it committed it. Ignored files (dist/) are invisible to
  # `git status --porcelain` by design, so a build artefact is not an offender.
  wt="$(git status --porcelain -- packages/ 2>/dev/null \
          | sed -E 's/^.. //' | grep -vE '\.(md|txt)$' || true)"
  if [ -n "$wt" ]; then
    offenders="$(printf '%s\n%s\n' "$offenders" "$wt" | sed '/^$/d' | sort -u)"
  fi
  if [ -z "$offenders" ]; then
    echo "OK: no code changes in ground-truth session $N (non-empty range evaluated; worktree clean)." >> "$LOG"; ok "$NAME"; return
  fi
  printf '%s\n' "$offenders" >> "$LOG"
  echo "BLOCK: ground-truth session $N changed code files (above)." >> "$LOG"
  bad "$NAME"
}

# --- Ground-truth remediation ledger (S36, hardened S37 — gives GT findings teeth) ---
# Ground-truth findings historically had no closure mechanism (S05's debt sat open
# 30 sessions). .ai/GT-REMEDIATIONS.md carries every GT session's remediations and
# each row's Status must be DONE, WAIVED, or DEFERRED; anything else BLOCKS closeout.
# S37 hardening (S36-review weakness): a bare `DEFERRED` was a rot hatch — accepted
# with no reason/expiry, mirroring the S05 failure the ledger claims to close. A
# DEFERRED row now ALSO needs `reason` AND an `expiry` (a `MM-DD`/`YYYY-MM-DD` date
# or the word "expiry") in its Evidence cell, so a deferral cannot rot silently.
check_gt_remediations() {
  local NAME="gt-remediations-dispositioned"; local LOG="$ARTIFACTS/${NAME}.log"
  local F=".ai/GT-REMEDIATIONS.md"
  if [ ! -f "$F" ]; then
    echo "MISSING: $F — ground-truth remediations must be tracked." > "$LOG"; bad "$NAME"; return
  fi
  : > "$LOG"
  local bad_rows
  bad_rows="$(awk -F'|' '
    /^\|/ {
      n=split($0, a, "|")
      if (n < 5) next
      id=a[2]; st=a[4]; ev=a[5]
      gsub(/^[ \t]+|[ \t]+$/, "", id); gsub(/^[ \t]+|[ \t]+$/, "", st)
      if (id == "#" || id ~ /^-+$/) next
      if (st != "DONE" && st != "WAIVED" && st != "DEFERRED") { print "  [" st "] " id; next }
      if (st == "DEFERRED") {
        evl=tolower(ev)
        has_reason=(evl ~ /reason/)
        has_expiry=(evl ~ /expiry/ || evl ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)
        if (!has_reason || !has_expiry) print "  [DEFERRED missing reason/expiry] " id
      }
    }' "$F")"
  if [ -z "$bad_rows" ]; then
    echo "OK: every remediation row is DONE/WAIVED, and every DEFERRED carries reason+expiry." >> "$LOG"; ok "$NAME"; return
  fi
  printf '%s\n' "$bad_rows" >> "$LOG"
  echo "BLOCK: undispositioned ground-truth remediation(s) above." >> "$LOG"
  bad "$NAME"
}

# Focused entry point: run ONLY the S36 integrity gates (coverage + GT no-code +
# GT remediations). `--integrity-only [N]`. Proves the gates EXECUTE, not just exist.
if [ "${1:-}" = "--integrity-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_session_coverage
  check_ground_truth_no_code
  check_gt_remediations
  echo ""
  echo "=== S36 integrity gates (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/merged-sessions-have-records.log" 2>/dev/null || true
  cat "$ARTIFACTS/ground-truth-no-code.log" 2>/dev/null || true
  cat "$ARTIFACTS/gt-remediations-dispositioned.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "INTEGRITY: PASS"; exit 0; else echo "INTEGRITY: FAIL"; exit 1; fi
fi

# Focused entry point: run ONLY the ground-truth no-code gate for an explicit N (S37).
# Lets a CODE session EXERCISE the offender path: evaluate a synthetic GT N (a multiple
# of 5) against a branch that DOES contain code changes, so the gate must BLOCK. The S36
# review found `--integrity-only 36` only ever reached the `N/A: not a ground truth`
# early-return, so the offender-detection path was never actually exercised.
# `--gt-no-code-only [N]` — exit 1 (as designed) is the PROOF the path works.
if [ "${1:-}" = "--gt-no-code-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_ground_truth_no_code
  echo ""
  echo "=== GT no-code gate (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/ground-truth-no-code.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "GT-NO-CODE: PASS"; exit 0; else echo "GT-NO-CODE: FAIL"; exit 1; fi
fi

check_session_file
check_required_files
check_session_boot
check_task_ref
check_state_sections
check_session_pair
check_session_coverage
check_roadmap_current
check_cost_tracking
check_execution_shas
check_verify_demo_scripts
check_fidelity_review
check_review_attestation
check_contract_freshness
check_required_crew
check_ground_truth_no_code
check_gt_remediations

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
