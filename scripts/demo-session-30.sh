#!/usr/bin/env bash
# S30 demo — what hosting was wired (cumulative: header + cases + table).
set -euo pipefail
echo "=== S30 DEMO: chitra.iifelse.com on Cloudflare Pages ==="
echo ""
echo "--- case 1: SPA fallback ships with the site ---"
cat artifacts/chitra-docs/public/_redirects
test -f artifacts/chitra-docs/dist/public/_redirects && echo "dist: _redirects present"
echo ""
echo "--- case 2: Pages project ---"
wrangler pages project list 2>&1 | grep -E "Project Name|^│ chitra " || true
echo ""
echo "--- summary ---"
printf '%-22s %s\n' "project" "chitra (chitra-5xh.pages.dev)"
printf '%-22s %s\n' "custom-domain" "chitra.iifelse.com"
printf '%-22s %s\n' "deploy-dir" "artifacts/chitra-docs/dist/public"
printf '%-22s %s\n' "verify" "scripts/verify-session-30.sh"
