# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Configuration Type
This is Doctor Dee's personal Neovim configuration repository using Lua-based configuration.
Targets Neovim 0.12+ (`/opt/homebrew/bin/nvim`).

## Key Architecture

### Plugin Management
- **lazy.nvim** manages all plugins; bootstrapped in `lua/config/lazy.lua`
- One spec file per plugin (or cluster) in `lua/plugins/`, auto-imported
- Versions pinned in `lazy-lock.json` — commit it after any `:Lazy update`
- Plugin-owned keymaps live in the spec's `keys = {}` table (also lazy-loads on keypress)

### Configuration Structure
- **init.lua** - requires `config.lazy`, `config.keymaps`, `config.autocmds`
- **lua/config/options.lua** - Vim options and leaders (loaded by `config.lazy` before plugins)
- **lua/config/keymaps.lua** - Non-plugin keymaps
- **lua/config/autocmds.lua** - Autocmds, `TrimWhitespace`, `RenameFile()`
- **lua/plugins/*.lua** - Plugin specs: colorscheme, telescope, treesitter, lsp, completion, neogit, hop, mundo, comment, editing
- **ftplugin/python.lua** - Python REPL keymaps (buffer-local)
- **lua/ginit.lua** - nvim-qt font tweaks, loaded on UIEnter when `:GuiFont` exists
- **after/** - R indent and treesitter query overrides
- **archive/** - Retired files kept for reference (Nvim-R ftplugin, snippets, radian scripts, luasnip config); nothing loads them
- **docs/superpowers/** - Specs and plans for past config changes

### LSP & Completion Setup
- **mason-lspconfig v2** installs servers and starts them with `vim.lsp.enable()`
- Per-server settings go in `vim.lsp.config(name, {...})` in `lua/plugins/lsp.lua` — not `lspconfig[name].setup()`, which v2 bypasses
- LSP keymaps are set buffer-local on `LspAttach` (lsp-zero's `default_keymaps` plus custom ones)
- **nvim-cmp** handles completion (sources: nvim_lsp, path, buffer)
- Python virtualenv at `.venv/` for the Neovim Python provider

### Treesitter
- **nvim-treesitter `main` branch (v1 API)**; `master` is archived and incompatible
- Parser builds need the tree-sitter CLI: `brew install tree-sitter-cli`
- Parser and filetype lists are at the top of `lua/plugins/treesitter.lua`; parsers land in `~/.local/share/nvim/site/parser/`

## Development Commands

### Tests
```bash
tests/run.sh   # headless smoke tests against the real config; exits non-zero on failure
```
Run after any config change. Output must be only PASS lines plus the summary.

### Plugin Management
```bash
# Inside Neovim
:Lazy            # UI
:Lazy update     # then commit lazy-lock.json
:Lazy build nvim-treesitter   # (re)install parsers
```

### Common Operations
```bash
nvim --startuptime /tmp/nvim-startuptime.log  # Profile startup time
nvim -u NONE  # Start without configuration (debugging)
:checkhealth lazy vim.lsp vim.deprecated
```

### Python Environment
```bash
source .venv/bin/activate
pip install pynvim
```

## Key Customizations

### Leader Keys
- **Space** - Main leader key (`<leader>`)
- **Comma** - Local leader key (`<localleader>`)

### Core Plugin Ecosystem
- **Telescope** (+ fzf-native) - Fuzzy finding (files, grep, buffers, LSP pickers)
- **Treesitter** (+ textobjects) - Highlighting, indent, `af`/`if`/`ar`/`ir`
- **lsp-zero + mason + nvim-cmp** - LSP and completion
- **Hop** - Quick navigation with `;`
- **Neogit** - `<LocalLeader>rg`
- **vim-mundo** - Undo tree, `<leader>m`
- **Editing cluster** (`lua/plugins/editing.lua`) - surround, repeat, unimpaired, cutlass, yoink, subversive, sideways, indent-tools, vim-textobj-* family
- **tokyonight** colorscheme

### Custom Mappings Pattern
- Plugin keymaps: lazy.nvim `keys` entries in the plugin's spec, e.g.
  `{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "find_files" }`
- Non-plugin keymaps: `map(mode, lhs, rhs)` calls in `lua/config/keymaps.lua`
- Filetype keymaps: in `ftplugin/<ft>.lua`, always with `buffer = true`

## Important Notes
- Backup/swap/undo files stored in `~/.cache/vimbackup/`
- Configuration supports both macOS and Windows
- Python host configured to use local `.venv/bin/python`
- Neovim's default `grr`/`grn`/`gri`/`gra`/`grt`/`grx` maps are deleted in `keymaps.lua` so `gr` (references) fires without a timeout
- always give me key mappings in the style of `lua/plugins/*.lua` `keys` entries (plugin keys) or `lua/config/keymaps.lua` (everything else)
- nvim is in /opt/homebrew/bin/nvim
