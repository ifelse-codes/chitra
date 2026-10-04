# Current Task Pointer

## Session 46 — the public flip (complete, closed 2026-10-04)

- **Branch:** `session-46-public-flip`; delivery **4 commits / 9 files** on top of `8a083c8`,
  squash-merged to `main` = **`86bc909`** (PR **#68**).
- **Contract:** `prompts/46-task-public-flip.md` — preconditions **P1/P2**, requirements **F1–F6**.
  **Never amended**; the N1 freeze held because the contract was not touched after the cold review
  started.
- **Delivered:**
  - **P1** — `git filter-repo` 2.47.0 rewrite of every ref we own: **1001 → 0** (commit, file) pairs
    across **444** commits; tree / count / tracked-files preserved (`8a083c8`, tree `8167462…`,
    **367**); one force-push, `--no-verify` disclosed (the tracked pre-push hook blocks *any* `main`
    push). **Residual disclosed:** `refs/pull/*` is read-only and **56 of 67** PR heads still carry
    the old blobs — support ticket **owed**.
  - **P2** — `{"enabled":true}`. Could not be green before F1 (public-repo-only endpoint, proved
    against a public control with `admin: true`); founder reordered to **F1 → P2** rather than
    waiving (**D-REORDER**, recorded in `sessions/session-46-flip.md`).
  - **F1/F2** — `private` `true`→`false`, `visibility`→`public`, clone URL `404`→`200`, anonymous
    clone works. **F3** — `homepage` + `repository.url` **unedited** (only the `version` line differs
    from `main`), URL now resolves. **F4** — every `REPO-SETTINGS` row re-probed; `SECURITY.md` and
    `CODE_OF_CONDUCT.md` no longer call an established route a pre-flip task.
  - **F5** — `0.4.0` (manifest + generated `version.ts` + CHANGELOG) tagged on merged `main`, CI run
    `37217761468` published it through Trusted Publishing with **no workflow edit**; `0.4.0` carries
    provenance (sigstore log `3078088104`), `0.3.0` does not.
  - **F6** — `t0` = **119 lifetime downloads, none organic**, recorded in `.ai/STATE.md` and derived
    from the downloads API; the two `.ai/` files that still called the baseline zero were corrected.
- **Product:** **453/453** unchanged; no `packages/core/src` change except generated `version.ts`;
  no lockfile change; **0** npm secrets; **1** release.
- **A gate was fixed, not left red:** S44's `home-path-scrubbed` demanded a commit that still carries
  the path — permanently unsatisfiable after P1. Proof moved to runtime-assembled samples plus an
  inverted history walk (`scripts/verify-session-44.sh`).
- **Closeout:** `scripts/verify-session-46.sh` (16 checks) + `demo-session-46.sh`; summary + cold
  review in `sessions/session-46-*.md`; `verify-closeout.sh` green behind the founder crew waiver
  (Vajra cannot verify helper provenance under OpenCode).

## Next session (S47)

- **Leading candidate:** the **S45 audit's 11 findings** — spec at
  `sessions/session-45-ground-truth.md` § *Findings, ranked*. Chiefly `check_session_coverage`
  (blind for S38–S44), the GT cadence missing from `AGENTS.md` (vajra-owned), S44's undisclosed
  `REJECT`, the 3-file cap (17 of 60), the stale-fact class, and the **owed GitHub support ticket**
  for the P1 residual.
- Alternatives: the **GTM proof pack** beyond `t0`, or **new product surface** (none since `c72cc14`).
- Contract for S47 does not exist yet — write `prompts/47-task-*.md` at plan time.
