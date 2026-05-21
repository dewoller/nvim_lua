# Nvim Lazy.nvim Migration — Design

**Date:** 2026-05-22
**Repo:** `/Users/dewoller/.config/nvim` (its own git repo, initialised during the prior plugin prune)
**Goal:** Rewrite the nvim config into the modern lazy.nvim spec layout — drop packer, drop the `dennis/` namespace, drop the `after/plugin/` split, keep all 16 retained plugins working with identical end-user behaviour.

## Decisions captured in brainstorming

- **Plugin manager:** lazy.nvim (folke/lazy.nvim).
- **Plugin file granularity:** one file per plugin in `lua/plugins/`, with the LSP/cmp stack split into `lsp.lua` + `completion.lua`, and the editing-enhancement cluster grouped into `editing.lua` (surround + repeat + unimpaired + yoink + subversive + cutlass).
- **Keymaps:** plugin-owned keys declared in each plugin's spec `keys = {}` table (also enables lazy-load-on-keypress); non-plugin keys (window nav, buffer cycling, etc.) in `lua/config/keymaps.lua`.
- **Namespace:** plain `lua/config/` and `lua/plugins/`. No more `lua/dennis/`.
- **Migration strategy:** clean rewrite in a git worktree on branch `migrate-lazy`, tested side-by-side via `NVIM_APPNAME=nvim-lazy`, merged to `main` when daily-driver-ready.

## Target layout

```
~/.config/nvim/
├── init.lua                       # 3 lines: bootstrap lazy + require "config"
├── lua/
│   ├── config/
│   │   ├── lazy.lua               # lazy.nvim bootstrap + setup({ spec = { { import = "plugins" } } })
│   │   ├── options.lua            # vim.opt.* / vim.g.* (migrated from lua/settings.lua)
│   │   ├── keymaps.lua            # non-plugin keymaps
│   │   └── autocmds.lua           # autocmds (migrated from lua/dennis/functions.lua + RenameFile)
│   └── plugins/
│       ├── colorscheme.lua        # tokyonight (priority = 1000, lazy = false)
│       ├── telescope.lua          # telescope + telescope-fzf-native, all <leader>f*/j* keys here
│       ├── treesitter.lua         # nvim-treesitter (build = ":TSUpdate") + textobjects + textsubjects
│       ├── lsp.lua                # lsp-zero + nvim-lspconfig + mason + mason-lspconfig
│       ├── completion.lua         # nvim-cmp + cmp-path/buffer/nvim-lsp/nvim-lua/cmdline
│       ├── neogit.lua             # neogit + plenary
│       ├── hop.lua                # hop.nvim, lazy-loaded on ";"
│       ├── mundo.lua              # vim-mundo, lazy on <leader>m
│       ├── comment.lua            # Comment.nvim
│       └── editing.lua            # surround/repeat/unimpaired/yoink/subversive/cutlass
└── archive/                       # preserved (luasnip backup)
```

**Total files:** 1 (init.lua) + 4 (config/) + 10 (plugins/) = 15.

## File contents — content map

### `init.lua` (3 lines)
```lua
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
```
`options.lua` is loaded as a side effect of `config.lazy` before lazy bootstraps (so `vim.g.mapleader` is set before any plugin runs).

### `lua/config/lazy.lua`
- Bootstrap lazy.nvim if not installed (clone from GitHub to `vim.fn.stdpath("data") .. "/lazy/lazy.nvim"`).
- `require("config.options")` (must happen before `lazy.setup` so `mapleader` is set).
- `require("lazy").setup({ spec = { { import = "plugins" } }, change_detection = { notify = false } })`.

### `lua/config/options.lua`
- Direct port of current `lua/settings.lua`: `<Space>` as leader, `,` as localleader, all `vim.opt` settings, backup/swap/undo dirs at `~/.cache/vimbackup/`.

### `lua/config/keymaps.lua`
Non-plugin keymaps from current `M.general`, `M.general_programming`, `M.os`, `M.buffer`, `M.next_buffer`, plus the tnoremap window-nav block and the Copilot-disabling `vim.g.copilot_no_tab_map` (kept as `vim.g.copilot_no_tab_map = true` even though Copilot is gone — defensive default).

Examples:
- `<C-h/j/k/l>` window nav (normal + visual)
- `<C-d>` close buffer
- `<CR>` clear search highlight
- `<leader>e` open file manager (macOS only — `package.config:sub(1,1) == "/"` check)
- `<F7>/<F8>` quickfix prev/next
- `<leader>n` `:call RenameFile()`
- `<leader>cd` cd to file's dir

### `lua/config/autocmds.lua`
Direct port from `lua/dennis/functions.lua`:
- `UIEnter`: `pcall(require, "ginit")` if `:GuiFont` exists (nvim-qt support)
- `FileChangedShellPost`: warning echo
- `BufLeave`/`FocusLost`: autosave modified buffers
- `BufReadPost`: restore last cursor position
- `RenameFile()` Lua function (rewritten from current vimscript, exposed as `:RenameFile` or callable from a keymap).

### Plugin specs — illustrative pattern

