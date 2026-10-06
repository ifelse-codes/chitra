# Session 48 — summary · the GTM proof pack

**Contract:** `prompts/48-task-gtm-proof-pack.md` — requirements **R1–R6**, spec
`.ai/ROADMAP.md:219` (the deferred *GTM proof pack*) + `.ai/GT-REMEDIATIONS.md`
S40 row 1 (adoption baseline, DEFERRED, expiry 2026-10-31).
**Branch:** `session-48-gtm-proof-pack` from `main` (`2f3c089` at branch time).
**Story:** every number a stranger sees is produced by a command, and there is one
measurable path from stranger to install.

---

## What shipped

| # | Requirement | Status | Evidence |
|---|---|---|---|
| **R1** | front-door claims derived, not typed | **SHIPPED** | `claims-match-truth` derives one source per fact: **20** charts ← export lines in `charts/index.ts`, **3** renderers ← the `RendererType` union, **7** themes ← `Object.keys(themes)` on the built package, **0** deps / **MIT** / **0.4.0** ← manifest, **453** ← the suite. Checked in three places: README badges + prose, the docs hero's five stat blocks, and the `all 20 charts` line in `KNOWLEDGE.md`. **4 counterfactuals red:** `charts-20→21`, `tests-453→452`, one glyph in the rendered example, install line removed |
| **R2** | adoption measured, not asserted | **SHIPPED** | `scripts/gtm-reads.mjs` prints the day-level series and labels release days from the npm registry's own publish times. **t0 = 119 reproduces exactly** with `--as-of 2026-10-03`; **t1 = 273** through 2026-10-06 (243 on the two release days, 30 across the following four, **0 on 10-05 and 10-06**). `.ai/GT-REMEDIATIONS.md` row 1 `DEFERRED → DONE`. **2 counterfactuals red:** `273→274`, `--as-of 10-03 → 10-02` (instrument says 115) |
| **R3** | benchmarks measured, cited with their command | **SHIPPED** | `scripts/gtm-bench.mjs` → **0** deps, **81.5 KB** packed, **398.4 KB / 39 files** installed, **≤ 2 ms** budget for a 100-point line (median of 200 runs on `toPlain()`, not stdout). New README *Benchmarks* section cites each figure with the reproduce command directly above. **3 counterfactuals red:** `81.5 KB → 40 KB`, command deleted, `39 → 40 files` |
| **R4** | one channel, one link, attributable | **SHIPPED** | Published **2026-10-06** on LinkedIn (native upload of the 42s `chitra-intro.mp4` film, repo/docs links in the first comment): `https://www.linkedin.com/posts/isuman_opensource-typescript-terminal-ugcPost-7513093305937657856-0U9h/`. STATE records URL + date + the reader pointer; `channel-recorded` fetches it (200 today, 404 when LinkedIn drops it); the demo prints SHIPPED only if it still answers |
| **R5** | first screen answers three questions, probed | **SHIPPED** | `first-screen-probes`: install command present; the docs link answers **200** live; README's 20-line example block is **byte-identical** to a real `noColor` render (trailing whitespace excluded) |
| **R6** | the record says what happened, not what we hope | **SHIPPED** | `ROADMAP.md:219` now says *delivered in S48* with both instruments and this summary beside it; `record-honest` scans STATE + ROADMAP and fails on any downloads figure the instrument does not print (only **119** and **273** are allowed) and on a STATE that loses its `never cite as traction` guard. **2 counterfactuals red:** `500 downloads` written in, pointer removed |

**Assumptions (2, both held):** AS-1 README's positioning line stayed the spec —
never rewritten; AS-2 the pack ships the **instrument**, not a promised number.

---

## Counterfactuals executed (11, each RED with the right diagnosis)

| Gate check | Stimulus | Result |
|---|---|---|
| `claims-match-truth` | badge `charts-20` → `21` | `claim ≠ truth in: README-badge` |
| `core-suite-green` | badge `tests-453` → `452` | `README claims 452 tests` |
| `first-screen-probes` | one glyph changed in the example | `README example has drifted from a real render` |
| `first-screen-probes` | install line removed | `no install command for a stranger` |
| `adoption-reading-recorded` | `273` → `274` | `instrument says '273'` |
| `adoption-reading-recorded` | `--as-of 10-03` → `10-02` | `instrument says '115'` |
| `benchmarks-cited-with-command` | `81.5 KB` → `40 KB` | `README tarball row ≠ measured 81.5 KB` |
| `benchmarks-cited-with-command` | reproduce command deleted | `does not show the command` |
| `benchmarks-cited-with-command` | `39 files` → `40` | `README footprint row ≠ measured … 39 files` |
| `record-honest` | `500 downloads` into STATE | `figure(s) no instrument prints: '500 downloads'` |
| `record-honest` | evidence pointer removed | `roadmap's pack row has no evidence pointer` |

The demo proved itself the same way: its first run printed **NOT PROVEN** on R3
because my own probe had a missing parenthesis — a row that cannot fail would have
printed `SHIPPED` over broken code.

---

## What the pack surfaced (findings, not deliverables)

1. **The naive command would have "fixed" a correct badge.** Counting files in
   `charts/` says **23**; the public API exports **20**. The extra three are
   `index.ts`, `line-model.ts` and **`ring.ts` — implemented but never exported**.
   The claim was right all along; only the *derivation* was missing.
2. **273 downloads, none organic, and the last two days are flat zero.** The 0.4.0
   spike (154 on 10-04) is our own release. Stated in STATE as such; never as traction.
3. **Every claim we could check was already true** — so R1's value is the lock, not
   a correction. That is the honest result: the front door was clean, just unguarded.

---

## Product

- **Untouched by design:** `product-untouched` green at every commit — no file under
  `packages/core/src/`, no lockfile change. A GTM session must not change the product.
- **453/453** tests re-derived; typecheck clean; docs link 200; npm `latest` `0.4.0`.

## Verify

- `bash scripts/verify-session-48.sh` → **10/10 PASS**, exit 0 (full scope).
- `bash scripts/demo-session-48.sh` → **6/6 SHIPPED**, exit 0 (every row probed).

## Cost

- One opencode session (this chat), plan approval + **D-48-1** taken to LinkedIn by
  the founder; **6** requirements, **2** assumptions, both held.
- **11 delivery commits**, max **3 files** each (derived per commit).
- **0** product tests added (453 stays 453), **0** lockfile changes, **0** releases,
  **0** npm secrets, **0** new recurring infrastructure. Token/`$` unmeasured (founder's plan).

## 3 next options

1. **Read the channel in 7 days** — `node scripts/gtm-reads.mjs` after 2026-10-13:
   if the days after the post stay at zero, the channel was wrong, not the product.
   The instrument already exists; only the reading is owed.
2. **New product surface** — nothing since `c72cc14` (S09); a channel that answers
   is the trigger for building what people ask for.
3. **S47's disclosed residuals** — one small maintenance lane (root-dotfile
   asymmetry, cost counts asserted not re-derived, one waiver covering two checks).
