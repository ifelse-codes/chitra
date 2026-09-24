# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S37 done, 2026-09-24.)

## Active Branch
`main` — S37 merged (PR #43, `fd8a96e`). The S36-deferred npm publish is **done**: the
package was renamed to the founder's scope and published; `v0.1.0` sits on `main` HEAD,
Release green. **Live deploy remains UNFROZEN (S31 order lifted).**

## What Currently Works (observed, not claimed)
- **`@ifelse.codes/core` is LIVE on npm (S37):** `@ifelse.codes/core@0.1.0`, 38 files /
  94.2 kB, dist-tag `latest`. Verified independently: `npm view @ifelse.codes/core
  version` → `0.1.0`; a clean `npm install @ifelse.codes/core@0.1.0` in `/tmp` added the
  package; registry packument `200`; tarball `200`. The S36 `DEFERRED` item is closed.
- **Package renamed (S37):** `@chitra/core` → `@ifelse.codes/core` across 26 live files
  (pkg identity, workspace deps + lockfile, docs imports/scripts, CI workflows, README/
  CONTRIBUTING/replit, tooling scripts, `.ai/`). Frozen `sessions/` + old `prompts/` are
  left as history. Post-rename: core **452/452**, typecheck, build, docs typecheck,
  `gen:charts:check` all green.
- **Publish unblock mechanism (S37, reusable):** publishing needed npm's web/passkey
  2FA flow, which `npm` only runs when stdin+stdout are TTYs — run `npm publish` inside
  `tmux`, press Enter, approve the passkey. (A plain non-TTY shell gets `EOTP` with a
  masked URL.)
- **Docs honest (S37):** README install section is a real install (no "not on npm yet");
  docs-hero pill reads `v0.1.0 · npm`.
- **Ground-truth teeth hardened (S37, per S36 review):** `check_gt_remediations` now
  requires a `DEFERRED` row's Evidence to carry a reason **and** an expiry (date or the
  word "expiry"); `verify-closeout.sh --gt-no-code-only N` exercises the GT no-code
  **offender path** (proven: on this branch it blocks with the code-file list).
- **Live docs site:** `chitra.iifelse.com` (S36 redeployed; `/ai-data` live).
- **`@ifelse.codes/core` library:** 20 charts, 3 renderers, 7 themes, `ChartResult`;
  LOCKED families S09–S28. `pnpm --filter @ifelse.codes/core run test` — **452/452**.
- **Release workflow** `release.yml` idempotent (publish job skips when the version
  exists); **no `v*` tag exists yet** (re-cut `v0.1.0` with the post-merge main).

## What Is Broken / Incomplete
- **`v0.1.0` tag** sits on `main` HEAD (`fd8a96e`); the Release workflow is green
  (publish job skipped — version already exists, idempotent).
- **CI publishing needs a new mechanism:** npm is **deprecating bypass-2FA tokens** for
  direct publishing; a *future* version's tag-driven publish needs npm **Trusted
  Publishing (OIDC)**, not a long-lived `NODE_AUTH_TOKEN`.
- **No MCP server ships** (README advertises the handler; roadmap item).
- `artifacts/api-server` exposes only `/healthz`.
- GTM proof pack (benchmarks / token-savings) and pricing story still to build.
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
  **S37** package renamed + **published to npm**.

## What Is In Progress
- S37 **complete** — merged (PR #43, `fd8a96e`); `v0.1.0` on `main` HEAD, Release green.
  **Next (S38):** MCP server, GTM proof pack, api-server. See [[roadmap]].

## Cost Tracking
- S37 measured: one opencode session — a 26-file rename (10 atomic commits), one **real
  npm publish** (web/passkey via tmux), README/hero honesty, ledger row 2 → DONE, two
  closeout-gate hardenings, and S37 artifacts. Token/`$` cost **unmeasured** (billed to
  the founder's opencode plan). npm publish cost: $0 (public package).
- Prior: S20 founder $20/mo plan; S21–S28 single ZCode chats; S29 3 build + 2 cold
  reviews; S30 ops deploy + 2 cold reviews; S31 1 recon + 2 cold reviews; S32
  knowledge-only; S33 four stories + 1 cold review; S34 one story + 4 cold reviews,
  approval-token gated; S35 NO-CODE audit; S36 docs/gates + live deploy (npm deferred).