Every plugin file follows the same shape — a table or list-of-tables returned from the file. Example (`lua/plugins/telescope.lua`):

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "find_files" },
      { "<leader>fr", "<cmd>Telescope live_grep<cr>",   desc = "live_grep" },
      { "<leader>b",  "<cmd>Telescope buffers<cr>",     desc = "buffers" },
      -- … all <leader>f*, <leader>j*, <leader>g*, <leader>t* keys from current M.telescope
      { "<bslash>",   "<cmd>Telescope buffers<cr>",     mode = { "n", "v" } },  -- from M.next_buffer
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
    end,
    opts = {
      defaults = { /* current contents of after/plugin/telescope.lua options.defaults */ },
      pickers  = { /* current contents of options.pickers */ },
      extensions_list = { "fzf" },
    },
  },
}
```

Other plugin files follow this shape. `hop.lua` uses `keys = { ";" }` for lazy-load. `mundo.lua` uses `keys = { "<leader>m" }`. Vimscript plugins (surround, yoink, subversive, cutlass, vim-mundo, vim-repeat, vim-unimpaired) declare `lazy = false` if they have side effects on insert/normal mode mappings before being touched.

### Migrating special cases

1. **`yoink.lua` (vimscript)** — current `after/plugin/yoink.lua` sets `vim.g.yoinkSavePersistently=1` and `vim.g.yoinkIncludeDeleteOperations=1` BEFORE the plugin loads, then defines two expr-noremap `p`/`P` mappings. In the spec, set those vim globals in `init = function()` (runs before plugin load) and put `p`/`P` mappings in `keys = {}`.

2. **`cutlass.lua`** — `init = function() vim.g... end` not needed; current packer config calls `require("cutlass").setup({...})` which translates to `opts = { exclude = { "nd", "nD", "xd", "ndd" } }` and `config = true`.

3. **`treesitter.lua`** — current `after/plugin/treesitter.lua` likely has a setup call; migrate that into `config = function() require("nvim-treesitter.configs").setup({...}) end`. The dependency `RRethy/nvim-treesitter-textsubjects` runs its own setup in current `lua/dennis/packer.lua`; move that into the same `config` block or use the textsubjects setup inside the textsubjects dep's own `config`.

4. **`lsp.lua` + `completion.lua`** — split current `after/plugin/lsp-zero.lua` and `after/plugin/mason-lspconfig.lua` and the cmdline configs (`after/plugin/cmdline.lua`, `after/plugin/cmp-cmdline.lua`). lsp-zero v4 conventions: set up Mason first, then lsp-zero, then cmp. nvim-cmp's sources currently are `nvim_lsp`, `path`, `buffer` — no `luasnip`, no `cmp_nvim_r` (already removed).

5. **`neogit.lua`** — branch pinned to `"master"` (per the prior fix). `keys = { { "<LocalLeader>rg", "<cmd>Neogit<cr>" } }`.

## Migration mechanics

### Setup
```
cd ~/.config/nvim
git worktree add ../nvim-lazy -b migrate-lazy
```
Worktree lives at `~/.config/nvim-lazy/`. Testing: `NVIM_APPNAME=nvim-lazy nvim`. Lazy.nvim's plugin install dir at `~/.local/share/nvim-lazy/lazy/` is auto-namespaced by `NVIM_APPNAME`, so it does not collide with the existing packer install at `~/.local/share/nvim/site/pack/packer/start/`.

### Build order (in worktree)
1. Remove old files: `lua/dennis/`, `lua/settings.lua`, `lua/ginit.lua` (move to `lua/config/ginit.lua` if kept), `after/plugin/*`, `plugin/packer_compiled.lua`, `scripts/` (R helpers — leave or remove; not in this migration's scope).
2. Add new files: `init.lua` (rewrite), `lua/config/*.lua`, `lua/plugins/*.lua`.
3. Commit per logical chunk: config skeleton, then each plugin spec, then sweeps.
4. Test with `NVIM_APPNAME=nvim-lazy nvim` after each commit.

### Merge to main
```
cd ~/.config/nvim
git checkout main
git merge migrate-lazy
git worktree remove ../nvim-lazy
```

### Rollback
- Pre-merge: just abandon the worktree (`git worktree remove ../nvim-lazy --force`).
- Post-merge: `git reset --hard <pre-merge-sha>`; lazy's plugin dir at `~/.local/share/nvim/lazy/` can be deleted any time and rebuilt by packer-on-main.

## Verification

After each plugin file added in the worktree:
```
NVIM_APPNAME=nvim-lazy nvim --headless /path/to/some/file.py "+qa" 2>&1
```
Expected: empty stderr.

After all files added:
- `NVIM_APPNAME=nvim-lazy nvim` opens cleanly, `:Lazy` shows all 16 plugins installed, `:checkhealth` clean.
- Smoke test the same keys verified at the end of the prune:
  - `<leader>ff`, `<leader>fr`, `<leader>b`, `<bslash>` (Telescope)
  - `;` (hop)
  - `gcc` (Comment.nvim)
  - `<leader>m` (mundo)
  - `saiw"` (surround)
  - `<LocalLeader>rg` (neogit)
  - `dd`/`nd` (cutlass split)
  - `p`/`<c-p>` (yoink ring)
  - LSP attach on a Python buffer

Once smoke test passes, merge.

## Out of scope

- Switching off `lsp-zero` to the modern nvim-lspconfig-only pattern (lsp-zero v4 still works fine).
- Switching off `tpope/vim-surround` → `kylechui/nvim-surround` (lua-native equivalent). Possible follow-up.
- Cleaning up `scripts/` (R helpers orphaned by the prune).
- Adding new plugins.

## Open verification items

- Confirm `after/plugin/cmp-cmdline.lua` and `after/plugin/cmdline.lua` contents during plan execution — the spec assumes they're cmdline cmp setup; if they contain other code, migrate that into the appropriate plugin file.
- Confirm `lua/settings.lua` doesn't import anything from `lua/dennis/`. If it does, port those imports into the new structure.
- Confirm `lua/ginit.lua` is still needed (depends on whether nvim-qt is still in use). If yes, place at `lua/config/ginit.lua` or keep at top-level `lua/ginit.lua` since `pcall(require, "ginit")` from autocmd doesn't care about path.
