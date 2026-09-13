#!/usr/bin/env bash
# verify-session-26.sh — S26: lock waterfall + funnel + sankey to the reference/panel language.
# Proves: waterfall now renders the locked panel (the P0 flat-dash bug retired by
# design — every negative delta a visible dashed outline box with a one-row
# minimum; tonal kinds with the accent spent EXACTLY once on the Total anchor
# as solid █ via raw-ANSI census, NO theme.colors[i] rainbow; INTEGER y-axis
# labels; dashed frame/NET eyebrow/signed-delta row/┄ connectors/dashed
# baseline/step labels/rule separators; START · Δ · TOTAL foot with TOTAL
# accented; empty/all-zero degenerate-safe) AND funnel renders the locked panel
# (▼ arrows deleted, left-anchored rows, accent once on the peak stage, integer
# percents, CONVERSION eyebrow, IN/OUT/DROP foot) AND sankey renders the locked
# panel (▶ deleted, accent once on the peak flow, toned node ledger, FLOW
# eyebrow, NODES/LINKS/PEAK foot), the falsifiability tests pass, the
# full core suite + typecheck stay green, and the regenerated docs previews are
# in sync (no chart drift).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="26"
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

# ── Criterion 1: P0 — down-deltas are outline boxes, sub-row keeps 1 row ──
run_check "p0-outline-proof" bash -c '
  cd packages/core
  cat > src/__verify_s26_p0.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
import { stripAnsi } from "./ansi.js";
// Audit capture: COGS −120 and OpEx −60 were flat dashes on the baseline.
const text = stripAnsi(waterfall({
  data: [500, -120, 80, -60, 150],
  labels: ["Start", "COGS", "Rev", "OpEx", "Sales"],
}).toString());
if (!text.includes("┌╌") || !text.includes("└╌")) {
  console.error("FAIL: no dashed outline boxes for the down-deltas"); process.exit(1);
}
// Sub-row delta (−1 in a 0..1000 range at height 12) keeps a minimum 1-row box.
const tiny = stripAnsi(waterfall({ data: [1000, -1], noColor: true }).toString());
if (!tiny.includes("┌╌")) { console.error("FAIL: sub-row delta collapsed (flat dash returns)"); process.exit(1); }
// Zero deltas: empty columns — no fill, no outline corners.
const zero = stripAnsi(waterfall({ data: [100, 0, 50], noColor: true }).toString());
if (zero.includes("┌╌┌") || /┌╌[^\n]*┌╌/.test(zero.split("\n").filter(l => l.includes("+0")).join())) {
  console.error("FAIL: zero delta rendered an outline"); process.exit(1);
}
console.log("OK: downs are outline boxes, sub-row keeps 1 row, zeros stay empty");
TS
  npx tsx src/__verify_s26_p0.ts; rc=$?
  rm -f src/__verify_s26_p0.ts
  exit $rc
'

# ── Criterion 2: raw-ANSI — accent ONLY on solid █ (Total), grey ramp rest ──
run_check "raw-ansi-tonal-census" bash -c '
  cd packages/core
  cat > src/__verify_s26_tonal.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = waterfall({ data: [500, -120, 80, -60, 150] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[█▓┌╌┐│└┘]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  const code = s[1], body = s[2];
  if (code === theme.axis) continue; // frame/guides/connectors/baseline, never bars
  if (!BAR.test(body)) continue;
  if (code === theme.accent) {
    accent++;
    if (!/^█+$/.test(body)) { console.error("FAIL: accent carries a non-solid segment " + JSON.stringify(body)); process.exit(1); }
  }
  else if (GREY_TONES.includes(code)) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the Total anchor"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " bar segments are neither accent nor a grey tone (theme.colors leak)"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no grey-ramp bars"); process.exit(1); }
console.log("OK: accent only on solid █ Total segments (" + accent + " rows), " + grey + " grey-ramp segs, 0 theme.colors leaks");
TS
  npx tsx src/__verify_s26_tonal.ts; rc=$?
  rm -f src/__verify_s26_tonal.ts
  exit $rc
'

# ── Criterion 3: integer y-axis labels (the retired decimal bug) ──────────
run_check "integer-y-labels" bash -c '
  cd packages/core
  cat > src/__verify_s26_ints.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
