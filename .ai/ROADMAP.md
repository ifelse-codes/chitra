# chitra — Working Roadmap

**Updated at every closeout.** North-star: *the best terminal chart lib ever created* —
zero-dep, AI-first, delightful. (Seeded S00; sequenced S01, 2026-07-02.)

## Milestone: Docs & examples
- **S01** ✅ — Docs-from-lib generator (PR #1, squash `d4242d8`).
- **S02** ✅ — Expand examples (PR #3).
- **S03** ✅ — Polish docs site.
- **S04** ✅ — README / getting-started.

## Backlog (not yet scheduled)
- 🔄 **Session 41 (S41) — cleanup Batch 1: the public face tells the truth, and a
  stranger can build it** (branch `session-41-repo-cleanup`, contract
  `prompts/41-task-repo-cleanup.md`). 13 requirements in three groups: what a visitor
  or consumer sees (the live docs meta placeholder, `VERSION` shipping as `0.1.0`,
  the internal design log in the npm README, five false claims in CONTRIBUTING, the
  `replit.md` Node facts, the release.yml provenance comment, the README's pointer
  into `.ai/`), what a stranger can do (root `build` typechecked the docs before
  core's gitignored `dist/` existed, so a fresh clone got `TS2307`; both vite configs
  threw without `PORT`/`BASE_PATH`), and junk that would ship on `git add -A`.
  Scope came from two independent audits — `code-cleanup-plan-session-41.md` and the
  blind `independent-audit-RESULT.md`, which found 8 things the first missed,
  including that the first one's prescribed build fix did not fix the build.
- ⬜ **Session 42 (S42) — cleanup Batch 2: dead weight.** Delete
  `artifacts/mockup-sandbox/` (69 files, breaks the root build, zero CI references),
  `lib/` + `artifacts/api-server/` (31 files, `/healthz` only, plus the 6-file
  reference chain in root `tsconfig.json`, docs `tsconfig.json`, docs
  `package.json`, `ci.yml`, root scripts, `pnpm-workspace.yaml`), `attached_assets/`
  (3 files, reachable only through an unused `@assets` alias), and 5 dead scripts.
  Do **not** delete the `verify-session-NN.sh` / `demo-session-NN.sh` pairs —
  `verify-closeout.sh` reads the current session's.
- ⬜ **Session 43 (S43) — cleanup Batch 3: docs weight.** 43 unused shadcn components
  (~5,000 LOC) and the dependencies that die with them, then the Prettier config
  (31 core files currently fail `--check`) and the `lint` script, which points at an
  eslint that is not installed and has no config.
- ⬜ **Session 44 (S44) — cleanup Batch 4: OSS polish + the founder decisions.**
  `SECURITY.md`, `CODE_OF_CONDUCT.md`, issue/PR templates, CI badge, coverage job,
  `engines`, and decisions **D1** (how much internal process goes public — options B
  and C break `check_session_coverage` / `check_task_ref` unless the gates are
  rewritten first), **D2** (hooks activation), **D3/D6** (track or ignore
  `playground/` and the design mockups), **D4** (personal-path scrub —
  **irreversible once public**), **D5** (`pnpm-workspace.yaml` overrides cruft, needs
  a lockfile regen in its own commit). **Then the public flip**, which resolves the
  README clone URL, npm `repository.url` / `homepage`, and turns npm provenance on in
  one move.
- ✅ **Session 37 (S37) — publish the package to npm (the S36-deferred item):** the
  `@chitra` npm **org is not owned by the account** (and unscoped `chitra` was taken),
  so the package was renamed `@chitra/core` → **`@ifelse.codes/core`** across 26 live
  files and **published**: `@ifelse.codes/core@0.1.0` (38 files / 94.2 kB, tag
  `latest`); a clean consumer `npm install` verified. Publishing needed npm's
  **web/passkey 2FA** flow, which npm runs only on a TTY — done inside `tmux`. README
  install + docs-hero pill made honest; `.ai/GT-REMEDIATIONS.md` row 2 → `DONE`;
  closeout gates hardened (a `DEFERRED` row needs reason+expiry; the GT no-code
  offender path is exercised). `v0.1.0` re-cut + tag pushed on the post-merge `main`.
- ✅ **Session 36 (S36) — close the S35 ground-truth gaps + unfreeze deploy
  (founder-waived multi-story):** **unfroze the live deploy** (S31 order lifted)
  and redeployed the docs site so the S33 `/ai-data` page is live; deleted the
  stale local `v0.1.0` tag; hardened `release.yml` (skip-if-published,
  idempotent tag push); fixed the docs-hero pills (`v0.1.0`, `452` tests);
  corrected KNOWLEDGE.md's stale facts (one canonical test count, 23 files,
  Node 26, `main` range, dist-built); gave ground-truth teeth
  (`.ai/GT-REMEDIATIONS.md` + `check_gt_remediations`, `check_session_coverage`,
  `check_ground_truth_no_code`, and `.ai/hooks/hook-ground-truth-guard.sh`);
  backfilled the S17/S32 session records; made cost tracking carry a measured
  line. **`@ifelse.codes/core@0.1.0` publish was deferred to S37** — now **done in
  S37**.
- ✅ **Session 38 (S38) — release runway:** npm **Trusted Publishing (OIDC)** wired into
  `release.yml#publish`; the long-lived `NODE_AUTH_TOKEN` path is gone and
  **`@ifelse.codes/core@0.2.0` was published by CI unattended** (tag `v0.2.0` on merged
  `main`; no human, no tmux, no passkey). The blocker was subtler than a config flag:
  **pnpm 9.x cannot exchange an OIDC token**, so the publish step had to move to
  `npm publish`. Repo is private, so npm generates **no provenance** — surfaced, not
  decided. The exposed npm *account* token is still open (founder-owned).
- ⏸️ **MCP server — DEFERRED by founder decision (S38).** Not built, not stubbed. The
  gate is explicit: build it only after a release exists **and** someone actually
  demands it **and** it is judged worth building. The README's
  `server.tool("render_chart", …)` snippet is labelled *not shipped yet* and points
  here, so the deferral leaves no dangling promise. (It previously advertised a
  handler that does not exist — that claim is now corrected in both places.)
- ✅ **Session 39 (S39) — rename the package to `@ifelse.codes/chitra`:** the npm page read
  `@ifelse.codes/core`, which buried the product name in every install command. The scope was
  never the problem — the part after the slash is. 27 files changed; `charts.ts` regenerated
  (never hand-edited); `mcp` dropped from `keywords` (nothing ships it, and a keyword is a
  promise in a search index); description now leads with the name.
  **A brand-new package name cannot be published by CI** — npm keeps the trusted-publisher
  config inside the package's own settings page, and a package that does not exist has no
  settings page. The `v0.3.0` run proved it (publish job 404'd on a missing publisher), a
  human published once, and the retry took the idempotency skip path → 4/4 green.
  **CI published `0.3.0` zero times** — asserted by three attempt-level checks, because
  S38's ordering check would have gone *falsely* green here. The founder also dropped the
  planned `npm deprecate` (no public release, nobody to redirect), which forced the rename
  notices to come out rather than stand as a claim about npm's registry. Three live lies fixed
  in passing: the docs hero pill (`v0.1.0` while the manifest said `0.2.0`), the CHANGELOG's
  "no public version published yet", and the contract's own deprecation sentence.
  `verify-session-39.sh` 43/43; cold review REJECTed the first delivery (a narrowed honesty
  guard, a hardcoded version literal, two fabricated demo `WORKS` rows) — all fixed.
- 🔜 **Next (S41 candidates):** the three S39 items stand unchanged, now pushed out one
  session by S40's mandatory ground-truth audit — a **GTM proof pack** (benchmarks /
  token-savings / before-after), a real **`0.4.0` through CI** (the cheapest proof that the
  trusted publisher works; nothing needs to change for it), and **fixing the
  `required-crew` gate** (two founder waivers, S38/S39, for a tech-lead step
  `.ai/AGENTS.md` never asks for). `artifacts/api-server` beyond `/healthz` remains the
  undecided "if the hosted API is pursued" bet, not a task.
- 🔜 **Session 40 (S40) — NO-CODE ground-truth audit (`40 % 5 == 0`) — DONE, 🔴 overall.** The
  **5-session cadence is now on the board**: it is constitutional and hook-enforced, yet it
  appeared in **zero of the last four handoffs** — which is exactly how S40 arrived as a
  surprise, since S39 offered three code-shaped candidates and named no audit.
  **The vision verdict came back 🟡, not 🔴, after two founder corrections recorded in the
  audit:** nothing has been released-and-marketed, so the **adoption baseline of zero is the
  correct pre-launch reading** — the finding is that the number had *never been read*
  (`@ifelse.codes/core`'s 304 downloads are 0 for the 9 days before its publish and all land
  in the 5 days after, release-runner shaped; `@ifelse.codes/chitra` is unindexed by the npm
  downloads API entirely). And **the repo goes public after a code cleanup** — so today's
  404s (README's `git clone`, npm `repository.url`, npm `homepage`) are a known, sequenced
  state, not a blocker. **Highest leverage, and newly named: the cleanup itself.** It gates
  the public flip, it has no roadmap item, no scope and no owner, and the flip then resolves
  all three links plus npm provenance in one move. Still 🔴 overall: **S16 vanished** with no
  artifacts, nothing on `main`, no ledger row and a gate floor above it; `KNOWLEDGE.md`
  re-serves a falsehood the S35 ledger already closed — **fixed in S40**, along with putting
  this cadence on the board; and the one automated check policing a ground-truth session is
  structurally blind in this harness (`check_ground_truth_no_code` diffs an empty range and
  returns `OK`; proved by planting a `.ts` file). The S40 closeout is **RED, 14 pass / 2 fail**
  — `required-crew` and `review-inputs-attested`, both structurally unsatisfiable in a
  NO-CODE session and founder-waived. Eleven remediations in `.ai/GT-REMEDIATIONS.md`:
  3 `DONE`, 8 `DEFERRED` to S41.
- ✅ **Session 35 (S35) — NO-CODE ground-truth (`N % 5 == 0`):** audited vision,
  roadmap, state, knowledge, constraints, constitution, cost. Overall 🟡 —
  direction sound, distribution blocked, governance claims unbacked. Found the
  stale `v0.1.0` tag, the npm E404, the dead `/ai-data` README link, three
  contradictory KNOWLEDGE test counts, S17/S32 closeout gaps, and a
  hook-enforced GT rule with no hook. Output
  `sessions/session-35-ground-truth.md`; remediations folded into S36 (see
  `.ai/GT-REMEDIATIONS.md`).
- ✅ **Session 34 (S34) — GTM README (the GitHub front door):** the repo had
  **no root README**; added `README.md` (214 lines) — positioning line
  *"Terminal charts for CLIs and agents."*, badge row (npm · MIT · 0 deps ·
  452 tests · 20 charts), install + quickstart with **three real library
  renders** (line, horizontalBar, sparkline), AI-builder lane first
  (`toContent()/toPlain()/toJSON()`, MCP handler, AI-data link), terminal lane
  second, a 20-chart gallery, and docs links. Added the MIT `LICENSE` at repo
  root **and** `packages/core/LICENSE` (fixing the package's unresolved
  `files: ["LICENSE"]` publish path). `verify-session-34.sh` 39/39 ALL GREEN —
  embedded renders regenerated from source and **byte-compared whole-block**
  (drift guard), facts (20/3/7/0/452) cross-checked against source, stale-claim
  guards; demo exit 0. Cold review ACCEPT **6/6** after three rounds (footer-only
  drift check → whole-block; missing npm badge → added; root-only LICENSE →
  package LICENSE), attested `60627a87…d231067`. Disclosed: `@ifelse.codes/core` is not
  on npm yet (README says so). PR #40.
- ✅ **Session 33 (S33) — release readiness (founder-waived multi-story):**
  Playwright browser QA wired into CI; candle ties-first exclusivity test
  (second tied candle proven un-accented); `lineModelToSvg` brought to
  terminal parity (canonical colours moved into the model; theme tones,
  markers every 2nd point, dash textures, `grid`-gated gridlines,
  legend/eyebrow/summary captions, accent-once) + `line-svg.test.ts` drift
  guard; new `ai-data` AI-data manual page + README link. `verify-session-33.sh`
  17/17 ALL GREEN, demo exit 0. Cold ACCEPT 5/5 (mutation-tested). Terminal
  line output byte-identical; 452 core tests green; drift gate green.
- ✅ **Session 31 (S31) — antra design atoms into chitra-docs
  (founder in-chat direction + follow-ups):** `--antra-*` violet tokens,
  ◆ eyebrow, solid hero accent, install strip, hairline route grid, mono
  topbar, global footer, IO reveal, atmosphere (grid/glow/mandalas),
  editor chrome, 6 fixed-geometry hero variants (`hero-charts.json`,
  19×64, drift-gated, 3s instant cut), Cascadia-led terminal stack
  (wall fix: JetBrains braille 14% wide → pixel-straight, proven).
  `verify-session-31.sh` 24/24 ALL GREEN, demo exit 0. Cold ACCEPT
  10/12 (req 2 tracking one-liner fixed post-pass; req 8 frozen-deploy
  PARTIAL, disclosed). Live deploy FROZEN by founder order.
- ✅ **Session 30 (S30) — docs site live on chitra.iifelse.com
  (Cloudflare Pages, founder in-chat direction):** project `chitra`
  (`chitra-5xh.pages.dev`, prod branch `main`, direct-upload) + deploy
  `2a690d58` (success) + custom domain `active`/verified (CNAME proxied
  → edge) + `public/_redirects` SPA fallback in `dist/`.
  `verify-session-30.sh` 7/7 ALL GREEN (live deploy + domain API
  checks), demo exit 0. Cold REJECT (gates asserted repo files only) →
  hardened → cold ACCEPT 6/6. External-browser render confirmed.
- ✅ **Session 29 (S29) — family-wide footer pass B-diet+ (founder ballot pick
  on real renders, closes the S21 deferral):** plain-words takeaway footers +
  one rule separator on all 20 charts (donut exempt by design: already
  single-rule, legend owns facts). `verify-session-29.sh` 12/12 ALL GREEN
  (core 444/444), demo exit 0 (4/4). Cold REJECT 4/8 → fixed (donut proof +
  rule/ties asserts) → cold ACCEPT 8/8
  (`Review-Inputs-SHA 60438f92…c4127a`). `### LOCKED: family-wide footer
  (B-diet+)` README block, authoritative over S09–S28 footer lines.
- ✅ **Session 28 (S28) — sparkline chart LOCKED (in progress, founder
  in-chat direction on the throwaway v8 shape+shade prototype):** `sparkline()`
  re-rendered in the reference/panel language — the heatmap strip grammar with
  a pulse (height reads the trend, shade reads the intensity). Every reading is
  one 2-wide column (≤4 rows by share of range) on the grey tone ramp with its
  matching shade glyph (`░ ▒ ▓`, peak solid `█` accent once, ties → first);
  dashed frame, label on top, `SPARKLINE` eyebrow, two rules,
  `n · min · max · last · peak` foot (peak accented). Retired: the single-teal
  `theme.colors[0]` strip, `▁▂▃` sub-blocks, braille/ascii paths (option
  accepted, design superseded), backtick markdown, bare `""` on empty.
  `verify-session-28.sh` 17/17 ALL GREEN (core 435/435, +15 tests), demo exit
  0 (4/4). `### LOCKED: sparkline chart` README block. The locked family now
  spans 19 charts.
- ✅ **Session 27 (S27) — candlestick + boxplot LOCKED (two stories by founder
  direction, "candlestick boxplot migrate first"):** `candlestick()` re-rendered
  (bullish solids `▓` on mid-grey, bearish dashed outline boxes per the waterfall
  precedent, peak-close solid `█` accent once with wicks in kind tone, adaptive
  price precision — integers when range spans 100+, else ≤1dp/≤2dp trimmed, `OHLC`
  eyebrow, `N · HI · LO · LAST` foot with LAST accented, `count`/`high`/`low`/`last`
  JSON); `boxplot()` re-rendered (peak-median group accent once, grey ramp +
  `░▒▓` shade fill by share of peak median, horizontal `───`/`═══` medians vs
  vertical `│` edges, `SPREAD` eyebrow, `GROUPS · MED · PEAK` foot with PEAK
  accented, `peakGroup` JSON). Neither chart had an audit mockup — family language
  by analogy. Retired: both `theme.colors` rainbows, decimal sprawl, bare titles,
  the empty-data crashes and NaN rows. Two `### LOCKED — session 27 design` README
  blocks. `verify-session-27.sh` 20/20 ALL GREEN (core 428/428, +37 tests), demo
  exit 0 (8/8). Cold review ACCEPT (attested, 13/13 SHIPPED,
  `Review-Inputs-SHA 313a52c5…2822531a`). The locked family now spans circular,
  area, line, bar, scatter, heatmap, horizontalBar, treemap, timeline, gauge,
  progress, histogram, waterfall, funnel, sankey, radar, candlestick, and boxplot.
- ✅ **Session 26 (S26) — waterfall + funnel + sankey + radar LOCKED (five
  stories by founder direction):** `waterfall()` re-rendered (P0 flat-dash
  downs now dashed outline boxes with 1-row minimum, integer y-labels, Start
  darkest-grey `█` + Total accent `█` once, ups `▓`, downs outlined,
  `┄` connectors, signed deltas, `START · Δ · TOTAL` foot, `steps` JSON);
  `funnel()` centered (audit §3.4 item 2 reversed by founder order, on
  research record — no `▼`), peak-stage accent once, integer pcts,
  `CONVERSION` eyebrow + `IN · OUT · CONVERSION · DROP` foot; `sankey()` with
  no `▶`, peak-flow accent once, toned `■` ledger, `FLOW` eyebrow + `PEAK`
  foot; `radar()` with five braille rings + `+` ticks, accent primary,
  dashed grey secondaries, `AVG · PEAK` foot (cold PARTIAL row 15: thin-edge /
  stipple / dashed-ring grammar substituted per the founder reference image,
  disclosed). Four `### LOCKED — session 26 design` README blocks.
  `verify-session-26.sh` 24/24 ALL GREEN (core 391/391, +59 tests), demo exit
  0 (9/9). Cold review ACCEPT (attested, 18/19 SHIPPED,
  `Review-Inputs-SHA cc9736ec…be50559`). The locked family now spans circular,
  area, line, bar, scatter, heatmap, horizontalBar, treemap, timeline, gauge,
  progress, histogram, waterfall, funnel, sankey, and radar — the audit queue
  is empty.
- ✅ **Session 25 (S25) — histogram chart LOCKED (single-chat, resumed from a z-code
  token stop):** `histogram()` re-rendered in the reference/panel language — the
  S18–S23 language on the distribution chart, per the mudra audit's P1 queue (§5;
  §3.3 mockup is the fidelity target). Both P0 bugs retired: integer-only y-axis
  count labels (the old decimal `31.11/22.22/13.33` counts lie) and the
  `theme.colors[0]` accent flood. ONE accent hue spent EXACTLY once as a solid `█`
  column on the mode bin (highest count, ties → first bin); every other bin takes
  the grey tone ramp (`#ECECEF→#6A6A75`) WITH its matching plain-text shade glyph
  (`░ ▒ ▓` by share of modal count — the founder's 2026-09-11 shade-texture ruling,
  so "how full" survives noColor). Dashed frame, uppercase `DISTRIBUTION` eyebrow
  (or `opts.xLabel`), dashed `└╌` baseline, bin-start labels, two rule separators;
  `n · mode · p50 · p99` footer (mode fact accented, nearest-rank percentiles).
  Degenerate-safe: empty → framed `n 0 · (no data)` panel with null JSON facts (the
  old code printed `NaN NaN NaN` bin labels); collapsed range lands in bin 0;
  non-finite samples excluded, never binned. Explicit `width` is a floor
  (auto-width); `toJSON()` gains additive `mode`/`p50`/`p99` (null when empty) +
  `count`. Public API unchanged, zero runtime deps. Docs previews regenerated
  (drift gate green), README `### LOCKED: histogram chart` block.
  `verify-session-25.sh` 13/13 ALL GREEN (core 332/332, +23 histogram tests), demo
  exit 0 (7/7). Cold review ACCEPT (attested, 13/14 SHIPPED,
  `Review-Inputs-SHA b10d5b94…0a761`). See "LOCKED: histogram chart" in
  `packages/core/README.md`. The locked family now spans circular, area, line, bar,
  scatter, heatmap, horizontalBar, treemap, timeline, gauge, progress, and
  histogram — funnel, waterfall, sankey, and radar followed in S26.
- ✅ **Session 24 (S24) — docs-site grouped chart nav (PR #26):** catalog sidebar in
  six semantic categories (trend & time / comparison / distribution & density /
  part-to-whole / flow & accumulation / single value & progress) via a generated
  `group` field (`chart-specs.ts` → `generate-charts.ts` → `charts.ts`, drift gate
  green); collapsible headers (caret, count tags, per-chart glyphs, persisted in
  localStorage, active group auto-expanded) + expand-all/collapse-all. Lock state
  stays internal: ALL status badges removed at founder direction mid-session (cold
  review REJECTs the written badge half — founder waiver, delivery faithful to final
  intent). Verify 12/12, demo exit 0, nav Playwright pass 14/14, S15 suite green on
  the new DOM.
- ✅ **Session 23 (S23) — progress chart LOCKED (single-chat, trio complete):**
  `progress()` re-rendered in the reference/panel language — the S18–S22 language on
  the single-value progress bar, completing the founder-named trio (`timeline` →
  `gauge` → `progress`). Rainbow `theme.colors[2/3/1]` traffic-light bands removed: the
  fill is the grey tone ramp (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) WITH its matching
  plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark — the
  heatmap/gauge texture language per the founder's 2026-09-11 shade-texture ruling, so
  intensity survives noColor); ONE accent hue spent EXACTLY once as the solid `█` on the
  fill's leading edge. The `style` option stays accepted but the locked design
  supersedes it (`▁▂▃` sub-blocks, `=`/`.` ascii, naked `[bar] pct` all retired);
  dashed frame, uppercase `PROGRESS` eyebrow (or `opts.label` uppercased), `+╌…╌+`
  guide + `0..max` scale row, two rule separators; the dim `─` track (axis colour) kept
  as the shared scale. **The silent clamp retired as a lie:** the fill clamps to the
  track while the footer AND `toJSON()` report the TRUE value and TRUE percent (the old
  code clamped `value` into `0..max` before computing); non-finite → framed `value n/a`
  panel; collapsed range (`max === 0`) safe; `value <v> · 0..<max> · <pct>%` footer
  (value fact accented); `showPercent: false` drops the pct fact; `toJSON()` gains
  additive `bucket` (0–3, `null` when n/a) and a true `percent`. Public API unchanged,
  zero runtime deps. `verify-session-23.sh` 13/13 ALL GREEN (core 309/309), demo exit 0
  (7/7), review ACCEPT (attested, 11/14 SHIPPED — the 3 PARTIAL rows are process facts
  a diff cannot carry). See "LOCKED: progress chart" in `packages/core/README.md`. The
  locked family now spans circular, area, line, bar, scatter, heatmap, horizontalBar,
  treemap, timeline, gauge, and progress.
- ✅ **Session 22 (S22) — gauge chart LOCKED (single-chat, founder demo deck):**
  `gauge()` re-rendered in the reference/panel language — the S18/S19/S21 language on the
  single-value chart. Rainbow `theme.colors[1/3/2]` value bands removed: the fill is the
  grey tone ramp (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) WITH its matching plain-text shade
  glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark by level — the heatmap texture
  language per the founder's 2026-09-11 shade-texture ruling, so intensity survives
  noColor); ONE accent hue spent EXACTLY once as the solid `█` on the fill's leading edge
  (marks where the reading stops); explicit `thresholds` stay a user override (tone
  replaced, glyph unchanged, accent yields). Dashed frame, uppercase `LEVEL` eyebrow (or
  `opts.label` uppercased), `+╌…╌+` guide + `min..max` scale row, two rule separators; the
  dim `─` track (axis colour) kept as the shared scale; `┤`/`├` endcaps retired;
  out-of-range clamps the fill (the old `"░".repeat(negative)` `RangeError` is gone) while
  the footer reports the TRUE value and TRUE percent; non-finite → framed `value n/a`
  panel; collapsed range safe; `value <v> · <min>..<max> · <pct>%` footer (value fact
  accented); `toJSON()` gains additive `bucket` (0–3, `null` when n/a) and `percent`.
  Public API unchanged, zero runtime deps, dead `labelLine` removed.
  `verify-session-22.sh` 13/13 ALL GREEN (core 284/284), demo exit 0 (7/7), review ACCEPT
  (attested, 9/9 SHIPPED). See "LOCKED: gauge chart" in `packages/core/README.md`. The
  locked family now spans circular, area, line, bar, scatter, heatmap, horizontalBar,
  treemap, timeline, and gauge.
