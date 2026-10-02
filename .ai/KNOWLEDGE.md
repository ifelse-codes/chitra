# chitra — Knowledge Base

**Permanent facts only. Reloaded every session.** (Seeded S00 brownfield onboarding, 2026-07-02.)

## What chitra is
- **`@ifelse.codes/chitra`** (`packages/core/`, v0.3.0, MIT) — the product: a zero-runtime-dependency
  TypeScript terminal charting library. "Beautiful visualizations for terminals, agents, and
  modern developer workflows." 20 chart types, 3 renderers (braille/blocks/ascii), 7 themes.
  **Published on npm as `@ifelse.codes/chitra@0.3.0` (S39, tag `latest`).** Renamed from
  `@ifelse.codes/core` on 2026-09-29; that name is **not** deprecated (no public release, no
  external user) — the S36/S37/S38 sections below keep it because they are dated records.
- Around the lib sits a **Replit-scaffolded full-stack** (all in-scope per founder):
  - `artifacts/chitra-docs/` — React 19 + Vite + Tailwind v4 + shadcn/ui docs/marketing site
    (renders chitra output; `src/data/charts.ts`, `src/data/ansi-charts.json`).
  - `artifacts/api-server/` — Node API server (esbuild bundle, pino logger; only `/healthz`
    route so far).
  - `artifacts/mockup-sandbox/` — Vite sandbox.
  - `lib/api-spec/openapi.yaml` — OpenAPI 3.1 source of truth (title `Api` — do NOT rename).
  - `lib/api-zod/` — zod schemas generated from the OpenAPI spec.
  - `lib/api-client-react/` — orval-generated TanStack Query client.
  - `lib/db/` — drizzle-orm schema.

## Stack & tooling
- pnpm workspaces (pnpm 9.12). CI uses Node **26** (`.github/workflows/ci.yml` +
  `release.yml`); the README requires Node 18+.
  TypeScript 5.9. ESM throughout.
- **pnpm only** — root `preinstall` hard-fails any other package manager and deletes
  `package-lock.json`/`yarn.lock`.
- Workspace globs (`pnpm-workspace.yaml`): `artifacts/*`, `lib/*`, `lib/integrations/*`,
  `packages/*`, `scripts`. Internal packages are named `@workspace/*`; the shippable one is
  `@ifelse.codes/chitra` (the *directory* is still `packages/core/` — S39 kept the path).
- Testing: **Vitest** (`packages/core/tests/`, 23 files, **453 tests**).

## Commands (verified working)
| Command | Effect |
|---|---|
| `pnpm install` | Install workspace (~25s; esbuild peer-dep warning on api-server is benign) |
| `pnpm --filter @ifelse.codes/chitra run test` | 453 tests (23 files) |
| `pnpm --filter @ifelse.codes/chitra run test:coverage` | tests + coverage |
| `pnpm --filter @ifelse.codes/chitra run typecheck` | `tsc --noEmit` on the lib |
| `pnpm run typecheck` | full-workspace typecheck (libs build + artifacts + scripts) |
| `pnpm run build` | typecheck + `pnpm -r run build` |

## Conventions & invariants (must never break)
- **Zero runtime dependencies** in `@ifelse.codes/chitra` — ANSI, braille math, rendering are all
  self-contained. Never add a runtime dep.
- **AI-agent output is core**: every chart returns a `ChartResult`
  (`{ render, toString, toPlain, toMarkdown, toJSON }`). `toPlain()` / `toJSON()` +
  `noColor: true` are the LLM/MCP integration surface.
- **Public API stability**: exported fns (`line`/`bar`/`area`/`sparkline`/… + `plot()` fluent
  builder) shouldn't break for consumers. `BaseChartOptions` carries shared fields; specific
  charts only declare unique options. `PlotBuilder` wraps the same chart fns (no duplication).
