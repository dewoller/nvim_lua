# Nvim Config Prune — Design

**Date:** 2026-05-21
**Repo:** `/Users/dewoller/.config/nvim` (tracked inside home-dir git repo at `/Users/dewoller`)
**Goal:** Rationalise the nvim config by removing plugins Doctor Dee does not use, plus the dead config files and keymaps that reference them.

## Decisions captured in brainstorming

- **Workflows kept:** Python, Markdown/prose, shell, web (JS/TS).
- **Workflows dropped:** R (Nvim-R + cmp-nvim-r removed).
- **AI assistants:** neither — both `claude-code.nvim` and Copilot mappings removed.
- **Snippets:** dropped — LuaSnip + telescope-luasnip stack removed. Existing snippet file moved aside, not silently deleted.
- **Scope:** full cleanup — plugin entries, orphaned `after/plugin/*.lua` configs, dead keymaps in `lua/dennis/mappings.lua`.

## Plugins to remove (23 entries, ~20 distinct user-facing plugins + 3 deps/duplicates)

| # | Plugin | Reason |
|---|---|---|
| 1 | `jalvesaq/Nvim-R` | R workflow dropped |
| 2 | `jalvesaq/cmp-nvim-r` | R completion (no R) |
| 3 | `greggh/claude-code.nvim` | AI assistant not used |
| 4 | `AndrewRadev/sideways.vim` | Not used (`[p`/`]p`) |
| 5 | `kana/vim-textobj-user` | Dep of legacy textobjs being removed |
| 6 | `coachshea/vim-textobj-markdown` | Replaced by treesitter-textobjects |
| 7 | `kana/vim-textobj-entire` | Replaced by treesitter-textobjects |
| 8 | `glts/vim-textobj-comment` | Replaced by treesitter-textobjects |
| 9 | `michaeljsmith/vim-indent-object` | Not used |
| 10 | `beloglazov/vim-textobj-quotes` | Replaced by treesitter-textobjects |
| 11 | `Julian/vim-textobj-variable-segment` | Replaced by treesitter-textobjects |
| 12 | `natecraddock/workspaces.nvim` | Not used (`<leader>tw`, `<leader>wa`) |
| 13 | `stevearc/oil.nvim` | Not used |
| 14 | `arsham/indent-tools.nvim` | Not used (`]i`/`[i`/`ii`) |
| 15 | `arsham/arshlib.nvim` | Dep of indent-tools |
| 16 | `feline-nvim/feline.nvim` | Custom statusline not wanted |
| 17 | `nvim-tree/nvim-web-devicons` | Dep of feline only |
| 18 | `lewis6991/gitsigns.nvim` | Gutter signs not wanted |
| 19 | `max397574/better-escape.nvim` | `jk→Esc` not wanted |
| 20 | `windwp/nvim-autopairs` | Autopairs not wanted |
| 21 | `L3MON4D3/LuaSnip` (×2 entries) | Snippets not used |
| 22 | `benfowler/telescope-luasnip.nvim` | Snippet picker (no snippets) |
| 23 | `ms-jpq/lua-async-await` | Unused — `grep` shows zero `require` sites |

Note: `arshlib.nvim` and `nvim-web-devicons` are dependencies (not directly used). `lua-async-await` is included because grep shows zero `require` sites. The packer file has two `LuaSnip` `use{}` entries — both removed.

## Plugins kept (~21)

- **Manager:** packer
- **Fuzzy find:** telescope + telescope-fzf-native
- **Treesitter:** nvim-treesitter + textobjects + textsubjects
- **LSP/completion:** lsp-zero (v4) + mason + mason-lspconfig + nvim-cmp + cmp-path / -buffer / -nvim-lsp / -nvim-lua / -cmdline
- **Git:** neogit
- **Editing:** vim-surround, vim-repeat, vim-unimpaired, vim-yoink, vim-subversive, cutlass.nvim
- **Navigation:** hop.nvim
- **Comments:** Comment.nvim
- **Undo:** vim-mundo
- **Colors:** tokyonight.nvim

