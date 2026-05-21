# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Configuration Type
This is Doctor Dee's personal Neovim configuration repository using Lua-based configuration.

## Key Architecture

### Plugin Management
- **Packer.nvim** manages all plugins (lua/dennis/packer.lua)
- Plugins are lazy-loaded where possible using `after` and conditional loading
- Main configuration entry points:
  - init.lua - loads core modules
  - lua/dennis/packer.lua - plugin definitions
  - after/plugin/*.lua - plugin-specific configurations loaded after plugins

### Configuration Structure
- **lua/settings.lua** - Core Vim options and global settings
- **lua/dennis/mappings.lua** - All keybindings organized by plugin/feature
- **lua/dennis/functions.lua** - Utility functions
- **after/plugin/** - Plugin-specific configurations (LSP, Telescope, etc.)

### LSP & Completion Setup
- **lsp-zero.nvim** provides simplified LSP configuration
- **Mason** handles automatic LSP server installation
- **nvim-cmp** manages autocompletion with multiple sources
- Python virtualenv at `.venv/` for Neovim Python provider

## Development Commands

### Plugin Management
```bash
# Inside Neovim
:PackerSync    # Install/update plugins
:PackerCompile # Compile plugin configurations
:PackerClean   # Remove unused plugins
```

### Common Operations
```bash
# Test configuration changes
nvim --startuptime /tmp/nvim-startuptime.log  # Profile startup time
nvim -u NONE  # Start without configuration (debugging)
```

### Python Environment
```bash
# Activate Neovim Python environment
source .venv/bin/activate

# Install/update Python dependencies
pip install pynvim
```

## Key Customizations

### Leader Keys
- **Space** - Main leader key (`<leader>`)
- **Comma** - Local leader key (`<localleader>`)

### Core Plugin Ecosystem
- **Telescope** - Fuzzy finding (files, grep, buffers)
- **Nvim-R** - R language support
- **Treesitter** - Syntax highlighting and text objects
- **Hop** - Quick navigation with `;` key
- **Oil.nvim** - File explorer
- **Workspaces** - Project management
- **Copilot** - AI code completion (Ctrl-L to accept)

### Custom Mappings Pattern
Mappings are organized in tables by feature/plugin in `lua/dennis/mappings.lua`:
- Each table contains mode-specific subtables (n, i, v, x, o)
- Format: `[key] = {command, description}`
- Applied via `setupKeyBindings()` function

## Important Notes
- Backup/swap/undo files stored in `~/.cache/vimbackup/`
- Configuration supports both macOS and Windows
- R integration uses custom radian scripts in `scripts/`
- Python host configured to use local `.venv/bin/python`
- always give me key mappings in the style of @lua/dennis/mappings.lua
- nvim is in /opt/homebrew/bin/nvim