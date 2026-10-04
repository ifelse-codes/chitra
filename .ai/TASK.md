# Current Task Pointer

## Session 44 — cleanup Batch 4: OSS polish + the founder decisions

- **Branch:** `session-44-oss-polish`, from `main` `1b6c17d` (the S43 merge).
- **Product:** **`@ifelse.codes/chitra@0.3.0`**, live on npm, **untouched** by this session.
- **Contract:** `prompts/44-task-oss-polish.md` — at HEAD, plus `## Contract amendments` →
  **A1** (D5's removal set: the real test is *does the override change resolution*, not *is the
  package named in the lockfile*) and **A2–A4** (the cold review's D4b figures, the scrub's
  `sessions/` edits, and requirement 10's own wording).
- **Delivered:** 14 requirements in four groups.
  - **OSS surface (1–6):** `SECURITY.md` (supported versions, private disclosure, explicit
    no-SLA/no-bounty scope that includes the release pipeline), `CODE_OF_CONDUCT.md`
    (Contributor Covenant 2.1 + enforcement ladder, **no invented mailbox** — private reports
    route through the one channel that reaches the maintainers), `.github/ISSUE_TEMPLATE/`
    (bug + feature forms, `config.yml` with blank issues off and three real contact links),
    `.github/PULL_REQUEST_TEMPLATE.md`, a **CI badge** pointing at `ci.yml`, **coverage enforced**
    in the `core` job (`test:coverage` replaces the plain `Test` step — suite still runs once),
    and **`engines`** derived from what `ci.yml` pins (repo `>=26` / pnpm `>=9.12.3`; package
    `>=22` **disclosed in CONTRIBUTING as a support policy, not a test result**).
  - **Decisions (7–8):** **D1 = A** (publish every tracked process file — derive it with
    `git ls-files .ai prompts sessions reviewer .claude darshan | wc -l`), **D2** documented in
    `CONTRIBUTING` (hooks are local config; a clone gets none), **D3/D6 = ignore**
    (`playground/` and the mockups stay untracked), **D4 = scrub** (15 files, one mechanical
    commit, `--no-verify` under the contract's own authorisation because the 3-file cap cannot
    express it), **D4b = recorded, not done** (history rewrite belongs to the flip),
    **D5 = all 81 overrides stripped**.
  - **Carried findings (9–10):** **N1** — a rule in `reviewer/SKILL.md` and
    `contract-freshness` in `verify-closeout.sh` (pure core so the session gate can extract it);
    **§4.9** — `VAJRA_GATE_SCOPE=fast|full` plus per-check timings, priced from measurements the
    gate writes itself.
  - **Proof (11–14):** product re-proved from live facts, `.ai/` re-synced with counts derived,
    fidelity map + independent cold review.
- **The counterfactual:** `s43-gate-verbatim-goes-red` extracts S43's **real**
  `ai-files-describe-s43` body and asserts it exits non-zero here — that check hard-codes
  `.ai/SESSION = 43` and the `session-43-docs-weight` branch, so it cannot survive S44's
  re-sync. The port re-expresses it as `ai-files-describe-s44`.
- **Product code:** 0 changes under `packages/core/src/`; **453/453** unchanged; no lockfile
  change at all.
- **Closeout:** `verify-session-44.sh` and `verify-closeout.sh` (or a recorded founder waiver
  for `required-crew`, as S38/S39/S42 did). Summary + cold review: `sessions/session-44-*.md`.
- **Next session (S45):** **the public flip** — clone URL, npm `repository.url`/`homepage`,
  provenance, a real `0.4.0`, and **D4b**. Open in a **new chat** — one vajra-session per chat.
