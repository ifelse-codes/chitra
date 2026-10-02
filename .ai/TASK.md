# Current Task Pointer

## Session 41 — COMPLETE. Cleanup Batch 1: the public face is honest, a fresh clone builds

- **Branch:** `session-41-repo-cleanup`, from `main` `ece61fc` (== `origin/main`).
- **Contract:** `prompts/41-task-repo-cleanup.md` — committed at HEAD, which is what
  `review-inputs-attested` hashes. S40 failed that gate because a NO-CODE session cannot
  commit its contract; this one could, and did.
- **Delivered:** all 13 numbered requirements, 12 SHIPPED and 1 PARTIAL (req 8 —
  `AGENTS.md`/`CLAUDE.md` still point into `.ai/`, which is founder decision **D1** that
  the contract explicitly does not make). 32 commits, 34 tracked files, **0 files touched
  under the LOCKED chart code**. The S41 gate is 24/24, each check with a demonstrated
  counterfactual; the core suite is green; S39's gate is 43/43. The package is
  **`@ifelse.codes/chitra@0.3.0`**, live on npm.
- **The three that were live, not theoretical:** the docs site at `chitra.iifelse.com` was
  serving the Replit placeholder as its meta description; `VERSION` shipped to npm as
  `0.1.0` against a `0.3.0` manifest; and a fresh clone could not build at all.
- **Fidelity map:** `sessions/session-41-summary.md`. **Independent verdict (6 passes,
  ACCEPT):** `sessions/session-41-review.md`. The review rejected the delivery twice and
  every finding was fixed in place — including a check that provably could not fail, a
  guard scoped to its author's habits, three fabricated numbers in the demo, and a
  missing test the builder's own summary had called done.
- **Carried forward, unchanged:** the S40 governance rows (`required-crew`, the vacuously
  passing no-code check, the cost gate that greps a heading, disposition S16) and the GTM
  proof pack, which must record the measured zero downloads as its `t0` and must never
  cite the 304 self-downloads.
- **Next session (S42):** cleanup **Batch 2 — dead weight** (`mockup-sandbox`, `lib/`,
  `api-server`, `attached_assets`, 5 dead scripts). Then S43, then S44, then the flip.
  Blocked on the founder's **D1** and **D4**. Open in a **new chat**.