- ✅ **Session 21 (S21) — timeline chart LOCKED (single-chat, plan-review cross-checked):**
  `timeline()` re-rendered in the reference/panel language — the S18/S19 language on the
  Gantt. Rainbow `theme.colors[i % n]` removed: ONE accent hue spent exactly once on the
  longest-span event (ties → first in event order) as a solid `█` run, grey tone ramp
  (`#ECECEF→#6A6A75`) + `░▒▓` shade texture by span bucket for every other event (the
  heatmap language, added on founder review — ordering survives noColor); dashed frame,
  `SPAN` eyebrow, `+╌…╌+` guide + `min..max` scale row, two rule separators; the `─` track
  kept as the shared time scale (axis colour); point events render exactly one `░`;
  `▶`/`◀` retired; `n · min..max · span <label>` footer (longest event accented);
  collapsed-range guard; empty/all-equal/single safe. Docs previews regenerated, dist
  rebuilt, README `### LOCKED: timeline chart` block. `verify-session-21.sh` 12/12 ALL
  GREEN (core 259/259), demo exit 0. Cold review owed post-commit. See "LOCKED: timeline
  chart" in `packages/core/README.md`. The locked family now spans circular, area, line,
  bar, scatter, heatmap, horizontalBar, treemap, and timeline.
