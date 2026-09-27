# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S38 done, 2026-09-27.)

## Active Branch
`main` — S38 merged (PR #46, `76d21f3`). The release path is **automated**: npm
**Trusted Publishing (OIDC)** replaced the long-lived token, and `v0.2.0` was published
by CI with no human in the loop. **Live deploy remains UNFROZEN (S31 order lifted).**

## What Currently Works (observed, not claimed)
- **Releases are unattended (S38):** `release.yml#publish` holds `id-token: write` +
  `contents: read` and references **no npm secret at all**. Pushing `v0.2.0` produced
  `@ifelse.codes/core@0.2.0` on npm with no tmux, no passkey, no manual step.
  Release run `36321392874`: 4/4 jobs green.
- **The publish-time ordering is proven, not assumed (S38):** npm's authoritative
  `time["0.2.0"]` = `13:11:11Z`; the Release run's `createdAt` = `13:09:02Z`. The
  publish is *no earlier* than the run, so CI published it — a human publishing locally
  first would show the reverse. Asserted by `published-after-run-start`.
- **Zero npm credentials in CI (S38, verified three ways):** `gh secret list --repo` → `[]`;
  org secrets → 404; no GitHub environments configured. A credential-less publish would
  fail `ENEEDAUTH`; it succeeded.
- **The OIDC blocker was pnpm, not a config flag (S38):** pnpm is pinned at **9.12.3**,
  which predates npm Trusted Publishing and is token-only (`_authToken` / `_auth` /
  `tokenHelper`) — it cannot exchange an OIDC token. The publish step now runs
  `npm publish` (npm ≥ 11.5.1; local 11.12.1, CI Node 26). pnpm still does
  install/build/test.
- **`0.2.0` consumer-verified:** clean `npm install @ifelse.codes/core@0.2.0` in a temp
  dir → 38 files / 446,486 B unpacked, `dist.signatures` present, and a real chart renders
  via the installed ESM entry. `dist-tags` → `latest: 0.2.0`.
- **S37 (still true):** `@ifelse.codes/core@0.1.0` was the S36-deferred publish, under the
  founder's `@ifelse.codes` scope (the `@chitra` npm org is not ours); local publishing
  needs npm's web/passkey flow, which only runs on a real TTY (use `tmux`).
- **Live docs site:** `chitra.iifelse.com` (`/ai-data` live).
- **`@ifelse.codes/core` library:** 20 charts, 3 renderers, 7 themes, `ChartResult`;
  LOCKED families S09–S28. `pnpm --filter @ifelse.codes/core run test` — **452/452**.

## What Is Broken / Incomplete
- 🔴 **The npm account token from the S37 chat (`npm_xToANF…`) is still valid.** It is
  founder-owned, not observable from CI, so nothing can assert it. npm's own order is
  *publisher → verify → restrict*, and **the first two steps are now done**, so this is
  unblocked: revoke at npmjs.com → Access Tokens, then set Publishing access to
  *require 2FA and disallow tokens*.
- 🟠 **No npm provenance.** The GitHub repo is **private**, and npm does not generate
  provenance attestations for private repos even under trusted publishing. Confirmed:
  `0.2.0` has `dist.signatures` but `attestations: null`. Publishing is unaffected. Making
  the repo public would fix it and suits an MIT package — **founder's open decision**.
  If visibility flips, `release.yml`'s comment must change with it or it becomes a lie.
- **MCP server: founder-DEFERRED (S38).** Not built, not stubbed. Gate: a release exists
  **and** someone demands it **and** it is judged worth building. The README snippet is
  labelled *not shipped yet* and ROADMAP records the deferral.
- **The trusted publisher's existence is inferred, not asserted.** npm's
  trusted-publisher API needs a session token, so no check can read it; the evidence is
  the outcome (a tokenless publish succeeded).
- `ci-no-auth-token-secret` covers **repo** secrets only — not org or environment secrets.
  None exist today and no environments are configured.
- GTM proof pack (benchmarks / token-savings) still to build — now unblocked, there is a
  real `0.2.0` to measure. `artifacts/api-server` remains the undecided "if the hosted API
  is pursued" bet. Pricing story still open.
- Frozen `sessions/` + old `prompts/` + old `scripts/verify-session-*.sh` still name
  `@chitra/core` (history; not re-run).
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
  **S37** package renamed + published · **S38** OIDC release runway, `0.2.0` unattended.

## What Is In Progress
- S38 **complete** — merged (PR #46, `76d21f3`); `v0.2.0` on `main` HEAD; Release green;
  `0.2.0` live on npm, CI-published. **Next (S39):** GTM proof pack, or the npm token
  revocation. See [[roadmap]].

## Cost Tracking
- S38 measured: one opencode session — an OIDC release-path rewrite, the pnpm→npm OIDC
  blocker caught before it shipped a red release, `0.2.0` published unattended, a README
  honesty rider, a ROADMAP correction, verify hardening driven by an adversarial cold
  review, and S38 artifacts. Token/`$` cost **unmeasured** (billed to the founder's
  opencode plan). npm publish cost: $0. Release-runner minutes: ~2.
- Prior: S20 founder $20/mo plan; S21–S28 single ZCode chats; S29 3 build + 2 cold
  reviews; S30 ops deploy + 2 cold reviews; S31 1 recon + 2 cold reviews; S32
  knowledge-only; S33 four stories + 1 cold review; S34 one story + 4 cold reviews,
  approval-token gated; S35 NO-CODE audit; S36 docs/gates + live deploy; S37 rename +
  real npm publish via tmux.
