/**
 * sre-sim.ts — SRE service simulation engine.
 * Generates realistic SRE metrics: golden signals, SLOs, capacity, incidents.
 */

const clamp = (v: number, lo: number, hi: number): number => Math.min(hi, Math.max(lo, v));
const keepLast = (arr: number[], n: number, v: number): void => {
  arr.push(v);
  while (arr.length > n) arr.shift();
};
const gauss = (): number => Math.random() + Math.random() + Math.random() + Math.random() - 2;

export const SERVICES = ["gateway", "auth", "users", "pay", "search", "notif"];
const SERVICE_WEIGHT = [0.32, 0.14, 0.18, 0.12, 0.16, 0.08];
const SERVICE_BASE_LATENCY = [12, 28, 18, 35, 22, 8];

export class SRESim {
  t = 0;
  rps = 2400;
  p50 = 32;
  p95 = 78;
  p99 = 142;
  errRate = 0.12;
  apdex = 0.96;
  cpu = 42;
  mem = 58;
  disk = 38;
  netMbps = 124;

  rpsHist: number[] = [];
  p50Hist: number[] = [];
  p95Hist: number[] = [];
  p99Hist: number[] = [];
  errHist: number[] = [];
  apdexHist: number[] = [];
  cpuHist: number[] = [];
  memHist: number[] = [];
  connHist: number[] = [];

  svcSamples: Record<string, number[]> = {};

  incident: { start: number; severity: number; left: number; label: string } | null = null;
  events: Array<{ label: string; start: number; end: number; kind: string }> = [];
  deployVersion = "2.14.0";

  constructor() {
    for (const s of SERVICES) this.svcSamples[s] = [];
  }

  get severity(): number {
    return this.incident ? this.incident.severity * (this.incident.left / 8) : 0;
  }

  tick(): void {
    this.t += 1;
    const sev = this.severity;

    if (this.incident) {
      this.incident.left -= 1;
      if (this.incident.left <= 0) {
        this.events.push({ label: `resolved: ${this.incident.label}`, start: this.t - 1, end: this.t, kind: "incident" });
        this.incident = null;
      }
    } else if (Math.random() < 0.025) {
      const labels = ["5xx spike", "latency degrade", "OOM kill", "disk pressure"];
      const label = labels[Math.floor(Math.random() * labels.length)]!;
      const left = 6 + Math.floor(Math.random() * 8);
      this.incident = { start: this.t, severity: 4 + Math.random() * 6, left, label };
      this.events.push({ label: `incident: ${label}`, start: this.t, end: this.t + left, kind: "incident" });
    }

    if (!this.incident && Math.random() < 0.05) {
      const parts = this.deployVersion.split(".").map(Number);
      parts[2] = (parts[2] ?? 0) + 1;
      this.deployVersion = parts.join(".");
      this.events.push({ label: `deploy ${this.deployVersion}`, start: this.t, end: this.t + 1, kind: "deploy" });
    }

    this.rps = clamp(this.rps + (Math.random() - 0.5) * 80 - sev * 12 + (2400 - this.rps) * 0.04, 800, 4200);
    this.p50 = clamp(this.p50 + (Math.random() - 0.5) * 3 + sev * 0.5, 18, 95);
    this.p95 = clamp(this.p50 * (1.8 + Math.random() * 0.4) + sev * 8, 40, 280);
    this.p99 = clamp(this.p95 * (1.3 + Math.random() * 0.3) + sev * 15, 60, 500);
    this.errRate = clamp(0.08 + (Math.random() - 0.5) * 0.15 + sev * 0.8, 0.01, 18);
    this.apdex = clamp(1 - (this.p50 / 500) - (this.errRate / 200) - sev * 0.02, 0.6, 1);
    this.cpu = clamp(this.cpu + ((this.rps - 2400) / 2400) * 5 + (Math.random() - 0.5) * 4 + sev * 0.8, 15, 96);
    this.mem = clamp(this.mem + (Math.random() - 0.5) * 1.5 + sev * 0.3, 35, 88);
    this.disk = clamp(this.disk + 0.02, 25, 65);
    this.netMbps = clamp(this.netMbps + (Math.random() - 0.5) * 10 + (this.rps - 2400) * 0.02, 40, 300);

    for (let k = 0; k < 8; k++) {
      const i = Math.floor(Math.random() * SERVICES.length);
      const svc = SERVICES[i]!;
      const sample = SERVICE_BASE_LATENCY[i]! * (1 + Math.abs(gauss()) * 0.4) + sev * 15;
      keepLast(this.svcSamples[svc] ??= [], 24, Math.round(sample));
    }

    keepLast(this.rpsHist, 28, Math.round(this.rps));
    keepLast(this.p50Hist, 28, Math.round(this.p50));
    keepLast(this.p95Hist, 28, Math.round(this.p95));
    keepLast(this.p99Hist, 28, Math.round(this.p99));
    keepLast(this.errHist, 28, Number(this.errRate.toFixed(2)));
    keepLast(this.apdexHist, 28, Number(this.apdex.toFixed(3)));
    keepLast(this.cpuHist, 28, Math.round(this.cpu));
    keepLast(this.memHist, 28, Math.round(this.mem));
    keepLast(this.connHist, 28, Math.round(this.netMbps));

    this.events = this.events.filter((e) => e.end >= this.t - 30).slice(-6);
  }
}

export const warmup = (sim: SRESim, ticks = 30): void => {
  for (let i = 0; i < ticks; i++) sim.tick();
};