- **LOCKED design (S09) — all future charts follow this look and feel** (see the
  "LOCKED: circular charts" contract in `packages/core/README.md`):
  - **Braille sub-pixel drawing** (2×4 dots/cell, supersampled 2×2 per dot) for smooth
    round geometry — no blocky steps.
  - **One accent hue on the primary/largest slice**, grey tone ramp (`#ECECEF→#6A6A75`)
    on the rest — never per-slice fill patterns/stripes/in-wedge labels.
  - **Dashed panel frame** (`┌╌…╌┐`, `│ ╌…╌ │`), eyebrow row, right-aligned legend
    beside the ring, optional status row, donut center shows total.
  - **Braille needs a glyph-complete mono font** (Cascadia Mono/Fira Code/Menlo) — docs
    site font stack must keep one or braille columns misalign in the browser.
  - **Area chart locked too** (S09): line = fill's interpolated top edge (no separate
    stroke); y-range auto-scales to the data so the area fills the panel; empty cells are
    spaces (never blank-braille `⠀` which renders as faint dots); one accent only on the
    peak cap + footer `max` value. See "LOCKED: area chart" in `packages/core/README.md`.
  - **Line chart locked to the founder's `tui-chart (1).html` reference** (S10): every
    series is a continuous thin braille line in its own colour (primary on the tone
    ramp), every series drops its glyph marker (`* ○ + × □`, every 2nd index, matching
    the SVG), dotted `·` gridlines on the y-step rows in the grid colour (series/markers
    outrank them), and per-series `min/max/avg/last` summary rows with the primary's
    `max` in accent. The primary keeps the 3-dot accent peak cap, and the cap outranks
    markers. Block/ascii renderers share the look. See "LOCKED: line chart" in
    `packages/core/README.md`.
  - **Bar chart locked (S12)**: `bar()` carries the shared locked design language. One
    accent on the globally highest bar (spent once); all other bars use the grey tone
    ramp — no per-series rainbow. Panel: dashed frame, eyebrow row, `+` y-guide top,
    `+` x-tick row, rule separators, per-series MIN/MAX/AVG/LAST summary rows (peak-series
    `max` in accent). Auto-scale y-range; empty cells are spaces; panel width auto-expands
    to fit summary rows. See "LOCKED: bar chart — session 12 design" in
    `packages/core/README.md`.
  - Handoff for LLM polish: `scripts/ring-polish-handoff.mjs` (the old `/tmp/ring-lab/`
    live preview is ephemeral — gone).
- **453 core tests stay green.** Never leave the suite red.
- North-star (founder): *"the best terminal chart lib ever created — zero-dep,
  AI-first, delightful."*

## Environment quirks / gotchas
- ESM **NodeNext**: imports use `.js` extensions on `.ts` files → run via `tsx`, not `node`
  directly. `tsx` is at `packages/core/node_modules/.bin/tsx`.
- Core `tsconfig.json` uses `noEmit: true`, no `rootDir`, so tests live in sibling `tests/`.
  The published build is real (S06): `build` runs `node build.mjs` (esbuild → `dist/index.js`
  ESM + `dist/index.cjs`) then `tsc -p tsconfig.build.json` for `.d.ts`. `typecheck` remains
  `tsc --noEmit`.
- `lib/api-spec/openapi.yaml` `info.title` must stay `Api` (comment: changing it breaks
  generated import paths).
