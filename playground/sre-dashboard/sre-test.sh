#!/usr/bin/env bash
# sre-test.sh — Run the SRE dashboard in terminal
# Usage: ./playground/sre-dashboard/sre-test.sh          # live in terminal
#        ./playground/sre-dashboard/sre-test.sh --once   # single snapshot

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TSX="$REPO_ROOT/packages/core/node_modules/.bin/tsx"

if [ ! -x "$TSX" ]; then
  echo "Installing dependencies..." >&2
  cd "$REPO_ROOT" && pnpm install --frozen-lockfile 2>/dev/null
fi

exec "$TSX" "$SCRIPT_DIR/sre-dashboard.ts" "$@"