- ✅ **Session 20 (S20) — treemap chart LOCKED (recovered session):** `treemap()`
  re-rendered in the reference/panel language — the S18 `heatmap` language on the
  hierarchical area chart. Rainbow `theme.colors[i % n]` removed: ONE accent hue spent once
  on the max leaf (first-flatten tie-break), grey tone ramp (`#ECECEF→#6A6A75`) + shade
  glyphs (`░▒▓█`) by magnitude; dashed frame, `AREA` eyebrow, `+`/`│` guide, two rule
  separators; `n · min..max · peak <label>` footer (peak accented); honest leaf flatten;
  SPACE empty grid; slivers stay clean blocks (whole-text-only labels); empty/all-equal
  /single safe. Built across pi + Command Code (stopped on credits) + closer chat.
  `verify-session-20.sh` 12/12 ALL GREEN (core 236/236), demo exit 0. Review REJECT on
  record (Req-6 proof gap; 3rd pass owed) — closeout under founder waiver. See "LOCKED:
  treemap chart" in `packages/core/README.md`. The locked family now spans circular, area,
  line, bar, scatter, heatmap, horizontalBar, and treemap.
- ✅ **Session 19 (S19) — horizontalBar chart LOCKED (Vajra S144 full-loop dogfood):**
  `horizontalBar()` re-rendered in the reference/panel language — the S12 `bar` language
  rotated to horizontal. Rainbow `theme.colors[i % n]` and the `░` phantom filler removed:
  ONE accent hue spent once on the global-max bar (first-max tie-break), grey tone ramp
  (`#ECECEF→#6A6A75`) for every other bar; dashed frame, uppercase eyebrow, rotated `+`
  value-axis guide + `min..max` scale row, two rule separators, per-item value labels with
  the peak value in accent; SPACE empty cells; auto-scale (`min(0,dataMin)`) + auto-width;
  empty/all-equal/single safe. Native chitra session driven by chitra's OWN fleet + hooks:
  tech-lead first, binding crew verdict (4 required + 5 deferred-budget), provenance-verified
  handoffs, S139 required-crew gate live. `verify-session-19.sh` 11/11 ALL GREEN (core
  217/217), demo exit 0, review ACCEPT (attested, 8/8 SHIPPED). See "LOCKED: horizontalBar
  chart" in `packages/core/README.md`. The locked family now spans circular, area, line,
  bar, scatter, heatmap, and horizontalBar — the core-set migration is complete.
