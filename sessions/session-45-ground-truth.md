# Session 45 — Ground-Truth Audit (NO-CODE)

**Session 45 · `45 % 5 == 0` · mandatory 5-session cadence · verdict: 🔴**

`main` = `5a39c43` at audit time (derive: `git rev-parse main` — **not** the `1b6c17d` that
`.ai/STATE.md:7`, `.ai/SESSION-BOOT.md:5,30`, `.ai/TASK.md:5` and `.ai/CONTINUATION-PROMPT.md:4`
still cite). Package `@ifelse.codes/chitra@0.3.0`, live on npm. Repo **private**. Product:
**453/453** tests in **23** files, measured this session, not copied forward.

**Scope note.** This is a NO-CODE ground-truth audit. The public flip that four tracked documents
named for S45 **cannot run here** — `45 % 5 == 0` and `hook-ground-truth-guard.sh` (L3) block every
write outside `sessions/ .ai/ prompts/ *.md`, while the flip's `0.4.0` needs
`packages/core/src/version.ts`. Founder decision: **the flip carries to S46 whole**
(`prompts/46-task-public-flip.md`, requirements **F1–F6** + preconditions **P1–P2**).

---

## Method — and its own blind spot, stated first

Every finding below is a **probe**: a command, its live output, and the output that would falsify it.
The bar S40 set and this session holds: **a finding whose number cannot be re-derived from the command
printed beside it is not a finding.**

**27 probes run, 3 retired.** Retired probes are listed, because a retired probe that is quietly
dropped is how a count becomes a fiction:

| Retired | Why |
|---|---|
| P6 | grepped `45[0-9]` and matched `rand(1500, **4500**)` — reported "the docs pill reads 450" before the context lines showed a timer jitter. **False alarm.** The pill is `453` at `App.tsx:927`, truthful. |
| P7 (×2) | used `grep -oE '\bS[0-9]+\b'`; BSD grep has no `\b`, and `check_session_coverage`'s own `session-([0-9]+)-` pattern does not match squash-merge subjects. Both attempts returned empty and were **retried, not reported**. |

**The blind spot this session is standing on.** `check_ground_truth_no_code` — the gate whose entire
job is proving a ground-truth session changed no code — **diffs an empty range and returns `OK`**
(GT-REMEDIATIONS row 10; S40 proved it by planting a `packages/core/src/*.ts` file and reading
`INTEGRITY: PASS`). So the NO-CODE claim in this file rests on the diff read directly, never on that
gate:

```
$ git diff --name-only main...HEAD -- . ':(exclude)sessions' ':(exclude)prompts' ':(exclude).ai' \
    | grep -vE '\.(md|txt)$'
(none)
```

**Falsifier:** if that command ever prints a path, this session was not NO-CODE, whatever any log says.

---

## The headline finding

> **The ground-truth cadence is enforced by a hook and declared in a config file, and it appears in
> neither the constitution nor the session-boot file nor the task pointer — the three documents every
> agent is required to read before acting.**

| File | mentions of the cadence / `N % 5` |
|---|---|
| `.ai/AGENTS.md` — **"Every AI agent MUST read this file"** | **0** |
| `.ai/SESSION-BOOT.md` | **0** |
| `.ai/TASK.md` | **0** |
| `.ai/CONSTRAINTS.yaml` | 1 (`ground_truth_every_n_sessions: 5`) |

The consequence is not hypothetical — it is this session:

```
$ grep -rlE '45 % 5|S45.*ground.?truth|ground.?truth.*45' .ai/ prompts/
prompts/45-task-public-flip.md          <- written by this session, today
$ grep -nE 'S45' .ai/ROADMAP.md
118:- ⬜ **Session 45 (S45) — the public flip.** One move resolves: the README `git clone` URL, npm
```

**Five tracked documents named S45 "the public flip" and not one of them computed `45 % 5`.** The
roadmap — the document whose job is naming the next session — scheduled a code session onto a
ground-truth slot. **S40 GT-REMEDIATIONS row 6** fixed exactly this by naming S40 on the board; the
fix was **reactive, not structural**, and the cadence went straight back out of sight. Five sessions
later it collided again.

**Falsifier:** add one line to `.ai/AGENTS.md`'s load-order or Hard Rules naming the cadence, and the
next handoff cannot be written without it.

---

## A · `vision_alignment` — 🟡

