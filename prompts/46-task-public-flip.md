# Session 46 — the public flip

**Status:** contract drafted by S45's ground-truth audit, at carry-forward. **Not yet amended or
reviewed** — a draft, so `reviewer/SKILL.md`'s N1 freeze has not attached.

**Why this contract exists where it does.** S45 was a NO-CODE ground-truth session
(`45 % 5 == 0`): `hook-ground-truth-guard.sh` (L3) blocks every write outside
`sessions/ .ai/ prompts/ *.md`, and the flip's `0.4.0` needs `packages/core/src/version.ts`. The flip
therefore **carries forward whole**, from `prompts/45-task-public-flip.md` § *Carried to S46*, with
every number and done-condition preserved. **46 % 5 == 1** — S46 is an ordinary code session.

---

## The one story

> **The repo stops being private, and every claim it makes becomes checkable by a stranger — each
> remote fact proven by a recorded before *and* after.**

Gated on **P1** and **P2** below. Both are preconditions, and P1 is **irreversible once the repo is
public** — so the decision is made *before* the push, never after.

---

## Preconditions — must be green before F1

| # | Prerequisite | State at S45 (derived) | Done-condition |
|---|---|---|---|
| **P1** | **D4b — the home path out of every commit reachable from `HEAD`** | `(/|-)Users[-/][a-z]+` matches **0** files in the tree at `main` and at `HEAD`, but **1001** (commit, file) pairs across history; earliest carrier S10. The commit count a rewrite moves was **443 at S45's audit** — **derive it, never trust that figure**, it moves with every commit: `git rev-list --count HEAD` | the pattern matches **nothing** in **any** commit reachable from `HEAD`, re-derived by walking `git rev-list HEAD` |
| **P2** | **Private vulnerability reporting established** | `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting` → **404**; `.github/REPO-SETTINGS.md` records the row **`unknown`** ("also what a caller without admin access gets", so it cannot distinguish off from not-allowed-to-ask). `SECURITY.md` and `CODE_OF_CONDUCT.md` both hedge it — a **closed door with honest signage**, not a lie | the row reads `enabled`, re-derived by the command already recorded beside it |

> **Correction carried from the S44 handoff, which is stale on this point:** it reads *"`main` still
> carries the home path."* After PR #65 the **tree** at `main` does **not** — only the **history**
> does. Re-derive; do not trust the citation.

**P1 is a repository-level rewrite, so S46 must decide — and record — the tool and the re-verify
order before pushing:** `git filter-repo` (preferred; refuses to run on a dirty tree, which is the
safety this needs) over `git filter-branch`; then re-verify **in this order**, because each step
invalidates the next's inputs: (1) the pattern matches nothing in any commit reachable from `HEAD`;
(2) the working tree at the rewritten tip is **byte-identical** to the pre-rewrite tip
(`git diff` empty, not "looks the same"); (3) `git rev-list --count HEAD` is unchanged; (4) the
**tracked-file count** is unchanged (`git ls-files | wc -l`); (5) 453/453 + typecheck + drift green.
Then force-push once, and tell every reader that SHAs moved.

---

## Scope — 6 requirements

**F1 — The repository is public.** `gh api repos/ifelse-codes/chitra --jq .private` reads `false`,
with the **pre-flip** reading (`true`) recorded beside it. *Counterfactual: today the same command
returns `true`.*

**F2 — The README `git clone` URL resolves to an anonymous client.** HTTP **200** post-flip; the
pre-flip **404** recorded beside it. *Today: 404.*

**F3 — npm `repository.url` and `homepage` resolve — and are not edited.** Both fields **already hold
correct values** in `packages/core/package.json`; they were unreachable, not wrong. Evidence = their
current bytes + the pre-flip 404 + the post-flip 200. **Editing either field is a FAILURE of F3, not a
delivery**, unless the pre-flip probe shows the value was wrong. *This is the requirement most likely
to be faked by editing a manifest to look busy.*

**F4 — `.github/REPO-SETTINGS.md` is re-derived post-flip.** Every row re-probed by the command
recorded beside it; `private` → `false`; the private-reporting row updated to whatever P2 made it.
**The file's own rule is binding:** anyone extending its clauses "must widen this paragraph in the same
commit, or this file will advertise an invariant the gate does not keep." The flip invalidates the
table; shipping it stale is the exact defect class S44 built the file to prevent.