- ✅ **Session 18 (S18) — heatmap chart LOCKED:** `heatmap()` re-rendered in the
  reference/panel language — grey tone ramp (`#ECECEF→#6A6A75`, light→dark) as the
  intensity encoding replacing the old 10-colour rainbow (`HEAT_COLORS_DARK`); the
  single accent hue spent exactly once on the max-value cell (ties → first row-major);
  dashed frame, `DENSITY` eyebrow, `│`/`+` guide, two rule separators,
  `rows×cols · min..max · peak (r,c)` footer; empty/degenerate safe.
  `verify-session-18.sh` 8/8 ALL GREEN (core 192/192), demo exit 0, review ACCEPT
  (attested). See "LOCKED: heatmap chart" in `packages/core/README.md`. The locked
  family now spans circular, area, line, bar, scatter, and heatmap.
- ✅ **Session 17 (S17) — scatter chart reference-locked** (single-series peak accent,
  multi-series primary-group accent; dashed panel, eyebrow, `+`/`│` guide, `n·x·y·peak`
  footer). See "LOCKED: scatter chart" in `packages/core/README.md`.
- ✅ **Session 15 (S15) — scripted browser QA of all 20 catalog pages:** Playwright
  drives every `/chart/:id` + doc pages; non-empty terminal output, zero console/page
  errors, Run-shortcut re-render, persistence smoke. `verify-session-15.sh` 8/8 GREEN.
