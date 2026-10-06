# Session 48 — independent fidelity review

**Verdict:** REJECT (pass 8) — **CLOSED BY FOUNDER ORDER, 2026-10-06; pass 9 NOT RUN**
**Review-Inputs-SHA:** f8c7cfe26db313f2f17acf6f327ba936d1172627a80ac211d68211e193d4c910

> **This file is not an acceptance, and it does not pretend to be one.**
> `scripts/verify-closeout.sh` reads the FIRST anchored verdict line; the line above says
> **REJECT**, so the closeout gate reads BLOCK and is closed only by the founder waiver
> (`VAJRA_CLOSEOUT_WAIVER=48`) with the reason recorded in the close log. Nothing in this
> repository claims the delivery was accepted — because it was not.
>
> | Pass | Author | Verdict | What it did |
> |---|---|---|---|
> | 1 | an independent reviewer session, fed contract + diff only | **REJECT** | 4 grounds: closeout `roadmap-references-N` red; core README + rendered license unchecked; `999 downloads` in KNOWLEDGE green; a traction sentence in the summary green |
> | 2 | same reviewer | **REJECT** | its 4 grounds closed and re-proved; found 2 more (unanchored `charts-20`, ledger outside the scan) + a regression |
> | 3 | same reviewer | **REJECT** | 11 contract greens left (N1–N11) |
> | 4 | same reviewer | **REJECT** | 8 contract greens (E3–E18) |
> | 5 | same reviewer | **REJECT** | 9 contract greens (H_*), plus the unsatisfiable-classes note |
> | 6 | same reviewer | **REJECT** | 6 contract greens (X_*/Y_*) |
> | 7 | same reviewer | **REJECT** | 7 contract greens (Z_*), and a bash-3.2 crash found in my rewrite |
> | 8 | same reviewer | **REJECT** | **1** ground left (V1: version stated in README prose) |
> | 9 | — | **NOT RUN** | the founder ordered the session closed without a further pass |
>
> **Ground count over the eight passes: 4 → 2 → 11 → 8 → 6 → 9 → 7 → 1.**
> **V1 was fixed in `e98928f` and is therefore UNREVIEWED** — the one open item this
> closure leaves behind, recorded in `.ai/STATE.md`.
>
> **Authorship:** the reviewer wrote none of the delivery, never read
> `sessions/session-48-summary.md` as prose, and every verdict above rests on exit codes it
> observed itself. The finisher session concatenated these eight sections verbatim (each
> was written by the reviewer to its own temp file) and wrote only this header.

---

# Session 48 — independent fidelity review (pass 1)

## Method controls

**Inputs fed cold.** Only (1) `prompts/48-task-gtm-proof-pack.md` read in full before
any delivery code, and (2) `git diff $(git merge-base main HEAD)..HEAD` / `git log`.
Merge-base = `2f3c0898173a6d7eea3bba2d7c38599e26b82cac`; 15 delivery commits, all
`S48:`-prefixed, all `prompts/48-task-gtm-proof-pack.md` history = exactly **1** commit.

**Contamination controls.**
- **Not read:** `sessions/session-48-summary.md` as prose. Disclosure of a deviation:
  I ran three *structural* greps against it (heading list; `[0-9]{3,}…downloads`
  pattern; traction-word pattern) plus one stimulus test (appended a traction
  sentence, observed the gate, restored byte-identically). Two of those greps echoed
  lines out of its R1/R6 fidelity-map table — **those builder claims were treated as
  untrusted and are not evidence for any row below**; every verdict is backed by my
  own probe or my own fetch.
- **Opened under contamination control, and only to verify the named fact:**
  `.ai/STATE.md` (R2 readings + R4 URL/date/reader pointer), `.ai/GT-REMEDIATIONS.md`
  row 1 (R2 DEFERRED→DONE), `.ai/ROADMAP.md` (R6 evidence pointer + the closeout
  `roadmap-references-N` literal), `.ai/SESSION` (closeout N=48), `.ai/KNOWLEDGE.md`
  (R1 claim site `all 20 charts` — grep only).
- **Refused:** any chat, note or summary of the agent that wrote this delivery.

**Probes run (observed exit codes).**
- `bash -n scripts/verify-session-48.sh` → **0**; `bash -n scripts/demo-session-48.sh`
  → **0**; `node --check scripts/gtm-reads.mjs` → **0**; `node --check scripts/gtm-bench.mjs`
  → **0**. (A `bash -n` over the two `.mjs` files errors by construction — they are JS;
  they are checked with `node --check`.)
- `bash scripts/verify-session-48.sh` → **0**, **10/10 PASS** (`.ai/verify/session-48/latest/`
  read: `summary.txt` 10×PASS, `timings.txt` present, 10 non-empty per-check logs;
  `claims-match-truth.log` = `charts=20 renderers=3 themes=7 deps=0 license=MIT version=0.4.0`).
- `bash scripts/demo-session-48.sh` → **0**, **6/6 SHIPPED** (each row is probed: `row()`
  prints SHIPPED only when its probe exits 0 *and* emits `ok`).
- `bash scripts/verify-closeout.sh` (N=48) → **1**, 14 pass / 3 fail
  (`roadmap-references-N`, `fidelity-review-accept`, `required-crew`).
- `bash scripts/verify-closeout.sh` with `VAJRA_CLOSEOUT_WAIVER=48` → **1**, 16 pass / 1 fail
  — `fidelity-review-accept` and `required-crew` turn green (the standing OpenCode crew
  reason), **`roadmap-references-N` stays red: `DRIFT: ROADMAP.md does not reference Session 48`**.
  Green on merit: `session-file-valid, required-files-exist, session-boot-current,
  task-ref-current, state-required-sections, session-prompt-summary-pair,
  merged-sessions-have-records, cost-tracking-present, execution-shas-filled,
  verify-demo-scripts-present, review-inputs-attested, contract-freshness,
  ground-truth-no-code, gt-remediations-dispositioned` (14). Waived: `required-crew`,
  `fidelity-review-accept` (the latter is legitimately owed to *this* pass).
  Not waived and red: `roadmap-references-N`.
- `bash scripts/verify-closeout.sh --inputs-sha 48` → **0**, printed
  `fdc8415131594c6154a73c50ab7d252b56d0b33a0da4b992c49d8bc64d07050e` (matches the
  required value).
- **17 mutations, each restored, each with `git status --porcelain` empty afterwards**
  (driver: `/private/var/…/T/opencode/s48-probe-driver.sh`, `…-driver2.sh`):

  | Stimulus | exit | RED |
  |---|---|---|
  | P0 baseline, no mutation | 0 | — |
  | P1 README badge `charts-20`→`21` | 1 | `claims-match-truth` |
  | P1b README prose `all 20 charts`→21 | 1 | `claims-match-truth` |
  | P1c `packages/core/README.md` `20 Chart Types`→21 | **0** | **none** |
  | P1d docs hero `stat-num` 20→21 | 1 | `claims-match-truth` |
  | P1e `.ai/KNOWLEDGE.md` `all 20 charts`→21 | 1 | `claims-match-truth` |
  | P1f README license badge URL `license-MIT`→`license-Apache` | **0** | **none** |
  | P1g README `dependencies-0`→`1` | 1 | `claims-match-truth` |
  | P2 README `tests-453%20passing`→`452` | 1 | `core-suite-green`, `claims-match-truth` |
  | P2b README `tests-453`→`999` | 1 | `core-suite-green`, `claims-match-truth` |
  | P3 one glyph in the ```text example (`TREND`→`TREM`) | 1 | `first-screen-probes` |
  | P4 delete `pnpm add @ifelse.codes/chitra` | 1 | `first-screen-probes` |
  | P5 STATE `t1 = 273`→`274` | 1 | `adoption-reading-recorded` |
  | P6 STATE `--as-of 2026-10-03`→`2026-10-02` | 1 | `adoption-reading-recorded` |
  | P7 README `81.5 KB`→`40 KB` | 1 | `benchmarks-cited-with-command` |
  | P8 delete `node scripts/gtm-bench.mjs` from README | 1 | `benchmarks-cited-with-command` |
  | P9 `500 downloads` appended to STATE | 1 | `record-honest` |
  | P10 ROADMAP evidence pointer removed | 1 | `record-honest` |
  | P11 STATE LinkedIn URL deleted | 1 | `channel-recorded` |
  | P11b STATE LinkedIn URL → bogus post URL | 1 | `channel-recorded` (HTTP leg, not just grep) |
  | P12 `999 downloads` appended to `.ai/KNOWLEDGE.md` | **0** | **none** |
  | P13 `adoption baseline is zero` appended to `.ai/ROADMAP.md` | **0** | **none** |
  | P14 traction sentence appended to `sessions/session-48-summary.md` | **0** | **none** |

  All 11 required probes behaved as specified; P1c/P1f/P12/P13/P14 are additional
  adversarial probes that came back **green** (findings below).
- **Independent instruments (I ran them, not the gate):** `gtm-reads --as-of 2026-10-03`
  → `total=119`; `--as-of 2026-10-06` → `total=273`, `release-shaped-total=243`,
  `non-release-total=30`, `days-since-last-non-zero=2`. `gtm-bench.mjs` → `deps=0`,
  `tarball-bytes=83496 / 81.5 KB`, `unpacked-bytes=407961 / 398.4 KB`, `pack-files=39`,
  `render-median-ms=0.07`, `render-budget-ms=2`, `verdict=within render budget`.
- **Independent network:** my own `downloads/range/2026-09-15:2026-10-06` fetch →
  22 days, sum **273**, non-zero `09-29=89, 09-30=15, 10-01=6, 10-02=5, 10-03=4,
  10-04=154`, `10-05=0`, `10-06=0` — day-for-day identical to the instrument.
  `npm view @ifelse.codes/chitra time --json` → `0.3.0: 2026-09-29`, `0.4.0: 2026-10-04`
  — the script's release-day labels are correct. `npm view … version license` →
  `0.4.0`, `MIT`, no dependencies.
- **R4 live:** LinkedIn post URL from STATE, browser UA, `-L` → **200**. `https://chitra.iifelse.com`
  → **200**, `https://chitra-5xh.pages.dev` → **200**.
- **R5 example:** my own render of `line({data:[12,19,14,27,22,34,29,41], title:"Weekly active users",
  noColor:true})` vs README's first ```text block → identical after trailing-space strip (20 lines).
- **Invariants:** 3-file cap over all 15 delivery commits → max **3** (`git show --numstat | grep -c .`).
  Smuggle diff `git diff $MB..HEAD --name-only -- .ai/AGENTS.md packages/ pnpm-lock.yaml .github/workflows/`
  → **empty**. Contract history → exactly **1** commit (`95dd29c`).
  `pnpm --filter @ifelse.codes/chitra run test` → **0**, `Test Files 23 passed / Tests 453 passed (453)`.
  `pnpm run typecheck` → **0** (`scripts` + `artifacts/chitra-docs` Done).
- **Hand-off:** `git status --porcelain` → **empty**; no `sessions/session-50-*`, no probe files.

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | Right derivations, one file short. Export lines in `charts/index.ts` = **20** (23 files, but `index.ts`/`line-model.ts`/`ring.ts` are not charts — `ring` is absent from `index.ts` *and* from `dist` exports: `has ring export: false`); `RendererType` = **3**; `Object.keys(themes)` on the built pkg = **7**; manifest = **0 deps / MIT / 0.4.0**; suite = **453**. Red proved on badge URL, README prose, docs hero, KNOWLEDGE, deps badge, tests badge (P1/P1b/P1d/P1e/P1g/P2/P2b all exit 1). **But R1 names `packages/core/README.md` and it is checked nowhere:** retyping `**20 Chart Types**`→21 there leaves 10/10 green (P1c), and retyping the *rendered* license badge `license-MIT`→`license-Apache` leaves 10/10 green (P1f — the check greps only the alt text `license: MIT`). R1's done-condition "red on the first disagreement" is therefore not met on two claim surfaces it explicitly names. |
| **R2** — adoption measured, not asserted | PARTIAL | Both readings re-derive live: `--as-of 2026-10-03` → **119**, `--as-of 2026-10-06` → **273**; I fetched the range API myself and got the same six non-zero days (89/15/6/5/4/154) and the same 273; release labels match `npm view … time`; delta explained as 243 release-shaped vs 30 other, 0 on 10-05/10-06; `GT-REMEDIATIONS.md` row 1 DEFERRED→**DONE** with the command; STATE carries t0/t1 with dates and a "never cite as traction" guard; P5/P6 red. **Counterfactual fails on scope:** "a downloads figure in `.ai/` that the API does not return right now → red" is enforced only over STATE+ROADMAP — `999 downloads` appended to `.ai/KNOWLEDGE.md` → 10/10 green (P12); likewise the "no file calls the baseline zero" guard is STATE-only, `adoption baseline is zero` appended to ROADMAP → green (P13), and `GT-REMEDIATIONS` row 1 still literally opens "**The adoption baseline is zero**" (S40's finding title, superseded inline by S45's ⚠ and by "`t0` is 119 … not zero"). |
| **R3** — benchmarks measured | SHIPPED | `node scripts/gtm-bench.mjs` prints `deps=0`, `tarball-bytes=83496`→**81.5 KB**, `unpacked-bytes=407961`→**398.4 KB**, `pack-files=**39**`, `render-median-ms=0.07` within `render-budget-ms=**2**` — all four README rows equal those values, and the README shows `node scripts/gtm-bench.mjs` above the table. Both named counterfactuals red: `81.5 KB`→`40 KB` → `benchmarks-cited-with-command` FAIL (P7); command deleted → FAIL (P8). Independently re-run by me, exit 0. |
| **R4** — one channel, one link, attributable | SHIPPED | STATE records the LinkedIn URL on the "One channel is live" line, `published 2026-10-06`, and the reader pointer (`node scripts/gtm-reads.mjs`) inside the same 7-line block, with "measurement window opens on that date". My own fetch with a Chrome UA → **200**. Deleting the URL → `channel-recorded` FAIL (P11); replacing it with a non-existent post → FAIL (P11b), proving the HTTP leg rather than the grep. |
| **R5** — first screen answers three questions, probed | SHIPPED | `pnpm add @ifelse.codes/chitra` present (README:88); `https://chitra.iifelse.com` → **200** (my fetch); README's first ```text block is byte-identical to a live `line()` render (my independent diff, 20 lines). Both named counterfactuals red: one glyph → `first-screen-probes` FAIL (P3), install line deleted → FAIL (P4). |
| **R6** — the record says what happened | PARTIAL | ROADMAP's GTM-pack row is annotated `**delivered in S48**` with `scripts/gtm-reads.mjs` + `scripts/gtm-bench.mjs` + `sessions/session-48-summary.md` beside it, and removing that pointer → `record-honest` FAIL (P10); `500 downloads` in STATE → FAIL (P9); STATE keeps the traction guard; summary carries separate `## What shipped` and `## What the pack surfaced (findings, not deliverables)` headings and no traction claim. **But R6's own counterfactual — "a summary sentence claiming traction with no R2 number beside it → red" — is green:** appending `Outcome: adoption grew fast — 500 downloads this week.` to `sessions/session-48-summary.md` leaves all 10 checks PASS (P14); `record-honest` only scans STATE+ROADMAP. |
| **Step-5 scripts** (`verify-session-48.sh` / `demo-session-48.sh`) | SHIPPED | `bash -n` clean; verify → **exit 0, 10/10** with 10 non-empty logs and `latest/` symlink; demo → **exit 0, 6/6 SHIPPED**, every row genuinely probed (`row()` requires exit 0 + literal `ok`), no canned output. |
| **Summary presence** (`sessions/session-48-summary.md`) | SHIPPED | Present (90 lines, 6921 bytes, committed in `87076f4`), plus `sessions/session-48-channel-post.md`. Structural greps only (see Method controls); not accepted as evidence for any row. |
| **`.ai` sync** (SESSION=48, BOOT, TASK) | SHIPPED | `.ai/SESSION` = `48`; closeout `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist`, `cost-tracking-present` all PASS on merit. |
| **Closeout gate** (`verify-closeout.sh` exit 0) | PARTIAL | Without waiver **exit 1** (14/3). With `VAJRA_CLOSEOUT_WAIVER=48` **still exit 1** (16/1): `roadmap-references-N` → `DRIFT: ROADMAP.md does not reference Session 48`. The ROADMAP contains **0** matches for `Session 48` (it has `Session 47 (S47) …` and only `S48` tokens); at merge-base with N=47 the same check was green — this delivery edited ROADMAP and left it red, and no waiver covers it. `fidelity-review-accept` also FAILs (no `sessions/session-48-review.md` — owed to this pass). |

## Count
**6 of 10 SHIPPED** (R3, R4, R5, step-5 scripts, summary presence, `.ai` sync).
PARTIAL: R1, R2, R6, closeout gate. NOT-BUILT: none.

## The fakest green

`claims-match-truth` logging **"README, KNOWLEDGE and the docs hero all carry the
derived values"**. It looks like a whole-of-surface claim: five facts derived from
five *sources* (export lines, the type union, `Object.keys(themes)`, the manifest, the
suite), three surfaces compared, exit 1 on the first mismatch.

What I did to test it:
- counted the export lines myself (**20**) and confirmed the trap (`23` files, `ring.ts`
  never exported — `has ring export: false`), so the derivation itself is the *right* one;
- then went looking for the surface it does **not** cover, because R1 says the file
  explicitly: retyped `**20 Chart Types:**` → `**21 Chart Types:**` in
  `packages/core/README.md` → **10/10 PASS, exit 0**;
- retyped the badge's rendered value `badge/license-MIT-green` → `badge/license-Apache-green`
  (alt text untouched) → **10/10 PASS, exit 0**, although a stranger now sees an Apache badge;
- confirmed `grep -rn "packages/core/README" scripts/verify-session-48.sh` returns nothing.

Runner-up: `core-suite-green`'s badge extraction —
`grep -oE 'tests-[0-9]+%20passing' | grep -oE '[0-9]+'` yields the **two-line** string
`453` + `20`, so the test is really `grep -E "Tests +453"` (plus a stray `20 passed`
alternative) and its own OK line prints `README badge (453 / 20) == suite output`.
I probed it at `452` and at `999` — both go red — so it is *loose, not broken*, but the
OK line over-claims what it read.

## Residual risks / owed items

1. **`verify-closeout.sh` cannot exit 0** — `roadmap-references-N` is red with no waiver
   available. Owed: a `Session 48` reference in `.ai/ROADMAP.md` (the S47 pattern is
   `- 🔄 **Session 47 (S47) — …`).
2. **`sessions/session-48-review.md` does not exist** (closeout `fidelity-review-accept`
   FAIL). Owed: this pass, committed cold and attested with the SHA below.
3. **`required-crew` still needs `VAJRA_CLOSEOUT_WAIVER=48`** — standing OpenCode
   condition (Vajra confirms helper provenance only from a Claude Code record). Waived,
   not green; the log records the waiver.
4. **R1 coverage gap** — `packages/core/README.md` (a file R1 names) is checked by no
   script; the license badge's *rendered* value is retypeable to green.
5. **R2/R6 guard breadth** — `record-honest` and the "baseline is zero" guard scan only
   `.ai/STATE.md` + `.ai/ROADMAP.md`; fake figures in `.ai/KNOWLEDGE.md`, fake zero-claims
   in ROADMAP, and traction sentences in the summary are all green (P12–P14).
6. **R1's `version` claim has no target** — `version=0.4.0` is derived and printed but
   never compared to any claim site (neither README carries a version claim), so that
   clause of R1 is vacuous rather than verified.
7. **`gtm-reads.mjs` omits zero days from its `day` lines** (`if (d.downloads === 0) continue`);
   the series is complete only in the sense that `days-since-last-non-zero` and the demo
   row report them. My own range fetch confirms 0 on 10-05/10-06.
8. **Pre-existing, untouched by this delivery:** ROADMAP still says `Session 47 … IN PROGRESS`.
9. **Toolchain precondition:** the gate is RED on a clean clone without
   `pnpm install --frozen-lockfile` + build — by design and documented in the script.
10. Contract's precondition table calls `charts: 20` "stale vs the tree's 23"; the
    delivery chose export-lines as the source of truth and left the badge at 20. I
    verified 20 is correct (23 = files; `ring.ts` unexported) — the call is right, but
    it is a judgement the contract did not spell out.

**Verdict:** **REJECT**

Specific unmet done-conditions:
1. **Closeout list item "`scripts/verify-closeout.sh` exit 0"** — exit **1** even with
   `VAJRA_CLOSEOUT_WAIVER=48`; `roadmap-references-N` = `DRIFT: ROADMAP.md does not
   reference Session 48`, a red this delivery introduced (green at merge-base with N=47)
   and no waiver covers.
2. **R1 done-condition "red on the first disagreement" for `README.md` *and*
   `packages/core/README.md`** — proved **exit 0** on a `20`→`21` retype in
   `packages/core/README.md` (P1c) and on a retype of the license badge's rendered URL (P1f).
