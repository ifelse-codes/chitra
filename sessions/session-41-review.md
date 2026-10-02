# Session 41 — cold adversarial fidelity review (EIGHTH and FINAL attestation pass)

**Reviewer:** the same independent reviewer. Narrow attestation of `0445fc5`, `d87d167`, `9fdb8e4`.
**Contract:** `prompts/41-task-repo-cleanup.md`. **Delivery as committed:** HEAD **`9fdb8e4`**,
33 commits. Working tree clean apart from this review artifact.

---

## Method controls

- **Two cold inputs only:** the contract and the committed diff. I read no `.ai/` prose; `.ai/`
  files under test were probed with counts, pattern matches and replayed check expressions.
- **The counterfactuals ran against the shipped code, not a retype.** I extracted the body of
  `contributing-coverage-numbers-real` out of `scripts/verify-session-41.sh` with an awk helper,
  confirmed it with `bash -n`, and executed that extracted file. Nothing I typed became evidence.
- **Restoration guaranteed and verified.** `CONTRIBUTING.md` was backed up outside the repo, a
  `trap` restored it on every exit path, and afterwards `git diff --stat CONTRIBUTING.md` is
  **0 lines** with 0 modified and 0 staged files.
- **Read-only otherwise.** Nothing fixed, nothing committed.

---

## What passes 7 and 8 verified, and how

### The two gates

| Gate | Result |
|---|---|
| `bash scripts/verify-session-39.sh` | **ALL GREEN (43 pass, 0 fail)** — run by me at `9fdb8e4` |
| `bash scripts/verify-session-41.sh` | **ALL GREEN (24 pass, 0 fail)** — run by me at `9fdb8e4`, including `fresh-clone-build-no-env`, `test-count-propagated` and `contributing-coverage-numbers-real` |

I also evaluated the two halves of the count guard **directly** rather than inferring them from the
suite: idiom clauses → *none failing*; discovered set → *MATCH (11 sites)*. Both halves green at
`9fdb8e4`, so pass 7's regression is genuinely closed.

### Claim 1 — the coverage check compared each published figure against itself

**The fix is real, and I proved it three ways.**

In the shipped code the measured values are captured into named variables *before* the published
values overwrite the positional parameters:

```
 18	  set -- $nums
 19	  e1=$1; e2=$2; e3=$3; e4=$4
 20	  pub=$(grep -oE "[0-9]{2}\.[0-9]{2}(–[0-9]{2}\.[0-9]{2})?" CONTRIBUTING.md | head -4 | tr "\n" " ")
 21	  set -- $pub
```

Line 28 then indirect-references the captured `e1..e4` via `m=$(eval echo \$e$i)`, so the two
sides of every comparison are now genuinely different values. The old shape — derive `got` from a
single `$@` that a later `set -- $pub` had overwritten — would have compared each published
figure with itself and passed unconditionally.

**Behavioural proof, against the extracted shipped body:**

| test | published figures the check reads | outcome |
|---|---|---|
| real state | `96.11 87.63–87.64 86.28 96.11` | **PASS** — `publishes figures within one hundredth of measured (96.11 87.63 86.28 96.11)` |
| gross rot, **position 1** (statements `96.11` → `12.34`) | `12.34 87.63–87.64 86.28 96.11` | **FAIL, exit 1** — `CONTRIBUTING figure 1 (12.34) does not match the measured 96.11.` |
| gross rot, **position 2** (branch `87.63–87.64` → `87.00`) | `96.11 87.00 86.28 96.11` | **FAIL, exit 1** — `CONTRIBUTING figure 2 (87.00) does not match the measured 87.64.` |
| after restore | `96.11 87.63–87.64 86.28 96.11` | **PASS** |

Both rotations flag, each naming the correct figure position and the correct measured value, and
the tree returned to pristine. Note that in the position-2 run the measurement read **87.64** — the
bimodality again, absorbed by the tolerance rather than by luck.

### Claim 2 — the premise was wrong too

**CONFIRMED, and the fix is the one I asked for.** `CONTRIBUTING.md:139-145` now publishes

> **96.11 / 87.63–87.64 / 86.28 / 96.11**

and documents the bimodality in prose: *"Branch coverage is genuinely bimodal at ±0.01 — eight
identical runs split 4–4 between 87.63 and 87.64, with no TTY, environment, clock or random
dependence anywhere in `src/`. It is v8's collection, not the code. The check allows one hundredth;
publish a single value and the gate is a coin flip."*

