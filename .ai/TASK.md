# Current Task Pointer

## Session 42 — IN PROGRESS. Cleanup Batch 2: dead weight

- **Branch:** `session-42-dead-weight`, from `main` `4893683` (the S41 merge).
- **Contract:** `prompts/42-task-dead-weight.md` — committed at HEAD, which is what
  `review-inputs-attested` hashes. S40 failed that gate because a session cannot
  commit a contract it never wrote; this one could, and did.
- **Scope:** 10 numbered requirements, against **`@ifelse.codes/chitra@0.3.0`** live on npm.
  Delete four dead trees (103 tracked files)
  and six dead scripts; cut the 9-file chain that references them; regenerate the
  lockfile; **port** the S41 gate rather than copy it; re-prove the product from
  live facts; browser QA + green CI; re-sync `.ai/`; fidelity map + independent
  cold review.
- **Delivered so far:** requirements 1–6 and 9a are committed. **110 files deleted,
  3 added, 11 modified**, 9 commits, **0 files touched under the LOCKED chart
  code**. Re-proven green: fresh clone → install → `pnpm run build` with no env
  vars, 453/453, root typecheck, S39's gate 43/43, `pnpm example`.
- **Two founder decisions taken, both asked in chat before any work:**
  deletions are outright with no archive branch (**F42-1** also authorises this
  session's agent to set `VAJRA_ALLOW_COMMIT` inline — see the contract, which
  records why that is a decision and not un-forgeable evidence); and
  `check-hero-dims.py` goes, letting `verify-session-31.sh` join the permanently
  unrunnable set.
- **Two roadmap claims did not survive the tree** and are recorded, not repeated:
  `mockup-sandbox` does **not** break the root build (both its build and its
  typecheck exit 0), and the "5 dead scripts" list names a file that does not
  exist.
- **Still to do:** requirements 7 (gate green end to end), 8 (browser QA + green
  CI), 9b (the rest of the `.ai/` sync), 10 (fidelity map + **independent**
  review), then the PR and closeout.
- **Next session (S43):** cleanup **Batch 3 — docs weight** (43 unused shadcn
  components, Prettier, the `lint` script with no eslint). Then S44, then the
  flip. Blocked on the founder's **D1** and **D4**. Open in a **new chat**.