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

**Use GitHub's private reporting: open the repository's _Security_ tab → _Report a
vulnerability_.** The report goes privately to the maintainers and is not disclosed until a
fix is published.

Please include:

1. the package version and the chart type, if one is involved;
2. a reproduction — a short script that triggers it is worth more than a description;
3. what you expected and what happened.

If private reporting is not enabled on this repository, the maintainers have not turned it
on — say so in a **public** issue and it will be treated as a bug in the project's own
configuration, not as an invalid report.

**Please do not open a public issue for a suspected vulnerability.**

## What you should not expect

- No SLA. This is a single-maintainer project; reports are answered when they are answered.
- No paid support, no bug bounty.
- No backports to versions other than the latest.
- No coordinated-disclosure timeline beyond "fix first, then publish".
