#!/usr/bin/env bash
# Builds the web playground (if needed) and serves it locally.
#
# Usage:
#   web/serve.sh            # build only if web/dist is missing, then serve
#   web/serve.sh --build     # always rebuild first, then serve
#   PORT=9000 web/serve.sh   # serve on a specific port (default 8080)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/web/dist"
PORT="${PORT:-8080}"

if [ "${1:-}" = "--build" ] || [ ! -f "$DIST_DIR/raylua_web.wasm" ]; then
  bash "$ROOT_DIR/web/build.sh"
fi

PYTHON="$(command -v python3 || command -v python || true)"
if [ -z "$PYTHON" ]; then
  echo "error: need python3 (or python) on PATH to serve $DIST_DIR" >&2
  exit 1
fi

echo "== serving $DIST_DIR at http://localhost:$PORT/"
cd "$DIST_DIR"
exec "$PYTHON" -m http.server "$PORT"
