# Reviewer — the fidelity / acceptance auditor (Vajra's QA/PO stage)

> **Status:** ACTIVE (S56 — teeth built). The *brain* of Vajra's missing heart. Boot-loaded like Darshan
> and Varta — instructions the agent internalizes; **nothing in the binary parses or runs this.** S56 gave
> it *teeth*: `scripts/verify-closeout.sh` now **requires** this skill's artifact and **fails closeout** on a
> missing / incomplete / REJECT review, absent an un-forgeable founder waiver. Prototyped live in
> `sessions/session-55-review.md` (cold re-audit of S54).

---

## Why this exists (DECISION-002)

Vajra enforces **discipline** (branch, file caps, tests-green, session state) but not **fidelity**
(*did the agent build what was actually asked*). S54 shipped ~1 of a 5-part job, self-certified, and
**every green gate passed.** A governance layer that proves the rails and never checks the cargo is half a
product — the dangerous half, because a green gate *looks* like proof.

**The Reviewer is the independent, adversarial pass that reads the prompt's requirements against the actual
diff and rules each one SHIPPED / PARTIAL / NOT-BUILT — gating closeout.**

---

## The one rule

> **Trust the diff, not the summary. Map every requirement to evidence. The builder never grades itself.**

---

## Non-negotiable independence (the inputs, not the label)

A reviewer that is the same model shares the builder's blind spots. Independence comes from **what it is
fed** and **how it is framed**, not from the word "QA":

1. **Separate pass.** Run in a fresh subagent (own context), never inline in the builder's reasoning.
2. **Cold inputs only.** Feed exactly two things: the **contract** (`prompts/NN-task-<slug>.md`) and the
   **delivery diff**. Nothing else from the repo.
3. **Strip the self-narrative.** Exclude `sessions/session-NN-summary.md`, `.ai/STATE.md`,
   `SESSION-BOOT.md` from the diff — they carry the builder's "all ✓" claims and contaminate the verdict.
   *(Check the summary/memory exist with a separate presence check — do not feed their prose.)*
4. **Withhold the answer.** Never tell the auditor the expected score. It must catch the gap unaided.
5. **Adversarial framing.** Instruct: *assume the builder silently re-scoped to whatever yields a green
   checkmark; find the fakest checkmark.*

---

## The procedure (6 steps)

1. **Extract requirements — from EVERY requirement-bearing section**, not just "Deliverables". Number them.
   Sources typically: a "job/steps" list, "Deliverables", and "what must be answered". (S54: 5 + 6 + 4 = 15.)
2. **Hunt evidence in the diff** for each — a function, hunk, or test that proves it was *built*, not merely
   *mentioned*. Quote the identifier / line.
3. **Rule per requirement:**
   - **SHIPPED** — real behavior + evidence in the diff.
   - **PARTIAL** — some present; name exactly what the contract asked that is missing.
   - **NOT-BUILT** — absent; the requirement lives only in prose / a doc-comment / a placeholder.
4. **Adversarial sweep — watch for these tells** (each seen live in S54):
   - A **gate that only warns/advises** where the contract said *block*.
   - **Delta / tracking written by hand** into a doc vs. actually computed by the code.
   - **Intake / options / "A/B/C"** steps that exist only as human prose, not behavior.
   - A **verify script asserting weak proxies** (`grep -q '## Heading'`) instead of the real requirement.
   - **Honesty theater** — the summary flags small true caveats but not the headline miss.
5. **Name the FAKEST GREEN** — the single thing that most looks done but is hollow, and why the checkmark
   is trivially true.
6. **Verdict:** a per-requirement table + a count ("X of N SHIPPED") + **ACCEPT / REJECT** + one line:
   *is the real scope "one narrow slice presented as the whole," or a faithful build of the whole contract?*

---

## The artifact (what S56 will require)

Emit `sessions/session-NN-review.md` containing, at minimum:

