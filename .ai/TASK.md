# Current Task Pointer

## Session 48 — the GTM proof pack (complete, closed 2026-10-06)

- **Branch:** `session-48-gtm-proof-pack` from `main`.
- **Contract:** `prompts/48-task-gtm-proof-pack.md` — requirements **R1–R6**,
  spec `.ai/ROADMAP.md:219` + `.ai/GT-REMEDIATIONS.md` S40 row 1.
  **Never amended**; N1 freeze held.
- **Cadence (`N % 5`):** S48 is a code session (`48 % 5 == 3`). **S50** is the next
  ground truth — named here so no handoff mis-schedules onto it again.
- **Delivered (all six):**
  - **R1** — front-door claims derive from their source: 20 charts ← export lines,
    3 renderers ← `RendererType`, 7 themes ← `Object.keys(themes)`, 453 ← suite,
    0 deps / MIT / 0.4.0 ← manifest. README + docs hero + KNOWLEDGE all checked.
  - **R2** — adoption read by `scripts/gtm-reads.mjs`: **t1 = 289** (2026-10-07
    re-read; the close read of 273 through 10-06 was later revised by npm — 16
    credited to 10-05), **t0 = 119** reproduces with `--as-of 2026-10-03`,
    release days labelled, **0 organic**. Ledger S40 row 1 `DEFERRED → DONE`.
  - **R3** — benchmarks from `scripts/gtm-bench.mjs`: 0 deps · 81.5 KB packed ·
    398.4 KB / 39 files · ≤ 2 ms — cited in the README with the command above.
  - **R4** — one channel live: LinkedIn post published **2026-10-06** (URL in
    STATE, re-fetched 200 by the gate), measurement window opens that day.
  - **R5** — first screen probed: install line, docs link 200, README example
    byte-identical to a real render.
  - **R6** — record honest: roadmap points at the instruments; only 119/273 may
    appear as downloads figures; `never cite as traction` enforced.
- **Gates:** `verify-session-48.sh` **10/10** · `demo-session-48.sh` **6/6 probed**
  · **11 counterfactuals** executed, all red with the right diagnosis.
- **Product:** 453/453 untouched (`product-untouched` green at every commit).

## Next session (S49)

- **Read the channel:** `node scripts/gtm-reads.mjs` after **2026-10-13** — compare
  the days after the post against the flat line before it. This is the reading the
  whole pack exists to produce.
- Alternatives: **new product surface** (none since `c72cc14`), or **S47's three
  disclosed residuals** (root-dotfile asymmetry, cost counts asserted-not-derived,
  one waiver covering two checks).
- **S50 (`50 % 5 == 0`) is the next NO-CODE ground truth.**
- Contract for S49 does not exist yet — write `prompts/49-task-*.md` at plan time.
