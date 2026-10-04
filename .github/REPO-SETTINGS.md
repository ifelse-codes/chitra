# Repository settings — recorded facts

These are the values `SECURITY.md` and `CODE_OF_CONDUCT.md` promise routes depend on. They are
**remote** state, so they cannot be read by an offline gate; they are recorded here, with the
command that re-derives each one, and the S44 gate checks the public docs against this file.
A stale row here is a public doc pointing at a closed door, so re-derive before trusting it.

Recorded 2026-10-04 on `session-44-oss-polish`:

| setting | value | re-derive with |
| --- | --- | --- |
| `private` | `true` | `gh api repos/ifelse-codes/chitra --jq .private` |
| `has_issues` | `true` | `gh api repos/ifelse-codes/chitra --jq .has_issues` |
| `blank_issues_enabled` | `false` | `.github/ISSUE_TEMPLATE/config.yml` (tracked, so a gate can read it) |
| `has_discussions` | **`false`** | `gh api repos/ifelse-codes/chitra --jq .has_discussions` |
| private vulnerability reporting | **unknown** — `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting` returns 404, which is also what a caller without access gets, so this row cannot distinguish "off" from "not permitted to ask" | same command, from an account with admin access |

## What this means for a reader's route

- **The repository is private.** Nothing on this page is reachable by an outsider yet. The
  public flip is session 45's job; these docs are written for the state *after* it.
- **Issues are on, blank issues are off.** GitHub's behaviour with `blank_issues_enabled:
  false` is that the *new issue* page offers only the configured templates — so a visitor can
  still open a **bug** or **feature** report, and cannot open an untemplated issue. Saying
  "open a blank issue" would be wrong; saying "open a bug report" is right.
- **Discussions are off.** Routing anyone to a discussion is routing them nowhere. That is why
  `CODE_OF_CONDUCT.md` uses the report forms.
- **Private reporting is not established.** Until that row reads `enabled`, this project has no
  route a reporter can be certain of, and the docs say so instead of inventing one.

## What the gate actually checks — and what it does not

`oss-surface-present` enforces three offline clauses, and nothing else about these settings:

1. the `has_discussions` row above — if it reads `false`, no reader-facing file may mention
   Discussions;
2. `blank_issues_enabled` from `.github/ISSUE_TEMPLATE/config.yml` — if `false`, a reader-facing
   file that sends someone to an issue must name a form;
3. any reader-facing file offering `security/advisories/new` must hedge it in the same file,
   because that route's status is the **unknown** row above.

It does **not** read the `private` row, the `has_issues` row, or the private-reporting row, and
no offline gate can resolve the last one. It does not check whether the docs and npm links
resolve — that is a network fact, checked by hand, not by this gate. Anyone extending these
clauses must widen this paragraph in the same commit, or this file will advertise an invariant
the gate does not keep; pass 5 caught exactly that.