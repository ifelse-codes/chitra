# Current Task Pointer

## Session 43 — cleanup Batch 3: docs weight

- **Branch:** `session-43-docs-weight`, from `main` `49e1ee2` (the S42 merge).
- **Product:** **`@ifelse.codes/chitra@0.3.0`**, live on npm, **untouched** by this session.
- **Contract:** `prompts/43-task-docs-weight.md` — at HEAD, which is what
  `review-inputs-attested` hashes.
- **Delivered:** 10 requirements.
  - **Deleted:** the **43** unused shadcn components (live set discovered: 12), the **30**
    devDeps that died with them (lockfile regenerated in its own commit), the three
    `@replit/*` Vite plugins (+ their workspace-catalog entries), the dead `lint` script.
  - **Prettier (F43-1):** `.prettierrc` + `.prettierignore` checked in, repo formatted
    (one mechanical commit, `--no-verify` — the 3-file cap cannot express it), `format:check`
    wired into CI as a new `format` job.
  - **The gate:** `verify-session-43.sh` is a **port** of `verify-session-42.sh`; the eight
    S42 findings **N2–N9** are fixed in it, each with a demonstrated counterfactual.
- **The counterfactual:** `s42-gate-verbatim-goes-red` extracts S42's REAL `charts-untouched`
  body and asserts it exits non-zero on the S43 format — S42 enumerated the LOCKED dirs, and
  S43 is the first session to legitimately reformat them. The port re-expresses it as
  `charts-format-only`.
- **Product code:** 0 semantic changes under `src/charts/`, `src/renderers/`, `src/themes/`;
  453/453 tests unchanged; each changed file is proven to be the Prettier transform of `main`.
- **Closeout:** `verify-session-43.sh` and `verify-closeout.sh` (or a recorded founder waiver
  for `required-crew`, as S38/S39/S42 did). Summary + cold review: `sessions/session-43-*.md`.
- **Next session (S44):** cleanup **Batch 4 — OSS polish + decisions D1–D6**, then the public
  flip. Open in a **new chat** — one vajra-session per chat.