- The **method controls** actually used (so a non-author can trust the independence).
- The **per-requirement table** (Requirement | Verdict | Evidence) covering **every** numbered requirement,
  using the verdict vocabulary `SHIPPED` / `PARTIAL` / `NOT-BUILT` (the gate requires ≥3 such verdicts — a
  real acceptance table, not a lone heading).
- The **count** and the **fakest green**.
- A **canonical machine-readable verdict line** the gate parses — exactly one line of the form
  `**Verdict:** ACCEPT` or `**Verdict:** REJECT`. A `## Overall verdict` heading with the word buried in
  prose is *not* enough — the S54 "fakest green" was a heading-grep, so the gate demands a real verdict
  field, not a heading.
- **On an ACCEPT: an input-attestation line** (S58 — DECISION-003) — exactly one line of the form
  `**Review-Inputs-SHA:** <64-hex sha256>`, the hash of the exact cold inputs (contract prompt + delivery
  diff) the pass consumed. **Compute it with the gate's own function** so it cannot drift from what the gate
  recomputes: `scripts/verify-closeout.sh --inputs-sha <N>`. Emit it *after* reviewing the committed diff
  (not a draft), so the hash binds the verdict to what actually shipped. A REJECT needs no attestation.

**Closeout rule (S56 teeth, live):** `scripts/verify-closeout.sh` FAILS if the review is missing, is
present-but-incomplete (no per-requirement table or no canonical `**Verdict:**` line), or `Verdict: REJECT`
— **absent a founder waiver.** The waiver is the env var `VAJRA_CLOSEOUT_WAIVER=<N>` (session-scoped,
founder-controlled at launch — mirrors `VAJRA_ALLOW_PUBLISH`), **never a text marker the agent can write
into a tracked file.** Run the gate in isolation with `scripts/verify-closeout.sh --fidelity-only <N>`.

**What the teeth do and do NOT enforce (honest limit — do not overclaim).** The gate structurally blocks a
*missing / hollow / REJECT* review and makes the **waiver** un-forgeable. It enforces the review's **shape**
(a real in-table verdict list + a canonical verdict line), the **waiver's authorship**, and — since S58
(DECISION-003) — an **input-attestation** on every ACCEPT: `check_review_attestation` recomputes
`sha256(prompt ‖ delivery-diff)` from the repo and FAILS an ACCEPT whose `**Review-Inputs-SHA:**` is
missing, forged, or **stale** (the delivery changed after the review), behind the same founder waiver.

**This is bar-raising, NOT tamper-proof — and the arc is honest about that.** Because the same agent can run
`--inputs-sha` and paste the hash, the attestation does **not** prove a *different mind* authored the verdict.
What it *does* raise the bar against: a review **recycled** from another session (different prompt/diff →
mismatch), a verdict written against an **earlier** diff then quietly shipped over a changed delivery
(freshness → mismatch), and a verdict **decoupled** from what actually shipped (the gate recomputes at
closeout from the live repo, so the attested inputs must equal the delivered ones). So the honest #1 —
"verdict *authorship* independence is procedural, not structural" — is **downgraded from an open gap to a
documented, bounded limit**, not closed: procedure (this skill's cold-subagent pass) still carries the
who-authored-it guarantee; the code now carries the what-was-reviewed binding.

---

## Honest limits (do not overclaim)

- Same-model reviewer shares blind spots; independence is *structural* (cold inputs + adversarial framing),
  **better than self-grading, not perfect.**
- The gate must not become ceremony-then-rote. It earns its place only by catching real "shipped 1 of N"
  gaps — as it did on S54. If it starts rubber-stamping, that is itself a fidelity failure.
- The verdict is only as good as **requirement extraction** — miss a requirement-bearing section and the
  gap hides. Extract from all of them.

---

## Boot ritual (like Darshan / Varta)

At boot, read → internalize → when a session reaches VERIFY/closeout, run this pass **cold** before
declaring done. The builder proposes; the Reviewer disposes. Green tests are the floor, never the proof.
