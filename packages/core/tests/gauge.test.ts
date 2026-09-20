import { describe, it, expect } from "vitest";
import { gauge } from "../src/charts/gauge.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

function plainLines(opts: Parameters<typeof gauge>[0]): string[] {
  return stripAnsi(gauge(opts).toString()).split("\n");
}

// A gauge fill is a run of shade-ramp glyphs (░▒▓█) ending in a solid `█` edge;
// the `─` track is scale, not fill. The reading's leading edge is the accent.
const RAMP = /[░▒▓█]/;

/** Count coloured RAMP segments by category: how many carry the accent code vs
 *  a grey-ramp code vs anything else. This is the S17 raw-ANSI census method —
 *  the accent must be spent on EXACTLY one bar segment (the leading edge), and
 *  the fill must be a documented grey tone (never a `theme.colors` band
 *  rainbow). The `─` track (axis colour), guide, scale and footer are excluded. */
function accentCensus(opts: Parameters<typeof gauge>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const acc = theme.accent!;
  const out = gauge(opts).toString();
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

describe("gauge chart — locked S22 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ value: 73 })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ value: 73 });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ value: 73 }).filter((l) => /^│ ╌/.test(l));
    expect(rules.length).toBe(1);
  });

  it("has the uppercase eyebrow row (LEVEL; opts.label uppercases)", () => {
    expect(stripAnsi(gauge({ value: 73 }).toString())).toMatch(/LEVEL/);
    expect(stripAnsi(gauge({ value: 73, label: "cpu load" }).toString())).toMatch(/CPU LOAD/);
  });

  it("shows the title in the frame when passed", () => {
    const plain = stripAnsi(gauge({ value: 73, title: "Disk Pressure" }).toString());
    expect(plain).toMatch(/Disk Pressure/);
  });

  it("carries the +╌…╌+ guide and a min..max scale row under the bar", () => {
    const plain = stripAnsi(gauge({ value: 73, min: 0, max: 100 }).toString());
    expect(plain).toMatch(/\+╌+\+/);
    expect(plain).toMatch(/0\s+100/);
  });

  it("keeps the ─ scale track so the level reads against the full range", () => {
    const rows = plainLines({ value: 73 }).filter((l) => /^│ +[░▒▓█]/.test(l));
    expect(rows.length).toBe(1); // one bar row
    expect(rows[0]).toMatch(/[░▒▓█]─/); // fill meets the dim scale track
  });

  it("retires the ┤/├ endcaps — no glyph outside the locked vocabulary", () => {
    const plain = stripAnsi(gauge({ value: 73 }).toString());
    expect(plain).not.toMatch(/[┤├]/);
  });

  it("renders every panel row at the same visible width", () => {
    const widths = new Set(plainLines({ value: 73 }).map((l) => l.length));
    expect(widths.size).toBe(1);
  });

  // ── Intensity IS the shade ramp (the heatmap/timeline texture language) ──
  it("encodes the level as the shade ramp, light → dark (░▒▓)", () => {
    const rowFor = (value: number) =>
      plainLines({ value, min: 0, max: 100 }).find((l) => RAMP.test(l))!;
    expect(rowFor(20)).toMatch(/░+█/); // bucket 0 fill + solid edge
    expect(rowFor(45)).toMatch(/▒+█/); // bucket 1
    expect(rowFor(70)).toMatch(/▓+█/); // bucket 2
    expect(rowFor(95)).toMatch(/█+█/); // bucket 3 = darkest, solid
  });

  it("uses ONLY documented ramp glyphs as fill — no phantom texture", () => {
    const ANSI = /\x1b\[[0-9;]*m|\x1b\[0m/g;
    const out = gauge({ value: 73 }).toString();
    for (const row of out.split("\n").filter((l) => RAMP.test(l))) {
      const residue = row.replace(ANSI, "").replace(/[A-Za-z0-9 +.,%_…\-│┌┐└┘╌─]/g, "");
      expect(residue).toMatch(/^[░▒▓█]*$/);
    }
  });

  it("the ramp survives noColor — the plain render still reads the level", () => {
    const plain = gauge({ value: 45, noColor: true }).toPlain();
    expect(plain).not.toMatch(/\x1b\[/);
    expect(plain).toMatch(/▒+█/);
    expect(plain).toMatch(/─/);
  });

  // ── The one accent, spent once on the reading's leading edge ──
  it("spends the accent hue EXACTLY once — one solid █ edge, no rainbow leak", () => {
    const c = accentCensus({ value: 73 });
    expect(c.accent).toBe(1);
    expect(c.other).toBe(0); // the fill is a documented grey tone, nothing else
    expect(c.grey).toBe(1);
  });

  it("the accent segment is the single-block leading edge of the fill", () => {
    const acc = resolveTheme(undefined).accent!;
    const out = gauge({ value: 73 }).toString();
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const accentSegs = segs.filter((s) => s[1] === acc && RAMP.test(s[2]!));
    expect(accentSegs.length).toBe(1);
    expect(accentSegs[0]![2]).toBe("█");
    // the edge sits at the END of the fill run (right before the ─ track)
    expect(stripAnsi(out)).toMatch(/[░▒▓]█─/);
  });

  it("every bar colour is the accent or a documented grey tone", () => {
    const acc = resolveTheme(undefined).accent!;
    const out = gauge({ value: 73 }).toString();
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const barCodes = new Set(segs.filter((s) => RAMP.test(s[2]!)).map((s) => s[1]!));
    for (const code of barCodes) {
      expect(code === acc || GREY_TONES.includes(code)).toBe(true);
    }
  });

  it("explicit thresholds stay a user override (not a theme rainbow)", () => {
    const user = "\x1b[38;5;208m";
    const out = gauge({
      value: 73,
      thresholds: [{ value: 0, color: user }],
    }).toString();
    expect(out).toMatch(/\x1b\[38;5;208m/); // the user's colour is honoured
    const c = accentCensus({ value: 73, thresholds: [{ value: 0, color: user }] });
    expect(c.accent).toBe(0); // the override replaces the accent edge
    expect(c.other).toBe(2); // …run + edge, both in the ONE user colour (documented choice)
    // the DEFAULT path stays accent-once
    expect(accentCensus({ value: 73 }).accent).toBe(1);
  });

  // ── Summary footer ────────────────────────────────────────────
  it("footer reports V of min..max · pct with the reading accented", () => {
    const plain = stripAnsi(gauge({ value: 73, min: 0, max: 100 }).toString());
    expect(plain).toMatch(/73 of 0\.\.100 · 73\.0%/);
    const acc = resolveTheme(undefined).accent!;
    const raw = gauge({ value: 73 }).toString();
    expect(raw).toContain(`${acc}73`);
  });

  it("honours explicit min/max (negative ranges format honestly)", () => {
    const plain = stripAnsi(gauge({ value: -2, min: -10, max: 10 }).toString());
    expect(plain).toMatch(/-2 of -10\.\.10 · 40\.0%/);
  });

  // ── Out-of-range is clipped on the bar, honest in the footer ──
  it("a reading past max clips at full width — never a RangeError", () => {
    const c = accentCensus({ value: 140, min: 0, max: 100 });
    expect(c.accent).toBe(1);
    const plain = stripAnsi(gauge({ value: 140, min: 0, max: 100 }).toString());
    expect(plain).toMatch(/140 of 0\.\.100 · 140\.0%/); // honest percent
    const row = plain.split("\n").find((l) => RAMP.test(l))!;
    expect(row).not.toMatch(/[░▒▓█]─/); // no track left — the bar is full
  });

  it("a reading below min renders an empty track, honestly reported", () => {
    const out = gauge({ value: -10, min: 0, max: 100 }).toString();
    expect(out).toBeTruthy(); // no negative-repeat RangeError
    const plain = stripAnsi(out);
    expect(plain).toMatch(/-10 of 0\.\.100 · -10\.0%/);
    expect(plain.split("\n").some((l) => /^│ ─+ │$/.test(l))).toBe(true); // bar row = all dim track
  });

  // ── Degenerate data is safe ───────────────────────────────────
  it("a collapsed range (min == max) never divides by zero", () => {
    const full = stripAnsi(gauge({ value: 50, min: 50, max: 50 }).toString());
    expect(full).not.toMatch(/NaN|Infinity/);
    expect(accentCensus({ value: 50, min: 50, max: 50 }).accent).toBe(1); // reading reaches max → full
    const empty = stripAnsi(gauge({ value: 40, min: 50, max: 50 }).toString());
    expect(empty).not.toMatch(/NaN|Infinity/);
    expect(empty).toMatch(/40 of 50\.\.50 · 0\.0%/); // below the point → empty
  });

  it("a non-finite reading renders a framed n/a panel — never NaN", () => {
    const plain = stripAnsi(gauge({ value: NaN, min: 0, max: 100 }).toString());
    expect(plain).not.toMatch(/NaN|Infinity/);
    expect(plain).toMatch(/n\/a of 0\.\.100/);
    expect(plain).toMatch(/^┌╌/m);
    expect(plain).toMatch(/^└╌/m);
  });

  it("a tiny explicit width still renders a consistent panel", () => {
    const widths = new Set(plainLines({ value: 73, width: 12 }).map((l) => l.length));
    expect(widths.size).toBe(1);
    expect(plainLines({ value: 73, width: 12 })[0]).toMatch(/^┌╌/);
  });

  // ── Agent output surface ──────────────────────────────────────
  it("toJSON carries type/value/min/max/percent/bucket/plain", () => {
    const json = gauge({ value: 70, min: 0, max: 100 }).toJSON() as Record<string, unknown>;
    expect(json.type).toBe("gauge");
    expect(json.value).toBe(70);
    expect(json.min).toBe(0);
    expect(json.max).toBe(100);
    expect(json.percent).toBe(70);
    expect(json.bucket).toBe(2); // 0.70 → ▓ bucket
    expect(typeof json.plain).toBe("string");
    expect(stripAnsi(json.plain as string)).toBe(json.plain);
  });

  it("toJSON bucket follows the ramp buckets (░▒▓█ = 0..3)", () => {
    const json = (v: number) =>
      gauge({ value: v }).toJSON() as { bucket: number | null; percent: number | null };
    expect(json(20).bucket).toBe(0);
    expect(json(45).bucket).toBe(1);
    expect(json(95).bucket).toBe(3);
    expect(json(NaN).bucket).toBeNull();
    expect(json(NaN).percent).toBeNull();
  });
});
