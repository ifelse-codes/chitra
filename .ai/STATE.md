# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S39 done, 2026-09-29.)

## Active Branch
`main` — S39 merged (PRs #53 rename · #54 no-deprecate · #55 publish record). The package is
now **`@ifelse.codes/chitra@0.3.0`**, live on npm.

## What Currently Works (observed, not claimed)
- **The rename is complete and consumer-verified.** `@ifelse.codes/chitra@0.3.0` (38 files /
  446,756 B) installs clean into an empty dir, imports by package name (48 exported functions),
  and renders real `line()` / `horizontalBar()` / `plot().line()` charts with working
  `toJSON()` / ANSI-free `toPlain()`.
- **The release path is automated — from `0.4.0`, not from `0.3.0`.** `release.yml#publish` holds
  `id-token: write` + `contents: read`, references **no npm secret**, and runs `npm publish`
  (pnpm 9.12.3 predates Trusted Publishing and cannot exchange an OIDC token).
- **The trusted publisher for `@ifelse.codes/chitra` exists (founder-attested 2026-09-29).**
  Not repo-verifiable — npm's trusted-publisher API needs a session token. The evidence is the
  outcome, and **the outcome has not happened yet**: no release has gone through CI since it was
  created. Treat unattended publishing as *configured, not demonstrated*.
- **CI published `0.3.0` zero times — proven, not assumed.** The `v0.3.0` run's attempt 1
  `publish` job **failed** (09:07:01→09:07:31Z, `PUT …/@ifelse.codes%2fchitra` → 404 "could not
  be found or you do not have permission"). A human published at **13:30:46Z**. Attempt 2 took
  the idempotency **skip** path and the run went **4/4 green**. npm's publish time *precedes*
  attempt 2's start (13:40:18Z), so neither attempt could have produced the version.
- **Root cause of that failure is structural, not a misconfiguration:** npm configures a trusted
  publisher *per package, inside that package's settings page*, and a package that does not exist
  has no settings page. **A brand-new package name can never be OIDC-published — its first
  publish is necessarily human.** Renaming always costs one.
- **The idempotency guard is proven behaviourally, not by grep.** Attempt 2 emitted
  `@ifelse.codes/chitra@0.3.0 is already on npm — skipping publish`, which is only reachable from
  the live `npm view` branch against the *new* package name.
- **`@ifelse.codes/core` is NOT deprecated** (founder decision). No public release, no external
  user, so a deprecation notice is ceremony for an audience of one. The old package stays at
  `0.2.0` and still resolves.
- **Live docs site:** `chitra.iifelse.com` (`/ai-data` live). Hero pill reads `v0.3.0 · npm` — the
  S38 lie where it still read `v0.1.0` is fixed. The pill is still a JSX literal; what changed is
  that `hero-pill-matches-version` now *derives* the expected value from the manifest, so the next
  bump without a pill edit goes red instead of shipping. The pill itself is not generated.
- **`@ifelse.codes/chitra` library:** 20 charts, 3 renderers, 7 themes, `ChartResult`;
  LOCKED families S09–S28. `pnpm --filter @ifelse.codes/chitra run test` — **452/452**.

## What Is Broken / Incomplete
- 🟠 **Unattended publishing is configured but unproven.** No release has traversed CI since the
  trusted publisher was created. The cheapest close is a real `0.4.0` through the pipeline.
- 🟠 **No npm provenance.** The GitHub repo is **private**, and npm does not generate provenance
  for private repos even under trusted publishing. Confirmed on `0.2.0`: `dist.signatures` is
  present, `attestations: null`. Publishing is unaffected. Making the repo public would fix it and
  suits an MIT package — **founder's open decision**. If visibility flips, `release.yml`'s comment
  must change with it or it becomes a lie.
- **MCP server: founder-DEFERRED.** Not built, not stubbed. Gate: a release exists **and**
  someone demands it **and** it is worth building. The `mcp` **keyword was dropped** in S39 —
  a keyword is a promise in a search index, and nothing ships it.
- **The `required-crew` closeout gate is structurally wrong** and has now cost two founder
  waivers (S38, S39): it demands a tech-lead handoff that `.ai/AGENTS.md`'s Session Loop never
  asks for. Fix or drop it.
- `ci-no-auth-token-secret` covers **repo** secrets only — not org or environment secrets. None
  exist today and no environments are configured.
- A **revoked** `npm_xToANF…` token still sits in the founder's global `~/.npmrc` (outside the
  repo) and is sent to the registry on authenticated calls. S39's bootstrap publish used an
  isolated `npm_config_userconfig` instead, which was deleted afterwards.
- GTM proof pack (benchmarks / token-savings) still to build — now unblocked and now measuring
  the *final* install command. `artifacts/api-server` remains the undecided "if the hosted API is
  pursued" bet. Pricing story still open.
- Frozen `sessions/` + old `prompts/` + old `scripts/verify-session-*.sh` still name
  `@ifelse.codes/core` (history; not re-run).
- `pnpm run lint` unrunnable — eslint not installed (pre-existing).

## Milestones done
- **S01–S04** docs/examples/polish/README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI · **S08** release.yml + line/SVG ·
  **S09** circular+area LOCKED · **S10** line · **S11** catalog two-panel ·
  **S12** bar · **S13** Darpan-parity chrome · **S14** URL routes+persistence ·
  **S15** scripted browser QA · **S17** scatter · **S18** heatmap ·
  **S19** horizontalBar · **S20** treemap · **S21** timeline · **S22** gauge ·
  **S23** progress · **S24** grouped nav · **S25** histogram ·
  **S26** waterfall+funnel+sankey+radar · **S27** candlestick+boxplot ·
  **S28** sparkline · **S29** family-wide footer B-diet+ · **S30** docs live ·
  **S31** antra atoms + hero rotation + wall fix · **S32** wall playbook ·
  **S33** release readiness · **S34** GTM README + MIT LICENSE ·
  **S35** NO-CODE ground-truth · **S36** S35 gaps closed + deploy unfrozen ·
  **S37** package renamed to `@ifelse.codes/core` + published ·
  **S38** OIDC release runway, `0.2.0` unattended ·
  **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live.

## What Is In Progress
- S39 **complete** — merged (`68d0b26`); `v0.3.0` on `main`; Release green; `@ifelse.codes/chitra@0.3.0`
  live. **Next (S40):** GTM proof pack, or a real `0.4.0` to prove the OIDC path. See [[roadmap]].

## Cost Tracking
- S39 measured: one opencode session (interrupted once by a server restart) — a package rename
  across 27 files, the npm chicken-and-egg that makes a first publish necessarily human, one
  human bootstrap publish, a red release diagnosed rather than retried, **two hollow checks
  caught in my own verify script and one more caught by the cold review** (a narrowed honesty
  guard, a hardcoded version literal, and two fabricated `WORKS` rows in the demo), and S39
  artifacts. Token/`$` cost **unmeasured** (billed to the founder's plan). npm publish cost: $0.
  Release-runner minutes: ~4 (two attempts on `v0.3.0`).
- Prior: S20 founder $20/mo plan; S21–S28 single ZCode chats; S29 3 build + 2 cold reviews;
  S30 ops deploy + 2 cold reviews; S31 1 recon + 2 cold reviews; S32 knowledge-only; S33 four
  stories + 1 cold review; S34 one story + 4 cold reviews, approval-token gated; S35 NO-CODE
  audit; S36 docs/gates + live deploy; S37 rename + real npm publish via tmux; S38 OIDC runway.