## File-level changes

### `lua/dennis/packer.lua`
Delete `use { ... }` blocks for every plugin in the remove list. Keep block-trailing whitespace consistent with the file's existing tab indentation.

Also drop the inline cmp source `{ 'jalvesaq/cmp-nvim-r' , after = "nvim-cmp" }` nested inside `lsp-zero`'s `requires` block.

Remove the now-pointless `LuaSnip` second `use{}` entry near line 174.

### `after/plugin/` — delete
- `nvim-r.lua` (Nvim-R config)
- `feline.lua` (statusline config — also remove `lua/dennis/feline_util.lua`)
- `workspaces.lua`
- `yoink.lua` *only if it just configures yoink without anything else worth keeping* — verify before deletion
- `luasnip.lua` → **move to `archive/luasnip.lua.bak`** rather than delete, because it contains a hand-written `%>%` snippet the user may want later
- `codeGPT.lua` — verify whether this is referenced by anything kept; if it's an orphan from an older AI plugin, delete; otherwise leave
- `playground.lua` and `treesitter-playground.lua` — verify whether these depend on a plugin still installed; the `nvim-treesitter/playground` entry is already commented out in packer.lua, so these are likely orphaned and should be deleted

### `after/plugin/` — keep
- `cmdline.lua`, `cmp-cmdline.lua`, `hop.lua`, `lsp-zero.lua`, `mason-lspconfig.lua`, `telescope.lua`, `treesitter.lua`, `trim-whitespace.lua`

### `lua/dennis/mappings.lua` — remove these mapping tables/lines
- `M.workspaces` (whole block)
- `M.sideways` (whole block)
- `M.claudecode` (whole block — also drops the terminal-paste mappings; if those are wanted independently, keep just the `t` submap and rename)
- The Copilot block:
  ```lua
  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Accept("<CR>")', ...)
  ```
- The `<c-p>` luasnip mappings inside `M.telescope` (`n`, `i`, `v` modes — the `Telescope luasnip` invocations)

### `lua/dennis/feline_util.lua`
Delete (only used by feline).

### `lua/dennis/init.lua`
No change needed — it just `require`s packer/settings/mappings/functions, none of which are being removed.

## Post-edit verification

1. `nvim --headless +"PackerSync" +qa` (or open nvim and run `:PackerSync` then `:PackerClean`) to remove plugin directories on disk.
2. Restart nvim. Watch for:
   - Errors loading `after/plugin/*` (deleted plugins still referenced).
   - `vim.keymap.set` errors from `mappings.lua`.
   - Statusline rendering (should fall back to default).
3. `nvim --startuptime /tmp/startup.log` — sanity-check startup time improved.

## Risk + rollback

- The home-dir git repo at `/Users/dewoller` tracks this folder. Before editing, the change should be staged on a topic branch (or at minimum, the current state of `lua/dennis/packer.lua` and `lua/dennis/mappings.lua` snapshotted) so a revert is one command away.
- `archive/luasnip.lua.bak` preserves the one hand-written snippet (`%>%` → ` %>%\n{.} -> `).
- `:PackerClean` is reversible — re-adding the `use{}` line and `:PackerSync` reinstalls.

## Out of scope

- Migrating from `packer.nvim` to `lazy.nvim`. Mentioned for awareness; not part of this prune.
- Cleaning up `scripts/` (radian/R helpers) — orphaned by Nvim-R removal but harmless to leave; user can decide separately.
- Re-organising the `after/plugin/` directory layout.

## Open verification items

Before implementation, confirm by inspection:
1. `after/plugin/codeGPT.lua` — is the referenced plugin in the kept list, or is this file orphaned?
2. `after/plugin/playground.lua` — depends on a removed/never-installed playground plugin?
3. `lua/dennis/functions.lua` — does it reference any removed plugin?
4. `scripts/` directory — purely R-related, or used by anything kept?

These checks happen during implementation; if any surface unexpected coupling, raise and adjust before deletion.
