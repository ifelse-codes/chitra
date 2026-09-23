# chitra — Knowledge Base

**Permanent facts only. Reloaded every session.** (Seeded S00 brownfield onboarding, 2026-07-02.)

## What chitra is
- **`@chitra/core`** (`packages/core/`, v0.1.0, MIT) — the product: a zero-runtime-dependency
  TypeScript terminal charting library. "Beautiful visualizations for terminals, agents, and
  modern developer workflows." 20 chart types, 3 renderers (braille/blocks/ascii), 7 themes.
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
  `@chitra/core`.
- Testing: **Vitest** (`packages/core/tests/`, 23 files, **452 tests**).

## Commands (verified working)
| Command | Effect |
|---|---|
| `pnpm install` | Install workspace (~25s; esbuild peer-dep warning on api-server is benign) |
| `pnpm --filter @chitra/core run test` | 452 tests (23 files) |
| `pnpm --filter @chitra/core run test:coverage` | tests + coverage |
| `pnpm --filter @chitra/core run typecheck` | `tsc --noEmit` on the lib |
| `pnpm run typecheck` | full-workspace typecheck (libs build + artifacts + scripts) |
| `pnpm run build` | typecheck + `pnpm -r run build` |

## Conventions & invariants (must never break)
- **Zero runtime dependencies** in `@chitra/core` — ANSI, braille math, rendering are all
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
- **452 core tests stay green.** Never leave the suite red.
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
- Repo **is** a git repo at `github.com/ifelse-codes/chitra`; `main` hosts S00–S36.
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
- **`@chitra/core@0.1.0` is publish-ready but NOT yet on npm.** The publish was
  attempted and returned `E403 … 2FA or granular token with bypass 2fa required`
  (the supplied token was a *Publish* token, not a *Classic Automation* token).
  Founder **deferred the publish to S37**. Dry-run is green: 38 files, 94.2 kB,
  org `chitra` owned by npm user `ifelse.codes`. Then: `npm publish --access
  public` in `packages/core`, re-cut `v0.1.0` on `main`, push the tag.
- **Tag hygiene:** the old local `v0.1.0` tag (pointing at a 2026-07-29 commit) was
  deleted; `v0.1.0` is re-cut on the release commit. Never `git push --tags` while a
  stale `v*` exists — `release.yml` publishes on any `v*` push.
- **Live deploy unfrozen (S31 order lifted):** `wrangler pages deploy dist/public
  --project-name=chitra --branch=main`; this makes the S33 `/ai-data` page live.
- **Docs-hero pills are truthful now:** `v0.1.0` (no "— stable") and `452` tests
  (`artifacts/chitra-docs/src/App.tsx`).
- **Ground-truth teeth:** `.ai/GT-REMEDIATIONS.md` ledger +
  `verify-closeout.sh#check_gt_remediations` (every row DONE/WAIVED);
  `#check_session_coverage` (a merged `session-NN-*` branch ≥ S17 must have a
  summary); `#check_ground_truth_no_code` (a GT session's diff touches no code).
  `.ai/hooks/hook-ground-truth-guard.sh` enforces no-code-in-GT in the Claude
  harness; opencode relies on the closeout backstop.
- **One canonical test count: 452.** If a session changes it, update it in one
  place and let `verify-session-34.sh#test-count-matches` guard the README badge.
