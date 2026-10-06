#!/usr/bin/env node
// S48 R2 — the adoption reading, derived (never asserted).
//
//   node scripts/gtm-reads.mjs [--as-of YYYY-MM-DD] [--start YYYY-MM-DD] [--json]
//
// What it answers, in one run:
//   * how many downloads, day by day, since the package existed;
//   * which of those days a RELEASE happened (npm registry publish time) — those
//     are ours: CI runners, the founder, dependency scanners triggered by a bump;
//   * how many days have passed with nothing, which is the only line that can
//     ever become a real signal.
//
// Why it exists: S40 read the baseline for the first time, S45 corrected it
// ("zero" was false — it was 119), and S46 recorded t0 = 119, none organic.
// Every one of those was a number typed into a file. This prints them instead.
//
// Exit codes: 0 = read cleanly, 1 = a fetch or a derivation failed.

const PKG = "@ifelse.codes/chitra";
const REGISTRY_TIME_URL = "https://registry.npmjs.org/" + PKG.replace("/", "%2f");

function arg(name, fallback) {
  const i = process.argv.indexOf(name);
  return i === -1 ? fallback : process.argv[i + 1];
}

const asOf = arg("--as-of", new Date().toISOString().slice(0, 10));
const start = arg("--start", "2026-09-15"); // the day before the first publish (2026-09-29)
const asJson = process.argv.includes("--json");

async function main() {
  const rangeUrl = `https://api.npmjs.org/downloads/range/${start}:${asOf}/${PKG}`;
  const [rangeRes, timeRes] = await Promise.all([
    fetch(rangeUrl),
    fetch(REGISTRY_TIME_URL),
  ]);
  if (!rangeRes.ok) throw new Error(`downloads range → HTTP ${rangeRes.status}`);
  if (!timeRes.ok) throw new Error(`registry time → HTTP ${timeRes.status}`);

  const range = await rangeRes.json();
  const times = await timeRes.json();

  // Publish days: version publish timestamps, UTC calendar days.
  const releases = Object.entries(times.time || times)
    .filter(([v]) => /^\d+\.\d+\.\d+$/.test(v))
    .map(([version, iso]) => ({ version, day: iso.slice(0, 10) }))
    .filter((r) => r.day >= start && r.day <= asOf)
    .sort((a, b) => a.day.localeCompare(b.day));
  const releaseDays = new Map(releases.map((r) => [r.day, r.version]));

  const days = range.downloads;
  const total = days.reduce((a, d) => a + d.downloads, 0);
  const nonZero = days.filter((d) => d.downloads > 0);
  const releaseTotal = days
    .filter((d) => releaseDays.has(d.day))
    .reduce((a, d) => a + d.downloads, 0);
  const lastNonZero = nonZero.length ? nonZero[nonZero.length - 1] : null;
  const daysSinceLast = lastNonZero
    ? Math.round(
        (Date.parse(asOf) - Date.parse(lastNonZero.day)) / 86400000
      )
    : null;

  if (asJson) {
    console.log(
      JSON.stringify(
        {
          pkg: PKG,
          start,
          asOf,
          total,
          nonZeroDays: nonZero.length,
          firstNonZero: nonZero[0] || null,
          lastNonZero,
          releaseDays: releases,
          releaseTotal,
          organicCandidateTotal: total - releaseTotal,
          daysSinceLastNonZero: daysSinceLast,
        },
        null,
        2
      )
    );
    return;
  }

  console.log(`package=${PKG}`);
  console.log(`window=${start}..${asOf}`);
  console.log(`total=${total}`);
  console.log(`non-zero-days=${nonZero.length}`);
  console.log(
    `first-non-zero=${nonZero[0] ? `${nonZero[0].day}=${nonZero[0].downloads}` : "none"}`
  );
  console.log(
    `last-non-zero=${lastNonZero ? `${lastNonZero.day}=${lastNonZero.downloads}` : "none"}`
  );
  console.log(`days-since-last-non-zero=${daysSinceLast}`);
  console.log(
    `release-days=${releases.map((r) => `${r.day}(${r.version})`).join(",") || "none"}`
  );
  console.log(`release-shaped-total=${releaseTotal}`);
  console.log(`non-release-total=${total - releaseTotal}`);
  for (const d of days) {
    if (d.downloads === 0) continue;
    const tag = releaseDays.has(d.day) ? "release" : "other";
    console.log(`day ${d.day} ${d.downloads} ${tag}`);
  }
  console.log(
    `verdict=${total === 0 ? "no downloads yet" : daysSinceLast > 0 && nonZero.length === releases.length ? "every non-zero day is a release day" : "see days above"}`
  );
}

main().catch((err) => {
  console.error(`gtm-reads failed: ${err.message}`);
  process.exit(1);
});