That matches my own measurements exactly (8 observations, 4–4) and my `src/` probe (0 files using
`Math.random` / `Date.now`). The check's tolerance is `awk … exit !(d <= 0.0101)` applied to **both
ends of a published range** — one hundredth, as specified — and a failure names the figure index.
A coin-flip gate has been replaced by a deterministic one.

I also credit an improvement I did not ask for: the loose
`9[0-9]\.[0-9]+ / …` proxy has been **removed** from `contributing-claims-true` — the weak pattern
match I criticised in pass 1 — with a comment deferring to the measuring check. The suite now has
one real check for coverage numbers instead of two, one of which was a fiction.

### Claim 3 — the closeout-prose drift fixed at the source

**CONFIRMED, and fixed in the prose rather than by loosening anything.**

- `.ai/CONTINUATION-PROMPT.md` reads `**453 green**` again, so the idiom clause is satisfied.
- `.ai/TASK.md` no longer carries a count at all (it now says "the core suite is green"), so it
  left the discovered set and the inventory matches at 11 sites.
- Both files also stopped naming `verify-session-39.sh` beside another score: the S41 gate's score
  was reworded `24/24` → "24 checks" / "24 of 24". I replayed S39's own `ai-docs-quote-real-score`
  expression across all five `.ai/` files it inspects and every one is **OK** — its rule is that a
  line naming the script may carry only `43/43`, and `24 of 24` has no slash, so it does not match
  the `NN/NN` pattern. My first probe flagged those lines; it was too coarse, and the builder's
  rewording is what satisfies the rule.
- **`scripts/verify-session-39.sh` is not in these three commits.** The regression guard itself was
  never touched — which is precisely "fixed at the source, not by loosening the check".

### Claim 4 — nothing else moved

**CONFIRMED.** `git diff 0285416..9fdb8e4 --stat` is six files: four `.ai/` prose files,
`CONTRIBUTING.md`, and `scripts/verify-session-41.sh`. No library code, no test code, no
`package.json`, no `tsconfig`, no workflow, no lockfile. Check count is 24.

---

## Per-requirement verdicts (17 rows)

Pass 5's adjudication stands. **X1 recovers** from the regression pass 7 recorded, on direct
evidence rather than on the suite alone: both halves green at `9fdb8e4`.

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Docs meta not the scaffold placeholder, in source **and** built page | **SHIPPED** | `index.html:6-14`; check greps source and built artifact; the replacement copy's factual claims audited true. |
| 2 | `VERSION` derived from `package.json`; no `0.1.0` in built `dist`; a test asserts `VERSION === pkg.version` | **SHIPPED** | Generated `version.ts` + CI `--check`; the test lives in the existing `composability.test.ts`; suite 453 / 23 files. |
| 3 | npm README: no design log; default `braille`; renderer count matches bullets | **SHIPPED** | 785 → 122 lines; `LOCKED:` 0; `types.ts:1` = 3 renderer values. |
| 4 | Five CONTRIBUTING falsehoods true; coverage claim states measured reality | **SHIPPED** | Five fixes present. The coverage clause is now **measured and compared** rather than pattern-matched, with gross rot proven to flag in positions 1 and 2 — the strongest evidence any row in this delivery has. |
| 5 | `pnpm example` runs `examples/basic.ts` and exits 0 | **SHIPPED** | `package.json:11`; ran it, exit 0, renders. |
| 6 | `replit.md` matches `ci.yml`; interface list matches `types.ts` | **SHIPPED** | Node 26 vs `ci.yml:20`; list = `types.ts:231-240`. |
| 7 | `release.yml` provenance comment true in **both** repo states | **SHIPPED** | `release.yml:98-107`; registry-verified (`dist.signatures` present, no `attestations`). |
| 8 | No public doc points into `.ai/` | **PARTIAL** | The named file is fixed; `AGENTS.md:3,5` and `CLAUDE.md:3,5` still direct readers into `.ai/AGENTS.md`, and the check reads three files. These are exactly the files founder decision **D1** governs, recorded unanswered — a decision this contract explicitly does not make, so it is not the builder's to close. |
| 9 | **Every** `.ai/` file describes S41, on this branch, now | **SHIPPED** | All five Files-column files touched and guarded; stale S40 phrase and dead branch name gone. |
| 10 | Root build order fixed; fresh clone with no env exits 0 | **SHIPPED** | `package.json:7`; `fresh-clone-build-no-env` PASS; my pass-1 counterfactual reproduced `TS2307` on revert. |
| 11 | Both vite configs default `PORT`/`BASE_PATH`; CI still overrides | **SHIPPED** | `?? "5000"` / `?? "/"`; proven by the green fresh-clone gate. |
| 12 | `lib/integrations/*` glob removed; install still resolves | **SHIPPED** | Line removed, dir absent; check provably failable since pass 1's rewrite. |
| 13 | Path-bearing + stale files deleted; undecided ones gitignored | **SHIPPED** | Five targets absent and never tracked; undecided set ignored and still on disk; `git status` clean of junk. |
| **X1** | Cross-cutting count: propagation, a guard, S39 43/43 | **SHIPPED** *(recovered)* | Inventory discovered from the tree and provably failable both directions; idiom clauses all satisfied; 11-site set matches; **S39 `ALL GREEN (43 pass, 0 fail)`**; the pass-7 regression (closeout prose breaking both halves of the guard) is closed at the prose source with `verify-session-39.sh` untouched. |
| **X2** | Assumption 1 (Batch 1 only), Assumption 2 (no flip, D1 open) | **SHIPPED** | Zero deletions; no Batch 2/3/4 work; D1–D6 unanswered and recorded. |
| **X3** | Out-of-scope constraints held | **SHIPPED** | `src/charts/**` untouched; these three commits changed no library code. |
| **X4** | Closeout deliverables | **SHIPPED** | S42–S44 on the roadmap; next-session options; `.ai/` synced; fidelity map committed; this review exists. |

