# Session 48 — the GTM proof pack

**Status:** contract drafted at plan time from `.ai/ROADMAP.md:219` (the S41-era
candidate *"a GTM proof pack (benchmarks / token-savings / before-after)"*) and
`.ai/GT-REMEDIATIONS.md` row 1 (adoption baseline, **DEFERRED, expiry 2026-10-31**).
**Not yet reviewed** — `reviewer/SKILL.md` N1 freeze has not attached.

**Why this contract exists where it does.** S46 made the repo public and S47 made the
gates able to fail. Neither touched the question S40 asked and S45 sharpened: *nothing
here has been released-and-marketed*. The baseline was never the problem — it was never
**read**. **48 % 5 == 3** — S48 is an ordinary code session; **S50** is the next
ground truth.

**Preconditions, re-derived at plan time (2026-10-06):**

| Fact | Reading | Command |
|---|---|---|
| npm `latest` | `0.4.0` | `npm view @ifelse.codes/chitra version` |
| downloads (18-month window) | **273** — `t0` was **119** on 2026-10-04 | `curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra"` |
| public docs | `https://chitra.iifelse.com` (Pages `chitra-5xh.pages.dev`) | `.ai/KNOWLEDGE.md` L176 |
| chart modules in tree | **23** | `ls packages/core/src/charts/*.ts \| wc -l` |
| README badge says | **`charts: 20`** — stale on the day this was written | `README.md:13` |

> The last two rows are the thesis of this session in one line: **the public claim and
> the tree already disagree, and nobody's gate noticed, because no gate looks at the
> front door.**

---

## The one story

> **Every number a stranger sees is produced by a command, and there is one measurable
> path from stranger to install.** A claim nobody can re-derive is not marketing — it is
> a bug with a shield.io badge on it.

---

## Scope — 6 requirements

**R1 — the front door's claims are derived, not typed.** Every count and version on
`README.md` and `packages/core/README.md` (chart count, test count, version, dependency
count, license) is checked by `scripts/verify-session-48.sh#claims-match-truth` against
the live tree, the manifest and the suite, and **red on the first disagreement** —
starting with `charts: 20` vs the tree's **23**. *Done-condition:* the check fails when
a badge is retyped; the corrected badge is derived by the same command the check runs.
*Counterfactual: retype `20` → red.*

**R2 — adoption is measured, not asserted (t0 → t1).** A script
(`scripts/gtm-reads.mjs` or equivalent) pulls the downloads API day-by-day, separates
publish-day / release-runner shaped days from every other day, prints the current
total **and its shape**, and writes the reading where the ledger can see it.
`.ai/GT-REMEDIATIONS.md` row 1 moves **DEFERRED → DONE** with that command as evidence.
*Done-condition:* `t0` (**119**) and today's reading (**273** at plan time) both appear
with the day-level series beside them, the delta is explained (release-shaped or not),
and no file calls the baseline zero. *Counterfactual: a downloads figure in `.ai/` that
the API does not return right now → red.*

**R3 — benchmarks exist because they were measured.** Bundle size (packed tarball
bytes), install footprint, dependencies (**0**), and a render-time figure for one
standard chart are produced by one script, cited in the README with the command beside
each number. *Done-condition:* each benchmark is re-runnable and the README says how.
*Counterfactual: a benchmark number with no command → red; a number the script does not
print → red.*

**R4 — one channel, one link, attributable.** The stranger path collapses to a single
canonical route: landing screen → 30-second install → one rendered example → docs. At
least **one public post or listing** is published and its **URL + date** recorded in
`.ai/STATE.md`, so R2's series has a date to line up against. *Posting needs the
founder's own identity — D-48-1 below.* *Done-condition:* URL + timestamp recorded and
the measurement window starts there. *Counterfactual: no URL in STATE → NOT-BUILT.*

**R5 — the first screen answers three questions, proven by probe.** A scripted check
confirms `README.md`'s top screen carries: the install command, a **live** demo link
(HTTP 200), and a rendered example whose bytes still match what the library prints
today (drift check against a real render). *Done-condition:* the check exits 0 on the
current tree and red when the example drifts or the link dies. *Counterfactual: break
the link or the example → red.*

**R6 — the record says what happened, not what we hope.** `ROADMAP.md`'s *"GTM proof
pack (benchmarks / token-savings / before-after)"* row is marked done with the evidence
pointer; `sessions/session-48-summary.md` states the pack's output **and** the outcome
separately (assets shipped vs downloads moved); no traction language anywhere beyond
what R2 derives. *Counterfactual: a summary sentence claiming traction with no R2 number
beside it → red.*

---

## Out of scope — named, so it cannot be smuggled in

| Item | Why |
|---|---|
| New chart modules / product surface | last new chart was `c72cc14` (S09) — real, but a different story; a channel asking for it is the trigger, not a guess |
| S47's disclosed residuals (root-dotfile asymmetry, asserted-not-derived cost counts, the waiver that covers two checks) | one small maintenance lane, its own session |
| Rebrand, pricing, paid ads, social accounts | founder decisions beyond one post |
| MCP server | founder-DEFERRED since S38, gate unmet |
| Claiming a download increase | an **outcome to measure**, never a deliverable to promise |

---

## Assumptions (2 — the cap)

- **AS-1 — README's positioning is the spec.** *"Terminal charts for CLIs and agents."*
  stays; this session makes it checkable, it does not rewrite it (D-48-2 can override).
- **AS-2 — one story: make the claim checkable and give it one measurable path.** The
  pack ships the **instrument**; the number it eventually reads is not this session's
  to deliver.

## Founder decisions needed at plan approval

- **D-48-1 — the channel.** One public post, under your identity: which one? (A place
  developers already look for CLI/agent tooling.) The session records the URL; you do
  the posting.
- **D-48-2 — the one-liner.** Keep README's current line, or replace it — you write the
  replacement if so.
- Commit approval.

---

## Closeout

`scripts/verify-session-48.sh` + `scripts/demo-session-48.sh` (code session) ·
`sessions/session-48-summary.md` · `sessions/session-48-review.md` (cold, attested) ·
`.ai/` synced (`SESSION` = 48) · `verify-closeout.sh` exit 0.

## The counterfactual this session demands

**A number nobody can re-derive is not proof.** The pack fails if any public claim,
benchmark or adoption figure is typed instead of printed by a command — and it fails
again if the instrument exists but was never run. Shield badges count as claims.
