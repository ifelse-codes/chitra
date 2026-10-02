# chitra — Continuation Handoff (after S43)

**Resume in a NEW chat (S44).** `.ai/SESSION` = 43; **`@ifelse.codes/chitra@0.3.0` is LIVE
on npm** (`latest`); the repo is still **private**, by decision — it goes public after a code
cleanup. `main` = the S42 merge `49e1ee2`; S43's branch `session-43-docs-weight` is the work
just done.

> **The one thing to carry forward:** the docs app now ships the components it renders and
> nothing else — **53** unused shadcn components, the **36** devDeps that served them, the
> three `@replit/*` Vite plugins and the dead `lint` script are gone, and **Prettier is
> adopted and CI-enforced** (F43-1). The product was not touched: 453 tests stay **453 green**,
> and every change under the LOCKED chart dirs is proven to be a Prettier transform.

## Where we are

Detail: `sessions/session-43-summary.md` + `sessions/session-43-review.md` + `.ai/STATE.md`.

| Delivered in S43 | State |
|---|---|
| 53 unused shadcn components | **deleted** — live set (2) discovered, not enumerated |
| 36 dead devDeps | **removed** + lockfile regenerated in its own commit (64 → 25) |
| 3 `@replit/*` Vite plugins | **removed** from config, manifest, and workspace catalog |
| dead `lint` script | **removed** — it called an eslint installed nowhere |
| Prettier | **adopted** (`.prettierrc` + `.prettierignore`), repo formatted, CI `format` job |
| S42 gate | **ported** to `verify-session-43.sh`; N2–N9 fixed, each with a counterfactual |
| Product | **untouched** — 453 tests unchanged; LOCKED dirs reformat-only (proven) |

## S44 — cleanup Batch 4: OSS polish + the founder decisions (the roadmap's next item)

1. **OSS polish:** `SECURITY.md`, `CODE_OF_CONDUCT.md`, issue/PR templates, a CI badge, a
   coverage job, and `engines`.
2. **Founder decisions D1–D6:** **D1** (how much internal process goes public — options B/C
   break `check_session_coverage` / `check_task_ref` unless the gates are rewritten first);
   **D2** (hooks activation); **D3/D6** (track or ignore `playground/` + the design mockups);
   **D4** (the `/Users/REDACTED/…` scrub — **irreversible once published**); **D5**
   (`pnpm-workspace.yaml` `overrides` cruft, needs its **own** lockfile regen).
3. **Two carried findings:** the contract-rewrite freshness hole (S42 N1), and the **~60-minute
   gate cost** (§4.9). S43 did not worsen the cost — its counterfactual extracts one check
   from `verify-session-42.sh` rather than chaining S42's whole gate.

## Then

- **The flip** — resolves the README `git clone`, npm `repository.url` and `homepage`, and
  turns npm provenance on, in one move.

## The two decisions only the founder can make

- **D1 — how much internal process goes public?** `~146 files`. Option A (keep) keeps the
  closeout gates working. **B and C break `check_session_coverage` / `check_task_ref` unless the
  gates are rewritten first.**
- **D4 — the personal-path scrub.** Tracked files carry `/Users/REDACTED/…`. **History is published
  with the flip; this is irreversible after it.** Answer before, not after.

## Also still open

- **A real `0.4.0` through CI** — the cheapest close on the trusted-publisher claim.
- **GTM proof pack** — record the measured **zero** downloads as `t0`; never cite the 304
  `@ifelse.codes/core` self-downloads.
- **S40's governance rows** — `required-crew` (now a **third** waiver; demands a handoff the
  Session Loop never asks for), `check_ground_truth_no_code` passing **vacuously**, the cost
  gate that greps "Cost Tracking", and **S16**.
- **Seven pre-existing dead docs deps** S43 named but did not remove (framer-motion,
  react-icons, @tanstack/react-query, zod, date-fns, @tailwindcss/typography, tw-animate-css) —
  they did not die with the 43 components, so they were out of scope.
- **Historical verify scripts are frozen** and several are unrunnable (01, 02, 03, 07, 31, 34,
  36, 37, 38). The live pair is **39 / 42 / 43**.
