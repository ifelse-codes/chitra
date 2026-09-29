# chitra — Continuation Handoff (after S39)

**Resume in a NEW chat (S40).** `main` = S00–S39 (`68d0b26`); `.ai/SESSION` = 39;
`v0.3.0` on `main` HEAD (`v0.1.0`/`v0.2.0` sit on their original commits, never moved);
**`@ifelse.codes/chitra@0.3.0` is LIVE on npm**
(`latest`).

> **The one thing to carry forward:** a brand-new package name can never be published by CI.
> npm keeps the trusted-publisher config *inside the package's own settings page*, and a package
> that does not exist has no settings page. **Renaming always costs one human publish**, and the
> unattended property does not come back until the *next* version.

## Where we are

S39 renamed the package. Detail: `sessions/session-39-summary.md` + `sessions/session-39-review.md`
+ `.ai/STATE.md`.

| Delivered in S39 | State |
|---|---|
| `@ifelse.codes/chitra@0.3.0` | **live**, 38 files / 446,756 B, consumer-verified |
| Rename across 27 changed files | `charts.ts` regenerated, never hand-edited |
| `mcp` keyword | **dropped** — nothing ships it; a keyword is a promise |
| The npm chicken-and-egg | `v0.3.0` publish job 404'd on a missing publisher — **proven, not assumed** |
| Who actually published | **a human**, 13:30:46Z. CI published **zero** times — asserted, not narrated |
| Idempotency guard | proven **behaviourally** (attempt 2 skipped), not by grep |
| Deprecation | **dropped** by founder — no public release, nobody to redirect |
| Verify | `verify-session-39.sh` **41/41**, 14 counterfactuals, all bit |

## S40 candidates (founder ranks these)

1. **GTM proof pack** — benchmarks / token-savings / before-after. Unblocked, and it now
   measures the final install command.
2. **A real `0.4.0` through CI** — the cheapest proof that the trusted publisher works, turning
   a founder attestation into a demonstrated fact. **Nothing needs to change for it**; the
   pipeline is already wired and the publisher already exists.
3. **Fix the `required-crew` gate** — it demands a tech-lead handoff `.ai/AGENTS.md`'s Session
   Loop never asks for, and it has now cost two founder waivers (S38, S39). Either surface the
   crew step in the constitution or drop the gate.

## Later

- **MCP server stays deferred** — a release exists (`0.3.0`); demand is still the missing half.
- **Repo visibility** (private ⇒ no npm provenance) — founder's open decision, unchanged. If it
  flips, `release.yml`'s comment must change with it or it becomes a lie.
- **Publishing access → require 2FA and disallow tokens** — deferred at the founder's direction
  ("ship first, watch adoption, harden later"). Decide a *trigger* (first real install, first
  external issue), not a date.
- `artifacts/api-server` beyond `/healthz` — the undecided "if the hosted API is pursued" bet.

## Notes / gotchas earned this session

- **A brand-new package cannot be OIDC-published.** Chain: OIDC publish → needs a trusted
  publisher → needs the package → needs a publish only a human can make. PyPI allows configuring
  OIDC for a not-yet-existing package; npm does not. The failure is
  `PUT …/@scope%2fname` → **404 "could not be found or you do not have permission"**, and the
  tarball builds fine right up to it, so the log looks healthy until the last line.
- **"publish time ≥ run start" does NOT prove CI published.** It passed for `0.3.0` while being
  false. To discriminate, assert three things: attempt 1's publish job failed; attempt 2 took
  the **skip** path (log has "is already on npm — skipping publish", no "Publishing to"); and
  npm's publish time **precedes** attempt 2's `started_at`. Read per-attempt data with
  `gh api repos/{o}/{r}/actions/runs/{id}/attempts/{n}/jobs` — **`gh run view` reports only the
  LATEST attempt**, which silently erases a failed first one.
- **A check can be hollow in its *scope*, not just its logic.** The honesty guard grepped three
  files under a name promising the whole surface, and none of them was the docs app a reader
  actually sees. Name a check after the surface it covers, and cover it.
- **A comment that asserts a property the code lacks is worse than no comment.** The hero-pill
  check said "pins it to the manifest" and grepped a hardcoded literal; bump the version and
  forget the pill, and it still passed. **Derive** expected values from the source of truth.
- **A summary table that hardcodes `WORKS` is a fabricated checkmark.** The demo printed green
  for two rows even when the check one screen above had printed a red cross. Recompute them.
- **Broad greps get narrowed away.** A blanket `deprecat` check false-positives on legitimate
  history (npm deprecating bypass-2FA tokens), and a check that must be quietened is a check
  that ends up checking nothing. Match the *specific lie* instead.
- `run_check` helpers that shell out via `bash -c` need BOTH the function and every variable it
  reads `export -f`/`export`ed. An unexported `$APP` expands to nothing and `grep -q PATTERN`
  with no file reads stdin and fails.
- Never use a bare `for f in a b c` for file lists — an unquoted word list is subject to
  globbing/splitting and was observed mangling an entry. Use an array **and** test `[ -f "$f" ]`
  first, because `grep` exit 2 (missing file) and exit 1 (name absent) are different failures.
- `npm login --auth-type=web` blocks on "Press ENTER to open the browser…". Opening the URL by
  hand instead lets the CLI die with `npm error Exit handler never called!`. Press Enter; npm
  opens the browser and the flow stays live. The publish then needs a *second* browser auth at
  `/auth/cli/<id>`.
- A **stale revoked token in the global `~/.npmrc` is sent to the registry** on authenticated
  calls and wins over interactive auth. Isolate with `export npm_config_userconfig=<tmp>` and
  delete the tmp file afterwards — the web-login session token dies with it.
- **Packument propagation lag, re-confirmed:** a successful publish 404'd on `npm view` for
  **~4 min**. Re-query; never re-publish on a 404.
- **pnpm cannot do npm Trusted Publishing.** pnpm 9.12.3 predates the feature; its auth is
  token-only. Use `npm publish` (npm ≥ 11.5.1, Node ≥ 22.14.0) for the publish step only.
  pnpm still does install/build/test. **Reusable constraint.**
- Frozen `sessions/`, old `prompts/`, old `scripts/verify-session-*.sh` and the dated S36–S38
  sections of `.ai/KNOWLEDGE.md` still name `@ifelse.codes/core` **on purpose** — they are
  history, not live facts. `scripts/workflows/15-qacheck.sh` is a frozen S15 artifact and
  cannot pass; ignore it.

## Housekeeping

- `pnpm --filter @ifelse.codes/chitra run test` → **452 green**
- `scripts/verify-session-39.sh` → **41/41**
- `scripts/demo-session-39.sh` → exit 0
- `scripts/verify-closeout.sh 39` → needs `VAJRA_CLOSEOUT_WAIVER=39` (`required-crew`,
  founder-waived, recorded in the close log)
