#!/usr/bin/env bash
# sre-serve.sh — Start the SRE dashboard HTTP server
# Access at http://chitra-dashboard.test:4173

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TSX="$REPO_ROOT/packages/core/node_modules/.bin/tsx"

# Kill any existing server on port 4173
lsof -ti:4173 | xargs kill -9 2>/dev/null || true
sleep 1

exec "$TSX" "$SCRIPT_DIR/sre-server.ts"