3. **R2 counterfactual "a downloads figure in `.ai/` that the API does not return right
   now → red"** — proved **exit 0** with `999 downloads` in `.ai/KNOWLEDGE.md` (P12);
   the sibling "no file calls the baseline zero" clause is STATE-only (P13).
4. **R6 counterfactual "a summary sentence claiming traction with no R2 number beside it
   → red"** — proved **exit 0** with a planted `500 downloads this week` outcome sentence
   in `sessions/session-48-summary.md` (P14).

Everything else in R1–R6 held under stimulus; the instruments themselves are real
(re-derived independently against the npm range API, the registry publish times and a
fresh pack), and the product/governance invariants all hold.

**Review-Inputs-SHA:**
`fdc8415131594c6154a73c50ab7d252b56d0b33a0da4b992c49d8bc64d07050e`

---

**Hand-off state:** `git status --porcelain` → empty (verified after every mutation and
again at the end). No `sessions/session-50-*`, no probe files, no residue left in the repo;
review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 2)

## What landed since pass 1 (verified by me)

| Commit | Files | What it claims | My verification |
|---|---|---|---|
| `be2cf38` | `.ai/ROADMAP.md` (1) | literal `Session 48` entry; S47 line `IN PROGRESS` → `DONE, 2026-10-05`; the S40 "adoption baseline of zero" narrative marked `superseded — false since S45: t0 = 119, not zero` | diff read; all three edits present; `git show --stat` = 1 file |
| `8d80f25` | `scripts/verify-session-48.sh`, `scripts/demo-session-48.sh` (2) | R1 coverage (core README, rendered license URL, CHANGELOG version), 7-file figure scan with backtick stripping, zero-claim supersede rule over line+2, single-number suite-badge extraction | diff read in full; each claim re-probed below — **4 of 5 closed, 1 same-class hole still open (see grounds)** |

Delivery is now **17 commits**, all `S48:`, max **3 files** each (derived per commit with `git show --numstat | grep -c .`; max = 3, zero breaches). Smuggle diff `git diff 2f3c089..HEAD --name-only -- .ai/AGENTS.md packages/ pnpm-lock.yaml .github/workflows/` → **empty**; `git diff 2f3c089..HEAD --name-only -- packages/` → **empty**, so `packages/core/README.md` (now *checked*) was **not** edited by the delivery. Contract still exactly **1** commit (`95dd29c`).

**Syntax / baseline (exit codes recorded):** `bash -n scripts/verify-session-48.sh` → **0**; `bash -n scripts/demo-session-48.sh` → **0**; `node --check scripts/gtm-reads.mjs` → **0**; `node --check scripts/gtm-bench.mjs` → **0**; `bash scripts/verify-session-48.sh` → **0, 10/10**; `bash scripts/demo-session-48.sh` → **0, 6/6** (the 7th `SHIPPED` grep hit is the closing line, not a row).

**Closeout (ground 1):**
- no env → **exit 1, 15 pass / 2 fail**: only `fidelity-review-accept` (`MISSING: sessions/session-48-review.md — … supply … (cold pass) or a founder waiver`) and `required-crew` (tech-lead handoff absent). **`roadmap-references-N` → PASS on merit: `OK: ROADMAP.md references Session 48`.**
- `VAJRA_CLOSEOUT_WAIVER=48 VAJRA_CLOSEOUT_WAIVER_REASON="required-crew only: …"` → **exit 0, ALL GREEN (17 pass, 0 fail)**, and the log records `WAIVED: VAJRA_CLOSEOUT_WAIVER=48 — <my reason>`. `roadmap-references-N` is PASS **without** the waiver.

**Invariants re-verified:** `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` PASS (no `packages/core/src/` or lockfile change). Instruments re-run by me, unchanged: `gtm-reads --as-of 2026-10-03` → `total=119`; `--as-of 2026-10-06` → `total=273`, `release-shaped-total=243`, `non-release-total=30`; `gtm-bench.mjs` → `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 verdict=within render budget`.

**Contamination controls (unchanged):** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed: heading list, `[0-9]{3,}…downloads` pattern, `` `500 downloads` `` backtick count, and the `moved|outcome|organic` line scan (line 56: `**273 downloads, none organic, and the last two days are flat zero.**` — the outcome statement R6 asks for, carrying a whitelisted derived number). No writes inside the repo except gitignored `.ai/verify/**`; `git status --porcelain` empty at hand-off.

## Stimulus re-runs

