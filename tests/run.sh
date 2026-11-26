#!/usr/bin/env bash
# Run the headless smoke tests against this config.
# Usage: tests/run.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
nvim="${NVIM:-/opt/homebrew/bin/nvim}"

# GUI launchers (Hammerspoon, Dock) start nvim with cwd "/"; the config
# should move to $HOME so pickers don't crawl the whole disk.
cwd="$(cd / && "$nvim" --headless "+lua io.stdout:write(vim.fn.getcwd())" +qa 2>&1)"
if [[ "$cwd" == "$HOME" ]]; then
  echo "PASS [e2e] launch from / lands in \$HOME"
else
  echo "FAIL [e2e] launch from / lands in \$HOME"
  echo "     cwd was '$cwd'"
  exit 1
fi

exec "$nvim" --headless -c "luafile $here/smoke.lua" 2>&1
