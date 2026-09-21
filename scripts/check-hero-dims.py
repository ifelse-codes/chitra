#!/usr/bin/env python3
"""S31 gate helper: hero rotation variants must share identical outer dims
(19 visible lines x 64 visible cols) so the hero mac box + chart frame
never move between swaps. ANSI escapes stripped before measuring."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HERO = ROOT / "artifacts/chitra-docs/src/data/hero-charts.json"
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

data = json.loads(HERO.read_text())
assert len(data) == 6, f"expected 6 hero variants, got {len(data)}"

bad = []
for key, raw in data.items():
    lines = [len(ANSI_RE.sub("", ln)) for ln in raw.split("\n")]
    if len(lines) != 19 or max(lines) != 64:
        bad.append(f"{key}: {len(lines)} lines x {max(lines)} cols")

if bad:
    print("OFF-DIMS:\n" + "\n".join(bad))
    sys.exit(1)
print("hero 6x19x64 UNIFORM")
