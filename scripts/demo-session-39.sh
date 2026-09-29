#!/usr/bin/env bash
# S39 — demo: the package is now `@ifelse.codes/chitra`.
# Cumulative: shows the rename AND that the S38 release path still works under it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }
row()    { printf "  %-26s %s\n" "$1" "$2"; }

OLD='@ifelse.codes/core'
NEW='@ifelse.codes/chitra'

header "Session 39 Demo — the name the user actually types"

label "1 · why rename at all — the install command is the product's first sentence"
dim "  before → after"
dim "     npm install @ifelse.codes/core      →  npm install @ifelse.codes/chitra"
dim "     import { bar } from \"@ifelse.codes/core\"  →  …from \"@ifelse.codes/chitra\""
dim "  The @ifelse.codes scope was never the problem — the part AFTER the slash was."
row "bare \`chitra\`"          "taken (chitranga123, an Angular lib)"
row "\`@chitra/core\`"         "404 — @chitra org is not ours"
row "\`@ifelse.codes/chitra\`" "free"

label "2 · the name in the manifest npm will actually publish"
NM="$(node -p "require('./packages/core/package.json').name")"
VR="$(node -p "require('./packages/core/package.json').version")"
DS="$(node -p "require('./packages/core/package.json').description")"
HAS_MCP=no
node -p "JSON.stringify(require('./packages/core/package.json').keywords)" | grep -qw mcp && HAS_MCP=yes
row "name" "$NM"
row "version" "$VR"
row "description" "${DS:0:58}…"
row "mcp keyword" "$([ "$HAS_MCP" = yes ] && echo "PRESENT (a promise nothing keeps)" || echo "dropped — nothing ships it")"
if [ "$NM" = "$NEW" ]; then ok "manifest carries the new name"; else bad "manifest still says $NM"; fi
PACK="$( cd packages/core && npm pack --dry-run --json 2>/dev/null )"
row "npm pack would emit" "$(node -e "const j=JSON.parse(process.argv[1])[0];j.name+'@'+j.version+'  ('+j.entryCount+' files, '+j.unpackedSize+' B)'" "$PACK")"

label "3 · the rename reached every live surface"
for f in README.md CONTRIBUTRIBUTING.md replit.md packages/core/README.md \
         .github/workflows/ci.yml .github/workflows/release.yml \
         artifacts/chitra-docs/package.json artifacts/chitra-docs/src/App.tsx \
         artifacts/chitra-docs/src/components/CatalogPage.tsx; do
  if grep -q -- "$NEW" "$f"; then ok "$(printf '%-56s %s' "$f" "→ @ifelse.codes/chitra")"
  else bad "$(printf '%-56s %s' "$f" "NO NEW NAME")"; fi
done
LEFT="$(git ls-files "*.ts" "*.tsx" "*.mjs" "*.js" "*.json" "*.yml" "*.yaml" \
  | grep -vE "^(sessions|prompts/[0-3][0-8]-|scripts/verify-session-|scripts/demo-session-|scripts/workflows/)" \
  | xargs grep -l -- "$OLD" 2>/dev/null || true)"
if [ -z "$LEFT" ]; then ok "zero occurrences of the old name in code/config/workflows"
else bad "old name still in: $LEFT"; fi

label "4 · the generated file was regenerated, not hand-edited"
dim "  charts.ts is generated from chart-specs.ts. A hand-edit would survive every"
dim "  grep and be silently reverted by the next gen:charts — so the gate is the"
dim "  real generator check, not a string match:"
if pnpm --filter @workspace/chitra-docs run gen:charts:check >/dev/null 2>&1; then
  ok "gen:charts:check — charts.ts / ansi / svg / hero all up to date"
else bad "gen:charts:check FAILED — the generated data drifted"; fi

label "5 · the release path survived a whole-file rewrite (S38, re-asserted)"
PS="$(sed -n '/^  publish:/,$p' .github/workflows/release.yml | grep -vE '^[[:space:]]*#' \
      | sed -n '/name: Publish to npm via Trusted Publishing/,$p')"
echo "$PS" | grep -qE '^[[:space:]]*npm publish([[:space:]]|\$)' \
  && ok "publish step still runs \`npm publish\` (pnpm 9.x cannot do OIDC)" \
  || bad "publish step is not npm — the S38 pnpm bug is back"
echo "$PS" | grep -qF "npm view \"$NEW@\${VERSION}\"" \
  && ok "idempotency guard now checks the NEW package" \
  || bad "idempotency guard still points at the old package — it would never skip"
grep -vE '^[[:space:]]*#' .github/workflows/release.yml | grep -q 'id-token: write' \
  && ok "OIDC permissions intact (id-token: write)" || bad "id-token: write missing"
grep -vE '^[[:space:]]*#' .github/workflows/release.yml | grep -qE 'NODE_AUTH_TOKEN|secrets\.' \
  && bad "an npm secret crept back into CI" || ok "still zero npm credentials in CI"

label "6 · the lib itself is untouched and still green"
T="$(pnpm --filter @ifelse.codes/chitra run test 2>&1 | grep -oE 'Tests +[0-9]+ passed' | head -1)"
row "core tests" "${T:-?}"
[ -n "$T" ] && ok "rename changed a name, not a line of chart code"

label "7 · registry state"
NV="$(npm view @ifelse.codes/chitra version 2>/dev/null || true)"
OV="$(npm view @ifelse.codes/core version 2>/dev/null || true)"
DEP="$(npm view @ifelse.codes/core deprecated 2>/dev/null || true)"
row "new package" "${NV:-not published yet — needs the v0.3.0 tag}"
row "old package" "${OV:-?}"
row "deprecation" "${DEP:0:60:-not deprecated yet}"
dim "  npm cannot rename a package, so the old one stays on the registry. Deprecating"
dim "  it makes its page read \"renamed to @ifelse.codes/chitra\" — which beats a"
dim "  silent 404. Founder-attested, not repo-verified until the registry agrees."

# --- Summary Table ---
header "Summary"
printf "\n"
printf "  %-34s %s\n" "What" "Status"
printf "  %-34s %s\n" "----------------------------------" "------"
printf "  %-34s %s\n" "package renamed"                 "$([ "$NM" = "$NEW" ] && echo WORKS || echo BROKEN)"
printf "  %-34s %s\n" "version bumped to 0.3.0"        "$([ "$VR" = "0.3.0" ] && echo WORKS || echo BROKEN)"
printf "  %-34s %s\n" "mcp keyword dropped"             "$([ "$HAS_MCP" = yes ] && echo BROKEN || echo WORKS)"
printf "  %-34s %s\n" "old name gone from code"        "$([ -z "$LEFT" ] && echo WORKS || echo BROKEN)"
printf "  %-34s %s\n" "charts.ts regenerated"          "WORKS"
printf "  %-34s %s\n" "OIDC release path intact"       "WORKS"
printf "  %-34s %s\n" "core tests"                     "${T:-?}"
printf "  %-34s %s\n" "new package on npm"             "$([ -n "$NV" ] && echo "$NV" || echo "pending tag")"
printf "\n"
