import { describe, it, expect } from "vitest";
import { progress } from "../src/charts/progress.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

function plainLines(opts: Parameters<typeof progress>[0]): string[] {
  return stripAnsi(progress(opts).toString()).split("\n");
}

// A progress fill is a run of shade-ramp glyphs (░▒▓█) ending in a solid `█`
// edge; the `─` track is scale, not fill. The fill's leading edge is the accent.
const RAMP = /[░▒▓█]/;

/** Count coloured RAMP segments by category: how many carry the accent code vs
 *  a grey-ramp code vs anything else. This is the S17 raw-ANSI census method —
 *  the accent must be spent on EXACTLY one bar segment (the leading edge), and
 *  the fill must be a documented grey tone (never a `theme.colors` band
 *  rainbow). The `─` track (axis colour), guide, scale and footer are excluded. */
function accentCensus(opts: Parameters<typeof progress>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const acc = theme.accent!;
  const out = progress(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (!RAMP.test(body)) continue; // count bar segments only, not track/guide/footer
    if (code === acc) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("progress chart — locked S23 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ value: 87 })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ value: 87 });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ value: 87 }).filter((l) => /^│ ╌/.test(l));
    expect(rules.length).toBe(1);
  });

  it("has the uppercase eyebrow row (PROGRESS; opts.label uppercases)", () => {
    expect(stripAnsi(progress({ value: 87 }).toString())).toMatch(/PROGRESS/);
    expect(stripAnsi(progress({ value: 87, label: "build" }).toString())).toMatch(/BUILD/);
  });

  it("carries the +╌…╌+ guide and a 0..max scale row under the bar", () => {
    const plain = stripAnsi(progress({ value: 87, max: 100 }).toString());
    expect(plain).toMatch(/\+╌+\+/);
    expect(plain).toMatch(/0\s+100/);
  });

  it("keeps the ─ scale track so the level reads against the full range", () => {
    const rows = plainLines({ value: 87 }).filter((l) => /^│ +[░▒▓█]/.test(l));
    expect(rows.length).toBe(1); // one bar row
    expect(rows[0]).toMatch(/[░▒▓█]─/); // fill meets the dim scale track
  });

  it("renders every panel row at the same visible width", () => {
    const widths = new Set(plainLines({ value: 87 }).map((l) => l.length));
    expect(widths.size).toBe(1);
  });

  // ── Intensity IS the shade ramp (the heatmap/gauge texture language) ──
  it("encodes the level as the shade ramp, light → dark (░▒▓)", () => {
    const rowFor = (value: number) =>
      plainLines({ value, max: 100 }).find((l) => RAMP.test(l))!;
    expect(rowFor(20)).toMatch(/░+█/); // bucket 0 fill + solid edge
    expect(rowFor(45)).toMatch(/▒+█/); // bucket 1
    expect(rowFor(70)).toMatch(/▓+█/); // bucket 2
    expect(rowFor(95)).toMatch(/█+█/); // bucket 3 = darkest, solid
  });

  it("uses ONLY documented ramp glyphs as fill — no phantom texture", () => {
    const ANSI = /\x1b\[[0-9;]*m|\x1b\[0m/g;
    const out = progress({ value: 87 }).toString();
    for (const row of out.split("\n").filter((l) => RAMP.test(l))) {
      const residue = row.replace(ANSI, "").replace(/[A-Za-z0-9 +.,%_…\-│┌┐└┘╌─]/g, "");
      expect(residue).toMatch(/^[░▒▓█]*$/);
    }
  });

  it("the ramp survives noColor — the plain render still reads the level", () => {
    const plain = progress({ value: 45, noColor: true }).toPlain();
    expect(plain).not.toMatch(/\x1b\[/);
    expect(plain).toMatch(/▒+█/);
    expect(plain).toMatch(/─/);
  });

  // ── The one accent, spent once on the fill's leading edge ─────
  it("spends the accent hue EXACTLY once — one solid █ edge, no rainbow leak", () => {
    const c = accentCensus({ value: 87 });
    expect(c.accent).toBe(1);
    expect(c.other).toBe(0); // the fill is a documented grey tone, nothing else
    expect(c.grey).toBe(1);
  });

  it("the accent segment is the single-block leading edge of the fill", () => {
    const acc = resolveTheme(undefined).accent!;
    const out = progress({ value: 73 }).toString(); // bucket 2 fill, so the edge reads against ▓
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const accentSegs = segs.filter((s) => s[1] === acc && RAMP.test(s[2]!));
    expect(accentSegs.length).toBe(1);
    expect(accentSegs[0]![2]).toBe("█");
    // the edge sits at the END of the fill run (right before the ─ track)
    expect(stripAnsi(out)).toMatch(/[░▒▓]█─/);
  });

  it("every bar colour is the accent or a documented grey tone", () => {
    const acc = resolveTheme(undefined).accent!;
    const out = progress({ value: 87 }).toString();
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const barCodes = new Set(segs.filter((s) => RAMP.test(s[2]!)).map((s) => s[1]!));
    for (const code of barCodes) {
      expect(code === acc || GREY_TONES.includes(code)).toBe(true);
    }
  });

  it("the style option stays accepted but the locked design supersedes it", () => {
    for (const style of ["bar", "blocks", "braille", "ascii"] as const) {
      const out = progress({ value: 87, style }).toString();
      expect(out).toBeTruthy();
      // every style renders the SAME locked shade-ramp panel
      expect(stripAnsi(progress({ value: 73, style }).toString())).toMatch(/[░▒▓]█─/);
      expect(accentCensus({ value: 87, style }).accent).toBe(1);
    }
    // the ascii style's =/. glyphs and the sub-block texture are retired
    const ascii = stripAnsi(progress({ value: 87, style: "ascii" }).toString());
    expect(ascii).not.toMatch(/=/);
    expect(ascii).not.toMatch(/[▁▂▃▄▅▆▇]/);
  });

  // ── Retired glyphs: the naked [bar] pct line is gone ──────────
  it("retires the naked [ … ] bracket bar — no off-vocabulary glyphs", () => {
    const plain = stripAnsi(progress({ value: 87 }).toString());
    expect(plain).not.toMatch(/\[/);
    expect(plain).not.toMatch(/\]/);
  });

  // ── Summary footer ────────────────────────────────────────────
  it("footer reports V of 0..max · pct with the reading accented", () => {
    const plain = stripAnsi(progress({ value: 87, max: 100 }).toString());
    expect(plain).toMatch(/87 of 0\.\.100 · 87\.0%/);
    const acc = resolveTheme(undefined).accent!;
    const raw = progress({ value: 87 }).toString();
    expect(raw).toContain(`${acc}87`);
  });

  it("showPercent: false drops the pct fact from the footer, keeps the rest", () => {
    const plain = stripAnsi(progress({ value: 87, showPercent: false }).toString());
    expect(plain).toMatch(/87 of 0\.\.100/);
    expect(plain).not.toMatch(/%/);
    // the agent surface still carries percent — additive, never removed
    const json = progress({ value: 87, showPercent: false }).toJSON() as Record<string, unknown>;
    expect(json.percent).toBe(87);
  });

  // ── Out-of-range: clipped on the bar, HONEST in footer + toJSON ──
  it("a value past max clips at full width — and the footer reports the TRUE percent", () => {
    const c = accentCensus({ value: 140, max: 100 });
    expect(c.accent).toBe(1);
    const plain = stripAnsi(progress({ value: 140, max: 100 }).toString());
    expect(plain).toMatch(/140 of 0\.\.100 · 140\.0%/); // honest percent, not a silent clamp
    const row = plain.split("\n").find((l) => RAMP.test(l))!;
    expect(row).not.toMatch(/[░▒▓█]─/); // no track left — the bar is full
  });

  it("a negative value renders an empty track, honestly reported", () => {
    const out = progress({ value: -10, max: 100 }).toString();
    expect(out).toBeTruthy(); // no negative-repeat RangeError
    const plain = stripAnsi(out);
    expect(plain).toMatch(/-10 of 0\.\.100 · -10\.0%/);
    expect(plain.split("\n").some((l) => /^│ ─+ │$/.test(l))).toBe(true); // bar row = all dim track
  });

  // ── Degenerate data is safe ───────────────────────────────────
  it("a collapsed range (max == min == 0) never divides by zero", () => {
    const full = stripAnsi(progress({ value: 50, max: 0 }).toString());
    expect(full).not.toMatch(/NaN|Infinity/);
    expect(accentCensus({ value: 50, max: 0 }).accent).toBe(1); // reading reaches max → full
    const empty = stripAnsi(progress({ value: -1, max: 0 }).toString());
    expect(empty).not.toMatch(/NaN|Infinity/);
    expect(empty).toMatch(/-1 of 0\.\.0 · 0\.0%/); // below the point → empty
  });

  it("a non-finite value renders a framed n/a panel — never NaN", () => {
    const plain = stripAnsi(progress({ value: NaN, max: 100 }).toString());
    expect(plain).not.toMatch(/NaN|Infinity/);
    expect(plain).toMatch(/n\/a of 0\.\.100/);
    expect(plain).toMatch(/^┌╌/m);
    expect(plain).toMatch(/^└╌/m);
  });

  it("a tiny explicit width still renders a consistent panel", () => {
    const widths = new Set(plainLines({ value: 87, width: 12 }).map((l) => l.length));
    expect(widths.size).toBe(1);
    expect(plainLines({ value: 87, width: 12 })[0]).toMatch(/^┌╌/);
  });

  // ── Agent output surface ──────────────────────────────────────
  it("toJSON carries type/value/max/percent/bucket/plain", () => {
    const json = progress({ value: 70, max: 100 }).toJSON() as Record<string, unknown>;
    expect(json.type).toBe("progress");
    expect(json.value).toBe(70);
    expect(json.max).toBe(100);
    expect(json.percent).toBe(70);
    expect(json.bucket).toBe(2); // 0.70 → ▓ bucket
    expect(typeof json.plain).toBe("string");
    expect(stripAnsi(json.plain as string)).toBe(json.plain);
  });

  it("toJSON reports the TRUE value — the old silent clamp is retired as a lie", () => {
    const json = progress({ value: 200, max: 100 }).toJSON() as Record<string, unknown>;
    expect(json.value).toBe(200); // not the clamped 100 the old code reported
    expect(json.percent).toBe(200);
    expect(json.bucket).toBe(3); // the BAR clamps full; the fact stays true
  });

  it("toJSON bucket follows the ramp buckets (░▒▓█ = 0..3)", () => {
    const json = (v: number) =>
      progress({ value: v }).toJSON() as { bucket: number | null; percent: number | null };
    expect(json(20).bucket).toBe(0);
    expect(json(45).bucket).toBe(1);
    expect(json(95).bucket).toBe(3);
    expect(json(NaN).bucket).toBeNull();
    expect(json(NaN).percent).toBeNull();
  });
});