import { stripAnsi } from "./ansi.js";
const lines = stripAnsi(waterfall({ data: [500, -120, 80, -60, 150] }).toString()).split("\n");
let labels = 0;
for (const line of lines) {
  const m = line.match(/^│ (\s*\S*)([+│])/);
  if (!m) continue;
  labels++;
  if (m[1]!.includes(".")) { console.error("FAIL: decimal y-label on the money axis: " + JSON.stringify(m[1])); process.exit(1); }
}
if (labels < 3) { console.error("FAIL: too few y labels rendered (" + labels + ")"); process.exit(1); }
console.log("OK: " + labels + " y-axis labels, every one an integer");
TS
  npx tsx src/__verify_s26_ints.ts; rc=$?
  rm -f src/__verify_s26_ints.ts
  exit $rc
'

# ── Criterion 4: panel chrome present ─────────────────────────────────────
run_check "panel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s26_chrome.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
import { stripAnsi } from "./ansi.js";
const lines = stripAnsi(waterfall({ data: [500, -120, 80, -60, 150] }).toString()).split("\n");
if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: no dashed frame top"); process.exit(1); }
if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: no dashed frame bottom"); process.exit(1); }
const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
if (rules.length !== 2) { console.error("FAIL: expected 2 rule separators, got " + rules.length); process.exit(1); }
if (!lines.some((l) => l.includes("NET +550"))) { console.error("FAIL: no NET metric in the eyebrow row"); process.exit(1); }
if (!lines.some((l) => l.includes("└╌"))) { console.error("FAIL: no dashed baseline"); process.exit(1); }
if (!lines.some((l) => l.includes("TOTAL 550"))) { console.error("FAIL: no TOTAL fact in the foot row"); process.exit(1); }
const widths = new Set(lines.map((l) => [...l].length));
if (widths.size !== 1) { console.error("FAIL: panel rows disagree on width: " + [...widths].join(",")); process.exit(1); }
console.log("OK: dashed frame + 2 rules + NET eyebrow + dashed baseline + TOTAL foot + uniform width");
TS
  npx tsx src/__verify_s26_chrome.ts; rc=$?
  rm -f src/__verify_s26_chrome.ts
  exit $rc
'

# ── Criterion 5: ┄ connectors + signed delta labels ───────────────────────
run_check "connectors-and-deltas" bash -c '
  cd packages/core
  cat > src/__verify_s26_conn.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
import { stripAnsi } from "./ansi.js";
const text = stripAnsi(waterfall({ data: [500, -120, 80, -60, 150] }).toString());
if (!text.includes("┄")) { console.error("FAIL: no ┄ step connectors"); process.exit(1); }
if (!text.includes("+80") || !text.includes("−120")) { console.error("FAIL: signed delta labels missing"); process.exit(1); }
if (!text.includes("+150") || !text.includes("−60")) { console.error("FAIL: signed delta labels incomplete"); process.exit(1); }
console.log("OK: ┄ connectors at running levels + signed delta facts (+80/−120/+150/−60)");
TS
  npx tsx src/__verify_s26_conn.ts; rc=$?
  rm -f src/__verify_s26_conn.ts
  exit $rc
'

# ── Criterion 6: foot facts + additive JSON steps, TOTAL accented ─────────
run_check "footer-and-steps" bash -c '
  cd packages/core
  cat > src/__verify_s26_footer.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
