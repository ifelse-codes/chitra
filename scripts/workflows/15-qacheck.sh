#!/usr/bin/env bash
# scripts/workflows/15-qacheck.sh — Entry point for session 15 (QA)
# Runs the QA suite and its gates.

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

echo "Running Session 15 QA workflow..."

# Check what exists
echo "Checking workflow files..."
if [ ! -d ".ai/verify/session-15" ]; then
  mkdir -p ".ai/verify/session-15"
fi

# Step 1: Run the QA script (which builds docs and runs Playwright)
echo "Step 1: Running Playwright QA suite..."
if node scripts/qa-catalog.mjs; then
  echo "✓ QA script completed successfully"
else
  echo "✗ QA script failed"
  exit 1
fi

# Step 2: Run standing gates
echo "Step 2: Running standing gates..."
if pnpm --filter @workspace/chitra-docs run check:catalog; then
  echo "✓ check:catalog green"
else
  echo "✗ check:catalog failed"
  exit 1
fi

if pnpm --filter @workspace/chitra-docs run typecheck; then
  echo "✓ docs typecheck clean"
else
  echo "✗ docs typecheck failed"
  exit 1
fi

if pnpm --filter @workspace/chitra-docs run gen:charts:check; then
  echo "✓ chart drift gate green"
else
  echo "✗ chart drift gate failed"
  exit 1
fi

# Step 3: Verify core (should be unchanged)
echo "Step 3: Verifying core invariants..."
if pnpm --filter @chitra/core run test | grep -q "163 passed"; then
  echo "✓ 163/163 core tests green"
else
  echo "✗ core tests failed"
  exit 1
fi

changed=$(git diff main -- packages/core 2>/dev/null | wc -l)
if [ "$changed" -eq 0 ]; then
  echo "✓ packages/core unchanged from main"
else
  echo "✗ packages/core changed ($changed lines)"
  exit 1
fi

# Step 4: Branch validation
echo "Step 4: Verifying branch name..."
branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" == session-15-* ]]; then
  echo "✓ Branch $branch matches session-15 pattern"
else
  echo "✗ Branch $branch doesn't match session-15-*"
  exit 1
fi

# Summary
echo ""
echo "=== Session 15 QA Workflow Summary ==="
echo "✓ Playwright QA suite completed"
echo "✓ Documentation site built"
echo "✓ All catalog pages verified"
echo "✓ Standing gates green"
echo "✓ Core invariants preserved"
echo "✓ Branch validated"
echo ""
echo "Session 15 complete!"