The north-star is *"the best terminal chart lib ever created — zero-dep, AI-first, delightful."*

**Probe (P23/P28).** The newest commit that *added* a chart module:

```
$ git log --diff-filter=A --format='%ad %h %s' --date=short -- 'packages/core/src/charts/*.ts' | head -1
2026-08-03 c72cc14 feat(core): shared braille-dot ring renderer for pie/donut (LOCKED S09 look)
$ ls packages/core/src/charts/*.ts | grep -vc test
23
```

**62 days and ~16 sessions** since new product surface (S28 sparkline → S44). The last 16 sessions
were governance, dead-weight removal and release mechanics.

**This is defensible sequencing, not drift** — the founder decided cleanup gates the flip, and the
evidence supports the decision: the repo genuinely carried 110 dead files (S42), 36 dead deps and 53
dead components (S43). But the honest reading of the constitution's own question — *"is current work
the shortest path to the north-star, or intellectually-fun scope creep?"* — is: **the cleanup was
load-bearing, and the flip it was clearing the path for has now slipped a session to a ground-truth
audit.** Sequencing without an owner is how a necessary detour becomes the destination.

**AI-first, the second half of the north-star:** `toPlain()` / `toJSON()` ship; the MCP server is
founder-DEFERRED since S38 with its gate intact ("a release exists **and** someone demands it **and**
it is judged worth building"). No public release-and-market has happened, so the deferral's condition
is honestly unmet. **Verdict: 🟡 — sound direction, and the detour now needs a named end.**

## B · `roadmap_alignment` — 🔴

**The roadmap schedules work onto a session that could not do it (P30), and promises S44 work S44
did not do (P12).**

```
$ sed -n '56p' .ai/ROADMAP.md
| `check_required_crew` is structurally unsatisfiable | Founder-waived at S38, S39, **and now S42**. Three waivers is a decision, four is a burial. It is **S44 decision work beside D2** |
```

That row lives under the heading **`### → recorded, deliberately NOT scheduled`** — a table whose
own header says *not scheduled* schedules it — and it names S44, which completed in October without
touching it. `.ai/STATE.md:107` still lists it open, now one closeout from a **fourth** waiver. The
line's own reasoning ("four is a burial") is the finding: **the roadmap wrote the epitaph and then
assigned the work.**

**Highest-leverage check.** The flip is still the right next move — it is the only item that
converts `@ifelse.codes/chitra@0.3.0` from *published but unreachable* into *inspectable*, and it
unblocks npm provenance, which no other work can. **But the roadmap has no item for the two
preconditions the flip is gated on**, which is why they read as 🔴 reds owned by nobody:

| Precondition | State | Owner in the roadmap |
|---|---|---|
| **P1** — D4b history rewrite (`(/|-)Users[-/][a-z]+` in **1001** commit-file pairs across **443** commits) | irreversible once public | **none** |
| **P2** — private vulnerability reporting (404; recorded `unknown`) | founder-only setting | **none** |

**Verdict: 🔴 — the next-session pointer is wrong, one open item is double-booked, and the flip's
two gates have no owner.**

## C · `state_drift` — 🔴

**Eight stale facts, every one re-derived.**

| # | Claim | Site | Live |
|---|---|---|---|
| 1 | `main` = `1b6c17d` | `STATE.md:7`, `SESSION-BOOT.md:5,30`, `TASK.md:5`, `CONTINUATION-PROMPT.md:4` | `5a39c43` |
| 2 | S44 is in-progress on `session-44-oss-polish` | `SESSION-BOOT.md:4-5`, `TASK.md:3-5` | **merged** (PR #65 + #66) |
| 3 | "**D4b — `main` still matches** `(/|-)Users[-/][a-z]+`" | `STATE.md:75-76` | **0 files in the tree** at `main` *and* `HEAD`; **1001** pairs in *history* — the claim is false about the tree, true about history, and says "tree clean, history not" three lines later |
| 4 | "the live set is **39 / 42 / 43 / 44**"; the rest unrunnable (01, 02, 03, 07, 31, 34, 36, 37, 38) | `STATE.md:118-119` | **36** numbered `verify-session-*.sh` exist (+1 template) — so the state names 4 as live and leaves **32** unclassified. A 4-item "live set" is prose curation with no deriving command. *(Corrected before review: this row first read "32 exist", miscounted from a truncated listing. See the summary's Corrections.)* |
| 5 | "Suite is 452 tests" | `KNOWLEDGE.md:207` | **453** |
| 6 | pill reads "`452` tests (`App.tsx` **L550 / L570**)" | `KNOWLEDGE.md:226` | `453` at **L927** — wrong number *and* wrong lines |
| 7 | "`main` hosts S00–S39"; "newest tag `v0.3.0` at `f4ff6ef9`", "`v0.2.0` at `76d21f3`" | `KNOWLEDGE.md:109,112` | main hosts S00–**S44**; `v0.3.0` = **`87dafe2`**, `v0.2.0` = **`9495fa7`** — 2 of 3 tag SHAs wrong |
| 8 | S44 cost line records one clean delivery | `STATE.md:141-151` | `sessions/session-44-summary.md:277` — "Cold review, pass 8: **REJECT**"; **0** mentions of the follow-up PR #66 or pass 8 in the cost block |

**`KNOWLEDGE.md` knows.** Line 111 states this class "has now been wrong twice: it said S00–S08 (S35),
was corrected to S00–S34 in S36, and drifted to S00–S37 by S40. **No guard protects it.**" S45 makes
it four. **The file diagnosed its own disease in 2026 and shipped no cure** — which is the finding,
more than any single number in it.

**Verdict: 🔴 — a snapshot that has drifted on eight facts, four of them the same recurring class.**

## D · `knowledge_staleness` — folded into C

Covered by rows 5–7 above. One structural note: `KNOWLEDGE.md` is `append-permanent-only`
(`CONSTRAINTS.yaml#state.knowledge_md_mode`), so a file that can only grow cannot self-correct — every
correction is an appended amendment over a stale body. **The mode and the drift are in conflict**, and
no check compares a `KNOWLEDGE.md` claim against a re-derived value.

## E · `constraint_violation_review` — 🔴

**The 3-file cap is violated by 17 of the last 60 commits on `main` — up from 8 when S40 measured it
(P13).**

```
$ git log --format='%H' -60 main | while read c; do
    n=$(git show --numstat --format='' "$c" | grep -c .); [ "$n" -gt 3 ] && echo x; done | wc -l
17
```

`.ai/AGENTS.md` states this rule as **"Hook-enforced"**. It is not, and cannot be: **PRs are
squash-merged, so no local hook ever runs.** The count doubled across exactly the four multi-file
cleanup sessions, i.e. **the rule degrades in proportion to how much legitimate work a session does** —
which is the precise condition under which a hard cap stops being a guard.

**Two more, recorded not fixed:** `.ai/.session-owner` is **gitignored** (`.gitignore:2`) and pinned at
chat `12` (session 36), so `one_session_per_chat` cannot bind across chats — S40 row 9, unchanged.
`verify.clean_room.enabled: false`, an S119 gap disclosed in the config and never closed.

**Verdict: 🔴 — a rule declared hook-enforced, enforced by nothing, degrading measurably.**

## F · `constitution_review` — 🔴

**The 13 hard rules hold their intent; three of their *claims* do not survive contact.**

| Rule | Claim | Reality |
|---|---|---|
| Max 3 files per atomic commit | "Hook-enforced" | squash merges bypass it; **17/60** violate |
| Verification = exit 0 | every session closes green | **S45 writes no gate at all** — lawfully: `check_verify_demo_scripts` **exempts `N % 5 == 0`** ("no session scripts expected"). *A check that knows its own scope is the counter-example to the vacuity finding below* |
| No self-certification | the builder never grades itself | **S44's canonical verdict is `REJECT`** (§G) |

**The constitution's silence on the cadence** is the finding in its own right: a binding,
hook-enforced, constitutional obligation with **zero lines** in `AGENTS.md` — the file whose first
line is *"Every AI agent MUST read this file."* A rule that lives only in a config key is one refactor
away from deletion.

**The three constitution questions:**

1. *Is any rule now blocking the vision instead of protecting it?* **`check_required_crew`** — it
   demands a tech-lead handoff that `AGENTS.md`'s own 9-step Session Loop **never asks for**, so the
   gate polices a step the constitution does not contain. Founder-waived S38, S39, S42, and S44 (a
   **fourth**). It protects nothing; it costs a waiver every five sessions.
2. *Did this audit's own mechanism have a blind spot?* **Yes, and it is §G's finding turned on itself:**
   `check_session_coverage` cannot see the seven most recent sessions.
3. *(implied)* *Is the cadence's absence from the constitution a rule or an oversight?* An oversight —
   but one that has now cost a session.

**Verdict: 🔴 — the constitution's text is narrower than its enforcement.**

## G · `constraint_violation_review` → the blind spot, called separately because it is the worst

> ### 🔴 `check_session_coverage` cannot see sessions **38 through 44**. It is green.

```
$ git log --merges --oneline main | wc -l          # 44 merge commits exist
$ git rev-list --count main                          # 443 commits total
$ git log --merges --format='%s' main | sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p' | sort -n -u | tr '\n' ' '
07 08 09 10 11 12 13 14 15 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 36 37
```

The check added in **S36** to catch exactly this species of gap — a merged session with no record —
reads its population from `git log --merges` and extracts `session-([0-9]+)-`. **Every session from S38
onward was squash-merged**, so their subjects read `S44: cleanup Batch 4 …` and match nothing. The
check's newest belief is **S37**. It has been blind for **seven sessions** and reports success.

**It has already cost a record (P20).**

```
$ for n in $(git log --format='%s' main | grep -oE 'S[0-9]{2}:' | tr -d 'S:' | sort -n -u); do
    [ "$n" -ge 17 ] && [ ! -f "sessions/session-$n-summary.md" ] && echo "S$n has NO summary"; done
S40 has NO summary
```

**S40 is a merged session with no `session-40-summary.md`** — and the gate built to catch that is the
one gate that cannot see it. **This is the S16 failure, re-occurring, in the check that was the S16
remediation.** Row 4 of the ledger proposed backfilling S16's records; it never proposed checking that
the detector still detects.

**Falsifier:** squash-merge one session PR and the check's "scanned N merged session branch(es)" line
stays identical — a check whose population can be emptied by a workflow change is not a check.

**Verdict: 🔴 — a vacuous green in a *new* species: not an empty diff, but an empty population.**

## H · `cost_review` — 🟠

`.ai/STATE.md`'s cost block is honest in form — "measured", with a derivation named — and **wrong in
substance for S44** (row 8 of §C): it records one session, one delivery, zero mention of the
**follow-up PR #66**, eight cold-review passes, or the REJECT. The S40→S43 line is a single
compressed sentence; S41's is absent.

**Token/`$` cost is recorded as "unmeasured (billed to the founder's plan)"** — that is the correct
honest reading and needs no invention. **But a cost line that under-reports its own session's second
half is not a measurement.** Measured figures for S45: **27 probes, 3 retired**, one session, zero
product-code changes, zero releases, zero npm secrets, $0.

**Verdict: 🟠 — the form is right, the S44 figure is not.**

## I · `knowledge_staleness` meta — a pattern, not a number

Across §C, §E and §G one shape repeats: **a check or a claim whose population is defined by prose
rather than derived from the thing it governs.**

| Site | Population defined by | Result |
|---|---|---|
| `check_session_coverage` | `git log --merges` + a subject regex | 7 sessions invisible |
| `STATE.md` "live set 39/42/43/44" | a hand-kept list of 4 | 28 scripts unclassified |
| `KNOWLEDGE.md` main range | typed, guarded by nothing | wrong 4× since S35 |
| `check_ground_truth_no_code` | `merge-base..HEAD` | empty range → `OK` |
| `check_cost_tracking` | `grep 'Cost Tracking'` | any text passes, incl. a lie |

**This repo does not have a "stale number" problem. It has a "population nobody derives" problem**,
and it is the same defect five times over. Three of those five are *checks* — and a check whose
population is a regex over commit subjects is a check that a workflow change can switch off without
anyone noticing.

---

## Findings, ranked

| # | Finding | Severity | Owner |
|---|---|---|---|
| **G1** | `check_session_coverage` blind for S38–S44; already missed S40's missing summary | 🔴 | S46 |
| **H1** | The GT cadence appears in **0** of `AGENTS.md` / `SESSION-BOOT.md` / `TASK.md`; 5 documents mis-scheduled S45 | 🔴 | S46 |
| **C1** | 8 stale facts across `STATE.md` / `SESSION-BOOT.md` / `TASK.md` / `KNOWLEDGE.md`, incl. `main`'s SHA in 5 places | 🔴 | S46 |
| **F1** | S44's canonical verdict is **REJECT** (single verdict line, waived) while `STATE.md`/`ROADMAP.md` record COMPLETE — and a REJECT makes `check_review_attestation` read `N/A`, so **S44 has no DECISION-003 input attestation** | 🔴 | S46 |
| **B1** | `ROADMAP.md:56` schedules `check_required_crew` to S44 inside the *deliberately NOT scheduled* table; S44 did not do it; a 4th waiver is one closeout away | 🔴 | S46 |
| **E1** | 3-file cap violated by **17/60** commits (S40 measured 8) and declared "hook-enforced" | 🔴 | S46 |
| **C2** | `STATE.md`'s D4b red is false about the tree (0 files) and true about history (1001 pairs) | 🟠 | S46 |
| **C3** | "Live set 39/42/43/44" is prose curation: **36** numbered scripts exist, 4 are named live, **32** are unclassified — with no deriving command | 🟠 | S46 |
| **H2** | S44's cost line omits the follow-up PR, 8 passes and the REJECT | 🟠 | S46 |
| **B2** | P1 and P2 — the flip's two gates — have **no roadmap owner** | 🟠 | **S46, blocking the flip** |
| **E2** | `.ai/.session-owner` gitignored and pinned at chat `12`; `clean_room.enabled: false` | 🟡 | backlog |

**Overall: 🔴.** Not because the direction is wrong — the north-star is intact, the OSS surface is
real, and the sequencing that produced this audit was defensible. 🔴 because **three of the four
findings that matter are checks that report green while doing nothing**: `check_session_coverage` sees
7 of 14 recent sessions, `check_ground_truth_no_code` passes on an empty range, `check_cost_tracking`
passes on a heading. A governance layer that proves the rails and never checks the cargo is half a
product — and this repo has already written that sentence about itself in `reviewer/SKILL.md`.

**What would move this to 🟡:** G1 and H1 fixed with gates, and F1 disclosed. Those three are the
whole distance.

---

## Ledger disposition (S40's 7 `DEFERRED` rows)

All re-probed this session; **no row moves on assertion.** `DONE` requires the command output beside
it; `DEFERRED` requires reason + expiry or `check_gt_remediations` blocks closeout.

| S40 row | Re-probe | Disposition |
|---|---|---|
| 1 — adoption baseline never read | registry still reports `@ifelse.codes/chitra` unindexed; 304 `@ifelse.codes/core` downloads unchanged | **DEFERRED** → S46 req **F6**. reason: needs a publish to measure. expiry 2026-10-31 |
| 4 — S16 vanished, no gate can see it | **CONFIRMED and worse** — `74b3c17` parked, nothing on `main`, and the detecting gate is itself blind (§G) | **DEFERRED** → S46 **G1**. expiry 2026-10-31 |
| 5 — `required-crew` structurally wrong | **CONFIRMED**; S44 recorded a **4th** waiver; roadmap still assigns it to a completed session | **DEFERRED** → S46 **B1**. expiry 2026-10-31 |
| 8 — cost gate greps a heading | **CONFIRMED**; and the S44 cost line is now demonstrably incomplete | **DEFERRED** → S46 **H2**. expiry 2026-10-31 |
| 9 — two "hook-enforced"/`true` claims false | **CONFIRMED and worsened**: 8 → **17** of 60 commits; `.session-owner` still gitignored at chat `12` | **DEFERRED** → S46 **E1**. expiry 2026-10-31 |
| 10 — GT no-code backstop blind | **CONFIRMED** — and this session declined to rely on it (§Method) | **DEFERRED** → S46. expiry 2026-10-31 |
| 11 — closeout unsatisfiable in NO-CODE | **HALF-CLOSED, by this session.** The `required-crew` half stands; the `review-inputs-attested` half is **closed** — committing the contract on a `-closeout` branch made `canonical_inputs_sha` computable: `40bd7929…3a48ea4` | **DONE** (partial) + **DEFERRED** remainder → S46 |
| S40 row 7 (second half) — commit the artifact on a `-closeout` branch | **CLOSED** — this session runs on `session-45-ground-truth-closeout`, which is what `CONSTRAINTS.yaml`'s `ground_truth_commit_exempt_branch_suffixes` exists for | **DONE** |

**Rows closed by this session: 1 partial + 1. Rows re-confirmed: 6.** No row was closed by prose.