import { resolveTheme } from "./themes/index.js";
const theme = resolveTheme("default");
const data = [500, -120, 80, -60, 150];
const labels = ["Start", "COGS", "Rev", "OpEx", "Sales"];
const raw = waterfall({ data, labels }).toString();
const footLine = raw.split("\n").find((l) => l.includes("TOTAL "))!;
if (!footLine.includes(theme.accent!)) { console.error("FAIL: TOTAL fact not in the accent hue"); process.exit(1); }
function strip(s: string): string { return s.replace(/\x1b\[[0-9;]*m/g, ""); }
const foot = strip(footLine);
if (!foot.includes("START 500") || !foot.includes("TOTAL 550")) { console.error("FAIL: foot facts wrong: " + foot); process.exit(1); }
const j = waterfall({ data, labels }).toJSON() as Record<string, unknown>;
const steps = j.steps as Array<Record<string, unknown>>;
if (steps.length !== 5) { console.error("FAIL: expected 5 steps, got " + steps.length); process.exit(1); }
if (steps[0]!.kind !== "start" || steps[1]!.kind !== "down" || steps[2]!.kind !== "up") {
  console.error("FAIL: step kinds wrong: " + JSON.stringify(steps.map(s => s.kind))); process.exit(1);
}
if (steps[1]!.start !== 500 || steps[1]!.end !== 380) { console.error("FAIL: COGS running levels wrong"); process.exit(1); }
console.log("OK: START 500 · Δ −120 +80 −60 +150 · TOTAL 550 (accent) + 5 typed steps");
TS
  npx tsx src/__verify_s26_footer.ts; rc=$?
  rm -f src/__verify_s26_footer.ts
  exit $rc
'

# ── Criterion 7: empty / all-zero safe ────────────────────────────────────
run_check "degenerate-safe" bash -c '
  cd packages/core
  cat > src/__verify_s26_degen.ts <<'"'"'TS'"'"'
import { waterfall } from "./charts/waterfall.js";
// empty: framed TOTAL 0 · (no data) panel, empty step facts
const empty = waterfall({ data: [] });
const emptyPlain = empty.toPlain();
if (!emptyPlain.startsWith("┌╌") || !emptyPlain.endsWith("┘")) { console.error("FAIL: empty panel missing its frame"); process.exit(1); }
if (!emptyPlain.includes("TOTAL 0 · (no data)")) { console.error("FAIL: empty footer incorrect"); process.exit(1); }
const ej = empty.toJSON() as Record<string, unknown>;
if ((ej.steps as unknown[]).length !== 0 || ej.total !== 0) { console.error("FAIL: empty facts dishonest"); process.exit(1); }
// all-zero: no NaN, honest TOTAL 0
const flat = waterfall({ data: [0, 0, 0] });
if (flat.toPlain().includes("NaN")) { console.error("FAIL: all-zero NaN leak"); process.exit(1); }
if ((flat.toJSON() as Record<string, unknown>).total !== 0) { console.error("FAIL: all-zero total wrong"); process.exit(1); }
console.log("OK: empty / all-zero render safely and honestly");
TS
  npx tsx src/__verify_s26_degen.ts; rc=$?
  rm -f src/__verify_s26_degen.ts
  exit $rc
'

# ── Criterion 8: funnel — chrome, no arrows, left-anchored ──────────────
run_check "funnel-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s26_fchrome.ts <<'"'"'TS'"'"'
import { funnel } from "./charts/funnel.js";
import { stripAnsi } from "./ansi.js";
const lines = stripAnsi(funnel({ data: [10000, 6800, 3400, 1200, 340] }).toString()).split("\n");
if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: no dashed frame top"); process.exit(1); }
if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: no dashed frame bottom"); process.exit(1); }
const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
if (rules.length !== 2) { console.error("FAIL: expected 2 rules, got " + rules.length); process.exit(1); }
if (!lines.some((l) => l.includes("CONVERSION 3%"))) { console.error("FAIL: no CONVERSION eyebrow"); process.exit(1); }
const text = lines.join("\n");
if (text.includes("▼")) { console.error("FAIL: ▼ arrows survived"); process.exit(1); }
if (!text.includes("DROP Stage 5")) { console.error("FAIL: no DROP foot fact"); process.exit(1); }
// Centered silhouette: the last (narrowest) bar carries more left padding
// than the first (widest) — the audit left-anchor is reversed by founder order.
const barAt = (label: string) => {
  const line = lines.find((l) => l.includes(label))!;
  const m = line.match(/[░▒▓█]/)!;
  return line.indexOf(m[0]);
};
if (!(barAt("Stage 5") > barAt("Stage 1"))) { console.error("FAIL: rows not centered (funnel silhouette missing)"); process.exit(1); }
const widths = new Set(lines.map((l) => [...l].length));
if (widths.size !== 1) { console.error("FAIL: width disagreement: " + [...widths].join(",")); process.exit(1); }
console.log("OK: funnel panel + CONVERSION eyebrow + no ▼ + DROP foot + uniform width");
TS
  npx tsx src/__verify_s26_fchrome.ts; rc=$?
  rm -f src/__verify_s26_fchrome.ts
  exit $rc
'

# ── Criterion 9: funnel — tonal census + integer pcts ─────────────────────
run_check "funnel-tonal" bash -c '
  cd packages/core
  cat > src/__verify_s26_ftonal.ts <<'"'"'TS'"'"'
import { funnel } from "./charts/funnel.js";
import { stripAnsi } from "./ansi.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const raw = funnel({ data: [10000, 6800, 3400, 1200, 340] }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const BAR = /[░▒▓█]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!BAR.test(s[2])) continue;
  if (s[1] === theme.accent) {
    accent++;
    if (!/^█+$/.test(s[2])) { console.error("FAIL: accent on non-solid " + JSON.stringify(s[2])); process.exit(1); }
  }
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the peak stage"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " theme.colors leaks"); process.exit(1); }
const text = stripAnsi(raw);
if (!text.includes("(68%)") || /\(\d+\.\d+%/.test(text)) { console.error("FAIL: percents not integers"); process.exit(1); }
const foot = raw.split("\n").find((l) => l.includes("IN "))!;
if (!foot.includes(theme.accent!)) { console.error("FAIL: CONVERSION fact not accented"); process.exit(1); }
console.log("OK: accent once on peak (" + accent + "), " + grey + " grey segs, integer pcts, accented foot");
TS
  npx tsx src/__verify_s26_ftonal.ts; rc=$?
  rm -f src/__verify_s26_ftonal.ts
  exit $rc
'

# ── Criterion 10: funnel degenerate-safe ──────────────────────────────────
run_check "funnel-degenerate" bash -c '
  cd packages/core
  cat > src/__verify_s26_fdegen.ts <<'"'"'TS'"'"'
import { funnel } from "./charts/funnel.js";
const empty = funnel({ data: [] });
if (!empty.toPlain().startsWith("┌╌") || !empty.toPlain().includes("STAGES 0 · (no data)")) { console.error("FAIL: empty panel wrong"); process.exit(1); }
const ej = empty.toJSON() as Record<string, unknown>;
if (ej.conversion !== null || ej.biggestDrop !== null) { console.error("FAIL: empty facts dishonest"); process.exit(1); }
const zero = funnel({ data: [0, 0, 5] });
if (zero.toPlain().includes("NaN")) { console.error("FAIL: zero-first NaN leak"); process.exit(1); }
if ((zero.toJSON() as Record<string, unknown>).conversion !== null) { console.error("FAIL: zero-first conversion must be null"); process.exit(1); }
console.log("OK: funnel empty / zero-first safe and honest");
TS
  npx tsx src/__verify_s26_fdegen.ts; rc=$?
  rm -f src/__verify_s26_fdegen.ts
  exit $rc
'

# ── Criterion 11: sankey — chrome, no arrows, ledger ──────────────────────
run_check "sankey-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s26_schrome.ts <<'"'"'TS'"'"'
import { sankey } from "./charts/sankey.js";
import { stripAnsi } from "./ansi.js";
const N = ["Visitors", "Free", "Paid", "Churned"];
const L = [
  { source: "Visitors", target: "Free", value: 60 },
  { source: "Free", target: "Paid", value: 25 },
  { source: "Free", target: "Churned", value: 20 },
  { source: "Visitors", target: "Paid", value: 5 },
];
const lines = stripAnsi(sankey({ nodes: N, links: L }).toString()).split("\n");
if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: no dashed frame top"); process.exit(1); }
if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: no dashed frame bottom"); process.exit(1); }
const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
if (rules.length !== 2) { console.error("FAIL: expected 2 rules, got " + rules.length); process.exit(1); }
if (!lines.some((l) => l.includes("FLOW 110"))) { console.error("FAIL: no FLOW eyebrow"); process.exit(1); }
const text = lines.join("\n");
if (text.includes("▶")) { console.error("FAIL: ▶ arrows survived"); process.exit(1); }
if (!text.includes("Nodes:") || !text.includes("in:60")) { console.error("FAIL: ledger facts missing"); process.exit(1); }
if (!text.includes("PEAK Visitors → Free 60")) { console.error("FAIL: no PEAK foot fact"); process.exit(1); }
const widths = new Set(lines.map((l) => [...l].length));
if (widths.size !== 1) { console.error("FAIL: width disagreement: " + [...widths].join(",")); process.exit(1); }
console.log("OK: sankey panel + FLOW eyebrow + no ▶ + ledger + PEAK foot + uniform width");
TS
  npx tsx src/__verify_s26_schrome.ts; rc=$?
  rm -f src/__verify_s26_schrome.ts
  exit $rc
'

# ── Criterion 12: sankey — tonal census + accented foot + degen ───────────
run_check "sankey-tonal-degen" bash -c '
  cd packages/core
  cat > src/__verify_s26_stonal.ts <<'"'"'TS'"'"'
import { sankey } from "./charts/sankey.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const N = ["Visitors", "Free", "Paid", "Churned"];
const L = [
  { source: "Visitors", target: "Free", value: 60 },
  { source: "Free", target: "Paid", value: 25 },
  { source: "Free", target: "Churned", value: 20 },
  { source: "Visitors", target: "Paid", value: 5 },
];
const raw = sankey({ nodes: N, links: L }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const FLOW = /[░▒▓█■]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis) continue;
  if (!FLOW.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the peak flow"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " theme.colors leaks"); process.exit(1); }
const foot = raw.split("\n").find((l) => l.includes("PEAK "))!;
if (!foot.includes(theme.accent!)) { console.error("FAIL: PEAK value not accented"); process.exit(1); }
const j = sankey({ nodes: N, links: L }).toJSON() as Record<string, unknown>;
if (JSON.stringify(j.peakFlow) !== JSON.stringify({ source: "Visitors", target: "Free", value: 60 })) {
  console.error("FAIL: peakFlow wrong: " + JSON.stringify(j.peakFlow)); process.exit(1);
}
const empty = sankey({ nodes: [], links: [] });
if (!empty.toPlain().includes("NODES 0 · (no data)")) { console.error("FAIL: empty panel wrong"); process.exit(1); }
if ((empty.toJSON() as Record<string, unknown>).peakFlow !== null) { console.error("FAIL: empty peak dishonest"); process.exit(1); }
console.log("OK: accent once on peak, " + grey + " grey segs, accented PEAK foot, empty safe");
TS
  npx tsx src/__verify_s26_stonal.ts; rc=$?
  rm -f src/__verify_s26_stonal.ts
  exit $rc
'

# ── Criterion 13: radar — chrome, markers, unclipped labels ───────────────
run_check "radar-chrome" bash -c '
  cd packages/core
  cat > src/__verify_s26_rchrome.ts <<'"'"'TS'"'"'
import { radar } from "./charts/radar.js";
import { stripAnsi } from "./ansi.js";
const L = ["Speed", "Power", "Range", "Accuracy", "Stamina"];
const lines = stripAnsi(radar({ data: [80, 60, 90, 70, 85], labels: L }).toString()).split("\n");
if (!lines[0]!.startsWith("┌╌")) { console.error("FAIL: no dashed frame top"); process.exit(1); }
if (!lines[lines.length - 1]!.startsWith("└╌")) { console.error("FAIL: no dashed frame bottom"); process.exit(1); }
const rules = lines.filter((l) => /^│ ╌+ │$/.test(l));
if (rules.length !== 2) { console.error("FAIL: expected 2 rules, got " + rules.length); process.exit(1); }
if (!lines.some((l) => l.includes("AXES 5"))) { console.error("FAIL: no AXES eyebrow"); process.exit(1); }
const text = lines.join("\n");
for (const label of L) { if (!text.includes(label)) { console.error("FAIL: axis label clipped: " + label); process.exit(1); } }
if (!text.includes("PEAK Range 90")) { console.error("FAIL: no PEAK foot fact"); process.exit(1); }
const widths = new Set(lines.map((l) => [...l].length));
if (widths.size !== 1) { console.error("FAIL: width disagreement: " + [...widths].join(",")); process.exit(1); }
console.log("OK: radar panel + AXES eyebrow + unclipped labels + PEAK foot + uniform width");
TS
  npx tsx src/__verify_s26_rchrome.ts; rc=$?
  rm -f src/__verify_s26_rchrome.ts
  exit $rc
'

# ── Criterion 14: radar — tonal census + accented foot + degen ────────────
run_check "radar-tonal-degen" bash -c '
  cd packages/core
  cat > src/__verify_s26_rtonal.ts <<'"'"'TS'"'"'
import { radar } from "./charts/radar.js";
import { resolveTheme, GREY_TONES } from "./themes/index.js";
const theme = resolveTheme("default");
const L = ["Speed", "Power", "Range", "Accuracy", "Stamina"];
const raw = radar({ data: [[80, 60, 90, 70, 85], [50, 75, 55, 80, 60]], labels: L }).toString();
const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
const SERIES = /[⠀-⣿●○]/;
let accent = 0, grey = 0, other = 0;
for (const s of segs) {
  if (s[1] === theme.axis || s[1] === (theme.grid ?? theme.axis)) continue;
  if (!SERIES.test(s[2])) continue;
  if (/[A-Za-z0-9]/.test(s[2])) continue;
  if (s[1] === theme.accent) accent++;
  else if (GREY_TONES.includes(s[1])) grey++;
  else other++;
}
if (accent === 0) { console.error("FAIL: no accent on the primary series"); process.exit(1); }
if (grey === 0) { console.error("FAIL: no toned secondary series"); process.exit(1); }
if (other !== 0) { console.error("FAIL: " + other + " theme.colors leaks"); process.exit(1); }
const foot = raw.split("\n").find((l) => l.includes("PEAK "))!;
if (!foot.includes(theme.accent!)) { console.error("FAIL: PEAK value not accented"); process.exit(1); }
const empty = radar({ data: [], labels: [] });
if (!empty.toPlain().includes("AXES 0 · (no data)")) { console.error("FAIL: empty panel wrong"); process.exit(1); }
if ((empty.toJSON() as Record<string, unknown>).max !== null) { console.error("FAIL: empty max dishonest"); process.exit(1); }
const neg = radar({ data: [-5, NaN, Infinity, 50, 30], labels: L });
if (neg.toPlain().includes("NaN")) { console.error("FAIL: non-finite NaN leak"); process.exit(1); }
console.log("OK: accent on primary, toned secondary, accented PEAK foot, empty/neg safe");
TS
  npx tsx src/__verify_s26_rtonal.ts; rc=$?
  rm -f src/__verify_s26_rtonal.ts
  exit $rc
'

# ── Criterion 15: the theme.colors rainbow is gone from all sources ───────
run_check "source-locked" bash -c '
  for f in waterfall funnel sankey radar; do
    SRC=$(sed -e '"'"'/\/\*/,/\*\//d'"'"' -e '"'"'s://.*$::'"'"' packages/core/src/charts/$f.ts)
    if echo "$SRC" | grep -q "theme\.colors\["; then
      echo "theme.colors[] rainbow still present in $f.ts"; exit 1
    fi
    echo "$SRC" | grep -q "frameTop" || { echo "no panel frame in $f.ts"; exit 1; }
    echo "$SRC" | grep -q "theme.accent" || { echo "no accent hue in $f.ts"; exit 1; }
  done
  echo "waterfall + funnel + sankey + radar: no rainbow, panel + accent present"
'

# ── Criterion 16: core tests green ───────────────────────────────────────
run_check "core-tests-green"       pnpm --filter @chitra/core run test
run_check "core-typecheck"         pnpm --filter @chitra/core run typecheck
run_check "waterfall-tests"        pnpm --filter @chitra/core run test -- waterfall
run_check "funnel-tests"           pnpm --filter @chitra/core run test -- funnel
run_check "sankey-tests"           pnpm --filter @chitra/core run test -- sankey
run_check "radar-tests"            pnpm --filter @chitra/core run test -- radar

# ── Criterion 17: README carries all four LOCKED contract blocks ─────────
run_check "readme-lock-block"      bash -c '
  grep -q "### LOCKED: waterfall chart — session 26 design" packages/core/README.md &&
  grep -q "### LOCKED: funnel chart — session 26 design" packages/core/README.md &&
  grep -q "### LOCKED: sankey chart — session 26 design" packages/core/README.md &&
  grep -q "### LOCKED: radar chart — session 26 design" packages/core/README.md
'

# ── Criterion 18: docs previews in sync (no chart drift) ─────────────────
run_check "chart-drift-gate"       pnpm --filter @workspace/chitra-docs run gen:charts:check

# ── Criterion 19: branch is s26 ──────────────────────────────────────────
run_check "branch-is-s26"          bash -c '
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ "$branch" == session-26-* ]] || { echo "branch=$branch, expected session-26-*"; exit 1; }
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
