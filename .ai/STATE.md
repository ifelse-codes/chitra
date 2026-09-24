# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S36 done, 2026-09-23.)

## Active Branch
`session-36-close-audit-gaps` — S36 delivery on branch: closed the S35
ground-truth gaps + unfroze the live deploy. npm publish **founder-deferred to
S37**. PR to `main` to go. **Live deploy is UNFROZEN (S31 order lifted).**

## What Currently Works (observed, not claimed)
- **Live docs site (S36, unfrozen):** `chitra.iifelse.com` redeployed via
  `wrangler pages deploy dist/public --project-name=chitra --branch=main`.
  Verified: prod 200, the new bundle `assets/index-Cu2gqnLT.js` serves, hero
  shows `v0.1.0` + `452`, and `/ai-data` (S33 page) returns 200 — the S34 README
  link is live.
- **Docs-hero pills honest (S36):** `App.tsx` → `v0.1.0` (dropped "— stable"),
  `134` → `452`.
- **`@ifelse.codes/core` publish-ready (S36):** dry-run green — `@ifelse.codes/core@0.1.0`,
  38 files, 94.2 kB, dist ESM+CJS+`.d.ts` + README + LICENSE. **Not on npm yet**
  (publish deferred — see Broken).
- **Release workflow idempotent (S36):** `release.yml` skips the publish when the
  version already exists, so a re-pushed `v*` tag stays green.
- **Tag hygiene (S36):** the stale local `v0.1.0` tag (2026-07-29 commit) was
  **deleted**; no `v*` tag exists now.
- **Ground-truth teeth (S36):** `.ai/GT-REMEDIATIONS.md` ledger +
  `verify-closeout.sh#check_gt_remediations` (rows must be DONE/WAIVED/DEFERRED);
  `#check_session_coverage` (a merged `session-NN-*` branch ≥ S17 must have a
  summary); `#check_ground_truth_no_code`; `.ai/hooks/hook-ground-truth-guard.sh`
  wired into `.claude/settings.json`.
- **S05 closeout debt closed (S36):** S17 + S32 session records backfilled
  (`sessions/session-17-summary.md`, `session-32-summary.md` + their prompts).
- **KNOWLEDGE.md corrected (S36):** one canonical test count (**452**), 23 test
  files, CI Node 26, `main` = S00–S36, dist-built, north-star wording.
- **`@ifelse.codes/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult`.
  LOCKED families S09–S28. `pnpm --filter @ifelse.codes/core run test` — **452/452**;
  typecheck exit 0.
- `scripts/verify-session-36.sh` + `scripts/demo-session-36.sh` (S36 gates).

## What Is Broken / Incomplete
- **npm publish DEFERRED to S37 (founder):** `@ifelse.codes/core` is not on npm. The
  npm **Publish** token returns `E403 … 2FA or granular token with bypass 2fa
  required`; a **Classic Automation token** (or Granular with Bypass 2FA) is
  needed. Then: publish, re-cut `v0.1.0` on `main`, push the tag.
- `v0.1.0` tag does not exist (deleted as stale; re-cut with the publish).
- **S34 README install line** still says "not on npm yet" — true until S37.
- `artifacts/api-server` exposes only `/healthz`.
- No MCP server ships (README advertises the handler; roadmap item added).
- GTM proof pack (benchmarks / token-savings) and pricing story still to build.
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
  **S35** NO-CODE ground-truth · **S36** S35 gaps closed + deploy unfrozen
  (npm publish deferred).

## What Is In Progress
- S36: commit + PR `session-36-close-audit-gaps` → `main`. Then closeout.
  **Next (S37):** publish `@ifelse.codes/core@0.1.0` (Classic Automation token),
  re-cut + push `v0.1.0`; then MCP server, GTM proof pack, api-server.
  See [[roadmap]].

## Cost Tracking
- S36 measured: one opencode session — docs honesty (1 file), KNOWLEDGE/ROADMAP/
  STATE sync, 1 new hook + 3 closeout gates, S17/S32 backfill (4 files), S36
  prompt/verify/demo/summary/review, one **live Cloudflare Pages deploy**, and
  release hardening. Token/`$` cost **unmeasured** (billed to the founder's
  opencode plan). npm publish deferred, so no registry cost this session.
- Prior: S20 founder $20/mo plan; S21–S28 single ZCode chats; S29 3 build + 2
  cold reviews; S30 ops deploy + 2 cold reviews; S31 1 recon + 2 cold reviews;
  S32 knowledge-only; S33 four stories + 1 cold review; S34 one story + 4 cold
  reviews, approval-token gated.
