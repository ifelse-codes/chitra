#!/usr/bin/env bash
# S31 demo — antra atoms in chitra-docs (header + cases + table).
set -euo pipefail
echo "=== S31 DEMO: antra design atoms → chitra-docs ==="
echo ""
echo "--- case 1: tokens + eyebrow + hero accent ---"
grep -m2 'antra-violet' artifacts/chitra-docs/src/index.css
echo ""
echo "--- case 2: install strip + footer + reveal wired ---"
grep -c 'install-strip\|site-footer\|reveal' artifacts/chitra-docs/src/App.tsx
echo ""
echo "--- summary ---"
printf '%-22s %s\n' "donor" "antra/landing/index.html"
printf '%-22s %s\n' "atoms" "tokens eyebrow hero-accent install-strip hairline topbar footer reveal"
printf '%-22s %s\n' "skipped" "mandalas full-sections chart-card-hover"
printf '%-22s %s\n' "verify" "scripts/verify-session-31.sh"
