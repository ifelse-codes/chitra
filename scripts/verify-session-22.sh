#!/usr/bin/env bash
# verify-session-22.sh — S22: lock the gauge chart to the reference/panel language.
# Proves: gauge now renders the locked panel (one accent spent exactly once on the
# reading's leading edge as a solid █ via raw-RGB accent census, grey tone ramp +
# shade texture for the fill, NO theme.colors[i % n] band rainbow, dashed frame/LEVEL
# eyebrow/+╌…╌+ guide/rule separators, value · min..max · pct summary footer, ─ scale
# track kept, ┤/├ retired, dead labelLine gone, out-of-range clamp + collapsed range +
# n/a all degenerate-safe), the falsifiability tests pass, the full core suite +
# typecheck stay green, and the regenerated docs previews are in sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="22"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
    echo "  ↳ FAIL log: $LOG" >&2
  fi
}

# ── Criterion 1: raw-RGB — accent hue spent EXACTLY once on the leading edge ──
run_check "raw-rgb-accent-once" bash -c '
  cd packages/core
  cat > src/__verify_s22_accent.ts <<'"'"'TS'"'"'
import { gauge } from "./charts/gauge.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = gauge({ value: 73, min: 0, max: 100 }).toString();
// Census coloured BAR segments. The `─` track is axis scale, not fill; only
// shade-ramp runs (░▒▓█) count.
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0, accentBody = "";
for (const s of segs) {
  const code = s[1], body = s[2];
  if (!BAR.test(body)) continue;
  if (code === theme.accent) { accent++; accentBody = body; }
  else if (theme.tones!.includes(code)) grey++;
  else other++;
}
if (accent !== 1) { console.error("FAIL: accent must be spent EXACTLY once, got " + accent); process.exit(1); }
if (accentBody !== "█") { console.error("FAIL: the accent segment must be the solid █ leading edge, got " + JSON.stringify(accentBody)); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " bar segments are neither accent nor a grey tone (rainbow leak)"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp fill"); process.exit(1); }
console.log("OK: accent spent once on the solid █ edge, " + grey + " grey-ramp segs, 0 rainbow leaks");
TS
  npx tsx src/__verify_s22_accent.ts; rc=$?
  rm -f src/__verify_s22_accent.ts
  exit $rc
'

# ── Criterion 2: panel chrome present ───────────────────────────────────────
run_check "panel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s22_chrome.ts <<'"'"'TS'"'"'
import { gauge } from "./charts/gauge.js";
const plain = gauge({ value: 73, min: 0, max: 100 }).toPlain();
const lines = plain.split("\n");
const topOk = lines[0].startsWith("┌╌");
const bottomOk = lines[lines.length - 1].startsWith("└╌");
const rules = (plain.match(/│ ╌/g) || []).length;
const eyebrow = plain.includes("LEVEL");
const labelled = gauge({ value: 73, label: "cpu load" }).toPlain().includes("CPU LOAD");
const guide = /\+╌+\+/.test(plain);
const scale = /0\s+100/.test(plain);
if (!topOk || !bottomOk || rules !== 2 || !eyebrow || !labelled || !guide || !scale) {
  console.error("FAIL: missing dashed frame/eyebrow/guide/scale row/rule separators"); process.exit(1);
}
console.log("OK: dashed frame, LEVEL eyebrow (opts.label uppercases), +╌…╌+ guide, min..max scale, two rule separators");
TS
  npx tsx src/__verify_s22_chrome.ts; rc=$?
  rm -f src/__verify_s22_chrome.ts
  exit $rc
'

# ── Criterion 3: footer reports value · min..max · pct, reading accented ────
run_check "footer-format" bash -c '
  cd packages/core
  cat > src/__verify_s22_footer.ts <<'"'"'TS'"'"'
import { gauge } from "./charts/gauge.js";
import { resolveTheme } from "./themes/index.js";
const acc = resolveTheme("default").accent;
const plain = gauge({ value: 73, min: 0, max: 100 }).toPlain();
if (!/value 73 · 0\.\.100 · 73\.0%/.test(plain)) {
  console.error("FAIL: footer format incorrect: " + plain.split("\n").slice(-3).join(" | ")); process.exit(1);
}
const raw = gauge({ value: 73, min: 0, max: 100 }).toString();
if (!raw.includes(acc + "value 73")) {
  console.error("FAIL: the reading is not in the accent hue"); process.exit(1);
}
console.log("OK: footer reports value · min..max · pct with the reading accented");
TS
  npx tsx src/__verify_s22_footer.ts; rc=$?
  rm -f src/__verify_s22_footer.ts
  exit $rc
'

# ── Criterion 4: retired glyphs gone; fill is the shade ramp + ─ scale only ─
run_check "retired-glyphs" bash -c '
  cd packages/core
  cat > src/__verify_s22_glyphs.ts <<'"'"'TS'"'"'
import { gauge } from "./charts/gauge.js";
const out = gauge({ value: 73, min: 0, max: 100 }).toString();
const ANSI = /\x1b\[[0-9;]*m|\x1b\[0m/g;
if (/[┤├]/.test(out)) { console.error("FAIL: retired ┤/├ endcaps still present"); process.exit(1); }
for (const row of out.split("\n").filter((l) => /[░▒▓█]/.test(l))) {
  const residue = row.replace(ANSI, "").replace(/[A-Za-z0-9 +.,%_…\-│┌┐└┘╌─]/g, "");
  if (!/^[░▒▓█]*$/.test(residue)) { console.error("FAIL: non-ramp fill: " + JSON.stringify(residue)); process.exit(1); }
}
console.log("OK: no ┤/├; the fill row is a shade-ramp run over the ─ scale only");
TS
  npx tsx src/__verify_s22_glyphs.ts; rc=$?
  rm -f src/__verify_s22_glyphs.ts
  exit $rc
'

# ── Criterion 5: the ramp survives noColor (texture language) ────────────────
run_check "ramp-survives-nocolor" bash -c '
  cd packages/core
  cat > src/__verify_s22_nocolor.ts <<'"'"'TS'"'"'
import { gauge } from "./charts/gauge.js";
const rowFor = (value: number) =>
  gauge({ value, min: 0, max: 100, noColor: true }).toPlain()
    .split("\n").find((l) => /[░▒▓█]/.test(l))!;
if (!rowFor(20).match(/░+█/)) { console.error("FAIL: value 20 is not the ░ ramp step"); process.exit(1); }
if (!rowFor(45).match(/▒+█/)) { console.error("FAIL: value 45 is not the ▒ ramp step"); process.exit(1); }
if (!rowFor(70).match(/▓+█/)) { console.error("FAIL: value 70 is not the ▓ ramp step"); process.exit(1); }
if (!rowFor(95).match(/█+█/)) { console.error("FAIL: value 95 is not the darkest █ step"); process.exit(1); }
console.log("OK: ░▒▓█ shade texture carries the level through noColor, light → dark");
TS
  npx tsx src/__verify_s22_nocolor.ts; rc=$?
  rm -f src/__verify_s22_nocolor.ts
  exit $rc
'

# ── Criterion 6: out-of-range clamp + collapsed range + n/a all safe ─────────
run_check "degenerate-safe" bash -c '
  cd packages/core
  cat > src/__verify_s22_degen.ts <<'"'"'TS'"'"'
import { gauge } from "./charts/gauge.js";
// past max: clips at full width, footer reports the TRUE percent
const over = gauge({ value: 140, min: 0, max: 100 }).toPlain();
if (!over.includes("value 140 · 0..100 · 140.0%")) { console.error("FAIL: out-of-range footer dishonest"); process.exit(1); }
const overRow = over.split("\n").find((l) => /[░▒▓█]/.test(l))!;
if (/[░▒▓█]─/.test(overRow)) { console.error("FAIL: bar not clipped at full width"); process.exit(1); }
// below min: empty track, honest percent
const under = gauge({ value: -10, min: 0, max: 100 }).toPlain();
if (!under.includes("value -10 · 0..100 · -10.0%")) { console.error("FAIL: below-min footer dishonest"); process.exit(1); }
// collapsed range: no division by zero
const collapsed = gauge({ value: 50, min: 50, max: 50 }).toPlain();
if (collapsed.includes("NaN") || collapsed.includes("Infinity")) { console.error("FAIL: collapsed range NaN/Infinity"); process.exit(1); }
// non-finite: framed value n/a panel
const na = gauge({ value: NaN, min: 0, max: 100 }).toPlain();
if (na.includes("NaN") || na.includes("Infinity")) { console.error("FAIL: non-finite leaks NaN/Infinity"); process.exit(1); }
if (!na.includes("value n/a · 0..100")) { console.error("FAIL: non-finite footer incorrect"); process.exit(1); }
if (!na.startsWith("┌╌") || !na.endsWith("┘")) { console.error("FAIL: n/a panel missing its frame"); process.exit(1); }
console.log("OK: out-of-range clip + below-min + collapsed + n/a all render safely and honestly");
TS
  npx tsx src/__verify_s22_degen.ts; rc=$?
  rm -f src/__verify_s22_degen.ts
  exit $rc
'

# ── Criterion 7: the rainbow default + dead labelLine are gone from source ──
run_check "source-locked" bash -c '
  # strip block + line comments, then look for a live rainbow assignment
  if sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/gauge.ts | grep -q "theme\.colors\["; then
    echo "theme.colors[] rainbow still present in gauge.ts"; exit 1
  fi
  grep -q "frameTop" packages/core/src/charts/gauge.ts || { echo "no panel frame in gauge.ts"; exit 1; }
  grep -q "theme.accent" packages/core/src/charts/gauge.ts || { echo "no accent hue in gauge.ts"; exit 1; }
  if grep -q "labelLine" packages/core/src/charts/gauge.ts; then
    echo "dead labelLine still computed in gauge.ts"; exit 1
  fi
'

# ── Criterion 8: core tests green ──────────────────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "gauge-tests"            pnpm --filter @chitra/core run test -- gauge

# ── Criterion 9: README carries the LOCKED contract block ──────────────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: gauge chart — session 22 design" packages/core/README.md
'

# ── Criterion 10: docs previews in sync (no chart drift) ───────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 11: branch is s22 ────────────────────────────────────────────
run_check "branch-is-s22"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-22-* ]] || { echo "branch=$branch, expected session-22-*"; exit 1; }
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf "%-34s %s\n" "STEP" "RESULT"
printf "%-34s %s\n" "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
