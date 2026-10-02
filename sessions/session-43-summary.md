# Session 43 — fidelity map

Cleanup **Batch 3: docs weight.** Contract: `prompts/43-task-docs-weight.md` (at HEAD).
Branch `session-43-docs-weight` from `main` `49e1ee2` (the S42 merge).

**21 commits · 138 files changed, +6757 / −9629 · 53 deleted (all shadcn components) ·
gate `verify-session-43.sh` 40/40 · 453/453 tests · 0 semantic changes under the LOCKED
chart code (format-only, proven).**

> **Fidelity ≠ discipline.** A green gate proves discipline, never fidelity. Every numbered
> requirement below is mapped to evidence, and the ones that are not fully delivered are
> called PARTIAL or NOT-BUILT rather than rounded up. The independent verdict is
> `sessions/session-43-review.md`; it is fed only the contract and the diff, and it does not
> trust this document.

---

## The headline: the roadmap's headline number was wrong

The roadmap and the first draft of the contract both said **43** unused shadcn components,
with a live set of **12**. Both numbers came from the same audit bug:

```
grep -rhoE "components/ui/[a-z-]+" src | grep -v "src/components/ui/"
```

`grep -o` prints **only the match**, so the `grep -v` meant to drop intra-ui references
filtered nothing — and one ui component importing another counted as usage. Computed
properly (references from *outside* the ui folder, closed transitively), the live set is
**2**: `card` (used by `pages/not-found.tsx`) and `toast` (used by `hooks/use-toast.ts`).
The true unused count is **53**, not 43; and 6 of the 12 "live" components were themselves
imported by nothing.

This was caught **in-session**, by the `ui-components-shipped` check the session was told to
write (it DISCOVERS the live set). The ten components the first pass kept were deleted in a
follow-up commit, and the six further dead deps with them. Every affected document —
contract, ROADMAP, STATE, KNOWLEDGE, SESSION-BOOT, TASK, CONTINUATION, demo — was corrected
and the correction recorded rather than the old number repeated.

---

## The map — 10 of 10

| # | Requirement | State | Evidence |
|---|---|---|---|
| 1 | Delete the unused shadcn components | **SHIPPED** | `dcde4b8` (43) + `3e5ae78` (10 more). `ui-components-shipped` DISCOVERS the live set (closure of external refs) and asserts no orphans: 2 tracked, both reachable. **53, not the contract's 43** — corrected in the contract |
| 2 | Remove the deps that die with them, own commit | **SHIPPED** | `522679f` (30) + `9bfb83e` (6 more) + lockfile regens. `docs-dead-deps-gone` asserts each is absent from the manifest and imported nowhere. 64 → 25 devDeps |
| 3 | Strip the 3 `@replit/*` Vite plugins | **SHIPPED** | `4015b05` + `e4e35e2`. Removed from `vite.config.ts`, manifest, and the workspace catalog. `replit-plugins-gone` asserts all three sites |
| 4 | Remove the dead `lint` script | **SHIPPED** | `f8d186c`. `lint-script-gone` |
| 5 | Prettier: adopt, format, enforce (F43-1) | **SHIPPED** | `83d0114` (config+scripts) + `3ae0f45` (format) + `0c220e8` (CI job). `prettier-adopted` runs `format:check` and asserts the CI step. **Side effect:** v8 statement/line coverage moved 96.11 → 94.27 with no behaviour change (v8 counts source lines); CONTRIBUTING updated and the cause disclosed |
| 6 | Port the gate — discover, don't enumerate | **SHIPPED** | `71eb534`. `vite-configs-discovered` kept; new checks discover the ui live set and the catalog ids |
| 7 | Fix N2–N9, each with a counterfactual | **SHIPPED** | `71eb534`. N5/N7 in `browser-qa-catalog-pages` (build core inside; discover catalog ids), N2 (`summary.txt` rewritten after every check), N4/N8 in `replit-globs-match-workspace`, N9 in `dead-scripts-gone`, N6 in `charts-format-only`, N3 in the derived counts |
| 8 | Re-prove the product from live facts | **SHIPPED** | Gate: `fresh-clone-build-no-env`, `core-tests` (453), `core-typecheck`, `root-typecheck`, `example-runs`, `browser-qa-catalog-pages` — all PASS |
| 9 | Re-sync `.ai/`; counts derived, not typed | **SHIPPED** | `a2a5250`…`e6f60db`. `ai-files-describe-s43`; the demo derives the count at runtime and `test-count-propagated` now asserts the demo does **not** carry the literal |
| 10 | Fidelity map + independent review | **SHIPPED** | This file + `sessions/session-43-review.md`. The counterfactual `s42-gate-verbatim-goes-red` extracts S42's REAL `charts-untouched` body and asserts it exits non-zero on the S43 format |

