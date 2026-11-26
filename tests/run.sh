#!/usr/bin/env bash
# Run the headless smoke tests against this config.
# Usage: tests/run.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
nvim="${NVIM:-/opt/homebrew/bin/nvim}"
exec "$nvim" --headless -c "luafile $here/smoke.lua" 2>&1