**Count: 17 rows — 16 SHIPPED, 1 PARTIAL, 0 NOT-BUILT.**

---

## The fakest green

**There isn't one, and I am not going to manufacture a fifth.** I went looking with the specific
intent of finding something load-bearing, and what I found instead:

- The published-figure extraction is **unanchored and positional** (`head -4` over the whole
  file). If an earlier `NN.NN` ever appeared in `CONTRIBUTING.md`, it would capture the wrong four
  tokens — but the comparison would then **fail loudly and red**. It cannot produce a false green.
  Cosmetic robustness, not a hollow check.
- The `±0.01` tolerance means a genuine one-hundredth drift in *branch* coverage specifically would
  be absorbed. That is the closest thing to a real weakness here, and it is a **deliberate,
  documented trade** on the one figure proven bimodal, chosen over a gate that flips on a coin.
  Bounded, honest, and the alternative is worse.
- The six public counters nobody verifies — `20 charts`, `7 themes`, `3 renderers`, `0 deps`
  (README badges, `App.tsx` hero, `index.html` meta, the npm README, `replit.md`) — are all
  **true today** and outside the contract's scope, which named the test count only. That is
  remaining rot surface, not a false green, and the discovery pattern now in the repo would
  generalise to them in a few lines if a later session wants the class closed.

Pass 3's fakest green (`test-count-propagated` claiming "consistent everywhere it is displayed"),
pass 4's (`THIS CLAUSE LIST IS THE INVENTORY`), pass 7's Finding A (the guard shipping red) and
pass 7's Finding B (a bimodal comparison) are all genuinely dead. What I have left is a delivery
whose checks fail when they should, pass when they should, and say only what they do.

---

**Verdict:** ACCEPT

Faithful, and faithful in the way that matters rather than the way that prints well. All four
claims were verified rather than believed, and the one that mattered most — that the coverage
check had been comparing each published figure against itself and could therefore never fail — I
proved dead twice, against the extracted shipped body, by rotating gross rot into positions 1 and
2 and watching each flag with the correct figure index and the correct measured value. The
bimodality premise is real, is documented in the public file it affects, and is now handled by a
one-hundredth tolerance instead of a coin flip. The closeout-prose drift that made the count guard
red in pass 7 was fixed in the prose, with the S39 regression guard never touched. Both gates are
green on the numbers they claim — 43/43 and 24/24 — and the working tree is exactly as I found it.
Sixteen of seventeen rows SHIPPED; the seventeenth is founder decision D1, recorded as open by the
contract that created it.

**Review-Inputs-SHA:** b627800077574435b04ba2433e78738ab3e72650b5f5381e676442665e5037f4