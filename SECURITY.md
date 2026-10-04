# Security Policy

## Supported versions

Only the latest published version of this package is supported.

| Version | Supported |
| --- | --- |
| `@ifelse.codes/chitra` — latest on npm | ✅ |
| any earlier release | ❌ |

The package is pre-1.0 (`0.3.0` at the time of writing) and the API is not yet covered by a
stability guarantee. Old releases are not patched: fix, publish, upgrade.

## What is in scope

- The published npm package `@ifelse.codes/chitra` — everything under `packages/core/src/`.
- This repository's build and release automation (`.github/workflows/`), including the npm
  trusted-publishing path, because a compromised release pipeline ships compromised code to
  every consumer.

## What is out of scope

- Your terminal emulator, your shell, and the font you render chart glyphs with.
- The docs site's hosting and DNS.
- Dependencies of the package: it has **zero** runtime dependencies, so the supply chain for
  the shipped artifact is this repository alone.
- Denial-of-service against a chart renderer that draws strings you gave it.

## Reporting a vulnerability

**If this repository has private reporting switched on, use it: the _Security_ tab → _Report a
vulnerability_.** A report sent that way reaches the maintainers and is not disclosed until a
fix is published. Whether the switch is on is a repository setting recorded, with the command that
re-derives it, in [`.github/REPO-SETTINGS.md`](.github/REPO-SETTINGS.md) — read that first. If it is
off, see "If private reporting is not enabled" below before you send anything.

Please include:

1. the package version and the chart type, if one is involved;
2. a reproduction — a short script that triggers it is worth more than a description;
3. what you expected and what happened.

If private reporting is **not** enabled on this repository, this project has **no private
channel**: it publishes no mailbox, no other channel a repository can offer is switched on, and
the issue tracker is public. None of those is acceptable for an exploit,
so say so plainly rather than inventing a route.

**What to do instead:** open a **bug report** through the form under
`.github/ISSUE_TEMPLATE/` with nothing but the statement that a security report is pending and
a request for a private channel — no version, no reproduction, no detail that would let anyone
else exploit it. The report is read before anything is asked for again. Private reporting **is**
enabled on this repository as of the public flip (session 46): if the Security tab shows no
*Report a vulnerability* button, the switch has been turned off again — the row and the command
that re-derives it are in [`.github/REPO-SETTINGS.md`](.github/REPO-SETTINGS.md).

The repository settings this depends on are recorded, with the command that re-derives each,
in [`.github/REPO-SETTINGS.md`](.github/REPO-SETTINGS.md). Check them before trusting a route
in this file.

**Please do not open a public issue for a suspected vulnerability.**

## What you should not expect

- No SLA. This is a single-maintainer project; reports are answered when they are answered.
- No paid support, no bug bounty.
- No backports to versions other than the latest.
- No coordinated-disclosure timeline beyond "fix first, then publish".