- Repo **is** a git repo at `github.com/ifelse-codes/chitra`; `main` hosts S00–S39
  (latest merge PR #59, `ba6cf6f`). **Read `main`'s real range, don't copy it** — this line
  has now been wrong twice: it said S00–S08 (S35), was corrected to S00–S34 in S36, and
  drifted to S00–S37 by S40. No guard protects it. The newest tag is `v0.3.0` at `f4ff6ef9`
  (S39); `v0.1.0` is at `802ffc7` and `v0.2.0` at `76d21f3`, all pushed, none stale.
  Vajra branch/commit/PR rules run via `.githooks/` (`core.hooksPath .githooks`) and
  `.ai/hooks/*`. Commits are founder-approved (`VAJRA_ALLOW_COMMIT=<NN>`); pushes/PRs
  need `VAJRA_ALLOW_PUBLISH=1`.

## Where things live
- `packages/core/src/`: `index.ts` (exports), `types.ts`, `ansi.ts`, `utils.ts`, `plot.ts`,
  `themes/`, `renderers/` (braille/blocks/ascii, `panel.ts`), `charts/` (20 chart files).
- `design-reference/` — target design language to build toward (founder-sourced):
  `tui-chart.html`, `mudra-chart.html`, `mudra-dashboard.html`. The terminal panel was
  "modeled on the tui-chart.html reference design language"; next session should learn
  these fully and rebuild the chart look to match.
- `examples/basic.ts` — worked examples for all chart types.
- `CONTRIBUTING.md`, `replit.md` (Replit agent notes), `darshan/SKILL.md` (output skill).

## S31 extension — antra atoms + hero rotation + wall fix (2026-09-21)
- Donor `antra/landing/index.html` (static single-file): violet tokens,
  ◆ eyebrow, install-block copy, hairline 1px-gap grids, blur nav,
  hairline footer, IO reveal, grid+glow background, mandala wisps.
  Borrowed as namespaced `--antra-*` + last-source-order S31 CSS section
  (beats the two theater `:root`/override layers without touching them).
- Hero rotation: `HERO_SPECS` in `scripts/chart-specs.ts` →
  `src/data/hero-charts.json` (drift-gated); every variant exactly
  19 visible lines × 64 visible cols (`scripts/check-hero-dims.py`
  pins it); 3s instant cut, hugging mac box, 8ch right buffer.
- Wall fix (measured, not guessed): JetBrains Mono advances braille
  14% wide (canvas `measureText`); `.terminal-body` leads Cascadia Mono
  (uniform) + ligatures/kerning off. Pixel proof: 19/19 rows share the
  right edge. Rule must live AFTER the theater font override (source
  order wins ties).
- **Wall-stagger playbook (permanent learning):** when a rendered chart
  frame's right wall staggers while its text measures column-uniform,
  the renderer is rewidthing glyphs — work this chain: (1) refresh-flash
  test — straight for a split second then distorted = webfont swap, the
  fallback font is uniform and the loaded font is not; (2) canvas
  `measureText` per codepoint per candidate family — JetBrains Mono drew
  braille `⣿⠿` at 7.52px vs 6.6px base while Cascadia Mono held every
  frame glyph (`╌ ─ │ ┌ ┐ └ ┘ ░ ▒ ▓ █ ⣿`) at 6.45px; (3) lead the
  uniform family on the chart-text stack + `font-variant-ligatures: none;
  font-kerning: none; letter-spacing: 0` (ligatures rewidth `╌` runs
  too); place the rule AFTER any theme font override — equal
  specificity loses by source order; (4) prove with pixels, not eyes:
  screenshot the text body, group rows, assert one shared right edge
  (19/19 @ x=1001, spread 0). Buffer (extra `ch` width) only hides
  clipping — it never straightens a wall.
- Live deploy FROZEN by founder order (local-proven only).

## S30 extension — live hosting on Cloudflare Pages (2026-09-21)
- **Site:** `https://chitra.iifelse.com` = `artifacts/chitra-docs` SPA.
  Pages project `chitra` (`chitra-5xh.pages.dev`, prod branch `main`,
  direct-upload, no Git — same pattern as `antra`/`kreeda`).
  Deploy: `wrangler pages deploy dist/public --project-name=chitra --branch=main`
  (build needs `PORT` + `BASE_PATH=/`, see CI).
- **SPA fallback:** `artifacts/chitra-docs/public/_redirects` with
  `/* /index.html 200` — ships into `dist/public`; without it
  `/chart/:id` deep links 404.
- **Custom domains:** `wrangler pages project` has NO domain subcommand
  (v4.100) — attach via API `POST /accounts/{id}/pages/projects/chitra/domains`
  using `wrangler auth token`. Auto-CNAME does NOT happen with a
  zone:read token — add `CNAME <name> → <project>.pages.dev` (proxied)
  in the dashboard by hand; API then flips `initializing → pending →
  active` (delete + re-add forces revalidation).
- **Gotcha:** fresh subdomains can NXDOMAIN on local resolvers (negative
  cache) while `nslookup @1.1.1.1` answers — bypass with device DNS
  `1.1.1.1`, not router reboots.

## S28 extension — composability + dashboard (2026-09-18, committed on `session-28-sparkline`)
- **Composability API (all 20 charts):** `BaseChartOptions.frame?` (default true),
  `compact?` (default false — body + axes only, no eyebrow/legend/summary),
  `maxWidth?` (ANSI-safe per-line cap, `truncateAnsi` in `ansi.ts`);
  `ChartResult.toContent()` (body-only; `toPlain()` semantics unchanged —
  still strips ANSI only, keeps frame glyphs); explicit `height` is body-exact
  rows-including-axes via `fitBodyLines`/`normalizeHeight` (`utils.ts`).
  `SparklineOptions`/`ProgressOptions` carry frame/compact/height/maxWidth
  parity. `index.ts` exports `frameTop`/`frameBottom`/`frameRow`/`frameRule` +
  `truncateAnsi`. `toJSON()` data is unaffected by display opts; defaults are
  unchanged (framed panels).
- **Known contract gaps (disclosed, worked around):** radar min-clamps height
  at 12 (`radar.ts:89`); boxplot/waterfall/candlestick append axis/label rows
  outside the height budget; `toContent()` is a compact re-render (2× cost).
- **Height gotcha:** `line` enforces min 3 plot rows (`max(3, height-2)`);
  `area` plot rows = `height-2` (height 3 → 1 row; height 5 → exactly 3).
  Waterfall/candlestick/boxplot honour `showAxes: false` (axes skipped).
  Waterfall/candle/boxplot plot glyphs legitimately contain `┌╌┐`/`└╌┘`
  (total blocks, wicks, baselines) — box-corner assertions must exempt them.
- **SRE dashboard** (`playground/sre-dashboard/`, committed): `sre-sim.ts`
  engine, `sre-dashboard.ts` CLI (`--once` + live), `sre-server.ts` (:4173,
  `/frame` raw ANSI + `/cells?single=&wide=` JSON). Web grid: 2 cols × 10
  rows, no-scroll, 20 tiles × exactly 3 rows, client-measured char widths
  (canvas measure of tile/pre font), 2s poll. Lessons: equal-`1fr` rows starve
  tall tiles (use content-weighted `fr`); flex-stretch defeats `margin:auto`
  centering (needs a centering wrapper); per-tile font shrink loops backfire —
  fixed type + exact line budgets won. Legends are the density floor (donut/pie
  need 6 rows for 6 services; heatmap header + N).
- **Suite is 452 tests** (`tests/composability.test.ts` +7 covers the contract).
  `pnpm run lint` unrunnable — eslint binary not installed (pre-existing).
- **Research spikes (no code):** TUI landscape — Ratatui's measure/render split
  + constraint layout (Length/Min/Max/Ratio/Fill, kasuari) is the model to
  steal; `ansi-to-tui` (official, truecolor) bridges Chitra ANSI → Ratatui
  `Paragraph` via a Node sidecar today.

## S36 extension — deploy unfreeze, GT teeth, release hardened (2026-09-23)
- **`@ifelse.codes/core@0.1.0` is publish-ready but was NOT on npm in S36.** The publish
  was attempted and returned `E403 … 2FA … required` (the supplied token was not a
  bypass-2FA token). Founder **deferred the publish to S37** (completed there — see the
  S37 extension). Dry-run green: 38 files, 94.2 kB. **[Corrected in S37: the `@chitra`
  scope is NOT owned by npm user `ifelse.codes`; the package was renamed to
  `@ifelse.codes/core` and published.]**
- **Tag hygiene:** the old local `v0.1.0` tag (pointing at a 2026-07-29 commit) was
  deleted; `v0.1.0` is re-cut on the release commit. Never `git push --tags` while a
  stale `v*` exists — `release.yml` publishes on any `v*` push.
- **Live deploy unfrozen (S31 order lifted):** `wrangler pages deploy dist/public
  --project-name=chitra --branch=main`; this makes the S33 `/ai-data` page live.
- **Docs-hero pills are truthful now:** `v0.3.0 · npm` (S39) and `452` tests
  (`artifacts/chitra-docs/src/App.tsx` L550 / L570). S38 fixed the pill to `v0.1.0` while the
  manifest said `0.2.0`; S39 corrected the text. `verify-session-39.sh#hero-pill-matches-version`
  now *derives* the expected value from the manifest, so a bump without a pill edit goes red
  — the pill is still a JSX literal, but it can no longer silently drift.
- **Ground-truth teeth:** `.ai/GT-REMEDIATIONS.md` ledger +
  `verify-closeout.sh#check_gt_remediations` (every row DONE/WAIVED);
  `#check_session_coverage` (a merged `session-NN-*` branch ≥ S17 must have a
  summary); `#check_ground_truth_no_code` (a GT session's diff touches no code).
  `.ai/hooks/hook-ground-truth-guard.sh` enforces no-code-in-GT in the Claude
  harness; opencode relies on the closeout backstop.
- **One canonical test count: 453.** If a session changes it, update it everywhere it
  is displayed — and note that the guard this line used to name,
  `verify-session-34.sh#test-count-matches`, is **dead** (it filters the pre-rename
  `@chitra/core` and matches no project). The live guard is
  `scripts/verify-session-41.sh#test-count-propagated`, which derives the count from the
  suite run and fails if the README badge, the docs hero stat, this file, or the roadmap
  guardrail disagree. Added S41, after the count moved 452 → 453 and had to be written
  into nine places by hand — the exact drift that guard now makes impossible.

## S37 extension — package published to npm (2026-09-24)
> Superseded by S39: the shippable name is now `@ifelse.codes/chitra` and `latest` is `0.3.0`.
> Kept as a dated record; the "dist-tag `latest`" below was true only until 2026-09-29.
- **`@ifelse.codes/core@0.1.0` is LIVE on npm** (38 files / 94.2 kB, dist-tag `latest`;
  clean consumer `npm install` verified). The package was **renamed** from `@chitra/core`
  because the `@chitra` npm **org is not owned by the account** (`npm org ls chitra` →
  403; unscoped `chitra` was taken). `@ifelse.codes` is the founder's user scope (free).
  26 live files renamed; frozen `sessions/` + old `prompts/` left as history.
- **Publishing needs a TTY + passkey.** npm's `otplease` only runs the web-2FA flow when
  `process.stdin.isTTY && process.stdout.isTTY` (`npm/lib/utils/auth.js`); a non-TTY shell
  gets `EOTP` with a MASKED url. Run `npm publish` inside `tmux`, press Enter, approve the
  passkey. (Passkey 2FA cannot produce a 6-digit OTP.)
- **Bypass-2FA tokens are being deprecated** by npm for direct publishing — a future
  tag-driven CI publish needs npm **Trusted Publishing (OIDC)**, not `NODE_AUTH_TOKEN`.
  `release.yml` is idempotent, so the publish job skips when the version already exists.
- **Publish propagation lag:** the registry `PUT` returned 200 and the tarball was live
  immediately, but the packument (metadata) 404'd for ~6 minutes; the search index had it
  first. Re-query — do not re-publish.
- **Closeout gates hardened (S37):** `check_gt_remediations` requires a `DEFERRED` row's
  Evidence to carry a reason AND an expiry; `verify-closeout.sh --gt-no-code-only N`
  exercises the GT no-code offender path (S36-review weakness).
- **pnpm 9.x cannot do npm Trusted Publishing (OIDC).** pnpm predates the feature: its
  auth surface is token-only (`_authToken` / `_auth` / `tokenHelper`) and it has no OIDC
  exchange. Under OIDC with no token present, `pnpm publish` fails with an error that
  reads like a config typo, not a missing capability. Use `npm publish` (npm ≥ 11.5.1,
  Node ≥ 22.14.0) for the publish step; pnpm may still install/build/test. **Reusable
  constraint for every release session.**
- **npm trusted-publisher configs created after 2026-09-03 default to `npm stage publish`
  only** — direct `npm publish` is denied unless explicitly opted in when creating the
  publisher. npm does **not** validate the config on save; the failure surfaces only at
  publish time. Always tell the founder to tick "allow `npm publish`".
- **A private GitHub repo gets no npm provenance.** npm does not generate provenance
  attestations for private repositories even under trusted publishing (documented
  limitation). Publishing works; the attestation does not. `dist.signatures` (ECDSA) is
  present regardless — do not read signatures as proof of provenance; check
  `dist.attestations`.
- **To prove CI published a version (not a human), compare timestamps.** npm's
  authoritative publish time is `time[<version>]` in the packument; the workflow's start
  is `gh run list --createdAt`. Require publish ≥ run-start. Public data, no npm auth.
  Beware: `npm view pkg time.0.2.0` does **not** work — npm parses the dots as nested
  field paths; read the whole map (`npm view pkg time --json`) and index the version key.
- **A credential-less publish is itself evidence.** If repo, org and environment secrets
  are all empty and a publish still succeeds, the OIDC exchange worked — the trusted
  publisher must exist. This is inference, not assertion: npm's trusted-publisher API
  needs a session token, so no CI check can read the config directly.
- **Verify-script authoring traps (both cost real debugging time this session):**
  (a) an `awk` range `/^  publish:/,/^  [a-z-]+:$/` collapses to ONE line, because the
  start line also matches the end pattern — use `sed -n '/start/,$p'`; (b) `run_check`
  style helpers that shell out via `bash -c` need BOTH the function and every variable it
  reads `export -f`/`export`ed, or they silently see an empty path.
- **A verify check over workflow TEXT proves the text, not the behaviour.** Substring
  greps stay green when the executed command is reverted behind an unreachable branch.
  Scope such checks to the step's `run:` block, anchor patterns to line start, and always
  construct the counterfactual before citing a check as a regression guard.

## S39 extension — the rename, and why a new package can never be published unattended (2026-09-29)
- **A brand-new package name CANNOT be published by CI. The first publish is necessarily
  human.** npm configures a trusted publisher *per package, inside that package's settings
  page* — and a package that does not exist has no settings page. So the chicken-and-egg is
  structural: OIDC → needs a trusted publisher → needs the package → needs a publish that
  only a human can make. (PyPI allows configuring OIDC for a not-yet-existing package; npm
  does not.) **Renaming a package therefore always costs one human publish**, and the S38
  "unattended" property does not survive a rename until the NEXT version. Order that works:
  human `npm publish` once → create the trusted publisher (tick "allow `npm publish`") →
  cut a new tag. The failure is `PUT .../@ifelse.codes%2fchitra` → **404 "could not be found
  or you do not have permission"**; the tarball builds fine first, so the log looks healthy
  right up to the auth line.
- **"publish time ≥ run start" does NOT prove CI published — it is a hollow check.** It
  passed for S39's `0.3.0` while being false: the publish job FAILED at 09:07:31Z and a human
  published at 13:30:46Z. To actually discriminate, assert THREE things: (1) the first
  attempt's publish job failed, (2) the retry's publish job took the *skip* path (log
  contains "is already on npm — skipping publish" and does NOT contain "Publishing to"),
  and (3) npm's publish time **precedes** the retry's publish-job `started_at`. Only (3)
  is decisive, and it is falsifiable in both directions. Read per-attempt data with
  `gh api repos/{o}/{r}/actions/runs/{id}/attempts/{n}/jobs` — `gh run view` only reports the
  LATEST attempt, which silently erases a failed first one.
- **Re-running a failed release is safe and is itself a proof.** `release.yml`'s idempotency
  guard makes attempt 2 exit 0 with a `::notice` — which is the *behavioural* proof that the
  guard aims at the renamed package. A grep over the workflow text could not show that.
- **npm's `npm login --auth-type=web` needs ENTER.** It prints the URL then blocks on
  "Press ENTER to open in the browser…". Opening the URL by hand without pressing ENTER lets
  the CLI die with `npm error Exit handler never called!` and fall back to a Username prompt.
  Press Enter (npm opens the browser, flow stays live), then the publish triggers a *second*
  browser auth at `/auth/cli/<id>`.
- **A stale revoked token in the global `~/.npmrc` will be sent to the registry and wins over
  interactive auth.** Isolate a publish with `export npm_config_userconfig=<tmp>` rather than
  editing or trusting the global config — then delete the tmp file; the web-login session
  token dies with it and there is nothing to leak or revoke.
- **A deploy is a MANUAL step, so the public site drifts silently — and S37/S38/S39 all shipped
  content nobody deployed.** The S39 gap audit found `chitra.iifelse.com` still serving
  `npm install @chitra/core` — the name from *before* S37, under an npm org S37 established the
  account does not own. CI was green, verify was green, the package was on npm. Nothing failed,
  because nothing checks the deployed artefact against `main`. Three sessions of correct merges
  produced a front door that would have 404'd any user who followed it. **`verify-session-39.sh`
  now runs `live-site-serves-current-name`** (fails closed on no network): it fetches the live
  shell, resolves the hashed bundle, and asserts the new name is present *and* both old names
  are absent. Deploy on every docs-content change:
  `wrangler pages deploy dist/public --project-name=chitra --branch=main` (build needs
  `PORT=5000 BASE_PATH=/`). **The remaining systemic gap: this lives in a session verify script,
  not in CI, so it only guards the session that adds it — a CI gate is the S40 fix.**
- **Keep local `main` fast-forwarded.** It sat at the S38 head through all of S39 because every
  branch was cut from `origin/main` and never merged back. That silently breaks
  `verify-closeout.sh`'s canonical `--inputs-sha`, which hashes `git merge-base main HEAD` — the
  attested hash moved when `main` caught up. An S40 branching from `main` would have started
  without any of S39's work. `git checkout main && git merge --ff-only origin/main` at closeout.
- **Packument propagation lag, re-confirmed:** the human publish returned success and the
  tarball was live immediately, but `npm view <pkg> version` 404'd for **~4 min**. Re-query;
  never re-publish on a 404.
