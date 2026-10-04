# chitra — Continuation Handoff (after S44)

**Resume in a NEW chat (S45).** `.ai/SESSION` = 44; **`@ifelse.codes/chitra@0.3.0` is LIVE
on npm** (`latest`); the repo is still **private**. `main` = the S43 merge `1b6c17d`; S44's
branch `session-44-oss-polish` is the work just done.

> **The one thing to carry forward:** the founder decisions are **answered**, and the answers
> live in the contract, `sessions/session-44-summary.md` and `.ai/STATE.md` — not in a
> transcript. **D1 = A** (publish all ~146 process files), **D2** documented in CONTRIBUTING,
> **D3/D6 = ignore**, **D4 = the tree is scrubbed**, **D4b = history is not, and that is yours
> to schedule**, **D5 = all 81 `overrides` removed with a zero-delta lockfile**. The product was
> not touched: **453 green**, and no file under `packages/core/src/` changed.

## Where we are

Detail: `sessions/session-44-summary.md` + `sessions/session-44-review.md` + `.ai/STATE.md`.

| Delivered in S44 | State |
|---|---|
| `SECURITY.md` | **shipped** — supported versions, private disclosure, no-SLA/no-bounty scope that includes the release pipeline |
| `CODE_OF_CONDUCT.md` | **shipped** — Contributor Covenant 2.1, **no invented mailbox** |
| issue forms + PR template | **shipped** — bug + feature forms, `config.yml` with blank issues off |
| CI badge | **shipped** — URL read out of the README, file must exist; RED on `main` |
| coverage in CI | **shipped** — `test:coverage` replaces the plain `Test` step; suite runs once; no coverage service |
| `engines` | **shipped** — repo `>=26`/`>=9.12.3` from `ci.yml`; package `>=22` stated as policy |
| D1–D6 | **answered + recorded** (D4b deferred to this session) |
| N1 — contract freshness | **closed** — rule in `reviewer/SKILL.md`, pure gate in `verify-closeout.sh` |
| §4.9 — gate cost | **priced** — `VAJRA_GATE_SCOPE=fast\|full` + per-check timings |
| D5 — workspace overrides | **removed** (81), lockfile **byte-identical** to `main` |

## S45 — the public flip

1. **History rewrite first (D4b).** The tracked tree is clean; **`main` still carries the
   home path** (the scrub touched this branch only), so the purge is still required — and it
   moves **every** commit reachable from `HEAD`, which `git rev-list --count HEAD` derives.
   `.ai/` cites `main` at
   `49e1ee2`, PR merge history and every recorded ref move with it. Decide the tool and the
   re-verify order **before** pushing. **Irreversible once published.**
2. **The public-facing resolutions** — README `git clone` URL, npm `repository.url` /
   `homepage`, and **npm provenance** (a private repo cannot generate it, which is why S38's
   trusted publisher has never proved itself end to end).
3. **A real `0.4.0` through CI** — the cheapest close on the trusted-publisher claim, and the
   first release that can carry provenance.
4. Then the **GTM proof pack**: record the measured **zero** downloads as `t0`; **never cite
   the 304 `@ifelse.codes/core` self-downloads** — they are release-runner shaped.

## Also still open, untouched by S44

- **Seven pre-existing dead docs deps** S43 named: `framer-motion`, `react-icons`,
  `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`, `tw-animate-css`.
- **`minimumReleaseAgeExclude: stripe-replit-sync`** — same species as the D5 overrides, but
  not an `overrides` entry, so requirement 11 did not reach it.
- **S40's governance rows** — `required-crew` (three founder waivers), the vacuous
  `check_ground_truth_no_code`, the cost gate that greps "Cost Tracking", and **S16**.
- **Historical verify scripts are frozen** and several are unrunnable (01, 02, 03, 07, 31, 34,
  36, 37, 38). The live set is **39 / 42 / 43 / 44**.
- **A contract rewrite now fails closeout.** If S45 edits `prompts/45-*.md` after
  `sessions/session-45-review.md` exists, `contract-freshness` turns red — append an amendment
  instead of rewriting the requirement.
