#!/usr/bin/env bash
# S48 demo — the GTM proof pack.
# Cumulative: what a stranger can now check that no session could before.
# Every row is PROBED, not typed (the S46 fakest-green fix): row() prints SHIPPED
# only when its probe exits 0 AND its last line is exactly `ok`, else NOT PROVEN
# and exit 1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAILS=0
row() {
  local label="$1"; shift
  local out rc=0
  out="$("$@" 2>/dev/null)" || rc=$?
  local last; last="$(printf '%s\n' "$out" | tail -1)"
  if [ "$rc" -eq 0 ] && [ "$last" = "ok" ]; then
    printf '%s\n' "$out" | sed '$d' | sed 's/^/  | /'
    printf '%-34s %s\n' "$label" "SHIPPED"
  else
    printf '%-34s %s\n' "$label" "NOT PROVEN — ${out:-exit $rc}"
    FAILS=$((FAILS+1))
  fi
}

p_r1() {  # claims derive from their source
  local charts renderers themes deps tests license version
  charts=$(grep -cE '^export \{ [a-z]' packages/core/src/charts/index.ts)
  renderers=$(grep -m1 'export type RendererType' packages/core/src/types.ts | grep -oE '"[a-z]+"' | grep -c .)
  read -r themes deps license version <<<"$(node -e '
    const m=require("./packages/core/package.json"), c=require("./packages/core/dist/index.cjs");
    console.log(Object.keys(c.themes).length, Object.keys(m.dependencies||{}).length, m.license, m.version);')"
  tests=$(grep -m1 -oE 'tests-[0-9]+' README.md | grep -oE '[0-9]+')
  # Anchored extraction (pass-2 NEW-A/NEW-B): a substring grep let a badge read 200
  # charts and a table cell 13 renderers while the gate stayed green.
  local b_charts b_url b_types b_renderers b_deps b_license
  b_charts=$(grep -m1 -oE '!\[charts: [0-9]+\]' README.md | sed -E 's/[^0-9]*([0-9]+).*/\1/') || return 1
  b_url=$(grep -m1 -oE 'badge/charts-[0-9]+' README.md | sed -E 's#.*charts-##') || return 1
  b_types=$(grep -m1 -oE '\| \*\*[0-9]+ chart types\*\* \|' README.md | grep -oE '[0-9]+') || return 1
  b_renderers=$(grep -m1 -oE '\| \*\*[0-9]+ renderers\*\* \|' README.md | grep -oE '[0-9]+') || return 1
  b_deps=$(grep -m1 -oE '!\[dependencies: [0-9]+\]' README.md | sed -E 's/[^0-9]*([0-9]+).*/\1/') || return 1
  b_license=$(grep -m1 -oE '!\[license: [^]]+\]' README.md | sed -E 's/^!\[license: //; s/\]$//') || return 1
  [ "$b_charts" = "$charts" ] || return 1
  [ "$b_url" = "$charts" ] || return 1
  [ "$b_types" = "$charts" ] || return 1
  [ "$b_renderers" = "$renderers" ] || return 1
  [ "$b_deps" = "$deps" ] || return 1
  [ "$b_license" = "$license" ] || return 1
  grep -qF "all ${charts} charts" README.md || return 1
  grep -qF "all ${charts} charts" .ai/KNOWLEDGE.md || return 1
  grep -qF "**${charts} Chart Types:**" packages/core/README.md || return 1
  grep -qF "badge/license-${license}-" README.md || return 1
  grep -qF "## [${version}]" packages/core/CHANGELOG.md || return 1
  node -e '
    const s=require("fs").readFileSync("artifacts/chitra-docs/src/App.tsx","utf8");
    const need=process.argv.slice(1);
    for (const n of need) if (!s.includes(`<span className="stat-num">${n}</span>`)) process.exit(1);
  ' "$charts" "$renderers" "$themes" || return 1
  echo "charts=$charts renderers=$renderers themes=$themes deps=$deps tests=$tests license=$license version=$version — all six badge/cell values extracted and equal"
  echo ok
}
p_r2() {  # adoption, read for the dates the record claims
  local t1 t1day t0 t0day
  t1=$(grep -m1 -oE 't1 = [0-9]+' .ai/STATE.md | sed -E 's/.*= //')
  t1day=$(grep -m1 -oE 'through \*\*[0-9-]+\*\*' .ai/STATE.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  t0=$(grep -m1 -oE '`t0` = [0-9]+' .ai/STATE.md | sed -E 's/.*= //')
  t0day=$(grep -m1 -oE '\-\-as-of [0-9]{4}-[0-9]{2}-[0-9]{2}' .ai/STATE.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  [ "$(node scripts/gtm-reads.mjs --as-of "$t1day" | grep -m1 '^total=')" = "total=$t1" ] || return 1
  [ "$(node scripts/gtm-reads.mjs --as-of "$t0day" | grep -m1 '^total=')" = "total=$t0" ] || return 1
  local since; since=$(node scripts/gtm-reads.mjs | grep -m1 '^days-since-last-non-zero=' | cut -d= -f2)
  echo "t0=$t0 ($t0day) and t1=$t1 ($t1day) re-derive; $since day(s) with no download"
  echo ok
}
p_r3() {  # benchmarks, measured now
  local out
  out=$(node scripts/gtm-bench.mjs --json) || return 1
  local deps tkb ukb files budget
  read -r deps tkb ukb files budget <<<"$(printf '%s' "$out" | node -e '
    let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const j=JSON.parse(s);
    console.log(j.deps,j["tarball-kb"],j["unpacked-kb"],j["pack-files"],j["render-budget-ms"]);})')"
  grep -qF "| **Runtime dependencies** | **${deps}** |" README.md || return 1
  grep -qF "**${tkb} KB** gzip tarball" README.md || return 1
  grep -qF "**${ukb} KB** unpacked, ${files} files" README.md || return 1
  grep -qF "node scripts/gtm-bench.mjs" README.md || return 1
  echo "${deps} deps, ${tkb} KB packed, ${ukb} KB / ${files} files installed, ≤${budget} ms — cited with the command"
  echo ok
}
p_r4() {  # one channel, live, with its date and its reader
  local url code
  url=$(grep -m1 -oE 'https://www\.linkedin\.com/posts/[A-Za-z0-9_/-]+' .ai/STATE.md || true)
  [ -n "$url" ] || return 1
  grep -q 'published 2026-10-06' .ai/STATE.md || return 1
  grep -A7 -i 'one channel is live' .ai/STATE.md | grep -q 'gtm-reads' || return 1
  code=$(curl -s -o /dev/null -m 20 -L -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36' -w '%{http_code}' "$url" || echo 000)
  [ "$code" = "200" ] || return 1
  echo "post live → 200; published 2026-10-06; days after it read with gtm-reads"
  echo ok
}
p_r5() {  # first screen: install, live link, example still true
  grep -qE '(pnpm add|npm install|npm i) @ifelse\.codes/chitra' README.md || return 1
  local code; code=$(curl -s -o /dev/null -m 20 -w '%{http_code}' https://chitra.iifelse.com || echo 000)
  [ "$code" = "200" ] || return 1
  local live want
  live=$(mktemp); want=$(mktemp)
  node -e '
    const { line } = require("./packages/core/dist/index.cjs");
    line({ data: [12,19,14,27,22,34,29,41], title: "Weekly active users", noColor: true }).render();
  ' > "$live" 2>/dev/null || { rm -f "$live" "$want"; return 1; }
  awk '/^```text$/{f=1;next} /^```$/{if(f)exit} f' README.md > "$want"
  diff <(sed -e 's/[[:space:]]*$//' "$live") <(sed -e 's/[[:space:]]*$//' "$want") >/dev/null \
    || { rm -f "$live" "$want"; return 1; }
  rm -f "$live" "$want"
  echo "install line present; docs link 200; README example == live render"
  echo ok
}
p_r6() {  # the record only carries derived numbers
  grep -A3 'GTM proof pack' .ai/ROADMAP.md | grep -q 'gtm-reads' || return 1
  grep -A3 'GTM proof pack' .ai/ROADMAP.md | grep -q 'gtm-bench' || return 1
  local files=(.ai/STATE.md .ai/ROADMAP.md .ai/KNOWLEDGE.md .ai/TASK.md
               .ai/SESSION-BOOT.md .ai/CONTINUATION-PROMPT.md .ai/GT-REMEDIATIONS.md
               sessions/session-48-summary.md)
  local f line hits h n bad=""
  for f in "${files[@]}"; do
    [ -f "$f" ] || return 1
    hits=$(grep -hiE 'downloads' "$f" 2>/dev/null \
           | awk '/^\|/{gsub(/`[^`]*`/,"")} {print}' \
           | grep -oE '[0-9]{3,}[^0-9]{0,25}downloads|downloads[^0-9]{0,25}[0-9]{3,}' || true)
    while IFS= read -r h; do
      [ -n "$h" ] || continue
      n=$(printf '%s' "$h" | grep -oE '[0-9]{3,}' | sed -n '1p')
      if [ "$f" = ".ai/GT-REMEDIATIONS.md" ]; then
        grep -F "$h" "$f" | grep -qE '⚠|FALSIFIED|→|re-probe|re-derived|derive|≠|not [0-9]' || bad="$bad $f:'$h'"
      else
        case "$n" in 119|273) : ;; *) bad="$bad $f:'$h'" ;; esac
      fi
    done <<< "$hits"
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      case "$line" in
        *superseded*|*false*|*"not zero"*|*must\ not*|*FALSIFIED*|*⚠*) : ;;
        *) bad="$bad $f:(zero-claim)" ;;
      esac
    done < <(awk '
      function flush() { if (buf != "") { print buf; buf = "" } }
      /baseline (of|is) zero/ { flush(); buf = $0; pending = 2; next }
      pending > 0 { buf = buf " " $0; pending--; if (pending == 0) flush(); next }
      END { flush() }' "$f" 2>/dev/null || true)
  done
  [ -z "$bad" ] || return 1
  grep -qi 'never cite' .ai/STATE.md || return 1
  echo "8 live files: only 119/273 (table-quoted stimuli stripped; ledger needs markers), zero-claims superseded, guard present"
  echo ok
}

echo "=== S48 demo: the GTM proof pack ==="
echo ""
echo "Before → after (each line re-derived above):"
echo "  public claims:   typed badges  ->  derived from source, 4 ways to fake them proved red"
echo "  adoption:        a number in a file -> gtm-reads, dated, t0 re-derived exactly"
echo "  benchmarks:      absent         -> 4 figures, each printed by gtm-bench.mjs"
echo "  the record:      any figure     -> only figures an instrument prints"
echo ""
row "R1 claims derive from source" p_r1
row "R2 adoption read, not asserted" p_r2
row "R3 benchmarks measured" p_r3
row "R4 one channel live" p_r4
row "R5 first screen probed" p_r5
row "R6 record is derived-only" p_r6

echo ""
if [ "$FAILS" -eq 0 ]; then echo "DEMO: all rows SHIPPED (probed)."; exit 0
else echo "DEMO: $FAILS row(s) NOT PROVEN."; exit 1; fi