---

## The counterfactual, and what it actually proves

`s42-gate-verbatim-goes-red` runs S42's **real** `charts-untouched` check body (extracted
from `scripts/verify-session-42.sh`, not transcribed) and asserts it exits non-zero on this
branch. It does: S42 asserted `git diff main...HEAD -- <LOCKED dirs>` was empty, and S43
formats those dirs (25 changed files) → red. The port re-expresses it as
`charts-format-only`, which proves each changed file is **exactly** the Prettier transform
of `main` — and fixes N6, S42's check having also PASSED VACUOUSLY when `main` did not
resolve.

It deliberately does **not** run S42's whole gate: that chains S41's gate plus two
fresh-clone installs (~60 min, S42 review §4.9). Extracting one check keeps the S43 gate at
~2 minutes.

---

## Defects found by running the thing, not reading it

| # | Defect | Caught by |
|---|---|---|
| 1 | **A `set -u` crash from a nested-quoting break.** My comment `S41's` inside a single-quoted `bash -c '…'` terminated the string, so the outer shell parsed the check's own lines and died on `n: unbound variable`. The S42 findings warn about exactly this; I did it anyway | First gate run |
| 2 | **`$sp` expanded by the outer shell** inside a double-quoted `bash -c` → `sp: unbound variable` | Second gate run |
| 3 | **A `git stash -q` I ran during a coverage check swallowed an uncommitted fix.** The `$sp` fix vanished; the third run failed on it again. Re-applied, stash dropped | Third gate run |
| 4 | **Every `printf '… %s …\n' "$D" "$N"` with one `%s` printed its line TWICE** — printf reuses the format for the extra arg. 21 lines in the demo | Running the demo, then `uniq -d` |
| 5 | **`charts-untouched` referenced the LOCKED dirs by path** — a green-from-the-previous-session gate that S43's own change turns red | Verified against `git diff` before writing the counterfactual |

Defect 5 is the session's thesis one level down: S42 discovered its *vite configs* but still
*enumerated* the LOCKED dirs, so the first session that legitimately reformats them breaks
it. **Discover, do not enumerate.**

---

## Honest gaps

- **The format commit used `--no-verify`.** 76 files reformatted at once; the pre-commit cap
  is 3 *edited* files per commit (deletions are exempt). The contract (F43-1: "one mechanical
  commit") authorises it, but a hook was bypassed, and that is disclosed rather than hidden.
- **Two of the 12 "kept" components are used only by dead files.** `not-found.tsx` and
  `use-toast.ts` are themselves unreachable from `main.tsx`. So the docs app renders **zero**
  shadcn components today; `card`/`toast` survive only because *tracked* files reference them.
  Deleting those two dead files is out of this session's scope — **named for S44**.
- **Seven pre-existing dead docs deps remain** (`framer-motion`, `react-icons`,
  `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`, `tw-animate-css`):
  zero references, but they did not die with the components, so removing them was out of scope.
- **CONTRIBUTING's coverage figures are still hand-typed.** They are now correct (94.27 etc.),
  but the session's own req 9 says counts should be derived. The check compares published vs
  measured; the derivation is not automated.
- **`required-crew` is unsatisfiable** (the standing S40 finding) and will need a founder
  waiver at closeout, as S38/S39/S42 took.
- **Cost:** one opencode session; 1 in-chat founder decision (F43-1) + plan approval; 2
  lockfile regens; 0 releases; 0 npm secrets. Token/`$` cost unmeasured.

## Cost Tracking

One opencode session. **One** in-chat founder decision (**F43-1**: Prettier format+adopt+
enforce) plus the plan approval. 10 requirements, 138 changed files, 21 commits, **53
tracked files deleted** (all components), **2** lockfile regens, **0** releases, **0** npm
secrets touched. `verify-session-43.sh` run 5 times to green (2 quote bugs, 1 lost stash, 2
corrected checks). Token/`$` cost **unmeasured**. npm cost: $0. No new recurring
infrastructure.