**F5 — `0.4.0` + npm provenance, released by CI unattended.** `packages/core/package.json` **and**
`packages/core/src/version.ts` bumped (`ci.yml:41` asserts they match — it cannot be routed around),
CHANGELOG, tag `v0.4.0` on merged `main`; published through **Trusted Publishing** with **no human,
no tmux, no passkey, no `NODE_AUTH_TOKEN`**; `0.4.0` **carries provenance and `0.3.0` does not** —
*the asymmetry is the proof, because `0.3.0` was published from a private repo.*
**F5 changes no workflow:** `release.yml` already runs `npm publish --access public` with no
`--provenance` flag, because npm attaches provenance automatically once the repo is public
(`release.yml:100–103`).

**F6 — GTM baseline recorded as `t0`, and the baseline is NOT zero.** Corrected by S45's cold review,
which falsified the premise this requirement inherited. `@ifelse.codes/chitra` **is** indexed:
**119** lifetime downloads, first non-zero **2026-09-29 = 89** — the same day `0.3.0` was published
(`npm view @ifelse.codes/chitra time` → `2026-09-29T13:30:46.739Z`), then 15 / 6 / 5 / 4 / 0.
`@ifelse.codes/core` is **318** lifetime, not 304. **So record `t0` as _119 downloads, none organic_**
— the whole figure lands inside a 6-day window that begins on the publish day, which is the
release-runner shape — and derive it with
`curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra"`.
**Never cite either package's downloads as traction, and never write "zero":** the number is real, its
*shape* is what disqualifies it.

**Also owed by S46, because the audit found the gates unowned:** record **P1's tool and re-verify
order** as a decision before the push, and record **P2's** outcome in F4's table.

---

## Out of scope — named, so it cannot be smuggled in

| Item | Why |
|---|---|
| **The 11 S45 audit findings** | 🔴 G1 (`check_session_coverage` blind for S38–S44), H1 (the cadence appears in **0** of `AGENTS.md`/`SESSION-BOOT.md`/`TASK.md`), C1 (8 stale facts), F1-as-**S45-F1** (S44's canonical verdict is **REJECT** while `STATE.md` records COMPLETE, and a REJECT makes `check-inputs-attested` read `N/A` — **S44 has no DECISION-003 attestation**), B1 (`ROADMAP.md:56` schedules `check_required_crew` to a completed S44), E1 (**17/60** commits breach the 3-file cap, up from 8), plus C2/C3/H2/E2 | **Governance/gate work — a different story from the flip.** Carried as the leading **S47** candidate in `.ai/ROADMAP.md` with owners and severities. S45's audit is the specification; `sessions/session-45-ground-truth.md` § *Findings, ranked* is the ranked list. Fixing `verify-closeout.sh` **in the same session that makes the repo public** would put the repo's public surface and its gates in one unreviewable commit |
| Seven dead docs deps · `minimumReleaseAgeExclude` | weight, not flip |
| The MCP server | founder-DEFERRED since S38 |
| The rest of the GTM proof pack | F6 is `t0` only |

---

## Assumptions (2 — the cap)

- **AS-1 — "carry forward" means the flip moves whole and keeps its identity.** Numbers `F1–F6` and
  `P1–P2` are preserved verbatim from S45's contract so a requirement cannot be quietly renumbered —
  the failure mode that made **S16** invisible to every ledger.
- **AS-2 — the flip is one story and the audit's 11 findings are another.** Two stories would breach
  "max 1 story per session", and mixing them would put the public surface and the governance gates in
  one commit.

## Founder decisions needed at plan approval

- **D-F1 — P1's rewrite tool** (`git filter-repo` recommended) and the re-verify order above.
  **Irreversible once public.**
- **D-F2 — P2**, a repository setting only the founder can change: enable private vulnerability
  reporting, or record a waiver naming that `SECURITY.md`/`CODE_OF_CONDUCT.md` keep pointing at a
  hedged route that is not established.
- Commit approval.

---

## Closeout

`sessions/verify-session-46.sh` + `demo-session-46.sh` (S46 is a code session —
`check_verify_demo_scripts` applies) · `sessions/session-46-summary.md` ·
`sessions/session-46-review.md` (cold, attested) · `.ai/` synced · `verify-closeout.sh` exit 0.

## The counterfactual this session demands

**A visibility change leaves no trace in the tree.** Any session can type `private: false` into a
markdown table and every gate here will agree — so every remote fact needs a `before` row captured
before the flip and an `after` row captured after, both with the command that re-derives it.

```
gh api repos/ifelse-codes/chitra --jq .private                                   # before: true
curl -s -o /dev/null -w '%{http_code}' https://github.com/ifelse-codes/chitra     # before: 404
gh api repos/ifelse-codes/chitra/private-vulnerability-reporting                  # before: 404
```

**A flip with no recorded `before` FAILS.** The `before` rows are reproducible by anyone today, which
is exactly what makes them evidence rather than narration.