- ✅ **Session 14 (S14) — real URL routes + boot-scoped editor persistence:**
  wouter drives navigation (`/chart/:id` for all 20 charts, `/install`
  `/quickstart` `/fluent-api` `/ai-output`; refresh/back work; unknown ids fall
  home). Editor edits persist across refresh/navigation until the dev server
  restarts (localStorage keyed by an injected per-boot id); Reset restores
  pristine. PR #15. `verify-session-14.sh` 20/20 ALL GREEN, demo exit 0, review
  ACCEPT (attested).
- ✅ **Session 13 (S13) — docs catalog chrome at Darpan parity:** toolbar on one
  control metric; Run = Darpan `.btnPrimary` accent fill + ⌘↩ / Ctrl ↩ keycap;
  global cmd/ctrl+enter shortcut; white-alpha fg tiers ported from Darpan's
  `theater-tokens.css` after reading the real codebase + live app; uppercase
  chips, ghost actions, inspector kv footer, dashed empty state, RUN FAILED
  banner. PRs #12/#13. `verify-session-13.sh` 27/27 ALL GREEN, demo exit 0,
  review ACCEPT (attested).
- ✅ **Session 10 (S10) — line chart reference-locked (thin multi-series lines):**
  `line()` now matches the founder's `tui-chart (1).html` reference — every series a
  continuous thin braille line in its own colour, glyph markers on every series
  (`* ○ + × □`, every 2nd index), dotted `·` gridlines on y-step rows, per-series
  `min/max/avg/last` summary rows, primary keeps the LOCKED accent peak cap.
  `verify-session-10.sh` 24/24 ALL GREEN, 142 tests, demo exit 0. See "LOCKED: line
  chart" in `packages/core/README.md`.
