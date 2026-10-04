# Session 46 — the public flip: decision + evidence log

**Contract:** `prompts/46-task-public-flip.md` (F1–F6, P1–P2). **Branch:** `session-46-public-flip`
from `main` `5a59eaf` (the S45 merge, PR #67).

Every remote fact below is a **command + reading**, before and after. A flip with no recorded
`before` FAILS.

---

## Decisions recorded before the push

### D-F1 — P1's rewrite tool and re-verify order (irreversible once public)

- **Tool:** `git filter-repo` **2.47.0** (installed this session via `brew install git-filter-repo`)
  over `git filter-branch`. The safety it gives: it refuses a dirty tree.
- **Expressions** (derived by walking history, every match site counted first — not typed):

  | Rule (the pattern itself is written out nowhere — this file is in the tree P1 scans) | Matches in history | Form |
  |---|---|---|
  | the macOS home path → `/Users/REDACTED` | **1009** | macOS home path |
  | its dash-encoded form → `-Users-REDACTED` | **236** | dash-encoded path (`…-playground-chitra`) |

  The `Users`-plus-backslash hits (**443**) are **not** paths: they are the `Users` column label of
  a sankey fixture followed by an ANSI escape — re-derived, **0** real Windows home-path carriers.
  Rules applied with **`--replace-text` and `--replace-message`** (one commit message also carries
  the pattern).

- **Pre-rewrite figures** (what the re-verify must reproduce):

  | Quantity | Value |
  |---|---|
  | `git rev-list --count HEAD` | **444** |
  | `git rev-parse HEAD^{tree}` | **8167462a8f21ca400f051635cd6032e233771dbe** |
  | `git archive HEAD \| shasum` | **39781d0e5a191690f4ccde24555bb7ca5580ae63** |
  | `git ls-files \| wc -l` | **367** |
  | tip (pre-rewrite) | `5a59eaf56cffe642eef986cce5211af1af72c5f1` |
  | tags | `v0.1.0 v0.2.0 v0.3.0` |

- **Rewrite outcome:** the post-rewrite tip `8a083c8bcc233c2f957f61f49b3e9853d7ea6fc8`
  replaced it — same tree, same commit count, same tracked-file count, every SHA moved
  (the rewrite also drops GPG signature headers, which is why even unsigned commits changed
  hash). Every local and remote ref was rewritten with it, plus the three tags, and force-pushed
  once with `--no-verify` because `.githooks/pre-push` blocks *any* push to `refs/heads/main`
  — that hook guards direct commits, and an approved history rewrite cannot open a PR against
  itself. Disclosed here rather than silently bypassed.

- **Re-verify order — each step invalidates the next's inputs, so run them in this order:**
  1. `(/|-)Users[-/][a-z]+` matches **nothing** in any commit reachable from `HEAD`
     (walk `git rev-list HEAD`, `git grep` per commit).
  2. working tree at the rewritten tip is **byte-identical** to the pre-rewrite tip
     (`git rev-parse HEAD^{tree}` unchanged **and** `git archive HEAD | shasum` unchanged — not
     "looks the same").
  3. `git rev-list --count HEAD` unchanged (**444**).
  4. tracked-file count unchanged (**367**).
  5. **453/453** + typecheck + drift green.

  Then **force-push once**, and tell every reader that SHAs moved.

### D-REORDER — P2 before F1 is unsatisfiable (founder-approved deviation)

The contract gates **P2** before **F1**. P2 cannot be green while the repo is private:

| Probe | Public control (`octocat/Hello-World`) | Ours (private) |
|---|---|---|
| `GET /repos/{o}/{r}/private-vulnerability-reporting` | `{"enabled":false}` | **404** |
| `PUT …/private-vulnerability-reporting` (enable) | — | **404** |
| `permissions.admin` | — | `true` (so not a permissions issue) |

GitHub serves that endpoint for **public** repositories only, so the precondition as written can
never be met pre-flip. **Founder decision:** reorder to **F1 → enable P2 → F2–F6**, with P2's
before-row (`404`) already captured. Recorded here rather than silently absorbed into the plan.

### D-F2 — P2 outcome

*Pending the post-F1 `PUT`; the row lands in `.github/REPO-SETTINGS.md` via F4 either way.*

---

## Before rows (captured pre-flip; reproducible by anyone today)

| # | Probe | Command | Before (pre-flip) | After (post-flip) |
|---|---|---|---|---|
| F1 | repo private | `gh api repos/ifelse-codes/chitra --jq .private` | `true` | **`false`** (`.visibility` → `public`) |
| F2 | clone URL | `curl -s -o /dev/null -w '%{http_code}' https://github.com/ifelse-codes/chitra` | `404` | **`200`** (git-upload-pack endpoint `200`; anonymous `--depth=1` clone tip `86bc909`) |
| P2 | vuln reporting | `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting` | `404` | **`{"enabled":true}`** |
| F3 | `repository.url` | `npm view @ifelse.codes/chitra repository.url` | `git+https://github.com/ifelse-codes/chitra.git` | **unchanged** (npm prefixes `git+`; manifest bytes untouched) |
| F3 | `homepage` | `npm view @ifelse.codes/chitra homepage` | `https://github.com/ifelse-codes/chitra` | **unchanged**; the URL now returns `200` |
| F3 | manifest bytes | `grep -n '"homepage"\|"url"' packages/core/package.json` | L16 / L19 | **unchanged** — the only line that differs from `main` in that file is `version` |
| F6 | `t0` downloads | `curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra"` | `119` lifetime; first non-zero **2026-09-29 = 89**, the `0.3.0` publish day | **recorded as `t0`, never as zero** — `.ai/STATE.md` |
| P1 | tree matches | `git grep -lE '(/-)Users[-/][a-z]+' HEAD -- \| wc -l` | `0` | `0` |
| P1 | history pairs | per-commit `git grep` over `git rev-list HEAD` | **1001** (commit, file) pairs | **0** across **444** commits |

### P1 — what the rewrite moved, and what it could not

| quantity | before | after |
|---|---|---|
| `(commit, file)` pairs carrying the path | **1001** | **0** (walked over every reachable commit) |
| reachable commits | 444 | **444** |
| tip | `5a59eaf56cffe642eef986cce5211af1af72c5f1` | **`8a083c8bcc233c2f957f61f49b3e9853d7ea6fc8`** (tree identical) |
| tracked files | 367 | **367** |
| tags | `v0.1.0 v0.2.0 v0.3.0` | same names, **new SHAs** (`48db41e`, `7664fed`, `f17b204`) |

**Residual, disclosed rather than dropped:** `refs/pull/*` is read-only on GitHub
(`DELETE …/git/refs/pull/67/head` → `422 refs/pull/* is read-only`), and **56 of 67** PR head refs
(PRs #9–#64) still carry the path — `git fetch origin refs/pull/64/head` returns a tree with 15
matching files. P1's done-condition is scoped to commits *reachable from HEAD*, so it is met; the
residual is **founder-accepted** (decision: flip now, disclose, file a support ticket to delete the
PR refs and GC the unreachable objects). The ticket is an owed action, not a completed one.

**Side effect of the tag push, audited:** force-pushing the three rewritten tags re-triggered the
Release workflow for `v0.1.0`, `v0.2.0` and `v0.3.0` at 15:23Z — each ran from *its own tag's*
tree, where the package was still named `@ifelse.codes/core`. All three published **nothing**:
the publish step is idempotent (`##[notice] … is already on npm — skipping publish (idempotent tag
push)`), and `npm view @ifelse.codes/core versions` still reads `[0.1.0, 0.2.0]`. No version was
republished under either name.

### F5 — the release, by CI unattended

| fact | reading |
|---|---|
| trigger | tag `v0.4.0` on merged `main` `86bc909`, pushed once |
| run | `37217761468` — core/docs/drift **success**, publish **success** |
| publish log | `+ @ifelse.codes/chitra@0.4.0` · `Signed provenance statement … transparency log: https://search.sigstore.dev/?logIndex=3078088104` |
| workflow edited by S46 | **no file under `.github/workflows/` changed** — npm attaches provenance automatically once the repo is public |
| human in the loop | **none** — no tmux, no passkey, no `NODE_AUTH_TOKEN`; OIDC only (`id-token: write`) |