**A. The five pass-1 greens — each now RED (diagnosis quoted from the check's own log):**

| Stimulus | Command | exit | Diagnosis line |
|---|---|---|---|
| P1c `**20 Chart Types:**` → `21` | `sed` in `packages/core/README.md` | 1 | `packages/core/README.md chart claim ≠ derived 20` |
| P1f `badge/license-MIT-green` → `badge/license-Apache-green` | `sed` in `README.md` | 1 | `README's rendered license badge is not MIT (the alt text can lie)` |
| P12 `Lifetime reads 999 downloads now.` appended | `printf >> .ai/KNOWLEDGE.md` | 1 | `figure or claim no instrument prints: .ai/KNOWLEDGE.md:'999 downloads'` |
| P13 `- note: the adoption baseline is zero.` appended | `printf >> .ai/ROADMAP.md` | 1 | `figure or claim no instrument prints: .ai/ROADMAP.md:(zero-claim with no superseding marker)` |
| P14 `Outcome: adoption grew fast — 500 downloads this week.` appended | `printf >> sessions/session-48-summary.md` | 1 | `figure or claim no instrument prints: sessions/session-48-summary.md:'500 downloads'` |

**B. The pass-1 red set, re-run verbatim (all still RED):**

| Stimulus | exit | RED | Diagnosis line |
|---|---|---|---|
| P0 baseline, no mutation | 0 | — | — |
| P1 `charts-20`→`21` | 1 | `claims-match-truth` | `claim ≠ truth in: README-badge (derived values above)` |
| P1b `all 20 charts`→`21` (README) | 1 | `claims-match-truth` | `claim ≠ truth in: README-prose (derived values above)` |
| P1d docs hero `stat-num` 20→21 | 1 | `claims-match-truth` | `docs hero drifted from the derived values:` (`> 21 Chart types`) |
| P1e `all 20 charts`→`21` (KNOWLEDGE) | 1 | `claims-match-truth` | `claim ≠ truth in: KNOWLEDGE-charts (derived values above)` |
| P1g `dependencies-0`→`1` | 1 | `claims-match-truth` | `claim ≠ truth in: README-deps (derived values above)` |
| P2 `tests-453%20passing`→`452` | 1 | `core-suite-green`, `claims-match-truth` | `README claims 452 tests; the suite printed something else` |
| P2b `tests-453`→`999` | 1 | `core-suite-green`, `claims-match-truth` | `README claims 999 tests; the suite printed something else` |
| P3 one glyph in the first text block | 1 | `first-screen-probes` | `README example has drifted from a real render:` (`> │ TREM …`) |
| P4 delete `pnpm add @ifelse.codes/chitra` | 1 | `first-screen-probes` | `README has no install command for a stranger` |
| P5 STATE `t1 = 273`→`274` | 1 | `adoption-reading-recorded` | `STATE says t1=274 through 2026-10-06; instrument says '273'` |
| P6 STATE `--as-of 2026-10-03`→`2026-10-02` | 1 | `adoption-reading-recorded` | `STATE says t0=119 through 2026-10-02; instrument says '115'` |
| P7 README `81.5 KB`→`40 KB` | 1 | `benchmarks-cited-with-command` | `README tarball row ≠ measured 81.5 KB` |
| P8 delete `node scripts/gtm-bench.mjs` | 1 | `benchmarks-cited-with-command` | `README does not show the command that produces these numbers` |
| P9 `500 downloads recorded` → STATE | 1 | `record-honest` | `figure or claim no instrument prints: .ai/STATE.md:'500 downloads'` |
| P10a **only** `**delivered in S48**` removed (instruments left) | **0** | — | *green — see note below* |
| P10b pointer **and every ROADMAP instrument name** removed | 1 | `record-honest` | `roadmap's pack row has no evidence pointer` |
| P11 STATE LinkedIn URL deleted | 1 | `channel-recorded` | `STATE records no post URL` |
| P11b URL → non-existent post | 1 | `channel-recorded` | `…/nonexistent-0000000000000000000-XXXX/ → 404 (expected 200)` |

P10a/P10b: the required stimulus (marker **and** instrument names) is red (P10b). Dropping only the bold `delivered in S48` marker stays green because `grep -A3 'GTM proof pack'` still finds `scripts/gtm-reads.mjs` on that line, and the new `Session 48 — DONE` row independently carries the evidence — **not a contract failure** (R6's "marked done with the evidence pointer" survives), reported for completeness.

**C. New adversarial probes against the fixes (these are the grounds):**

| Stimulus | exit | Result |
|---|---|---|
| **NEW-A** README badge `charts: 20` + `badge/charts-20-blue` → **`charts: 200` / `badge/charts-200-blue`** (line verified: `[![charts: 200](https://img.shields.io/badge/charts-200-blue)]`) | **0** | **GREEN — nothing caught a badge that now claims 200 charts** |
| **NEW-B** README table `**3 renderers**` → `**13 renderers**` (line verified) | **0** | **GREEN — front-door prose now claims 13 renderers, truth is 3** |
| **NEW-C** bare `the adoption baseline is zero.` appended to `.ai/GT-REMEDIATIONS.md` | **0** | GREEN |
| **NEW-D** `888 downloads observed.` appended to `.ai/GT-REMEDIATIONS.md` | **0** | GREEN |
| **NEW-E** `Lifetime reads \`999 downloads\` now.` appended to `.ai/KNOWLEDGE.md` (backticked) | **0** | GREEN (the exemption) |
| **SHIELD-S** same sentence appended to `sessions/session-48-summary.md` | **0** | GREEN (the exemption) |
| **SHIELD-C** bare zero-claim whose line+2 window contains an *unrelated* `119` | **0** | GREEN (window looseness) |
| **FAIL-OPEN** `.ai/CONTINUATION-PROMPT.md` removed entirely | **0** | GREEN, and `record-honest` still logs `all 7 live files carry only 119/273` — an OK line about a file it did not read |
| contrast `all 20 charts`→`all 200 charts` (prose) | 1 | `claim ≠ truth in: README-prose` — the prose grep *is* boundary-safe; the badge grep is not |
| contrast `badge/license-MIT-green`→`badge/license-MIT2-green` | 1 | `README's rendered license badge is not MIT (the alt text can lie)` |
| contrast CHANGELOG `## [0.4.0]`→`## [0.4.1]` | 1 | `CHANGELOG has no heading for the manifest version 0.4.0` (the new version check is real) |

**On the backtick exemption (asked for explicitly): defensible *and* gameable — I accept it as implemented, and I record the hole.** It is *load-bearing, not decorative*: `sessions/session-48-summary.md` quotes `` `500 downloads` `` twice inside its counterfactual table (structural grep, 2 hits); strip the exemption and P0 goes red — the exemption is what lets a counterfactual table show its own stimulus as evidence. It is also *gameable by intent*: any figure wrapped in backticks, anywhere in the seven files, is invisible to the scan (NEW-E, SHIELD-S), with no requirement that the line be a table row, sit under a counterfactual heading, or be labelled as evidence. I do not make that a ground, because the alternative (no exemption) breaks the very requirement it enforces; I make it a residual with a concrete tightening: exempt a backticked figure only on a line that also carries a counterfactual/stimulus marker.

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | Both pass-1 grounds closed and re-proved: core README (`≠ derived 20`) and rendered license URL (`the alt text can lie`) now red; the version clause has a real target (`## [0.4.0]` retype → red); suite-badge extraction is a single number (`README claims 452 tests`); CHANGELOG/hero/KNOWLEDGE/deps/prose all still red on stimulus. **But R1's own done-condition still fails:** "*the check fails when a badge is retyped*" / "*red on the first disagreement*" / "*Counterfactual: retype `20` → red*". Retyping `20` → **`200`** (alt text *and* shield URL, badge visibly claims 200 charts) → **exit 0** (NEW-A); retyping README's `3 renderers` → **`13 renderers`** → **exit 0** (NEW-B). The four presence greps (`charts-`, `${renderers} renderers`, `dependencies-`, `all … charts` last-but-one) are unanchored substrings: `charts-20` matches inside `charts-200`, `3 renderers` inside `13 renderers`. Two counts on `README.md` can disagree with the tree while the gate stays green. |
| **R2** — adoption measured, not asserted | PARTIAL | Both readings still re-derive live (119 / 273, release-shaped 243 vs 30); P5/P6 red with the instrument's own number in the diagnosis; ledger row 1 DONE; guard present; and the pass-1 breadth grounds are closed — `999 downloads` in KNOWLEDGE and a bare zero-claim in ROADMAP are both red. **R2's counterfactual is still not met for one `.ai/` file:** "`888 downloads observed.`" appended to **`.ai/GT-REMEDIATIONS.md`** → **exit 0** (NEW-D), and a bare zero-claim there → **exit 0** (NEW-C). That file is not governed (unlike `AGENTS.md`), is *live* (edited this session, row 1 `DEFERRED → DONE`), is where R2's done-condition says the ledger sees the reading, and it already carries `304 downloads` / `119 downloads`. The seven-file list is one file short of its own claim ("all 7 live files") and of the contract's "a downloads figure in `.ai/`". |
| **R3** — benchmarks measured | SHIPPED | Unchanged and re-run by me: `deps=0, 81.5 KB, 398.4 KB / 39 files, ≤2 ms, verdict=within render budget`; P7 (`README tarball row ≠ measured 81.5 KB`) and P8 (`README does not show the command…`) both red; command shown above the table. |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + `gtm-reads` reader pointer all present in STATE; gate re-fetches it every run (green on every baseline run here); P11 `STATE records no post URL`, P11b `… → 404 (expected 200)` — the HTTP leg, not the grep. |
| **R5** — first screen answers three questions, probed | SHIPPED | install line present; docs link 200 on every run; README example still byte-identical to a live render; P3 (`README example has drifted from a real render:`) and P4 (`README has no install command for a stranger`) both red. |
| **R6** — the record says what happened | SHIPPED | ROADMAP now has `✅ Session 48 (S48) — the GTM proof pack — DONE, 2026-10-06` **and** the pack row keeps its evidence pointer; removing the instruments → `roadmap's pack row has no evidence pointer` (P10b). Summary separates output (`## What shipped`) from outcome (line 56, `273 downloads, none organic … flat zero` — a whitelisted derived number) and carries no unquoted traction figure; the contract's summary counterfactual is now red (P14). `never cite` guard present. Remaining breadth holes sit under R2 (they are *figures*, not traction language — GT-REMEDIATIONS carries no traction claim). |
| **Step-5 scripts** (`verify-session-48.sh` / `demo-session-48.sh`) | SHIPPED | `bash -n` → 0/0; verify **exit 0, 10/10**; demo **exit 0, 6/6**, rows still probed (`row()` requires exit 0 **and** a literal `ok`; the R1/R6 probes were updated in lock-step with the gate, so the demo cannot stay green on the old two-file scan). |
| **Summary presence** | SHIPPED | `sessions/session-48-summary.md` present (committed `87076f4`, unmodified by the fix commit); structural greps only. |
| **`.ai` sync** (SESSION=48, BOOT, TASK) | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` all PASS on merit. |
| **Closeout gate** (`verify-closeout.sh` exit 0) | SHIPPED | No env → **15/2**, the two fails being `fidelity-review-accept` (this file — not yet in `sessions/`, by my write-nothing instruction) and `required-crew` (standing OpenCode reason). With the prescribed waiver+reason → **exit 0, ALL GREEN (17 pass, 0 fail)**. **`roadmap-references-N` is PASS on merit with no waiver**: `OK: ROADMAP.md references Session 48`. 15 verified + 2 waived, and the waiver text is recorded in the log. |

## Count
**8 of 10 SHIPPED** (R3, R4, R5, R6, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1, R2. NOT-BUILT: none.

## The fakest green (this pass)

**`claims-match-truth` exiting 0 on a README whose badge reads `charts: 200`.**

The fix hardened exactly the surfaces I named (core README with a literal `grep -qF`, license URL with `grep -qF "badge/license-MIT-"`, version with `grep -qF "## [${version}]"` — all three now provably red), and left the *original* four presence greps unanchored. So the check is now precise on the new surfaces and still porous on the one the contract opens with.

What I did:
1. `sed -i '' 's|badge/charts-20-blue|badge/charts-200-blue|; s|charts: 20\]|charts: 200]|' README.md`, then **printed the mutated line** to prove the stimulus applied: `13:[![charts: 200](https://img.shields.io/badge/charts-200-blue)](packages/core/README.md)`.
2. Ran the full gate → **exit 0, 10/10, `RED=[]`**.
3. Repeated for README's table cell → `64:| **13 renderers** | Braille … |` → **exit 0**.
4. Control probes to show it is the *matcher*, not the mutation: retyping the prose `all 20 charts`→`all 200 charts` → **red** (`claim ≠ truth in: README-prose`), and `license-MIT-green`→`license-MIT2-green` → **red** (`README's rendered license badge is not MIT`). Boundary-safe on two surfaces, boundary-unsafe on `charts-${charts}` and `${renderers} renderers`.

Why it is the fakest green rather than a nit: R1's done-condition is the sentence "*the check fails when a badge is retyped*", and its counterfactual is literally "*retype `20` → red*". `20` → `21` is red; `20` → `200` is green. A stranger's front door can read **200 charts** and **13 renderers** while the gate reports `README … all carry the derived values`.

Runner-up (same class, smaller): `record-honest`'s OK line claims `all 7 live files` while `[ -f "$f" ] || continue` lets a missing file be skipped silently — deleting `.ai/CONTINUATION-PROMPT.md` leaves the gate at exit 0 with that line printed (the repo's own S47 lesson: *an OK line that claims counts it never read*).

## Residuals (carried from pass 1 + new)

| # | Pass-1 residual | Status now |
|---|---|---|
| 1 | `verify-closeout.sh` could not exit 0 (`roadmap-references-N`) | **CLOSED** — PASS on merit; 17/17 with the standing waiver |
| 2 | `sessions/session-48-review.md` absent | **REMAINS** — still owed; this document is it, uncommitted by instruction |
| 3 | `required-crew` needs `VAJRA_CLOSEOUT_WAIVER=48` | **REMAINS (standing, disclosed)** — waived with reason, recorded in the log; 15 verified + 2 waived |
| 4 | R1 coverage: core README + license URL unchecked | **CLOSED** — both now red (P1c, P1f) |
| 5 | Guard breadth (KNOWLEDGE figure, ROADMAP zero-claim, summary traction) | **CLOSED for those three** (P12/P13/P14 red); see new R-1/R-3 below for what survives |
| 6 | Version clause had no target | **CLOSED** — `## [0.4.0]` CHANGELOG heading, retype proved red |
| 7 | `gtm-reads.mjs` omits zero days from its `day` lines | **REMAINS, judged immaterial** — the totals, `days-since-last-non-zero`, `release-shaped`/`non-release` split and the demo's "2 day(s) with no download" all report them, and I confirmed 10-05/10-06 = 0 against the range API myself. It is a display choice, not a claim. Would like it printed; not owed. |
| 8 | ROADMAP's S47 line still `IN PROGRESS` | **CLOSED** — now `✅ … DONE, 2026-10-05` |
| 9 | Clean-clone RED without install+build | **REMAINS by design** (documented in the script) |
| 10 | Contract's "23 vs 20" judgement spelled out only in a code comment | **REMAINS** — call verified correct (`ring.ts` never exported); still a judgement, now at least written down |
| — | Suite-badge extraction yielded `453`+`20` | **CLOSED** — `sed -E 's/tests-([0-9]+).*/\1/'`; diagnosis reads `README claims 452 tests` |

**New residuals:**
- **R-1 (ground): unanchored presence greps in R1.** `charts-${charts}` matches inside `charts-200`; `${renderers} renderers` matches inside `13 renderers`. Fix shape: anchor both ends (`grep -qE "charts-${charts}[^0-9]"` / word boundary on the number, or parse the badge token).
- **R-2 (ground): `.ai/GT-REMEDIATIONS.md` outside the seven-file scan.** The one non-governed `.ai/*.md` left out — and the ledger R2 writes into. A naive include breaks the gate on its legitimate history (`304 downloads`, `318`, `89`), which is presumably why it was left out; the honest fix is a per-file/per-package allow-list or a supersede-marker rule like the zero-claim one, not silence.
- **R-3: backtick exemption is unbounded** (defensible *and* gameable — argued above). Tighten to lines also carrying a counterfactual/stimulus marker.
- **R-4: zero-claim window is line+2** — an unrelated `119`/`false` two lines below excuses a bare `baseline is zero` (SHIELD-C, exit 0). Acceptable for markdown wrapping; not tamper-evident.
- **R-5: fail-open on a missing scanned file** (FAIL-OPEN, exit 0 with `all 7 live files` printed). Either require the file or say "6 of 7 (… missing)".
- **R-6: `record-honest`'s `grep -A3 'GTM proof pack'`** accepts any instrument name within three lines of *any* occurrence, so P10a (marker-only removal) is green. Backstopped by the Session 48 row, hence informational.
- **R-7: `fidelity-review-accept` can be satisfied by waiver instead of by the file** — the closeout can be green with no `sessions/session-48-review.md` ever landing. Gate design, not this delivery's doing, but it means an ACCEPT here must actually be committed to be worth anything.

**Verdict:** **REJECT**

The four grounds I raised in pass 1 are **closed and re-proved** (five greens → red with correct diagnoses; `roadmap-references-N` PASS on merit; closeout 17/17; full red set still red; invariants hold; inputs-sha matches). I am not rejecting them — I am rejecting on two contract-named counterfactuals that remain provably green in the very requirements that were fixed:

1. **R1's done-condition is still unmet.** "*Every count … on `README.md` … is checked … red on the first disagreement*" / "*the check fails when a badge is retyped*" / "*Counterfactual: retype `20` → red*". Retype `charts: 20` → **`charts: 200`** (badge visibly claims 200) → **exit 0, 10/10** (NEW-A, mutated line quoted above); retype `3 renderers` → **`13 renderers`** → **exit 0** (NEW-B). Two front-door counts can disagree with the tree while the gate reports `… all carry the derived values`.
2. **R2's counterfactual is still unmet for `.ai/`.** "*a downloads figure in `.ai/` that the API does not return right now → red*". `888 downloads observed.` in **`.ai/GT-REMEDIATIONS.md`** → **exit 0** (NEW-D); a bare `the adoption baseline is zero.` there → **exit 0** (NEW-C). That file is live, ungoverned, and is the ledger R2's done-condition points at; the seven-file list stops one file short of its own "all 7 live files" claim being complete over `.ai/`.

Both are one-line-class fixes with the stimulus already written; neither requires new surface. Until each is red, R1 and R2 are PARTIAL and the pack's headline promise — *every number a stranger sees is produced by a command, and the gate fails on the first disagreement* — is not yet true of the front door.

**Review-Inputs-SHA:**
`9d035bc12d094a8c9b670306f9d9e2bee5420955e4a9cc6bcbb8bb9fe0f22c47`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (checked after every mutation, after `git checkout -- README.md` once a broken backup path left a `license-MIT2` edit in the worktree, and at the end). No `sessions/session-50-*`, no probe files, no debris inside the repo; every stimulus file restored byte-identically; review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 3)

## What landed since pass 2 (verified by me)

`d26a418` — **scripts only** (`verify-session-48.sh` +52/−24, `demo-session-48.sh` +43/−17); `.ai/ROADMAP.md` untouched since `be2cf38`. Delivery now **18 commits**, all `S48:`; file list unchanged (15 files, none under `packages/`).

Code read line by line. What the diff actually does:

- **R1 → value extraction.** `charts` badge **alt** (`![charts: N]`) *and* **shield URL** (`badge/charts-N`), the `| **N chart types** |` cell, the `| **N renderers** |` cell, the deps **alt** (`![dependencies: N]`) and the license **alt** (`![license: X]`) are each extracted with `grep -m1 -oE` and `[ ]`-compared; the four old substring greps are gone (`all N charts` prose greps remain, now `-qF`). Verified: `grep -nE 'grep|b_[a-z]+='` over the function shows **no `badge/dependencies-` extraction at all**, and no check of `packages/core/README.md` beyond `**${charts} Chart Types:**`.
- **R2 → ledger in scope.** `.ai/GT-REMEDIATIONS.md` joins the 8-file scan; there a figure is allowed only if some line containing that exact hit also matches `⚠|FALSIFIED|→|re-probe|re-derived|derive|≠|not [0-9]`. Zero-claims: marker set now `superseded|false|not zero|must not|FALSIFIED|⚠` (`119` removed) over line+2.
- **Exemptions narrowed.** Backticks are stripped **only on lines starting with `|`** (prose backticks stay claims).
- **Fail-closed.** `[ -f "$f" ] || { echo "live file missing: $f"; return 1; }` — replaces the `continue` that printed an OK line about an unread file.
- **Pointer rule.** ROADMAP must name both instruments (checked by removing them all → red).
- **Demo mirrors** all of it — including the same blind spots (its `b_deps` also reads only the alt).

**Syntax / baseline:** `bash -n` on both shell scripts → **0**; `node --check` on both `.mjs` → **0**; `bash scripts/verify-session-48.sh` → **exit 0, 10/10**; `bash scripts/demo-session-48.sh` → **exit 0, 6/6**.

**Closeout:** bare → **15 pass / 2 fail**, the two being exactly `fidelity-review-accept` (`MISSING: sessions/session-48-review.md … or a founder waiver`) and `required-crew`; **`roadmap-references-N` PASS on merit** (`OK: ROADMAP.md references Session 48`). With `VAJRA_CLOSEOUT_WAIVER=48` + the prescribed reason → **exit 0, `ALL GREEN (17 pass, 0 fail)`**, waiver text recorded in the log.

**Invariants:** 18 commits → 11×1 file, 5×2, 2×3, **zero breaches**; smuggle diff (`.ai/AGENTS.md`, `packages/`, `pnpm-lock.yaml`, `.github/workflows/`) → **empty**; contract still exactly **1** commit (`95dd29c`); `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` → `no packages/core/src or lockfile change in delivery`; instruments re-run by me → `gtm-reads --as-of 2026-10-03` = `total=119`, `--as-of 2026-10-06` = `total=273`, `release-shaped-total=243`, `non-release-total=30`; `gtm-bench` = `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 verdict=within render budget`.

**Contamination controls:** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed: row-count of `` `500 downloads` `` (2), the two table rows containing it (echoed by the grep, untrusted as claims), and the `taking off|888 installs` line check used to confirm my own mutations applied. No writes in the repo except gitignored `.ai/verify/**`. `git status --porcelain` empty at hand-off.

## Stimulus re-runs

**A. The seven pass-2 greens — all now RED:**

| Stimulus | exit | Diagnosis line (quoted from the check's log) |
|---|---|---|
| NEW-A README badge `charts: 20` + `badge/charts-20-blue` → `200` (both) | 1 | `claim ≠ truth in: README-badge-alt('200'≠20) README-badge-url('200'≠20)` |
| NEW-B `\| **3 renderers** \|` → `\| **13 renderers** \|` | 1 | `claim ≠ truth in: README-renderers('13'≠3)` |
| NEW-C GT-REMEDIATIONS bare `- note: the adoption baseline is zero.` | 1 | `figure or claim no instrument prints: .ai/GT-REMEDIATIONS.md:(zero-claim with no superseding marker)` |
| NEW-D GT-REMEDIATIONS `- observed 888 downloads today.` | 1 | `figure or claim no instrument prints: .ai/GT-REMEDIATIONS.md:'888 downloads'` |
| NEW-E KNOWLEDGE prose `` It now reads `999 downloads` daily. `` | 1 | `figure or claim no instrument prints: .ai/KNOWLEDGE.md:'999 downloads'` |
| SHIELD-C ROADMAP bare zero-claim + unrelated `119` two lines later | 1 | `figure or claim no instrument prints: .ai/ROADMAP.md:(zero-claim with no superseding marker)` |
| FAIL-OPEN `.ai/CONTINUATION-PROMPT.md` removed | 1 | `live file missing: .ai/CONTINUATION-PROMPT.md` |

**B. The full pass-1 red set — P1 through P11b, one regression:**

| Stimulus | exit | RED | Diagnosis |
|---|---|---|---|
| P0 baseline | **0** | — | — |
| P1 `charts-20`→`21` | 1 | `claims-match-truth` | `README-badge-url('21'≠20)` |
| P1b `all 20 charts`→`21` (README) | 1 | `claims-match-truth` | `README-prose` |
| P1d hero `stat-num` 20→21 | 1 | `claims-match-truth` | `docs hero drifted from the derived values:` (`> 21 Chart types`) |
| P1e `all 20 charts`→`21` (KNOWLEDGE) | 1 | `claims-match-truth` | `KNOWLEDGE-charts` |
| **P1g `dependencies-0`→`dependencies-1`** | **0** | **—** | **GREEN — regression, see ground 1** |
| P2 `tests-453`→`452` | 1 | `core-suite-green`, `claims-match-truth` | `README claims 452 tests; the suite printed something else` |
| P2b `tests-453`→`999` | 1 | both | `README claims 999 tests; the suite printed something else` |
| P3 one glyph in the text block | 1 | `first-screen-probes` | `README example has drifted from a real render:` (`> │ TREM …`) |
| P4 delete `pnpm add …` | 1 | `first-screen-probes` | `README has no install command for a stranger` |
| P5 `t1 = 273`→`274` | 1 | `adoption-reading-recorded` | `STATE says t1=274 through 2026-10-06; instrument says '273'` |
| P6 `--as-of 2026-10-03`→`2026-10-02` | 1 | `adoption-reading-recorded` | `STATE says t0=119 through 2026-10-02; instrument says '115'` |
| P7 `81.5 KB`→`40 KB` | 1 | `benchmarks-cited-with-command` | `README tarball row ≠ measured 81.5 KB` |
| P8 delete bench command | 1 | `benchmarks-cited-with-command` | `README does not show the command that produces these numbers` |
| P9 `500 downloads` → STATE | 1 | `record-honest` | `figure or claim no instrument prints: .ai/STATE.md:'500 downloads'` |
| P10 pointer + all instrument names removed | 1 | `record-honest` | `roadmap's pack row has no evidence pointer` |
| P11 LinkedIn URL deleted | 1 | `channel-recorded` | `STATE records no post URL` |
| P11b URL → non-existent post | 1 | `channel-recorded` | `…-XXXX/ → 404 (expected 200)` |

**C. Exemptions that had to stay green — all green in the unmutated P0 run**, each verified present in the tree that run read: the summary's **2 backticked `` `500 downloads` `` inside counterfactual table rows** (rows echoed structurally), the ledger's historical `downloads/range/2026-09-15:2026-09-28` + `304`/`318`/`89` lines with their markers, and ROADMAP's `superseded — false since S45: t0 = 119, not zero` (line 248). No legitimate case broke.

## New holes hunted

Every mutation below was **printed back from the file before the gate ran** (evidence lines captured), then restored — no green is a no-op sed.

**Contract counterfactuals (grounds):**

| # | What I tried | Mutation verified | exit | Why the contract covers it |
|---|---|---|---|---|
| **N1** | deps badge **shield URL** `badge/dependencies-0-brightgreen` → `-1-` | `12:[![dependencies: 0](…badge/dependencies-1-brightgreen)]` | **0** | R1: "Every count on README.md … red on the first disagreement"; counterfactual "retype a badge → red". **Regression:** the *verbatim* pass-1 P1g stimulus was red in pass 1 and pass 2. |
| **N2** | README table cell `\| **Zero dependencies** \|` → `\| **2 dependencies** \|` | `66:\| **2 dependencies** \|` | **0** | R1 names README's "dependency count" — now only the alt is checked, the cell is not. The OK line still claims `…all carry the derived values`. |
| **N3** | `packages/core/README.md` `MIT` → `Apache-2.0` (line 122, under `## License`) | `Apache-2.0` present | **0** | R1: "Every count and version on `README.md` **and `packages/core/README.md`** (… license) is checked". Only the chart-count line of that file is checked. |
| **N4** | `packages/core/README.md` `**Zero Dependencies:**` → `**2 Dependencies:**` | `9:- **2 Dependencies:**` | **0** | Same sentence — "dependency count" on that file. |
| **N5** | duplicate false badge appended: `[![charts: 99](…badge/charts-99-red)]` | line 231 present | **0** | R1 "every count … red on the first disagreement"; `grep -m1` means a second badge is invisible to the extractor. |
| **N6** | STATE: `- Lifetime adoption: 1,119 downloads since launch.` | line 174 present | **0** | R2 counterfactual: "a downloads figure in `.ai/` that the API does not return right now → red". The API returns 273, not 1,119; the regex hands the checker `119`, which is whitelisted. |
| **N7** | ledger: `- ⚠ 888 downloads observed today.` | line 89 present | **0** | Same counterfactual. The new rule lets **any** number through on a line carrying *any* marker — and `⚠` in that very file marks **falsified** claims, so a falsified downloads figure is now the exempt kind. |
| **N8** | KNOWLEDGE table row: `` \| adoption \| `999 downloads` \| last week \| `` | line 478 present | **0** | Same counterfactual. The exemption was meant for a *counterfactual* table showing its own stimulus; "any line starting with `\|`" is far broader. |
| **N9** | summary: `Outcome: adoption is taking off — the channel is working.` | line 92 present | **0** | R6 counterfactual: "a summary sentence claiming traction with **no R2 number beside it** → red". There is literally no number here. |
| **N10** | summary: `Outcome: 888 installs this week.` | line 93 present | **0** | Same counterfactual — a number, but not one R2 derives. The scan only selects lines containing the literal word `downloads`. |
| **N11** | README Benchmarks table: add `\| **Cold start** \| **500 ms** (measured by hand) \|` | line 82 present | **0** | R3 counterfactual: "**a benchmark number with no command → red**". A fabricated figure sits in the table the gate calls `… all printed by gtm-bench.mjs, command shown`. |

**Outside the contract (→ residuals, said plainly):**

| What I tried | Mutation verified | exit | Why it is *not* a contract ground |
|---|---|---|---|
| CHANGELOG: `## [0.4.1] - probe` inserted above `## [0.4.0]` | lines present | 0 | The CHANGELOG is not one of R1's named claim surfaces (`README.md`, `packages/core/README.md`); this only falsifies the *voluntary* "manifest version heads the changelog" check's intent. |
| STATE: `- the adoption baseline was zero before S45.` | line 176 present | 0 | R2's counterfactual is the downloads figure; "no file calls the baseline zero" is a state condition the delivery does satisfy (its only zero-call is the marked historical one). The gate's zero-rule is phrase-keyed (`baseline (of\|is) zero`), so `was zero` slips. |
| STATE: `- Adoption: 888 installs this week.` / `- Adoption is taking off.` | appended | 0 | R6's counterfactual names the **summary** only; "no traction language anywhere" is a requirement, not a red-proving stimulus, and the delivered files contain none. |
| drift the **second** of README's three ```text blocks (all three mutated blocks exist) | `text blocks: 3 … mutated block 2` | 0 | R5 scopes the drift check to the **top screen**'s example; blocks 2–3 are below the fold and outside that wording. |
| delete `.ai/TASK.md` | — | 1 | control: `live file missing: .ai/TASK.md` — fail-closed works for other files too. |
| control: deps badge **alt** `![dependencies: 0]` → `1` | — | 1 | `README-deps('1'≠0)` — the alt side *is* checked; only the URL/cell side is not. |
| control: charts badge **alt** `![charts: 20]` → `21` (URL untouched) | — | 1 | `README-badge-alt('21'≠20)` — charts checks both sides, which is exactly the shape deps lacks. |

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | Real progress: pass-2 NEW-A/NEW-B now red with the mismatch printed (`README-badge-alt('200'≠20)`, `README-renderers('13'≠3)`); core README chart count and rendered license URL and the CHANGELOG version target all red on stimulus. **But three R1-named surfaces are still green when wrong:** the deps badge's **shield URL** and README's **`\| **Zero dependencies** \|`** cell (N1/N2 — a regression: the pass-1 P1g stimulus went red → green), and `packages/core/README.md`'s **license** and **dependency count** (N3/N4 — R1 names that file's license and dep count explicitly). Plus a duplicate `charts: 99` badge is invisible to `grep -m1` (N5). |
| **R2** — adoption measured, not asserted | PARTIAL | Readings still re-derive (119/273), P5/P6 red, ledger row DONE, all seven pass-2 greens red, ledger now scanned. **R2's counterfactual still green three ways:** `1,119 downloads` (comma → checker sees `119`, whitelisted), `⚠ 888 downloads` in the ledger (marker = free pass, and `⚠` marks *falsified* claims there), and a backticked `999 downloads` in an arbitrary table row (N6/N7/N8). |
| **R3** — benchmarks measured | PARTIAL | The four real rows still equal `gtm-bench.mjs` and P7/P8 stay red. **R3's own counterfactual fails:** a fabricated `\| **Cold start** \| **500 ms** (measured by hand) \|` row inside the Benchmarks table is green (N11) — "a benchmark number with no command → red" is not enforced beyond the four rows the script already knows. |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + reader pointer present; gate re-fetches (200 on every run here); P11 `STATE records no post URL`, P11b `… → 404 (expected 200)`. No new hole found. |
| **R5** — first screen answers three questions, probed | SHIPPED | install line present, docs 200, first text block byte-identical to a live render; P3/P4 red. Blocks 2–3 unchecked → residual (contract scopes this to the top screen). |
| **R6** — the record says what happened | PARTIAL | ROADMAP `✅ Session 48 … DONE` + pointer (P10 red when removed); summary separates `## What shipped` from the outcome line; P14-style unquoted figure red; fail-closed on missing files. **R6's counterfactual green twice:** a purely qualitative traction sentence in the summary and `888 installs this week` there both pass (N9/N10) — the scan is keyed to the literal word `downloads`. |
| **Step-5 scripts** | SHIPPED | `bash -n` 0/0; verify **exit 0, 10/10**; demo **exit 0, 6/6**, rows still probed and mirroring the gate's logic. |
| **Summary presence** | SHIPPED | `sessions/session-48-summary.md` present and unmodified by `d26a418`; structural greps only. |
| **`.ai` sync** | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` PASS on merit. |
| **Closeout gate** | SHIPPED | Bare → **15/2** (only `fidelity-review-accept` — this file, still uncommitted by my write-nothing instruction — and `required-crew`); **`roadmap-references-N` PASS on merit**. With the prescribed waiver+reason → **exit 0, 17/17**, waiver recorded. |

## Count
**6 of 10 SHIPPED** (R4, R5, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1, R2, R3, R6. NOT-BUILT: none.

## Residuals (carried + new)

| # | Item | Status / verdict |
|---|---|---|
| 1 | pass-1: closeout `roadmap-references-N` red | **CLOSED** (PASS on merit, 17/17 waived) |
| 2 | pass-1: `sessions/session-48-review.md` absent | **REMAINS** — owed; this document is it |
| 3 | pass-1/2: `required-crew` needs the standing waiver | **REMAINS (standing)** — 15 verified + 2 waived |
| 4 | pass-1: core README + license URL unchecked | **PARTLY CLOSED** — chart count + README license yes; core README license/deps no (N3/N4) |
| 5 | pass-2: guard breadth (KNOWLEDGE/ROADMAP/summary) | **CLOSED** for those (all red now) |
| 6 | pass-1: version had no target | **CLOSED** — CHANGELOG heading, retype red |
| 7 | pass-1: `gtm-reads` omits zero days from `day` lines | **REMAINS, immaterial** (totals, `days-since-last-non-zero` and the demo's "2 day(s)" carry them; I confirmed 10-05/10-06 = 0 against the API myself) |
| 8 | pass-1: ROADMAP S47 `IN PROGRESS` | **CLOSED** |
| 9 | clean-clone RED without install+build | **REMAINS by design** |
| 10 | contract's 23-vs-20 judgement only in a comment | **REMAINS** (call verified correct) |
| — | pass-2: backtick exemption unbounded | **NARROWED to table rows, still too broad** → ground N8 |
| — | pass-2: fail-open on missing file | **CLOSED** (`live file missing`, proved on CONTINUATION-PROMPT and TASK) |
| — | pass-2: zero-claim line+2 window | **NARROWED** (`119` removed, `⚠` added; SHIELD-C red) |
| **NEW** | R1 extraction is `-m1` + first-match: a second/contradicting badge is invisible | ground N5 |
| **NEW** | deps badge has **no URL extraction** though charts does — asymmetric fix, and a **regression** of a stimulus that was red for two passes | ground N1/N2 |
| **NEW** | ledger rule allows *any* figure on *any* marker line; `⚠`/`derive`/`not [0-9]` are not evidence of a downloads reading | ground N7 (contract) + residual (marker vocabulary quality) |
| **NEW** | figure scan keyed to the literal word `downloads` — `installs`, `adoption is taking off`, `1,119` all pass | grounds N6/N9/N10 (contract) + residual for the non-summary files |
| **NEW** | benchmark check is a four-row allow-list, not "every number in the Benchmarks table" | ground N11 |
| **NEW** | README blocks 2–3 never drift-checked | residual (outside R5's "top screen") |
| **NEW** | CHANGELOG "heads" check is a substring, so a newer heading above it passes | residual (CHANGELOG not an R1 surface) |
| **NEW** | `fidelity-review-accept` still satisfiable by waiver rather than by the file | residual (gate design) |

**Verdict:** **REJECT**

The pass-2 grounds are closed and I re-proved each: all seven greens are now red with the right diagnosis, the full red set still holds (except the regression below), the exemptions that must survive do survive in P0, fail-closed works, closeout is 17/17 with `roadmap-references-N` green on merit, and every invariant holds.

REJECT is on **eleven contract-covered counterfactuals that are still green**, one of them a regression introduced by the fix itself:

- **R1** (counterfactual: *retype → red*; *red on the first disagreement*): the deps badge's shield URL (N1 — **the verbatim pass-1 P1g stimulus turned red→green in `d26a418`**), README's `| **Zero dependencies** |` cell (N2), `packages/core/README.md`'s **license** (N3) and **dependency count** (N4) — both surfaces R1 names by file — and a duplicate `charts: 99` badge (N5).
- **R2** (counterfactual: *a downloads figure in `.ai/` the API does not return → red*): `1,119 downloads` (N6), `⚠ 888 downloads` in the ledger (N7), a backticked `999 downloads` in a non-counterfactual table row (N8).
- **R3** (counterfactual: *a benchmark number with no command → red*): a fabricated `Cold start | 500 ms (measured by hand)` row inside the Benchmarks table (N11).
- **R6** (counterfactual: *a summary sentence claiming traction with no R2 number beside it → red*): `adoption is taking off` (no number at all) and `888 installs this week` in the summary (N9/N10).

Each is a matcher-scope fix, not new surface: extract the deps URL and the deps cell the way charts already does; check core README's `## License` line and `**Zero Dependencies**` the way it checks `**20 Chart Types:**`; take the *last*/all badge matches instead of `-m1`; compare figures after stripping thousands separators and reject any that is not `119|273` regardless of marker; require the table-exempt backtick to sit on a counterfactual/stimulus line; scan the whole Benchmarks table for rows the script cannot derive; and match traction language, not just the word `downloads`.

Until those are red, "every number a stranger sees is produced by a command, and the gate fails on the first disagreement" is still false for the front door, the ledger, the benchmark table and the summary.

**Review-Inputs-SHA:**
`1599613ba3510221d271b56c8e97af42ec0c68d14d65fb533c6719924feb34d6`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (checked after every driver, after each integrity pass, and at the end). All 18 mutations restored byte-identically; the two deleted live files were restored (`git checkout --`); no `sessions/session-50-*`, no probe files, no debris in the repo — review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 4)

## What landed since pass 3 (verified by me)

`346f63d` — **scripts only** (`verify-session-48.sh` +75/−12, `demo-session-48.sh` +13/−1); `.ai/` untouched since `be2cf38`. Delivery **19 commits**, all `S48:`, 15 files, none under `packages/`.

Code read in full for the changed functions. What it actually does now:

- **R1** — `b_deps_url` (`badge/dependencies-N`) extracted and compared; README deps cell built from derived deps and `grep -qF`'d; `packages/core/README.md`'s `## License` value pulled by awk and compared, plus its `**${deps} Dependencies:**` line; **occurrence counting** over every `![charts: N]` and `![dependencies: N]` (`grep -cv "^${charts}$"` → `README-charts-badge-xN`), so a duplicate alt is caught.
- **R2** — figure regex widened to `<num> downloads|installs` + `downloads<sep><num>`, commas stripped before the whitelist; `*/​*` hits dropped as paths; ledger switched from a marker grep to a **finite allow-list** `89|119|181|273|304|318`; backticks stripped **only** on table rows that also match `counterfactual|stimulus|→|red|FAIL|instrument prints|probe`; a summary-only traction scan over `taking off|is working|grew |growth|surging|exploding|popular|demand` with a negated/conditional exemption (`*no\ *|*not\ *|*never*|*without*|*rather*|*cannot*|*if\ *`).
- **R3** — every `| **…** |` value cell under `## Benchmarks` must be in `allowed=(deps, tkb KB, ukb KB, files, ≤ budget ms)`.

**Syntax / baseline:** `bash -n` ×2 → **0**, `node --check` ×2 → **0**; `bash scripts/verify-session-48.sh` → **exit 0, 10/10**; `bash scripts/demo-session-48.sh` → **exit 0, 6/6** (0 `NOT PROVEN`).

**Closeout:** bare → **15 pass / 2 fail**, exactly `fidelity-review-accept` (`MISSING: sessions/session-48-review.md …`) + `required-crew`; **`roadmap-references-N` PASS on merit** (`OK: ROADMAP.md references Session 48`). With `VAJRA_CLOSEOUT_WAIVER=48` + the prescribed reason → **exit 0, `ALL GREEN (17 pass, 0 fail)`**, waiver recorded in the log.

**Invariants:** 19 commits → 11×1 file, 6×2, 2×3, **zero breaches**; smuggle diff (`.ai/AGENTS.md`, `packages/`, `pnpm-lock.yaml`, `.github/workflows/`) → **empty**; contract exactly **1** commit (`95dd29c`); `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` → `no packages/core/src or lockfile change in delivery`; instruments re-run by me → `gtm-reads --as-of 2026-10-03` = `total=119`, `--as-of 2026-10-06` = `total=273`, `release-shaped-total=243`, `non-release-total=30`; `gtm-bench` = `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 verdict=within render budget` (5 consecutive runs, byte-stable at 83496).

**Contamination controls:** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed (counts of `` `500 downloads` `` / `273 downloads`, and my own planted lines to confirm a mutation applied). No writes in the repo except gitignored `.ai/verify/**`.

**Disclosed process incident:** my first pass-4 sub-driver built its backup dir without the `.ai/` subpath, so `restore()` silently failed and four mutations accumulated across eight probes (and one probe timed out). I caught it from the `cp:` errors, ran `git checkout -- .` (the tree was clean at pass-4 start, so this restores byte-identically), verified `git status --porcelain` empty and each planted string gone (0 hits), then fixed the driver's paths, added a fail-loud `[ -s "$BAK/$f" ] || exit 9` guard, and **re-ran every affected probe cleanly**. The contaminated run's results are not used anywhere below.

## Stimulus re-runs

**A. The eleven N-probes — all RED (diagnosis quoted from the check's own log):**

| Probe | exit | Diagnosis line |
|---|---|---|
| N1 deps badge shield URL → `1` | 1 | `claim ≠ truth in: README-deps-url('1'≠0)` |
| N2 README `\| **Zero dependencies** \|` → `2 dependencies` | 1 | `claim ≠ truth in: README-deps-cell(expected '\| **Zero dependencies** \|')` |
| N3 core README license `MIT` → `Apache-2.0` | 1 | `claim ≠ truth in: coreREADME-license('Apache-2.0'≠MIT)` |
| N4 core README `**Zero Dependencies:**` → `**2 Dependencies:**` | 1 | `claim ≠ truth in: coreREADME-deps(expected '**Zero Dependencies:**')` |
| N5 duplicate false badge `charts: 99` | 1 | `claim ≠ truth in: README-charts-badge-x1 disagreeing badge(s)` |
| N6 STATE `1,119 downloads since launch` | 1 | `figure or claim no instrument prints: .ai/STATE.md:'1,119 downloads'` |
| N7 ledger `⚠ 888 downloads observed today.` | 1 | `figure or claim no instrument prints: .ai/GT-REMEDIATIONS.md:'888 downloads'` |
| N8 KNOWLEDGE table row, backticked `999 downloads` | 1 | `figure or claim no instrument prints: .ai/KNOWLEDGE.md:'999 downloads'` |
| N9 summary `adoption is taking off — the channel is working.` | 1 | `…sessions/session-48-summary.md:(traction claim with no derived number: Outcome: adoption is taking off — the channel is working.)` |
| N10 summary `888 installs this week.` | 1 | `…sessions/session-48-summary.md:'888 installs'` |
| N11 Benchmarks `Cold start \| **500 ms** (measured by hand)` | 1 | `Benchmarks table carries value(s) no command prints: '500 ms'` |

**B. Full red set — P0–P11b, then the pass-2 seven:**

| Probe | exit | Diagnosis |
|---|---|---|
| **P0 baseline (exemptions)** | **0** | — |
| P1 `charts-20`→`21` | 1 | `README-badge-url('21'≠20)` |
| P1b `all 20 charts`→`21` (README) | 1 | `README-prose` |
| P1d hero 20→21 | 1 | `docs hero drifted from the derived values:` (`> 21 Chart types`) |
| P1e `all 20 charts`→`21` (KNOWLEDGE) | 1 | `KNOWLEDGE-charts` |
| P1g `dependencies-0`→`1` | 1 | `README-deps-url('1'≠0)` |
| P2 / P2b tests `452` / `999` | 1 / 1 | `README claims 452 tests; the suite printed something else` / `…999…` |
| P3 one glyph in the text block | 1 | `README example has drifted from a real render:` (`> │ TREM …`) |
| P4 delete `pnpm add …` | 1 | `README has no install command for a stranger` |
| P5 `t1=273`→`274` | 1 | `STATE says t1=274 through 2026-10-06; instrument says '273'` |
| P6 `--as-of 2026-10-03`→`2026-10-02` | 1 | `STATE says t0=119 through 2026-10-02; instrument says '115'` |
| P7 `81.5 KB`→`40 KB` | 1 | `README tarball row ≠ measured 81.5 KB` |
| P8 delete bench command | 1 | `README does not show the command that produces these numbers` |
| P9 `500 downloads` → STATE | 1 | `…: .ai/STATE.md:'500 downloads'` |
| P10 pointer + all instrument names removed | 1 | `roadmap's pack row has no evidence pointer` |
| P11 LinkedIn URL deleted | 1 | `STATE records no post URL` |
| P11b URL → non-existent post | 1 | `…-XXXX/ → 404 (expected 200)` |
| NEW-A badge 20→200 | 1 | `README-badge-alt('200'≠20) README-badge-url('200'≠20) README-charts-badge-x1` |
| NEW-B `\| 3 renderers \|`→`13` | 1 | `README-renderers('13'≠3)` |
| NEW-C ledger bare zero-claim | 1 | `.ai/GT-REMEDIATIONS.md:(zero-claim with no superseding marker)` |
| NEW-D ledger `observed 888 downloads today.` | 1 | `.ai/GT-REMEDIATIONS.md:'888 downloads'` |
| NEW-E KNOWLEDGE prose backtick | 1 | `.ai/KNOWLEDGE.md:'999 downloads'` |
| SHIELD-C zero-claim + unrelated `119` | 1 | `.ai/ROADMAP.md:(zero-claim with no superseding marker)` |
| FAIL-OPEN CONTINUATION-PROMPT removed | 1 | `live file missing: .ai/CONTINUATION-PROMPT.md` |
| pass-3 control `charts-020` | 1 | `README-badge-alt('020'≠20) README-badge-url('020'≠20)` |
| pass-3 control: `gtm-bench.mjs` renamed away | 1 | `instrument scripts/gtm-bench.mjs missing` |
| pass-3 control: `gtm-reads.mjs` renamed away | 1 | `instrument scripts/gtm-reads.mjs missing` |
| control: summary `Organic growth is real here.` | 1 | `…(traction claim with no derived number: Organic growth is real here.)` |
| controls E8/E9 (`downloads total: 888`, `888 downloads/week`) | 1 / 1 | `…: 'downloads total: 888'` / `…: '888 downloads'` |

**C. Exemptions confirmed GREEN (all present in the tree P0 read):** summary `` `500 downloads` `` ×2 inside counterfactual table rows; summary `273 downloads` ×1; `.ai/CONTINUATION-PROMPT.md` `273` ×3; ledger `119 downloads`, `304 downloads`, `318`, `75/17/12/181/19`, `downloads/range/2026-09-15:2026-09-28` (path excluded as a path); STATE `119 lifetime downloads`; ROADMAP `superseded — false since S45: t0 = 119, not zero`. **No legitimate case broke.**

## New holes hunted

Every mutation was printed back from the file before the gate ran, then restored. Labelled **GROUND** (contract counterfactual / done-condition) vs **RESIDUAL** (outside R1–R6's wording).

| # | Stimulus | Mutation verified | exit | Label |
|---|---|---|---|---|
| E1 | badge URL colour only: `badge/charts-20-blue` → `-green` | applied | 0 | **RESIDUAL** — a colour is not a count or version; R1 enumerates counts/version/license |
| E2 | `charts-20` → `charts-020` (leading zero, alt too) | applied | 1 | control — fail-closed (`'020'≠20`) |
| E3 | second badge: `[![charts: 20](…badge/charts-99-red)]` | line present | **0** | **GROUND (R1)** — a badge a stranger sees rendering **charts 99**; R1: *every count … red on the first disagreement*. Occurrence counting covers **alts**; `b_charts_url` is still `-m1`, so a duplicate URL escapes |
| E4 | second badge `[![tests: 999 passing](…tests-999%20passing-red)]` | line present | **0** | **GROUND (R1)** — test count on README; `grep -m1` for both the badge and the hero's number |
| E5 | core README second bullet `- **99 Chart Types:** line, bar.` | line present | 0 (gate red, **`claims-match-truth` PASS**) | **GROUND (R1)** — presence check `grep -qF "**20 Chart Types:**"` cannot see a contradicting count on the file R1 names. *Proven by running the gate with the mutation and reading the per-check table:* `claims-match-truth PASS`, `benchmarks-cited-with-command FAIL` — and that FAIL is incidental (the edit grew the pack, 81.5 → 81.6 KB), not the claim |
| E6 | core README chart **names**: drop `sankey` from the list | applied | 0 | **RESIDUAL** — a list of names is not in R1's enumeration (chart count, test count, version, dependency count, license) |
| E7 | README prose second claim `// all 99 charts, any combo.` | line present | **0** | **GROUND (R1)** — `grep -qF "all 20 charts"` is presence-only; a disagreeing chart count on README.md |
| E18 | Benchmarks row `\| **Cold start** \| **0** \|` | line present | **0** | **GROUND (R3)** — the script prints `0`, so the flat allow-list accepts it, but no command produces "cold start = 0". R3: *each benchmark … produced by one script*; counterfactual *a benchmark number with no command → red*. Values are checked, rows are not bound |
| E19/E20 | rename `gtm-bench.mjs` / `gtm-reads.mjs` away | — | 1 / 1 | controls — `instrument … missing` (both instruments guarded) |
| E10 | STATE `0.8k downloads` | line present | **0** | **GROUND (R2)** — a downloads figure the API does not return (273); the regex needs `[0-9][0-9,]*` before ` downloads`, and `0.8k` never matches |
| E11 | STATE `eight hundred downloads` | line present | 0 | **RESIDUAL** — words, not a numeral; R2 says "figure" and every instrument in the pack speaks numerals. Borderline; I am not resting a verdict on it |
| E12 | STATE `888 stars on the repo` | line present | 0 | **RESIDUAL** — `stars` is in the grep list but never in the figure regex; R2's counterfactual names *downloads* figures. (The voluntary extras are dead code — worth noting) |
| E13 | `sessions/session-48-channel-post.md` gets `999 downloads …` | line present | 0 | **RESIDUAL** — R2 scopes to `.ai/`; R6's counterfactual scopes to the summary; R6's "anywhere" is requirement text and that file is otherwise clean |
| E14 | STATE `- the adoption baseline was zero before S45.` | line present | 0 | **RESIDUAL** — zero-rule is keyed to `baseline (of\|is) zero`; "no file calls the baseline zero" is a state condition the delivery satisfies |
| E15 | summary `Milestone reached: our first user came from the post.` | line present | **0** | **GROUND (R6)** — a summary sentence claiming traction with no R2 number beside it → must be red. `milestone` / `first user` are not in the keyword list |
| E16 | summary `The channel is working, no ads needed.` | line present | **0** | **GROUND (R6)** — same counterfactual, and worse: the line **matches** `is working` but is exempted by `*no\ *` because of "no ads". A one-word negation turns a positive traction claim green (control: `Organic growth is real here.` → red) |
| E17 | STATE `Adoption is taking off in every channel.` | line present | 0 | **RESIDUAL** — the traction scan is summary-only, which matches R6's counterfactual wording; STATE carries no traction language today |
| F1 | ledger `- 304 downloads on @ifelse.codes/chitra today.` | line present | 0 | **RESIDUAL** — `304` is on the finite allow-list and *is* returned by the API (for `@ifelse.codes/core`); this is package misattribution, not an unreturned figure |
| — | any new/extra file added to the working tree | — | 0 | **RESIDUAL** — R1–R6 never require the gate to enumerate new files; the 3-file cap and smuggle diff are *my* invariants (both pass here) |

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | All five pass-3 grounds closed and re-proved (N1–N5 red with the value mismatch printed; P1g's regression reversed: `README-deps-url('1'≠0)`); `charts-020` fail-closed; hero/KNOWLEDGE/CHANGELOG/license URL still red on stimulus. **But "every count … red on the first disagreement" still fails for contradicting duplicates**: alt-correct-but-URL-false badge (E3), second tests badge (E4), second `**99 Chart Types:**` bullet on `packages/core/README.md` (E5 — `claims-match-truth` PASS proven), second prose `all 99 charts` (E7). Four counts on R1's two named files can disagree with the tree while the check reports `… all carry the derived values`. |
| **R2** — adoption measured, not asserted | PARTIAL | Readings re-derive (119/273, 243/30), P5/P6 red, ledger allow-list works (`⚠ 888 downloads` red), comma figures now caught (`1,119 downloads` red), path hits excluded, missing file fails closed, all six legitimate exemptions intact. **Counterfactual still green:** `0.8k downloads` (E10) — a downloads figure the API does not return. |
| **R3** — benchmarks measured | PARTIAL | Four rows still bound to `gtm-bench.mjs`; fabricated `500 ms` row now red (N11); command-deletion and instrument-deletion red. **Counterfactual still green:** `\| **Cold start** \| **0** \|` (E18) — a value from the allow-list in a row no command produces. |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + reader pointer present; re-fetched every run; P11 `STATE records no post URL`, P11b `… → 404 (expected 200)`. No hole found. |
| **R5** — first screen answers three questions, probed | SHIPPED | install line, docs 200, first text block byte-identical to a live render; P3/P4 red. Blocks 2–3 unchecked → residual (contract scopes to the top screen). |
| **R6** — the record says what happened | PARTIAL | ROADMAP `✅ Session 48 … DONE` + instruments (P10 red when removed); summary figure red (N9/N10), keyword control red (`Organic growth is real here.`); missing file fails closed. **Counterfactual green twice:** unlisted traction words (`milestone` / `first user`, E15) and a positive claim escaping through the negation rule (`is working … no ads`, E16). |
| **Step-5 scripts** | SHIPPED | `bash -n` 0/0; verify **exit 0, 10/10**; demo **exit 0, 6/6** (0 `NOT PROVEN`), rows probed, mirrors the gate. |
| **Summary presence** | SHIPPED | present, unmodified by `346f63d`; structural greps only. |
| **`.ai` sync** | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` PASS on merit. |
| **Closeout gate** | SHIPPED | bare **15/2** (only `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; waived → **exit 0, 17/17**, reason recorded. |

## Count
**6 of 10 SHIPPED** (R4, R5, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1, R2, R3, R6. NOT-BUILT: none.

## Residuals (carried + new)

| Item | Status |
|---|---|
| pass-1: closeout `roadmap-references-N` | **CLOSED** (PASS on merit; 17/17 waived) |
| pass-1: `sessions/session-48-review.md` absent | **REMAINS** — owed; this document is it |
| pass-1/2: `required-crew` needs the standing waiver | **REMAINS (standing)** — 15 verified + 2 waived |
| pass-1/2: core README unchecked, version no target, fail-open file skip, zero-claim window, backtick exemption | **CLOSED** (N3/N4/N6/N7/N8, `live file missing`) |
| pass-1: `gtm-reads` omits zero days from `day` lines | **REMAINS, immaterial** (totals/`days-since-last-non-zero`/demo carry them; verified against the API myself) |
| pass-1: clean-clone RED without install+build | **REMAINS by design** |
| pass-1: 23-vs-20 judgement only in a comment | **REMAINS** (call verified correct) |
| pass-3: README blocks 2–3 never drift-checked | **REMAINS — RESIDUAL** (outside R5's "top screen") |
| pass-3: CHANGELOG `## [0.4.0]` is a substring check | **REMAINS — RESIDUAL** (CHANGELOG not an R1 surface) |
| **NEW** | duplicate/contradicting claims on `grep -qF` surfaces (core README, README prose, deps cell) — **GROUND** (E3/E4/E5/E7) |
| **NEW** | `b_charts_url` / tests badge still `-m1` while alts are counted — **GROUND** (E3/E4) |
| **NEW** | benchmark allow-list is value-only, rows unbound — **GROUND** (E18) |
| **NEW** | figure regex never matches `0.8k`-style numbers — **GROUND** (E10) |
| **NEW** | traction keyword list is finite and the negation exemption is a one-word escape — **GROUNDS** (E15/E16) |
| **NEW** | `stars`/`signups` are grepped but never extracted (dead branch) — **RESIDUAL** (E12) |
| **NEW** | ledger allow-list is package-agnostic (`304 downloads on chitra` green) — **RESIDUAL** (F1) |
| **NEW** | any edit under `packages/core/` shifts the packed size, so the bench row must be re-earned (I hit this on E5: 81.5 → 81.6 KB) — correct behaviour, but it means claim probes there cannot be isolated; noted for method |
| **NEW** | `fidelity-review-accept` still satisfiable by waiver rather than by the file — **RESIDUAL** (gate design) |

**Verdict:** **REJECT**

Everything the previous three passes demanded is closed and re-proved: all eleven N-probes red with the value mismatch named, the entire pass-1/2/3 red set intact, the seven exemptions preserved, fail-closed on missing files and missing instruments, closeout 17/17 with `roadmap-references-N` green on merit, and every invariant holds.

REJECT rests on **eight contract-covered counterfactual instances still green**, each labelled above:

- **R1 — "every count … on `README.md` and `packages/core/README.md` … red on the first disagreement"** (4): a badge whose URL renders `charts 99` with an honest alt (E3), a second `tests: 999 passing` badge (E4), a second `**99 Chart Types:**` bullet in `packages/core/README.md` (E5 — `claims-match-truth` **PASS** while the mutation is on disk), a second prose claim `all 99 charts` (E7). The N5 fix counted badge **alts**; every other surface is still presence-only.
- **R2 — "a downloads figure in `.ai/` that the API does not return right now → red"** (1): `0.8k downloads` (E10).
- **R3 — "a benchmark number with no command → red"** (1): `| **Cold start** | **0** |` (E18) — the value is in the allow-list, the row's claim is produced by nothing.
- **R6 — "a summary sentence claiming traction with no R2 number beside it → red"** (2): `Milestone reached: our first user …` (E15), and `The channel is working, no ads needed.` (E16), which matches the keyword and is then exempted by a bare `no `.

These are the same class of fix as N1–N11 — count *every* occurrence of a claim surface (not just alts, not `grep -m1`), bind benchmark **rows** to the command rather than values to a flat list, extend the figure tokenizer to `0.8k`-shaped numbers, and make the traction test a positive-claim test rather than a keyword list plus a negation escape hatch. Everything else I could think to break stayed red or is labelled a residual above.

**Review-Inputs-SHA:**
`26358cebf6db85ed0f84e19dc607c536fddcf072ce843b2928d43eac93ffe785`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (verified after every driver, after the `git checkout -- .` recovery, and at the end). No `sessions/session-50-*`, no probe or stash files, no debris in the repo; review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 5)

## What landed since pass 4 (verified by me)

`7c090b1` — **three scripts, exactly the 3-file cap** (`verify-session-48.sh`, `demo-session-48.sh`, `gtm-bench.mjs`). Delivery **20 commits**, all `S48:`; this commit touches no `.ai/` file and no README.

Code read in full for the changed parts:

- **R1 → `every_equals()`** (line 84): loops over **every** `grep -oE` match of a pattern in a file and fails with `contradicting claim(s): <surface>` if any extracted value ≠ the derived one. Applied to 10 surfaces: README shield URLs (charts + deps), all `tests-N%20passing` badges (now compared against **`SUITE_N`**, the count the suite itself printed, inside `core-suite-green`), README + KNOWLEDGE `all N charts`, core README's `**N Chart Types:**` / `**N Dependencies:**`, README's chart-types / renderers / deps cells. Presence checks kept for the "missing" direction; alt-text occurrence counts kept too.
- **R2 → tokenizer**: figure regex now `[0-9][0-9,.]*[kKmM]? … downloads|installs|stars`, then normalisation (strip separators, expand `k/M` ×1e3/×1e6) before the allow-list; `stars` is now parsed (it was grepped but never extracted); **`0` added to every allow-list** ("a zero can never be inflated traction").
- **R3 → rows bound**: `gtm-bench.mjs` now emits `rows=Runtime dependencies|npm install download|Installed footprint|Render a 100-point line chart` (verified by running it), and the README's `## Benchmarks` table must equal that list **in order** — a mismatch prints `README: a|b|c`.
- **R6 → guard list**: the exemption is now an explicit list of this record's own guard sentences (`none organic`, `never cite`, `never as traction`, `flat zero`, …), and the keyword list gained `milestone`, `first user`, `worked`, `organic`, `signups`, `traction`.

**Syntax / baseline:** `bash -n` ×2 → **0**; `node --check` ×2 → **0**; `bash scripts/verify-session-48.sh` → **exit 0, 10/10**; `bash scripts/demo-session-48.sh` → **exit 0, 6/6** (0 `NOT PROVEN`).

**Closeout:** bare → **15 pass / 2 fail**, exactly `fidelity-review-accept` (`MISSING: sessions/session-48-review.md …`) + `required-crew`; **`roadmap-references-N` PASS on merit** (`OK: ROADMAP.md references Session 48`). With `VAJRA_CLOSEOUT_WAIVER=48` + the prescribed reason → **exit 0, `ALL GREEN (17 pass, 0 fail)`**, waiver recorded in the log.

**Invariants:** 20 commits → 11×1 file, 6×2, 3×3, **zero breaches**; smuggle diff (`.ai/AGENTS.md`, `packages/`, `pnpm-lock.yaml`, `.github/workflows/`) → **empty**; contract exactly **1** commit (`95dd29c`); `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` → `no packages/core/src or lockfile change in delivery`; instruments re-run by me → `gtm-reads --as-of 2026-10-03` = `total=119`, `--as-of 2026-10-06` = `total=273`, `release-shaped-total=243`, `non-release-total=30`; `gtm-bench` = `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 rows=Runtime dependencies|npm install download|Installed footprint|Render a 100-point line chart verdict=within render budget`.

**Contamination controls:** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed (counts of `` `500 downloads` ``, `273 downloads`, the guard-sentence trio, plus my own planted lines to prove a mutation applied). No writes in the repo except gitignored `.ai/verify/**`.

**Tooling incidents, disclosed:** (a) I briefly ran a mutation-verification command *concurrently* with a probe batch — two writers on one worktree. I stopped, ran `git checkout -- .`, confirmed `git status --porcelain` empty and every planted string gone (0 hits), then **re-ran that whole batch sequentially**; every number below comes from the clean re-run only. (b) My first draft of the runner used `declare -A`, which macOS's bash 3.2 cannot execute; caught by `bash -n`, rewritten as a `case` label map (cosmetic).

## Stimulus re-runs

**A. The eight pass-4 grounds — all now RED (diagnosis quoted from the check's log):**

| Probe | exit | Diagnosis line |
|---|---|---|
| E3 duplicate badge alt-20 / URL-99 | 1 | `contradicting claim(s): README-shield-charts` |
| E4 duplicate `tests: 999 passing` badge | 1 | `tests badge disagreeing with the suite: '999' (suite printed 453)` |
| E5 core README second `**99 Chart Types:**` | 1 | `contradicting claim(s): coreREADME-chart-types` |
| E7 README prose second `all 99 charts` | 1 | `contradicting claim(s): README-prose-count` |
| E10 STATE `0.8k downloads` | 1 | `figure or claim no instrument prints: .ai/STATE.md:'0.8k downloads'` |
| E15 summary `Milestone reached: our first user …` | 1 | `…(traction claim with no derived number: Milestone reached: our first user came from the post.)` |
| E16 summary `The channel is working, no ads needed.` | 1 | `…(traction claim with no derived number: The channel is working, no ads needed.)` |
| E18 Benchmarks `Cold start` row with `0` | 1 | `README: Runtime dependencies\|npm install download\|Installed footprint\|Cold start\|Render a 100-point line chart` |

**B. The accumulated red set — P0 green, everything else red:**

| Probe | exit | Diagnosis |
|---|---|---|
| **P0 baseline (exemptions)** | **0** | `RED=[]` |
| P1 `charts-20`→`21` | 1 | `README-badge-url('21'≠20)` |
| P1b `all 20 charts`→`21` (README) | 1 | `README-prose` |
| P1d hero 20→21 | 1 | `docs hero drifted from the derived values:` (`> 21 Chart types`) |
| P1e KNOWLEDGE `all 20 charts`→`21` | 1 | `KNOWLEDGE-charts` |
| P1g `dependencies-0`→`1` | 1 | `README-deps-url('1'≠0)` |
| P2 / P2b tests `452` / `999` | 1 / 1 | `tests badge disagreeing with the suite: '452' / '999' (suite printed 453)` |
| P3 one glyph in the text block | 1 | `README example has drifted from a real render:` (`> │ TREM …`) |
| P4 delete `pnpm add …` | 1 | `README has no install command for a stranger` |
| P5 `t1=273`→`274` | 1 | `STATE says t1=274 through 2026-10-06; instrument says '273'` |
| P6 `--as-of 2026-10-03`→`2026-10-02` | 1 | `STATE says t0=119 through 2026-10-02; instrument says '115'` |
| P7 `81.5 KB`→`40 KB` | 1 | `README tarball row ≠ measured 81.5 KB` |
| P8 delete bench command | 1 | `README does not show the command that produces these numbers` |
| P9 `500 downloads` → STATE | 1 | `…: .ai/STATE.md:'500 downloads'` |
| P10 ROADMAP pointer + instruments removed | 1 | `roadmap's pack row has no evidence pointer` |
| P11 / P11b LinkedIn URL deleted / → non-existent | 1 / 1 | `STATE records no post URL` / `…-XXXX/ → 404 (expected 200)` |
| pass-2 NEW-A, NEW-B | 1 / 1 | `README-badge-alt('200'≠20) README-badge-url('200'≠20) README-charts-badge-x1` / `README-renderers('13'≠3)` |
| pass-2 NEW-C, NEW-D, NEW-E | 1 / 1 / 1 | ledger zero-claim / ledger `'888 downloads'` / KNOWLEDGE `'999 downloads'` |
| pass-2 SHIELD-C, FAIL-OPEN | 1 / 1 | ROADMAP zero-claim / `live file missing: .ai/CONTINUATION-PROMPT.md` |
| pass-3 N1…N5 | 1 ×5 | `README-deps-url('1'≠0)`, `README-deps-cell(…)`, `coreREADME-license('Apache-2.0'≠MIT)`, `coreREADME-deps(…)`, `README-charts-badge-x1` |
| pass-3 N6…N10 | 1 ×5 | `'1,119 downloads'`, ledger `'888 downloads'`, table-row `'999 downloads'`, summary traction ×2 |
| pass-3 N11 | 1 | `Benchmarks table carries value(s) no command prints: '500 ms'` |

**C. Exemptions confirmed GREEN in P0 — every listed case present in the tree P0 read:** summary `` `500 downloads` `` ×2 in counterfactual table rows; summary `273 downloads` ×1; summary guard lines (`none organic` / `never as traction` / `flat zero`) ×2; STATE `119 lifetime downloads` ×1 and `0 downloads on 10-05 and 10-06` ×1; ROADMAP `downloads are 0` ×1 and `superseded — false since S45: t0 = 119, not zero` ×1; ledger `119 downloads`, `304 downloads`, `318`, `75/17/12/181/19`, `downloads/range/2026-09-15:2026-09-28`; CONTINUATION `273` ×3 (`273 downloads` ×1). **No legitimate case broke.**

## New holes hunted (labelled GROUND or RESIDUAL)

Every mutation was printed back from the file before the gate ran, then restored.

| # | Stimulus | Mutation verified | exit | Label |
|---|---|---|---|---|
| H_LIC | second README badge `[![license: Apache](…badge/license-Apache-green)]` | line 231 present | **0** | **GROUND (R1)** — R1 enumerates *license* on `README.md` and demands "red on the first disagreement"; `every_equals` has no license surface, `b_license` is `-m1`, the URL check is `grep -qF` presence. A stranger reads an Apache badge on an MIT package |
| H_LIC2 | second `## License` block (`Apache-2.0`) appended to `packages/core/README.md` | applied; the extractor still prints `MIT` | **0** | **GROUND (R1)** — same enumeration on the second named file; the awk takes the *first* `## License` block, so a contradicting second one rides along |
| H_VER | `[![version: 0.9.0](…badge/version-0.9.0-blue)]` added to README | line 233 present | **0** | **GROUND (R1)** — R1: "Every count **and version** on `README.md` … checked against the manifest … red on the first disagreement". Manifest is `0.4.0`; nothing looks at a README version claim |
| H_ALTURL | second chart badge `https://img.shields.io/static/v1?label=charts&message=99` (alt honest, image renders **99**) | line 235 present | **0** | **GROUND (R1)** — a *chart count* on README disagreeing; the patterns only recognise `badge/charts-N`, so the rendered 99 is invisible |
| H_ZERO | STATE `- Adoption: 0 downloads in October 2026.` | line 174 present | **0** | **GROUND (R2)** — counterfactual: *a downloads figure in `.ai/` the API does not return right now → red*. The API returns **169** for 2026-10-01…10-06, not 0. The blanket `0` allowance is the same shape as the pass-3 marker free-pass: an exemption class that lets an unreturned figure through — and a false zero is the exact error this session exists to kill |
| H_ZERO2 | STATE `- Lifetime total: 0 downloads since launch.` | line 176 present | **0** | **GROUND (R2)** — the API returns 273 lifetime; 0 is not returned for that window |
| H_BUNDLE | README row `\| **Bundles at 5 MB** \| Tiny footprint … \|` placed outside `## Benchmarks` | line 231 present | **0** | **GROUND (R3)** — R3 names **bundle size** as one of the four numbers that must be "produced by one script, cited … with the command beside each number"; counterfactual *a benchmark number with no command → red*. The script prints 81.5 KB packed; the rows-check is scoped to `## Benchmarks`, so a bundle claim elsewhere is green |
| H_GUARD | summary `Milestone: our first user arrived — never cite it as traction.` | line 92 present | **0** | **GROUND (R6)** — counterfactual: *a summary sentence claiming traction with no R2 number beside it → red*. It claims a milestone + first user with no R2 number and is exempted only because a guard sentence shares the line — the structural twin of pass-4 E16, moved from the negation rule into the guard list |
| H_VOCAB | summary `Stars are climbing every day.` | line 93 present | **0** | **GROUND (R6)** — same counterfactual: traction claimed, no R2 number; the same class as pass-4 E15 (closed then by adding words). **Stated plainly: this class cannot be closed by any finite keyword list** — R6's counterfactual is unbounded English, so the rule must change shape (allowlist the summary's outcome claims, or require every sentence in the outcome section to quote a derived number) rather than grow another word |
| H_TABLEK | KNOWLEDGE row `` \| probe \| `0.8k downloads` \| counterfactual: red \| `` | line 478 present | 0 | **RESIDUAL** — the marker-gated table exemption I accepted at pass 3/N8; planting `counterfactual` in a row buys the shield. The price of an exemption the summary's own table needs |
| H_URL2 | second LinkedIn URL appended to STATE | line 174 present | 0 | **RESIDUAL** — R4's counterfactual covers *absence* (`no URL → NOT-BUILT`); "one channel, one link" has no red-proving stimulus |
| H_DATE2 | `- Earlier draft published 2026-10-05.` appended to STATE | line 176 present | 0 | **RESIDUAL** — same: no counterfactual covers a duplicate timestamp |
| H_FORGEROWS | `"Cold start"` added to `gtm-bench.mjs`'s own `rows=` **in the matching position**, plus README `\| **Cold start** \| **0** \|` | `rows=…\|Cold start\|Render a…` | **0** | **RESIDUAL** — self-referential trust: R3 believes the instrument's own declaration and `0` is in the value allow-list. Reaching it requires editing the *instrument* (the checker), which is tampering with the gate and outside R1–R6's wording; recorded as the boundary of what "re-runnable" can guarantee. (An *unaligned* forge — my first attempt — went red on order, so the order check is real) |
| H_SCI | STATE `2.73e2 downloads` (a true 273) | line present | 1 | control, fail-closed: reads `2` → **RESIDUAL** (tokenizer mis-reads scientific notation, but errs red) |
| H_TILDE / H_SENT | `~888 downloads` / `We crossed 888 downloads this week …` | applied | 1 / 1 | controls — `'888 downloads'` |
| H_REORDER | Benchmarks rows swapped | applied | 1 | control — order enforced (`README: npm install download\|Runtime dependencies\|…`) |
| H_DELGTR | `.ai/GT-REMEDIATIONS.md` deleted | — | 1 | control — `S40 row 1 (adoption baseline) status is '', not DONE` + `live file missing` |
| pass-4 residual | STATE `888 stars on the repo` | line present | 1 | control — `'888 stars'`; they closed that residual too |

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | All four pass-4 duplicates closed and re-proved (`contradicting claim(s): README-shield-charts / coreREADME-chart-types / README-prose-count`; tests now bound to `SUITE_N`); P1/P1b/P1e/P1g and N1–N5 red; `charts-020` fail-closed. **Four surfaces R1 names are still green when wrong:** README's *license* (H_LIC), core README's *license* (H_LIC2), README's *version* (H_VER — a `0.9.0` badge on a `0.4.0` package), and a *chart count* rendered through a shields format the patterns do not recognise (H_ALTURL). |
| **R2** — adoption measured, not asserted | PARTIAL | Readings re-derive (119/273, 243/30); every figure probe from passes 1–4 red, including `0.8k`, `1,119`, `~888`, `888 downloads/week`, `888 stars`; exemptions intact; ledger allow-list holds. **Counterfactual still green:** `0 downloads in October 2026` and `0 downloads since launch` (H_ZERO/H_ZERO2) — figures the API does not return, admitted by the blanket `0` allowance. |
| **R3** — benchmarks measured | PARTIAL | Values and rows now bound to `gtm-bench.mjs` (E18, `500 ms`, row re-order, command deletion, instrument deletion all red; `rows=` printed by the script). **Counterfactual still green:** a bundle-size claim outside the table — `\| **Bundles at 5 MB** \|` (H_BUNDLE) — produced by no command, in the one dimension R3 names first. |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + reader pointer present; re-fetched every run; P11/P11b red. Second URL/date are residuals (no counterfactual covers them). |
| **R5** — first screen answers three questions, probed | SHIPPED | install line, docs 200, first text block byte-identical to a live render; P3/P4 red. README blocks 2–3 remain a residual (outside "top screen"). |
| **R6** — the record says what happened | PARTIAL | ROADMAP row + instruments (P10 red); summary figures red (N9/N10/E15/E16); keyword control red (`Organic growth is real here.`); guard sentences still green in P0. **Counterfactual green twice:** a traction claim carrying a guard phrase (H_GUARD — same escape mechanism as pass-4 E16) and unlisted traction vocabulary (H_VOCAB). |
| **Step-5 scripts** | SHIPPED | `bash -n` 0/0; verify **exit 0, 10/10**; demo **exit 0, 6/6** (0 `NOT PROVEN`), rows probed, mirrors the gate. |
| **Summary presence** | SHIPPED | present, unmodified by `7c090b1`; structural greps only. |
| **`.ai` sync** | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` PASS on merit. |
| **Closeout gate** | SHIPPED | bare **15/2** (only `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; waived → **exit 0, 17/17**, reason recorded. |

## Count
**6 of 10 SHIPPED** (R4, R5, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1, R2, R3, R6. NOT-BUILT: none.

## Residuals (carried + new)

| Item | Status |
|---|---|
| pass-1: closeout `roadmap-references-N` | **CLOSED** (PASS on merit; 17/17 waived) |
| pass-1: `sessions/session-48-review.md` absent | **REMAINS** — owed; this document is it |
| pass-1/2: `required-crew` needs the standing waiver | **REMAINS (standing)** — 15 verified + 2 waived |
| pass-1–4: every previously named ground (P1c/P1f, breadth, fail-closed, N1–N11, E3/E4/E5/E7/E10/E15/E16/E18) | **CLOSED and re-proved this pass** |
| pass-4 residual: `888 stars` never parsed | **CLOSED** (now red) |
| pass-1: `gtm-reads` omits zero days from `day` lines | **REMAINS, immaterial** |
| pass-1: clean-clone RED without install+build | **REMAINS by design** |
| pass-1: 23-vs-20 judgement only in a comment | **REMAINS** (call verified correct) |
| pass-3: README blocks 2–3 never drift-checked | **REMAINS — RESIDUAL** (outside R5's "top screen") |
| pass-3: CHANGELOG `## [0.4.0]` substring check | **REMAINS — RESIDUAL** (CHANGELOG not an R1 surface) |
| pass-4: ledger allow-list is package-agnostic (`304 downloads on chitra`) | **REMAINS — RESIDUAL** (the number *is* returned, for another package) |
| **NEW** | marker-gated backtick exemption can be bought by writing `counterfactual` in a row — **RESIDUAL** (H_TABLEK) |
| **NEW** | second LinkedIn URL / second publish date not detected — **RESIDUAL** (H_URL2/H_DATE2; no R4 counterfactual) |
| **NEW** | R3 believes the instrument's own `rows=` declaration — **RESIDUAL** (H_FORGEROWS; editing the checker) |
| **NEW** | tokenizer mis-reads scientific notation (`2.73e2` → 2) — **RESIDUAL**, fails closed |
| **NEW** | `fidelity-review-accept` still satisfiable by waiver rather than by the file — **RESIDUAL** (gate design) |
| **NEW** | R6's counterfactual is unbounded English; a finite keyword list can only be falsified, never verified — see H_VOCAB. This is a **contract-design** problem as much as an implementation one, and it is why H_VOCAB is labelled GROUND rather than waved through |

**Verdict:** **REJECT**

Everything demanded by passes 1–4 is closed and re-proved: the eight E-grounds are red with the value mismatch named, the whole accumulated red set (P0 green, 36 others red) holds, every exemption survives in P0, closeout is 17/17 with `roadmap-references-N` green on merit, and every invariant holds.

REJECT rests on **nine contract-covered counterfactual/done-condition instances still green**, each labelled above:

- **R1 — "Every count and version on `README.md` and `packages/core/README.md` … red on the first disagreement"** (4): a second *license* badge on README (H_LIC), a second `## License` block in `packages/core/README.md` (H_LIC2), a `version-0.9.0` badge on a `0.4.0` package (H_VER), and a *chart count* rendered through `img.shields.io/static/v1?…message=99` (H_ALTURL). `every_equals` covers ten surfaces — these four are the enumeration's own members that it does not.
- **R2 — "a downloads figure in `.ai/` that the API does not return right now → red"** (2): `0 downloads in October 2026` and `0 downloads since launch` — the blanket `0` allowance is the same class of exemption-as-free-pass as the pass-3 `⚠` marker, and a false zero contradicts the very finding this session exists to record.
- **R3 — "a benchmark number with no command → red"** (1): `| **Bundles at 5 MB** |`, a bundle-size claim produced by no command, sitting outside the one table the rows-check reads.
- **R6 — "a summary sentence claiming traction with no R2 number beside it → red"** (2): `Milestone: our first user arrived — never cite it as traction.` (guard phrase inside the claim — the same mechanism as E16, relocated) and `Stars are climbing every day.` (unlisted vocabulary — same class as E15).

The fixes are the same shape as before and none needs new surface: give license and version an `every_equals` surface on both files and treat every badge *format* as a claim; make the `0` allowance window-bound (only where a date the API confirms is on the line, or simply keep `0` out of the general allow-list and permit the two lines that actually say `10-05/10-06`); scan for benchmark-shaped claims anywhere in the README rather than only under `## Benchmarks`; and invert the R6 test (a positive-claim allowlist for the summary's outcome section) instead of extending a keyword list and a guard list that can always be ridden past.

**Review-Inputs-SHA:**
`5cc7cf5de2275ac68ce66d1c2b44db52991bec5a8229e205904c50c3df7ce244`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (checked after every probe batch, after each disclosed incident, and at the end). All mutations restored byte-identically; no `sessions/session-50-*`, no probe/stash files, no debris in the repo — review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 6)

## What landed since pass 5 (verified by me)

`9fc5226` — **two scripts** (`verify-session-48.sh` +135/−?, `demo-session-48.sh` +92/−?), inside the 3-file cap. Delivery **21 commits**, all `S48:`; 15 delivery files, none under `packages/`; contract still exactly 1 commit.

Code read in full for the changed parts:

- **R1** — `every_equals` grew from 10 to 17 surfaces: README license **alt**, README/core README **version** alt + shield, and shields **static** format `label=charts|dependencies|tests&message=N`. Core README's `## License` check now walks **every** `## License` block (the pass-5 second-block case).
- **R2** — the blanket `0` is gone. A zero is admitted only when **its own line** matches `*10-05*|*10-06*|*before its publish*|*re-probe*|*re-derived*`; otherwise `zero with no window the API supports`. Line-based scan (replacing the previous line-independent hit loop), hits captured first and iterated with a here-string (the bash-3.2 crash fix).
- **R3** — outside `## Benchmarks`, every **size token** (`MB|KB|kB|GB`) must be one of the two the script prints: `README carries a size claim no command prints`.
- **R6** — the guard-sentence exemption is **deleted**; the rule is now structural: a line matching `TRACT` must contain **a digit**, else `traction claim quoting no number`.
- **Bash-3.2 crash** — the nested `while read < <(...)` inside the file loop is gone; the current code captures `hits` into a variable and uses `done <<< "$hits"`.

**Stability — three consecutive gate runs (the fix's own claim):**

| Run | exit | result |
|---|---|---|
| 1 | **0** | `10 pass, 0 fail` |
| 2 | **0** | `10 pass, 0 fail` |
| 3 | **0** | `10 pass, 0 fail` |

`bash scripts/demo-session-48.sh` → **exit 0, 6/6** (0 `NOT PROVEN`). Syntax: `bash -n` ×2 → **0**, `node --check` ×2 → **0**. **No crash, no RC 133/134, no empty output; the gate is stable across three runs.**

**Closeout:** bare → **15 pass / 2 fail** (exactly `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; with `VAJRA_CLOSEOUT_WAIVER=48` + the prescribed reason → **exit 0, `ALL GREEN (17 pass, 0 fail)`**, reason recorded.

**Invariants:** 21 commits → 11×1 file, 7×2, 3×3, **zero breaches**; smuggle diff (`.ai/AGENTS.md`, `packages/`, `pnpm-lock.yaml`, `.github/workflows/`) → **empty**; contract exactly **1** commit; `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` → `no packages/core/src or lockfile change in delivery`; instruments re-run by me → `gtm-reads --as-of 2026-10-03` = `total=119`, `--as-of 2026-10-06` = `total=273`, `release-shaped-total=243`, `non-release-total=30`; `gtm-bench` = `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 rows=Runtime dependencies|npm install download|Installed footprint|Render a 100-point line chart verdict=within render budget`.

**Contamination controls:** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed (counts of `` `500 downloads` ``, `273 downloads`, the guard-line trio, and my own planted lines to prove a mutation applied). No writes in the repo except gitignored `.ai/verify/**`.

**Tooling incidents:** none this pass. Every probe batch ran sequentially; no two mutating commands were ever concurrent; backups are guarded by `[ -s "$BAK/$f" ] || exit 9`.

## Stimulus re-runs

**A. The nine pass-5 grounds — all now RED (diagnosis quoted):**

| Ground | exit | Diagnosis line |
|---|---|---|
| H_LIC second README license badge | 1 | `contradicting claim(s): README-license-alt` |
| H_LIC2 second `## License` block in core README | 1 | `core README License block(s) disagreeing: 'Apache-2.0' (expected MIT)` |
| H_VER `version-0.9.0` badge | 1 | `contradicting claim(s): README-version-alt README-version-shield` |
| H_ALTURL static `label=charts&message=99` | 1 | `contradicting claim(s): README-static-charts` |
| H_ZERO `0 downloads in October 2026` | 1 | `figure or claim no instrument prints: .ai/STATE.md:'0 downloads' (zero with no window the API supports)` |
| H_ZERO2 `0 downloads since launch` | 1 | `…(zero with no window the API supports)` |
| H_BUNDLE `\| **Bundles at 5 MB** \|` | 1 | `README carries a size claim no command prints: '5 MB' (script prints 81.5 KB / 398.4 KB)` |
| H_GUARD milestone + guard phrase | 1 | `…(traction claim quoting no number: Milestone: our first user arrived — never cite i)` |
| H_VOCAB `Stars are climbing every day.` | 1 | `…(traction claim quoting no number: Stars are climbing every day.)` |

**B. The accumulated red set — 44 stimuli: P0 green, the other 43 red.**

| Group | Result |
|---|---|
| **P0 baseline (exemptions)** | **exit 0, `RED=[]`** |
| P1, P1b, P1d, P1e, P1g | 1 ×5 — `README-badge-url('21'≠20)`, `README-prose`, `docs hero drifted…` (`> 21 Chart types`), `KNOWLEDGE-charts`, `README-deps-url('1'≠0)` |
| P2, P2b | 1 ×2 — `tests badge disagreeing with the suite: '452' / '999' (suite printed 453)` |
| P3, P4 | 1 ×2 — `README example has drifted from a real render:` (`> │ TREM …`), `README has no install command for a stranger` |
| P5, P6 | 1 ×2 — `STATE says t1=274 … instrument says '273'`, `STATE says t0=119 … instrument says '115'` |
| P7, P8 | 1 ×2 — `README tarball row ≠ measured 81.5 KB`, `README does not show the command…` |
| P9, P10 | 1 ×2 — `…: .ai/STATE.md:'500 downloads'`, `roadmap's pack row has no evidence pointer` |
| P11, P11b | 1 ×2 — `STATE records no post URL`, `…-XXXX/ → 404 (expected 200)` |
| pass-2 NEW-A…FAIL-OPEN (7) | 1 ×7 — `README-badge-alt('200'≠20)…`, `README-renderers('13'≠3)`, ledger zero-claim, ledger `'888 downloads'`, KNOWLEDGE `'999 downloads'`, ROADMAP zero-claim, `live file missing: .ai/CONTINUATION-PROMPT.md` |
| pass-3 N1…N11 (11) | 1 ×11 — `README-deps-url`, `README-deps-cell`, `coreREADME-license`, `coreREADME-deps`, `README-charts-badge-x1`, `'1,119 downloads'`, ledger `'888 downloads'`, table-row `'999 downloads'`, summary traction ×2, `Benchmarks table carries value(s) no command prints: '500 ms'` |
| pass-4 E3…E18 (8) | 1 ×8 — `README-shield-charts`, suite `'999'`, `coreREADME-chart-types`, `README-prose-count`, `'0.8k downloads'`, summary traction ×2, row-order mismatch |

**C. Exemptions confirmed GREEN in P0 — every listed case present in the tree P0 read:** summary `` `500 downloads` `` ×2 in counterfactual table rows; summary `273 downloads` ×1; summary guard lines with numbers (`none organic` / `never as traction` / `flat zero`) ×2; STATE `119 lifetime downloads` ×1 and `0 downloads on 10-05 and 10-06` ×1; ROADMAP `downloads are 0 for the 9 days before its publish` ×1 and `superseded — false since S45` ×1; ledger `119 downloads`, `304 downloads`, `318`, `75/17/12/181/19`, `downloads/range/2026-09-15:2026-09-28`; CONTINUATION `273 downloads` ×1. **No legitimate case broke.**

## New holes hunted (labelled GROUND or RESIDUAL)

Every mutation was printed back from the file before the gate ran, then restored.

| # | Stimulus | Mutation verified | exit | Label |
|---|---|---|---|---|
| X_REL_BADGE | `[![release: 9.9.9](https://img.shields.io/badge/release-9.9.9-blue)]` on README | line 231 present | **0** | **GROUND (R1)** — a shield badge claiming **9.9.9** on a `0.4.0` package. R1: "Every count **and version** on `README.md` … red on the first disagreement"; "Shield badges count as claims." The version surfaces are `![version: …]`, `badge/version-…` and `label=…&message=…` — a `release`-labelled badge is the same shape, unfixed |
| X_STATIC_LIC | `[![x](…static/v1?label=license&message=Apache)]` on README | line 233 present | **0** | **GROUND (R1)** — license is enumerated by R1 and this is the exact static format they added for charts/deps/tests one commit ago, minus the license label. A stranger reads Apache on an MIT package |
| X_ZERO_WINDOW | STATE `- Adoption: 0 downloads in October 2026 (note the gap since 10-05).` | line 174 present | **0** | **GROUND (R2)** — counterfactual: *a downloads figure in `.ai/` the API does not return right now → red*. The claim is 0 for October (API: **169**); it is admitted only because the token `10-05` sits on the same line — the same "unrelated nearby token satisfies a window test" mechanism as pass-3 SHIELD-C, which was fixed then |
| X_TRACTION_DIGIT | summary `Milestone: our first user arrived — 99 likes on the post.` | line 92 present | **0** | **GROUND (R6)** — counterfactual: *claiming traction with no **R2 number** beside it → red*. The new rule demands **a digit**, and `99` is not anything R2 derives (119/273/243/30/day values). Finite fix: the line's figures must be in the instrument-printed set — a whitelist this code already runs for figures |
| Y_TIME | README `\| **Renders in 500 ms** \| Fast enough for a prompt loop. \|` (outside `## Benchmarks`) | line 231 present | **0** | **GROUND (R3)** — R3 names **a render-time figure** as one of its four numbers; counterfactual *a benchmark number with no command → red*. The script prints `render-budget-ms=2` (median 0.07); the outside-scan only looks for size tokens, so a time claim anywhere else is green. Same shape as H_BUNDLE, closed for size only |
| Y_HANDOFF | `Observed 999 downloads during that session.` appended to `.ai/handoffs/session-46-tech-lead.md` | count 1 | **0** | **GROUND (R2)** — the counterfactual says **`.ai/`**, with no qualifier, and `.ai/handoffs/*.md` is `.ai/` markdown this repo's own loop writes (S48's tech-lead handoff would land there). Fix is finite: add the directory to the scanned set (or say "the eight live files" in the contract — it does not). *Weakest of the six; flagged as literal scope.* |
| Y_AGENTS | `Observed 999 downloads…` appended to `.ai/AGENTS.md` | count 1 | 0 | **RESIDUAL** — same literal `.ai/` boundary, but AGENTS.md is the vajra-governed constitution with an explicit "do not edit below this line"; a plant there is a **smuggle**, which the empty-smuggle-diff invariant (mine) covers, not a claim this delivery may write |
| X_TRACTION_VOCAB2 | summary `Adoption doubled this week.` | line 93 present | 0 | **RESIDUAL** — no `TRACT` keyword, so the structural number-rule never fires. **This is the class I declared unsatisfiable in pass 5**: no finite trigger list covers English, and I prescribed the structural fix, which they shipped. The trigger can only ever be grown, never completed — contract-design gap, not an implementable instance |
| X_FENCE | README ```ts fence: `// 99 charts available in this release` | line 24 present | 0 | **RESIDUAL** — free-text chart count in prose/fence. Same unboundedness as X_TRACTION_VOCAB2; the *enumerable* claim surfaces (badges, cells, tables, `all N charts`) are covered. The contract's written counterfactual for R1 is "retype `20` → red" — the badge — which is red |
| X_DLBADGE | jsdelivr **downloads** badge added to README | line 235 present | 0 | **RESIDUAL** — a downloads badge on README falls between R2's counterfactual (scoped to `.ai/`) and R6's (scoped to the summary). Real front-door gap, outside both counterfactuals as written |
| X_DENIAL | summary `No organic signal yet.` | line 94 present | 1 | **RESIDUAL** — false positive: a denial trips the traction rule for lacking digits. The contract only demands red for *claims*; P0 proves the delivered summary has no such line |
| X_ROWS_DRIFT | README Benchmarks rows reordered | applied | 1 | control — `README: npm install download\|Runtime dependencies\|…` (script/README rows are compared; drift cannot pass both sides) |

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | All four pass-5 grounds red (license alt, every `## License` block, version alt+shield, static charts); 17 surfaces now compared; P1/P1b/P1e/P1g, N1–N5, E3/E4/E5/E7 all red; `charts-020` fail-closed. **Two named surfaces still green:** a `release-9.9.9` version badge (X_REL_BADGE) and a `label=license&message=Apache` license badge (X_STATIC_LIC) — both badges, both enumerated claim types, both finite to add to the same list. |
| **R2** — adoption measured, not asserted | PARTIAL | Readings re-derive (119/273, 243/30); every figure probe from passes 1–5 red (incl. `0.8k`, `1,119`, `~888`, `0 downloads in October`, `0 downloads since launch`); exemptions intact; ledger allow-list holds. **Counterfactual still green twice:** a false zero admitted by an unrelated `10-05` on the line (X_ZERO_WINDOW), and `999 downloads` in `.ai/handoffs/*.md` — the counterfactual says `.ai/` (Y_HANDOFF). |
| **R3** — benchmarks measured | PARTIAL | Table values + row order bound to `gtm-bench.mjs`; size claims outside the table now scanned (H_BUNDLE red); command/instrument deletion red; row drift red. **Counterfactual still green:** `\| **Renders in 500 ms** \|` outside the table (Y_TIME) — a render-time claim the script contradicts, caught only for size tokens. |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + reader pointer present; re-fetched every run; P11/P11b red. Second URL/date remain residuals (no R4 counterfactual). |
| **R5** — first screen answers three questions, probed | SHIPPED | install line, docs 200, first text block byte-identical to a live render; P3/P4 red. Blocks 2–3 remain a residual (outside "top screen"). |
| **R6** — the record says what happened | PARTIAL | The structural rule works: H_GUARD, H_VOCAB, E15, E16, N9 all red with `traction claim quoting no number`; P10 red when the pointer goes. **Counterfactual still green:** a traction line quoting a **non-R2** number (`99 likes`, X_TRACTION_DIGIT) — the rule demands *a digit*, R6 demands *an R2 number*. Trigger-vocabulary gaps are residuals (declared unsatisfiable in pass 5). |
| **Step-5 scripts** | SHIPPED | `bash -n` 0/0; **gate exit 0 ×3 consecutive (10/10 each)**; demo **exit 0, 6/6**; rows probed. |
| **Summary presence** | SHIPPED | present, unmodified by `9fc5226`; structural greps only. |
| **`.ai` sync** | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` PASS on merit. |
| **Closeout gate** | SHIPPED | bare **15/2** (only `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; waived → **exit 0, 17/17**, reason recorded. |

## Count
**6 of 10 SHIPPED** (R4, R5, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1, R2, R3, R6. NOT-BUILT: none.

## Residuals (carried + new)

| Item | Status |
|---|---|
| pass-1: closeout `roadmap-references-N` | **CLOSED** (PASS on merit; 17/17 waived) |
| pass-1: `sessions/session-48-review.md` absent | **REMAINS** — owed; this document is it |
| pass-1/2: `required-crew` needs the standing waiver | **REMAINS (standing)** — 15 verified + 2 waived |
| pass-1–5: every previously named ground (P1c/P1f, breadth, fail-closed, N1–N11, E3/E4/E5/E7/E10/E15/E16/E18, H_LIC/H_LIC2/H_VER/H_ALTURL/H_ZERO/H_ZERO2/H_BUNDLE/H_GUARD/H_VOCAB) | **CLOSED and re-proved this pass** |
| pass-5: bash-3.2 crash in `record-honest` | **CLOSED** — three consecutive exit-0 runs, no RC 133/134 |
| pass-5: `888 stars`, marker-table backtick, second URL/date, forged `rows=`, `2.73e2` | **unchanged — RESIDUALS** (H_TABLEK, H_URL2/H_DATE2, H_FORGEROWS, X_SCI-equivalent) |
| pass-1: `gtm-reads` omits zero days from `day` lines | **REMAINS, immaterial** |
| pass-1: clean-clone RED without install+build | **REMAINS by design** |
| pass-1: 23-vs-20 judgement only in a comment | **REMAINS** (call verified correct) |
| pass-3: README blocks 2–3 never drift-checked | **REMAINS — RESIDUAL** |
| pass-3: CHANGELOG `## [0.4.0]` substring check | **REMAINS — RESIDUAL** |
| pass-4: ledger allow-list is package-agnostic | **REMAINS — RESIDUAL** |
| **NEW** | trigger-vocabulary for the traction rule can never be complete (`Adoption doubled this week.` green) — **RESIDUAL**, contract-design; I prescribed and they shipped the structural half |
| **NEW** | false positive: a *denial* without digits trips the traction rule (`No organic signal yet.` → red) — **RESIDUAL** |
| **NEW** | free-text/fence count phrasings (`// 99 charts available`) unchecked — **RESIDUAL** (unbounded prose) |
| **NEW** | downloads badge on README falls between R2's `.ai/` scope and R6's summary scope — **RESIDUAL** |
| **NEW** | `.ai/AGENTS.md` figure unchecked — **RESIDUAL** (governed file; covered by the smuggle invariant) |
| **NEW** | `fidelity-review-accept` still satisfiable by waiver rather than by the file — **RESIDUAL** (gate design) |

**Verdict:** **REJECT**

Five passes of grounds are closed and re-proved: all nine pass-5 grounds red with the diagnosis named, the full 44-stimulus set holds (P0 green, 43 red), every exemption survives, the gate is stable across three consecutive exit-0 runs, closeout is 17/17 with `roadmap-references-N` green on merit, and every invariant holds.

REJECT rests on **six contract-written counterfactual instances still green**, each labelled GROUND above:

- **R1 — "Every count and version on `README.md` … red on the first disagreement" / "Shield badges count as claims"** (2): `release-9.9.9` badge on a `0.4.0` package (X_REL_BADGE); `static/v1?label=license&message=Apache` badge (X_STATIC_LIC) — the very format they added this pass for charts, deps and tests, minus license.
- **R2 — "a downloads figure in `.ai/` that the API does not return right now → red"** (2): `0 downloads in October 2026 (… since 10-05)` (X_ZERO_WINDOW — an unrelated window token on the line buys the zero), and `999 downloads` in `.ai/handoffs/*.md` (Y_HANDOFF — literal `.ai/` scope, the weakest of the six).
- **R3 — "a benchmark number with no command → red"** (1): `| **Renders in 500 ms** |` outside the table (Y_TIME) — R3 names render-time as one of its four numbers; only *size* tokens were added to the outside-scan.
- **R6 — "claiming traction with no R2 number beside it → red"** (1): `Milestone: our first user arrived — 99 likes on the post.` (X_TRACTION_DIGIT) — the rule requires a digit, the contract requires an **R2** number.

All six are finite fixes on surfaces already half-built: add `badge/release-` and `label=license&message=` to the existing `every_equals` list; require a zero's line to state the window *and* to carry no competing period (or verify the zero against the API for the window it names); scan time tokens outside `## Benchmarks` the way size tokens now are; add `.ai/handoffs/*.md` to the scanned set (or narrow the contract's wording); and require a traction line's figures to be in the instrument-printed set — a whitelist `record-honest` already runs three lines below.

Everything else I could construct is either a control that stays red, a deliberate exemption the contract needs, or a residual listed above — including the two classes I myself declared unsatisfiable (trigger-vocabulary and free-text phrasing), which I am not using to drive this verdict.

**Review-Inputs-SHA:**
`ef3ff87ee60e4ba09c7f8fb70ae0b05f8b38c46a84e247ad25b203b76e732b8a`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (checked after every probe batch and at the end). All mutations restored byte-identically; no `sessions/session-50-*`, no probe/stash files, no debris in the repo — review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 7)

## What landed since pass 6 (verified by me)

`6c91fde` — **two scripts** (`verify-session-48.sh` +131/−?, `demo-session-48.sh` +70/−?), inside the 3-file cap. Delivery **22 commits**, all `S48:`; 15 delivery files, none under `packages/`; contract exactly 1 commit.

Code read in full for the changed parts:

- **R1** — four more `every_equals` surfaces: `badge/release-[0-9A-Za-z.]+` (both files) and `label=license&message=[A-Za-z0-9.-]+` (both files). Total surfaces now 21.
- **R2** — new `zero_claim_total()`: a zero is **re-derived** — the window the *line itself* claims (named month → that month; `since launch|lifetime|all time|so far` → `2026-09-15..today`; explicit `MM-DD`/`YYYY-MM-DD` → sum those days) is queried against the downloads API; `0` passes, anything else reports `API returns N for the window this line claims`, and an unparseable window is `zero whose window the line never states`. Lines carrying `re-probe|re-derived|before its publish` keep their historical exemption. `.ai/handoffs/*.md` joined the scanned set (`for hf in .ai/handoffs/*.md`).
- **R3** — a **time-token** scan outside `## Benchmarks` (`ms|msec|milliseconds|seconds|s`), compared against the declared `render-budget-ms`, with `*seco*` tokens multiplied by 1000.
- **R6** — the traction rule now needs a number **the instruments print**: `READS_SET` is built lazily from two `gtm-reads` runs plus STATE's `t0`/`t1`, and every digit on a traction sentence must be in it (`traction number '99' no instrument prints`). Lines starting with `|` are exempt from this *sentence* rule (their citations aren't claims); their downloads figures stay under the figure rule.

**Stability — three consecutive gate runs:**

| Run | exit | result |
|---|---|---|
| 1 | **0** | `10 pass, 0 fail` |
| 2 | **0** | `10 pass, 0 fail` |
| 3 | **0** | `10 pass, 0 fail` |

`bash scripts/demo-session-48.sh` → **exit 0, 6/6** (0 `NOT PROVEN`). Syntax: `bash -n` ×2 → **0**, `node --check` ×2 → **0**. No crash, no RC 133/134, no empty output. A fourth full-scope run after all probing also exited **0**.

**Closeout:** bare → **15 pass / 2 fail** (exactly `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; with `VAJRA_CLOSEOUT_WAIVER=48` + the prescribed reason → **exit 0, `ALL GREEN (17 pass, 0 fail)`**, reason recorded.

**Invariants:** 22 commits → 11×1 file, 8×2, 3×3, **zero breaches**; smuggle diff (`.ai/AGENTS.md`, `packages/`, `pnpm-lock.yaml`, `.github/workflows/`) → **empty**; contract exactly **1** commit; `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` → `no packages/core/src or lockfile change in delivery`; instruments re-run by me → `gtm-reads --as-of 2026-10-03` = `total=119`, `--as-of 2026-10-06` = `total=273`, `release-shaped-total=243`, `non-release-total=30`; `gtm-bench` = `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 rows=Runtime dependencies|npm install download|Installed footprint|Render a 100-point line chart verdict=within render budget`.

**Contamination controls:** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed (line counts, digit extraction from two named lines, `TRACT`-keyword count over `^|` rows, my own planted lines to prove mutations applied). No writes in the repo except gitignored `.ai/verify/**`.

**Tooling incidents:** none. Every probe batch ran sequentially; one batch timed out mid-run (11 probes > 10 min) and was simply resumed — no mutation was left un-restored, `git status --porcelain` empty throughout.

## Stimulus re-runs

**A. The six pass-6 grounds — all now RED (diagnosis quoted):**

| Ground | exit | Diagnosis line |
|---|---|---|
| X_REL_BADGE `release-9.9.9` badge | 1 | `contradicting claim(s): README-release-shield` |
| X_STATIC_LIC `label=license&message=Apache` | 1 | `contradicting claim(s): README-static-license` |
| X_ZERO_WINDOW `0 downloads in October 2026 (… since 10-05)` | 1 | `…: .ai/STATE.md:'0 downloads' (API returns 169 for the window this line claims)` |
| Y_HANDOFF `999 downloads` in `.ai/handoffs/session-46-tech-lead.md` | 1 | `…: .ai/handoffs/session-46-tech-lead.md:'999 downloads'` |
| Y_TIME `\| **Renders in 500 ms** \|` outside the table | 1 | `README carries a timing claim no command prints: '500 ms' (budget is 2 ms)` |
| X_TRACTION_DIGIT `99 likes` | 1 | `…(traction number '99' no instrument prints)` |

**B. The accumulated red set — 53 stimuli: P0 green, the other 52 red.**

| Group | Result |
|---|---|
| **P0 baseline (exemptions)** | **exit 0, `RED=[]`** |
| P1, P1b, P1d, P1e, P1g (5) | 1 ×5 — `README-badge-url('21'≠20)`, `README-prose`, `docs hero drifted…` (`> 21 Chart types`), `KNOWLEDGE-charts`, `README-deps-url('1'≠0)` |
| P2, P2b | 1 ×2 — `tests badge disagreeing with the suite: '452' / '999' (suite printed 453)` |
| P3, P4 | 1 ×2 — `README example has drifted from a real render:` (`> │ TREM …`), `README has no install command for a stranger` |
| P5, P6 | 1 ×2 — `STATE says t1=274 … instrument says '273'`, `STATE says t0=119 … instrument says '115'` |
| P7, P8 | 1 ×2 — `README tarball row ≠ measured 81.5 KB`, `README does not show the command…` |
| P9, P10 | 1 ×2 — `…: .ai/STATE.md:'500 downloads'`, `roadmap's pack row has no evidence pointer` |
| P11, P11b | 1 ×2 — `STATE records no post URL`, `…-XXXX/ → 404 (expected 200)` |
| pass-2 seven (NEW-A…FAIL-OPEN) | 1 ×7 — badge `200`, renderers `13`, ledger zero-claim, ledger `888`, KNOWLEDGE `999`, ROADMAP zero-claim, `live file missing: .ai/CONTINUATION-PROMPT.md` |
| pass-3 N1…N11 (11) | 1 ×11 — deps URL/cell, core license/deps, `README-charts-badge-x1`, `1,119`, ledger `888`, table `999`, summary traction ×2, `Benchmarks table carries value(s) no command prints: '500 ms'` |
| pass-4 E3…E18 (8) | 1 ×8 — `README-shield-charts`, suite `'999'`, `coreREADME-chart-types`, `README-prose-count`, `'0.8k downloads'`, summary traction ×2, row-order mismatch |
| pass-5 H_LIC…H_VOCAB (9) | 1 ×9 — `README-license-alt`, `core README License block(s) disagreeing: 'Apache-2.0'`, `README-version-alt README-version-shield`, `README-static-charts`, `API returns 169 …`, `API returns 273 …`, `size claim no command prints: '5 MB'`, summary traction ×2 |

**C. Exemptions still GREEN (present in the tree P0 read):** summary `` `500 downloads` `` ×2 in counterfactual table rows; STATE `119 lifetime downloads` ×1 and `0 downloads on 10-05 and 10-06` ×1 — **and I fetched the API myself: `2026-10-05:2026-10-06` → `[{0,"2026-10-05"},{"0","2026-10-06"}]`, so that zero is genuinely API-verified, not pattern-matched**; ROADMAP `downloads are 0 for the 9 days before its publish` ×1 and `superseded — false since S45` ×1; ledger `119 downloads`, `304 downloads`, `318`, `75/17/12/181/19`, `downloads/range/2026-09-15:2026-09-28`; CONTINUATION `273 downloads` ×1.

**Numbers I saw accepted on the summary's two guard prose lines** (structural digit extraction): line 56 `2. **273 downloads, none organic, and the last two days are flat zero**` → digits **2, 273, 0, 4, 0**; line 57 `spike (154 on 10-04) is our own release` → digits **154, 10, 04**. Every one of them is in `READS_SET` (which I reconstructed: `0 01 02 03 04 06 09 10 15 154 2 2026 243 273 29 3 30 4 5 6 89 119` — the union of both `gtm-reads` runs plus STATE's t0/t1). No legitimate line broke.

## New holes hunted (GROUND or RESIDUAL)

Every mutation was printed back from the file before the gate ran, then restored; all eight greens were re-applied afterwards and their lines echoed to prove they were real.

| # | Stimulus | Mutation verified | exit | Label |
|---|---|---|---|---|
| Z_STATIC_VER | `[![v](https://img.shields.io/static/v1?label=version&message=9.9.9)]` | line 231 present | **0** | **GROUND (R1)** — a shields badge displaying **version 9.9.9** on a `0.4.0` package. R1: "Every count **and version** on `README.md` … red on the first disagreement"; "Shield badges count as claims." The static format was added this pass for `license` but not `version` |
| Z_VER_SHORT | `[![v](https://img.shields.io/badge/ver-9.9.9-blue)]` | line 232 present | **0** | **GROUND (R1)** — same, via `badge/ver-`. They check `badge/version-` and `badge/release-`; the badge still says 9.9.9 and nothing compares it |
| Z_BADGEN | `[![v](https://flat.badgen.net/npm/v/@ifelse.codes/chitra/9.9.9)]` | line 233 present | **0** | **GROUND (R1)** — a version claim on README from another provider. No synonym list is needed: one finite rule covers all three above — *every `x.y.z` triple inside an image URL must equal the manifest version* |
| Z_SECONDS | `\| **Renders in 2 s** \| Snappy enough. \|` outside `## Benchmarks` | line 234 present | **0** | **GROUND (R3)** — counterfactual *a benchmark number with no command → red*. The time scan converts only `*seco*` tokens; a bare `s` is compared as milliseconds, so **2 s = 2000 ms passes a 2 ms budget**. One-line fix: treat `s`/`S` as seconds (or reject non-ms units) |
| Z_BYTES | `\| **Ships in 500000 bytes** \| Minimal. \|` outside `## Benchmarks` | line 235 present | **0** | **GROUND (R3)** — R3 names **bundle size and install footprint**; the script prints `tarball-bytes=83496 / unpacked-bytes=407961`. The unit list is `MB\|KB\|kB\|GB\|Gb` — `bytes` is invisible, so a size claim the instrument contradicts stays green |
| Z_TRACTION_DATE | summary `Milestone: our first user arrived on 2026-10-06.` | line 92 present | **0** | **GROUND (R6)** — counterfactual: *claiming traction with no **R2 number** beside it → red*. `READS_SET` is built with `grep -oE '[0-9]+'` over `gtm-reads` output, so it contains **date parts** (`2026`, `10`, `06`, `09`, `15`…) — not readings. The line quotes no R2 figure and passes. Fix: build the set from *values* (`total=`, `day … N`, `release-shaped-total=`, `non-release-total=`, t0/t1), not from every digit |
| Z_TRACTION_ROW | summary `\| adoption \| Adoption is taking off in every channel \| record-honest \|` | line 93 present | **0** | **GROUND (R6)** — that cell **is a sentence** (subject, verb, claim) claiming traction with no R2 number, exempted only because the line starts with `|`. **Challenging the scope decision as invited:** the exemption protects citations, but citations carry no `TRACT` keyword — and I traced the fix: after the *same backtick scrub the figure rule already applies*, your own R6 row keeps digits `6 48 119 273 2` and **zero** `TRACT` keywords (structural grep), so scrubbing rows and then applying the sentence rule keeps P0 green *and* catches this cell |
| Z_TRACTION_R154 | summary `Milestone: 154 likes on the post.` | line 94 present | 0 | **RESIDUAL** — `154` **is** an R2 reading (10-04's downloads), so the counterfactual's condition ("no R2 number beside it") is not met. Quoting a real number for the wrong thing is sloppy, not a written counterfactual |
| Z_FUTURE | STATE `- Adoption: 0 downloads in January 2027.` | applied | 1 | control — `(API returns ERR for the window this line claims)`; the API refuses future ranges and the code fails closed |
| fast scope | `VAJRA_GATE_SCOPE=fast bash scripts/verify-session-48.sh` | — | 1 | control → **RESIDUAL**: `claims-match-truth` fails with `README tests badge(s) disagreeing value(s): '453' (expected )` because `SUITE_N` is only set by `core-suite-green`, which `FAST_SKIP` skips. A *false red* in the optional scope (default/full scope exits 0, re-verified). Not a counterfactual — no contract text requires fast scope green — but the FAST_SKIP list and the new suite dependency are now inconsistent |
| handoff glob | code read + `session-46` proved red above | — | — | `.ai/handoffs/*.md` is globbed (every `.md` at that level); one file proved red, no subdirectories exist |

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | Pass-6 grounds red (`README-release-shield`, `README-static-license`); 21 surfaces compared; 17 red probes on R1 surfaces across passes 1–5 (badges, cells, prose, hero, KNOWLEDGE, core README, CHANGELOG) all still red. **Three version-shaped badge values still green:** `label=version&message=9.9.9`, `badge/ver-9.9.9`, `flat.badgen.net/…/9.9.9` (Z_STATIC_VER/Z_VER_SHORT/Z_BADGEN) — R1 enumerates *version* on `README.md` and says badges count as claims. |
| **R2** — adoption measured, not asserted | SHIPPED | Both readings re-derive (119/273; release-shaped 243 vs 30); **zeros are now re-derived from the API** (`0 downloads in October 2026` → `API returns 169`, `since launch` → `API returns 273`, future month → `ERR`, all red); I confirmed the API really returns **0** for 10-05/10-06; `.ai/handoffs/*.md` scanned (Y_HANDOFF red); every figure probe from passes 1–6 red; all exemptions green in P0. No R2 ground found this pass. |
| **R3** — benchmarks measured | PARTIAL | Table values, row order, size-claims outside the table, command and instrument presence all bound and red on stimulus (`5 MB`, `500 ms`, `2.73e2`-style controls). **Two timing/size claims still green:** `\| **Renders in 2 s** \|` (bare `s` not converted → 2000 ms passes a 2 ms budget) and `\| **Ships in 500000 bytes** \|` (unit outside the scan) — both are numbers R3 names and the script contradicts. |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + reader pointer present; re-fetched every run; P11/P11b red. Second URL/date remain residuals (no R4 counterfactual). |
| **R5** — first screen answers three questions, probed | SHIPPED | install line, docs 200, first text block byte-identical to a live render; P3/P4 red. Blocks 2–3 remain a residual (outside "top screen"). |
| **R6** — the record says what happened | PARTIAL | The instrument-number rule works on prose: `99 likes`, guard-phrase lines, unlisted vocabulary and no-number claims are all red with their own diagnoses; P10 red when the pointer goes. **Two counterfactual instances still green:** a traction sentence whose only numbers are **date parts** (`2026-10-06`) because `READS_SET` scrapes every digit, and a traction **sentence living in a table cell** (exempt wholesale). |
| **Step-5 scripts** | SHIPPED | `bash -n` 0/0; **gate exit 0 ×3 consecutive (10/10 each)** + a fourth after probing; demo **exit 0, 6/6**; rows probed. |
| **Summary presence** | SHIPPED | present, unmodified by `6c91fde`; structural greps only. |
| **`.ai` sync** | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` PASS on merit. |
| **Closeout gate** | SHIPPED | bare **15/2** (only `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; waived → **exit 0, 17/17**, reason recorded. |

## Count
**7 of 10 SHIPPED** (R2, R4, R5, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1, R3, R6. NOT-BUILT: none.

## Residuals (carried + new)

| Item | Status |
|---|---|
| pass-1: closeout `roadmap-references-N` | **CLOSED** (PASS on merit; 17/17 waived) |
| pass-1: `sessions/session-48-review.md` absent | **REMAINS** — owed; this document is it |
| pass-1/2: `required-crew` needs the standing waiver | **REMAINS (standing)** — 15 verified + 2 waived |
| pass-1–6: every previously named ground (P1c/P1f, breadth, fail-closed, N1–N11, E3/E4/E5/E7/E10/E15/E16/E18, H_LIC…H_VOCAB, X_REL_BADGE, X_STATIC_LIC, X_ZERO_WINDOW, Y_HANDOFF, Y_TIME, X_TRACTION_DIGIT) | **CLOSED and re-proved this pass** |
| pass-5: bash-3.2 crash | **CLOSED** — three consecutive exit-0 runs |
| pass-4/5/6: marker-table backtick, second URL/date, forged `rows=`, `2.73e2`, package-agnostic ledger allow-list, README blocks 2–3, CHANGELOG substring, `.ai/AGENTS.md` figure | **REMAINS — RESIDUALS** (unchanged, outside the contract's counterfactuals) |
| pass-1: `gtm-reads` omits zero days from `day` lines | **REMAINS, immaterial** |
| pass-1: clean-clone RED without install+build | **REMAINS by design** |
| **NEW** | traction rule exempts *whole table rows* — a sentence in a cell escapes (Z_TRACTION_ROW); **GROUND**, with a traced fix that keeps P0 green |
| **NEW** | `READS_SET` contains date parts, so a date satisfies "an instrument-printed number" (Z_TRACTION_DATE) — **GROUND** |
| **NEW** | seconds unit unconverted (`2 s` passes a 2 ms budget) — **GROUND** |
| **NEW** | `bytes` outside the size scan — **GROUND** |
| **NEW** | version-shaped badge values (`label=version`, `badge/ver-`, badgen) never compared to the manifest — **GROUND** |
| **NEW** | a real R2 number quoted for an unrelated claim passes (`154 likes`) — **RESIDUAL** (the contract's condition is "no R2 number beside it") |
| **NEW** | `VAJRA_GATE_SCOPE=fast` is red because `SUITE_N` is empty when `core-suite-green` is skipped — **RESIDUAL** (false red, not a false green; default scope unaffected) |
| **NEW** | `fidelity-review-accept` still satisfiable by waiver rather than by the file — **RESIDUAL** (gate design) |

**Verdict:** **REJECT**

Six passes of grounds are closed and re-proved: all six pass-6 grounds red with the diagnosis named, the 53-stimulus accumulated set holds (P0 green, 52 red), every exemption survives — including the STATE zero, which I confirmed the API really returns as `0` for 10-05/10-06 — the gate is stable across three consecutive exit-0 runs, closeout is 17/17 with `roadmap-references-N` green on merit, and every invariant holds.

REJECT rests on **seven contract-written counterfactual instances still green**, across three requirements:

- **R1 — "Every count and version on `README.md` … red on the first disagreement" / "Shield badges count as claims"** (3): `static/v1?label=version&message=9.9.9`, `badge/ver-9.9.9`, and `flat.badgen.net/npm/v/…/9.9.9` — three badges a stranger reads as *9.9.9* on a `0.4.0` package. One finite rule closes all three: every `x.y.z` inside an image URL must equal the manifest version.
- **R3 — "a benchmark number with no command → red"** (2): `| **Renders in 2 s** |` (bare `s` compared as milliseconds → 2000 ms passes the 2 ms budget) and `| **Ships in 500000 bytes** |` (unit outside the size scan, while the script prints 83496/407961 bytes).
- **R6 — "claiming traction with no R2 number beside it → red"** (2): `Milestone: our first user arrived on 2026-10-06.` (date parts satisfy `READS_SET`, no reading quoted) and a traction sentence sitting in a table cell, exempt wholesale from the sentence rule.

On the scope decision you invited me to challenge: **I disagree with the breadth of the row exemption, and I can show the narrow version works.** Citations carry no `TRACT` keyword, so the sentence rule needs no row exemption to protect them — after the backtick scrub your own R6 fidelity row yields digits `6 48 119 273 2` and **zero** `TRACT` keywords (structural grep, quoted above), so "scrub rows the way the figure rule already does, then apply the sentence rule" keeps P0 green and catches `Adoption is taking off in every channel`.

**Review-Inputs-SHA:**
`9709059f55e34dc061807d6e26e6d03d1185a0155e05367a725df6d4a9a1d54a`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (checked after every probe batch and at the end). All mutations restored byte-identically; no `sessions/session-50-*`, no probe/stash files, no debris in the repo — review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

# Session 48 — independent fidelity review (pass 8)

## What landed since pass 7 (verified by me)

`2fc4b98` — **two scripts** (`verify-session-48.sh` +84/−?, `demo-session-48.sh` +56/−?), inside the 3-file cap. Delivery **23 commits**, all `S48:`; 15 delivery files, none under `packages/`; contract exactly 1 commit.

Code read in full for the changed parts:

- **R1 → one rule per class:** every `x.y.z` triple inside an **image URL** in either README must equal the manifest version (`image badge(s) display a version the manifest does not: … (expected 0.4.0)`). Provider-agnostic: shields static, `badge/ver-`, badgen, unseen providers alike. Absence is fine.
- **R3 → units:** a timing token that is not `ms` is treated as **seconds** (`2 s` → 2000 ms vs the 2 ms budget); `bytes|byte` joined the size scan and is compared to the exact `tarball-bytes`/`unpacked-bytes` (83496 / 407961).
- **R6 → readings, not digits:** `READS_SET` is built from *values only* — `day` field 3, plus `total`, `release-shaped-total`, `non-release-total`, `non-zero-days`, `days-since-last-non-zero`, `first-non-zero`, `last-non-zero`, plus STATE's `t0`/`t1`. A traction line needs **≥1 reading**; other digits must look like date parts (`[0-9]|[01][0-9]|[12][0-9]|3[01]|20[0-9][0-9]`). The **row exemption is gone**: table cells run the same rule after the figure rule's backtick scrub plus citation stripping (`X:219`, `S48`/`R6`, `#47`, `session-48`).
- **Fast scope:** with `core-suite-green` skipped the tests badge is compared against itself instead of an empty `SUITE_N`.

**Stability (three full runs + fast + demo):**

| Run | exit | result |
|---|---|---|
| full 1 | **1** | 9 pass / **1 fail — `channel-recorded`**: `…0U9h/ → 000000 (expected 200)` (curl could not connect within the 20 s timeout) |
| full 2 | **0** | `10 pass, 0 fail` |
| full 3 | **0** | `10 pass, 0 fail` |
| `VAJRA_GATE_SCOPE=fast` | **0** | 6 PASS + 4 SKIP (the pass-7 fast-scope residual is **closed**) |
| demo | **0** | 6/6 SHIPPED, 0 `NOT PROVEN` |
| final full run (after all probing) | **0** | 10/10 |

**Flake quantified from the artifacts** (498 gate runs carry a `channel-recorded.log` today): 14 reds are my deliberate bogus-URL probes (`nonexistent-…-XXXX → 404`), and **exactly 1 genuine failure** — `20261006T100142Z`, real URL, `000000` = connection failure. So the real-URL fetch fails about **1 in ~470** runs (≈0.2 %), always **fail-closed** (false red, never a false green). Syntax: `bash -n` ×2 → **0**, `node --check` ×2 → **0**.

**Closeout:** bare → **15 pass / 2 fail** (exactly `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; with `VAJRA_CLOSEOUT_WAIVER=48` + the prescribed reason → **exit 0, `ALL GREEN (17 pass, 0 fail)`**.

**Invariants:** 23 commits → 11×1 file, 9×2, 3×3, **zero breaches**; smuggle diff (`.ai/AGENTS.md`, `packages/`, `pnpm-lock.yaml`, `.github/workflows/`) → **empty**; contract exactly **1** commit; `pnpm --filter @ifelse.codes/chitra run test` → **exit 0**, `Test Files 23 passed / Tests 453 passed (453)`; `pnpm run typecheck` → **exit 0**; `product-untouched` → `no packages/core/src or lockfile change in delivery`; instruments re-run → `gtm-reads` 119 / 273 (release-shaped 243, non-release 30), `gtm-bench` `deps=0 tarball-kb=81.5 unpacked-kb=398.4 pack-files=39 render-budget-ms=2 rows=Runtime dependencies|npm install download|Installed footprint|Render a 100-point line chart verdict=within render budget`.

**Contamination controls:** `sessions/session-48-summary.md` never read as prose — structural greps only, disclosed (digit extraction from lines 56/57, `` `500 downloads` `` count, `TRACT` keyword counts, my own planted lines). No writes in the repo except gitignored `.ai/verify/**`.

**Tooling incidents:** one probe batch hit the 10-minute shell timeout after 5 of 11 probes; I resumed with the remaining 6 — no mutation left un-restored, `git status --porcelain` empty at every checkpoint.

## Stimulus re-runs

**A. The seven pass-7 grounds — all now RED (diagnosis quoted):**

| Ground | exit | Diagnosis line |
|---|---|---|
| Z_STATIC_VER `static/v1?label=version&message=9.9.9` | 1 | `image badge(s) display a version the manifest does not: '9.9.9' (expected 0.4.0)` |
| Z_VER_SHORT `badge/ver-9.9.9` | 1 | `image badge(s) display a version the manifest does not: '9.9.9' (expected 0.4.0)` |
| Z_BADGEN `flat.badgen.net/npm/v/…/9.9.9` | 1 | `image badge(s) display a version the manifest does not: '9.9.9' (expected 0.4.0)` |
| Z_SECONDS `\| **Renders in 2 s** \|` | 1 | `README carries a timing claim no command prints: '2 s' (budget is 2 ms)` |
| Z_BYTES `\| **Ships in 500000 bytes** \|` | 1 | `README carries a size claim no command prints: '500000 bytes' (script prints 83496 / 407961 bytes)` |
| Z_TRACTION_DATE `…arrived on 2026-10-06.` | 1 | `…(traction claim quoting no reading: 2026 10 06)` |
| Z_TRACTION_ROW `\| adoption \| Adoption is taking off in every channel \| …` | 1 | `…(traction claim quoting no number: \| adoption \| Adoption is taking off in every)` |

**B. Full accumulated red set — 67 probes: P0 green, the other 66 red.**

| Group | Result |
|---|---|
| **P0 baseline (exemptions)** | **exit 0, `RED=[]`** |
| pass-1 P1…P11b (17 + P0) | 1 ×17 — `README-badge-url('21'≠20)`, `README-prose`, `docs hero drifted…`, `KNOWLEDGE-charts`, `README-deps-url('1'≠0)`, suite `'452'`/`'999'`, example drift, install line missing, `t1=274`, `t0=119/10-02`, `tarball row ≠ 81.5 KB`, command missing, `'500 downloads'`, `pack row has no evidence pointer`, `no post URL`, `404 (expected 200)` |
| pass-2 NEW-A…FAIL-OPEN (7) | 1 ×7 — badge `200` (alt+url+x1), renderers `13`, ledger zero-claim, ledger `'888 downloads'`, KNOWLEDGE `'999 downloads'`, ROADMAP zero-claim, `live file missing: .ai/CONTINUATION-PROMPT.md` |
| pass-3 N1…N11 (11) | 1 ×11 — deps URL/cell, core license/deps, `README-charts-badge-x1`, `'1,119 downloads'`, ledger `'888 downloads'`, table `'999 downloads'`, summary traction ×2, `no command prints: '500 ms'` |
| pass-4 E3…E18 (8) | 1 ×8 — `README-shield-charts`, suite `'999'`, `coreREADME-chart-types`, `README-prose-count`, `'0.8k downloads'`, traction ×2, row order |
| pass-5 H_LIC…H_VOCAB (9) | 1 ×9 — `README-license-alt`, `core README License block(s) disagreeing`, `image badge(s) … '0.9.0' … (expected 0.4.0)`, `README-static-charts`, `API returns 169 …`, `API returns 273 …`, `'5 MB'`, traction ×2 |
| pass-6 X/Y grounds (6) | 1 ×6 — `README-release-shield`, `README-static-license`, `API returns 169 …`, `.ai/handoffs/…:'999 downloads'`, `'500 ms' (budget is 2 ms)`, `traction number '99' no instrument prints` |
| pass-7 Z grounds (7) | 1 ×7 (table A above) |

**C. Exemptions still GREEN in P0** — summary `` `500 downloads` `` ×2 in counterfactual rows; STATE `119 lifetime downloads` ×1 and `0 downloads on 10-05 and 10-06` ×1 (**API re-fetched by me: `{"downloads":[{0,"2026-10-05"},{"0","2026-10-06"}]}` — genuinely 0**); ROADMAP `downloads are 0 for the 9 days before its publish` ×1 and `superseded — false since S45` ×1; ledger `119 downloads`, `304 downloads`, `318`, `75/17/12/181/19`, `downloads/range/2026-09-15:2026-09-28`; CONTINUATION `273 downloads` ×1.

**Readings and date parts I saw accepted on the summary's two guard prose lines** (structural digit extraction, per line): **line 56** `2 273 0 4 0` → readings **273, 4, 0, 2** (t1, the 10-01 day total, a zero-day, `days-since-last-non-zero`), all in `READS_SET`; **line 57** `154 10 04` → reading **154** (10-04's total) plus date parts **10, 04**. Both lines satisfy "≥1 reading, remaining digits date-shaped". No legitimate line broke.

## New holes hunted (GROUND or RESIDUAL)

Every mutation was printed back from the file before the gate ran, then restored.

| # | Stimulus | Mutation verified | exit | Label |
|---|---|---|---|---|
| V1 | README prose `Latest release: [v9.9.9](https://github.com/ifelse-codes/chitra/releases).` | line 231 present | **0** | **GROUND (R1)** — a **version** stated on `README.md` that disagrees with the manifest. R1: "Every count **and version** on `README.md` … checked against the manifest … **red on the first disagreement**." The new class rule stops at *image URLs*; link **text** is unchecked. Finite fix (not a vocabulary list): both READMEs contain **zero** `x.y.z` tokens today (verified by grep), so `grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' README.md packages/core/README.md` vs the manifest is exact on this tree — the same one-rule-per-class shape they just shipped for image URLs |
| V2 | `.ai/CONSTRAINTS.yaml` → `# downloads: 999 this session` | line 99 present | 0 | **RESIDUAL** — machine-read config, not prose the record presents; consistent with my `.ai/AGENTS.md` residual (the loop writes neither the config nor the constitution, and neither is in the 15-file delivery). R2's done-condition is "where the ledger can see it", and the ledger is `GT-REMEDIATIONS.md` |
| W1 | legit `[![node](…badge/node-%3E%3D18.0.0-blue)]` | applied | 1 | **RESIDUAL** — false **red** on a legitimate badge (`'18.0.0' (expected 0.4.0)`). Over-strict, fails closed, and not exercised today: the delivered READMEs contain no version triple at all (P0 green). Cost of the class rule; scoping the triple to version-shaped labels/paths would remove it |
| W2 | size claim `**Ships in 500000 bytes**` in `packages/core/README.md` | applied | 1 *(wrong check)* | **RESIDUAL** — red came from `README tarball row ≠ measured 81.6 KB`: editing a packed file grows the tarball, so this probe cannot be isolated (same coupling I disclosed at pass-4 E5). On wording: R3 says "**the** README … the README says how" — the file that carries `## Benchmarks` and `node scripts/gtm-bench.mjs`; R1 is the only requirement that names **both** files. Outside R3's wording as written |
| W3 | `- Adoption is taking off in every channel.` in `.ai/STATE.md` | applied | 0 | **RESIDUAL** — confirmed as asked: R6's counterfactual names **the summary**; "no traction language anywhere" is requirement text, and delivered STATE carries none |
| W4 | `- Cache footprint: 273 MB on disk.` in STATE | applied | 0 | **RESIDUAL** — not a downloads figure, so R2's counterfactual (`a downloads figure in .ai/`) does not reach it |
| W5 | summary cell `\| adoption \| Adoption is taking off — ROI of 99 \| …` | applied | 1 | control — `traction number '99' no instrument prints`: citation stripping (`X:219`, `S48`, `#47`, `session-48`) does not swallow `99` |
| W6 | `Bundle size: 273 downloads of JS per page load.` in root README | applied | 0 | **RESIDUAL** — R2's counterfactual is scoped to `.ai/`; and 273 is a true reading anyway |
| V3 | `scripts/gtm-reads.mjs` renamed away under `VAJRA_GATE_SCOPE=fast` | — | 1 | control — **fails closed**: `traction claim quoting no reading: 154 10 04` / `traction number '154' no instrument prints`. With the instrument unavailable `READS_SET` collapses to STATE's t0/t1, so a real reading is rejected rather than accepted — the safe direction (answers "what happens when gtm-reads fails") |
| Z_FUTURE / X_ROWS_DRIFT / handoff plant | future-month zero, row reorder, `.ai/handoffs` figure | — | 1 / 1 / 1 | controls — `API returns ERR …`, row-list mismatch, `live file missing`-class figure catch |
| unchanged residuals re-probed | `Adoption doubled this week.` (X_TRACTION_VOCAB2), jsdelivr downloads badge (X_DLBADGE), `// 99 charts available` in a ```ts fence (X_FENCE), `Milestone: 154 likes…` (Z_TRACTION_R154) | applied | 0 | **RESIDUALS** — as labelled in passes 5/6/7: unbounded trigger vocabulary, README downloads badge between R2's `.ai/` and R6's summary scope, code-fence prose, and a real R2 number quoted out of context (the contract's condition is "no R2 number beside it", and 154 is one) |

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **R1** — front-door claims derived, not typed | PARTIAL | Pass-7 grounds red with one shared diagnosis (`image badge(s) display a version the manifest does not: '9.9.9' (expected 0.4.0)` ×3); 21 surfaces + the provider-agnostic version class; every earlier R1 probe (badges, cells, prose counts, hero, KNOWLEDGE, core README, CHANGELOG, license, deps) still red. **One named surface still green:** a version stated in README **prose** (`[v9.9.9]`, V1) — "every … version on `README.md` … red on the first disagreement". |
| **R2** — adoption measured, not asserted | SHIPPED | Readings re-derive (119/273, 243/30); zeros **re-derived from the API** (`169`, `273`, `ERR` all red); handoffs scanned; every figure probe from passes 1–6 red; exemptions intact with the API-verified `0` for 10-05/10-06. Residuals only: `.ai/CONSTRAINTS.yaml` (config), root-README figures (outside `.ai/`), `273 MB` (not a downloads figure). |
| **R3** — benchmarks measured | SHIPPED | Table values, row order, size **and** timing tokens outside the table, command and instrument presence all bound; `2 s`, `500000 bytes`, `5 MB`, `500 ms`, `Cold start`, row drift, instrument deletion all red. Residual: size claims in `packages/core/README.md` (outside R3's "the README", and not isolatable from the pack-size coupling). |
| **R4** — one channel, one link, attributable | SHIPPED | URL + `published 2026-10-06` + reader pointer; re-fetched every run (1 genuine connect failure in ~470, fail-closed); P11/P11b red. |
| **R5** — first screen answers three questions, probed | SHIPPED | install line, docs 200, first text block byte-identical to a live render; P3/P4 red. Blocks 2–3 remain a residual (outside "top screen"). |
| **R6** — the record says what happened | SHIPPED | The reading rule works in prose and in cells: `99 likes`, date-only numbers, guard-phrase lines, unlisted vocabulary, no-number claims and my table-cell sentence are all red with their own diagnoses; P10 red when the pointer goes; every exemption green. Residuals only: trigger-vocabulary breadth (declared unsatisfiable), fence prose, a real number quoted out of context, STATE (outside the counterfactual's scope). |
| **Step-5 scripts** | SHIPPED | `bash -n` 0/0; **2 of 3 consecutive full runs exit 0, 10/10** (run 1 lost only to the LinkedIn connect flake, quantified above); fast scope **exit 0 (6 PASS + 4 SKIP)** — pass-7's fast residual **closed**; demo **exit 0, 6/6**. |
| **Summary presence** | SHIPPED | present, unmodified by `2fc4b98`; structural greps only. |
| **`.ai` sync** | SHIPPED | `.ai/SESSION` = `48`; `session-boot-current`, `task-ref-current`, `session-prompt-summary-pair`, `state-required-sections`, `required-files-exist` PASS on merit. |
| **Closeout gate** | SHIPPED | bare **15/2** (only `fidelity-review-accept` + `required-crew`), **`roadmap-references-N` PASS on merit**; waived → **exit 0, 17/17**, reason recorded. |

## Count
**9 of 10 SHIPPED** (R2, R3, R4, R5, R6, step-5 scripts, summary presence, `.ai` sync, closeout gate). PARTIAL: R1. NOT-BUILT: none.

## Residuals (carried + new)

| Item | Status |
|---|---|
| pass-1: closeout `roadmap-references-N` | **CLOSED** (PASS on merit; 17/17 waived) |
| pass-1: `sessions/session-48-review.md` absent | **REMAINS** — owed; this document is it |
| pass-1/2: `required-crew` needs the standing waiver | **REMAINS (standing)** — 15 verified + 2 waived |
| pass-7 fast-scope false red (`SUITE_N` empty) | **CLOSED** — `VAJRA_GATE_SCOPE=fast` now exit 0 |
| pass-1–7: every previously named ground (67 probes re-run) | **CLOSED and re-proved this pass** |
| pass-1: `gtm-reads` omits zero days from `day` lines | **REMAINS, immaterial** |
| pass-1: clean-clone RED without install+build | **REMAINS by design** |
| pass-3/4: README blocks 2–3, CHANGELOG substring, package-agnostic ledger allow-list | **REMAINS — RESIDUALS** |
| pass-4/5/6: marker-table backtick, second URL/date, forged `rows=`, `2.73e2`, `.ai/AGENTS.md` figure, `154` out of context | **REMAINS — RESIDUALS** |
| **NEW** | **V1 — version stated in README prose (`[v9.9.9]`) is green** — **GROUND (R1)** |
| **NEW** | legitimate `node-18.0.0` badge would be **red** (over-strict, fail-closed, unexercised on this tree) — **RESIDUAL** |
| **NEW** | size/time/figure claims in `packages/core/README.md`, `.ai/CONSTRAINTS.yaml`, root README prose — **RESIDUALS** (outside R3's "the README", R2's `.ai/` prose record, and R2's figure wording respectively) |
| **NEW** | LinkedIn fetch flaked **1 in ~470** real-URL runs (`000000`, connect failure), always fail-closed — **RESIDUAL** (reliability, not a false green) |
| **NEW** | `fidelity-review-accept` still satisfiable by waiver rather than by the file — **RESIDUAL** (gate design) |

**Verdict:** **REJECT**

Seven passes of grounds are closed and re-proved: the full 67-stimulus accumulated set holds (P0 green, 66 red), all seven pass-7 grounds now share one class-level diagnosis (`image badge(s) display a version the manifest does not`), the unit and reading rules hold (`'2 s'`, `'500000 bytes'`, `no reading: 2026 10 06`, my table-cell sentence all red), every exemption survives with the API-verified `0` for 10-05/10-06, closeout is 17/17 with `roadmap-references-N` green on merit, fast scope is now green, and every invariant holds.

REJECT rests on **one contract-written counterfactual instance still green**:

- **R1 — "Every count and version on `README.md` and `packages/core/README.md` … checked against the manifest … red on the first disagreement"** (1): `Latest release: [v9.9.9](…)` — a version **stated in README prose** (V1). The new class rule covers every `x.y.z` inside an *image URL*; the same triple in link text is unchecked, and it disagrees with `0.4.0`. This is the same claim *type* (version) whose three badge surfaces you closed this pass — the fourth surface is text, and it is finitely checkable: both READMEs contain **zero** version-shaped tokens today, so one `grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+'` over the two files against the manifest is exact on this tree (no vocabulary list, no engine-version allow-list needed unless one is ever added to the README).

Everything else I could construct is either a control that stays red (future-month zero, row reorder, handoff figure, `ROI of 99`, instrument unavailable) or a labelled residual — including the four classes I myself declared unsatisfiable, the over-strict cases that fail closed, and the single network flake. None of them drives this verdict.

**Review-Inputs-SHA:**
`2cbcdb6f812d310ae02a5afd0c8a206041f4e4fe547136f73cae7109f75d258d`

(matches the required value; `bash scripts/verify-closeout.sh --inputs-sha 48` → exit 0.)

---

**Hand-off state:** `git status --porcelain` → **empty** (checked after every probe batch and at the end). All mutations restored byte-identically; no `sessions/session-50-*`, no probe/stash files, no debris in the repo — review artefacts live only under `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/opencode/`.


---