- ✅ **Session 09 (S09) — circular charts LOCKED (pie/donut braille-dot look):** see the
  "LOCKED: circular charts" contract in `packages/core/README.md`. The braille
  sub-pixel circle + dashed panel + tone-ramp/one-accent + right legend is the
  official look — **every future chart rebuild should carry this exact look and
  feel**. Area chart locked to the same language too (line = fill top edge,
  accent only on the peak). Docs site updated (Cascadia Mono font stack for
  braille), handoff file at `scripts/ring-polish-handoff.mjs`, live preview at
  `/tmp/ring-lab/index.html`.
- ✅ **S06** — Real publishable `dist/` build for `@ifelse.codes/core` (ESM + CJS + `.d.ts`, zero deps).
- ✅ **S07** — CI workflows (`.github/workflows/ci.yml`: core · docs · chart-drift gates, pinned toolchain).
- ✅ **Session 08 (S08)** — release.yml publish workflow. v* tag push → re-runs S07
  gates → `pnpm publish --access public` with `NODE_AUTH_TOKEN`. Plus line-chart
  SV-grade upgrade, shared `LineChartModel` + `toSVG()` web renderer, docs SVG
  output, and the terminal dashboard panel (`timestamp`/`status`/`summary`).
- Flesh out `artifacts/api-server` beyond `/healthz` if the hosted API is pursued.
- ✅ Real release **done (S37)**: `@ifelse.codes/core@0.1.0` is **live on npm**
  (renamed from the unowned `@chitra` scope); `v0.1.0` tag cut on post-merge `main`.
- ✅ S05 ground-truth remediation **closed (S36)**: S17/S32 records backfilled;
  closeout-integrity gates added (`check_session_coverage`,
  `check_ground_truth_no_code`, `check_gt_remediations`). S04/S06 (pre-convention)
  remain grandfathered.

## Guardrails carried forward (see [[knowledge]])
- Zero runtime deps · keep `toPlain()`/`toJSON()` agent output · **452 tests green** ·
  public API stability.
