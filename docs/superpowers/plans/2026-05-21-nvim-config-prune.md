# Nvim Config Prune Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove ~20 unused nvim plugins, their orphan config files, and dead keymaps without breaking startup.

**Architecture:** Incremental prune in commit-per-category slices. After each slice: open nvim headless, confirm no load errors, commit. The home-directory git repo at `/Users/dewoller` tracks this folder — every `git add` uses explicit paths (never `-A`/`.`) to avoid sweeping in unrelated dotfile noise.

**Tech Stack:** Lua, packer.nvim, nvim ≥0.9 (`/opt/homebrew/bin/nvim`)

**Spec:** [`docs/superpowers/specs/2026-05-21-nvim-config-prune-design.md`](../specs/2026-05-21-nvim-config-prune-design.md)

---

## Prereqs

- Working dir: `/Users/dewoller/.config/nvim`
- nvim binary: `/opt/homebrew/bin/nvim`
- Git repo root: `/Users/dewoller` (home-dir monorepo). All `git add` calls must enumerate explicit paths inside `.config/nvim/`.
- There is no test framework. The "test" after every change is: nvim launches headless without errors. Standard verification command:

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1 | tee /tmp/nvim-prune-check.log
  ```
  Expected: empty output (no stderr).

- Commit message style: lower-case prefix (`prune:`, `chore:`), then short summary. Co-Author trailer per global git rules.

---

## File Map

**Modified:**
- `lua/dennis/packer.lua` — delete `use{}` blocks
- `lua/dennis/mappings.lua` — delete dead mapping tables and Copilot block

**Deleted:**
- `after/plugin/nvim-r.lua`
- `after/plugin/feline.lua`
- `after/plugin/workspaces.lua`
- `lua/dennis/feline_util.lua`
- (conditionally) `after/plugin/codeGPT.lua`, `after/plugin/playground.lua`, `after/plugin/treesitter-playground.lua`, `after/plugin/yoink.lua` — pending Task 1 verification

**Archived (moved aside, not deleted):**
- `after/plugin/luasnip.lua` → `archive/after-plugin-luasnip.lua.bak`

---

## Task 0: Pre-flight snapshot

**Files:**
- Create: `/tmp/nvim-prune-baseline.txt`

- [ ] **Step 1: Snapshot current startup time**

  Run:
  ```bash
  /opt/homebrew/bin/nvim --startuptime /tmp/nvim-startup-before.log "+qa"
  tail -1 /tmp/nvim-startup-before.log
  ```
  Record the total ms in `/tmp/nvim-prune-baseline.txt`:
  ```bash
  echo "before: $(tail -1 /tmp/nvim-startup-before.log)" > /tmp/nvim-prune-baseline.txt
  ```

- [ ] **Step 2: Snapshot installed packer plugins**

  Run:
  ```bash
  ls ~/.local/share/nvim/site/pack/packer/start/ > /tmp/packer-before.txt
  wc -l /tmp/packer-before.txt
  ```
  Expected: ~40 lines. This is the "before" count.

- [ ] **Step 3: Confirm baseline launch is clean**

  Run:
  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1 | tee /tmp/nvim-prune-baseline-stderr.log
  ```
  Expected: empty output. If non-empty, **stop and surface the pre-existing errors** — fixing them first is out of scope for this plan.

---

## Task 1: Verify "open items" from spec

**Files:**
- Read: `after/plugin/codeGPT.lua`, `after/plugin/playground.lua`, `after/plugin/treesitter-playground.lua`, `after/plugin/yoink.lua`, `lua/dennis/functions.lua`, `scripts/` directory

- [ ] **Step 1: Inspect `after/plugin/codeGPT.lua`**

  ```bash
  cat /Users/dewoller/.config/nvim/after/plugin/codeGPT.lua
  ```
  Decision rule: if the file `require`s a plugin name that is **not** in the kept list (telescope, treesitter, lsp-zero, mason, cmp, neogit, mundo, hop, surround, repeat, unimpaired, yoink, subversive, cutlass, Comment.nvim, tokyonight), mark for deletion in Task 9.

- [ ] **Step 2: Inspect `after/plugin/playground.lua` and `after/plugin/treesitter-playground.lua`**

  ```bash
  cat /Users/dewoller/.config/nvim/after/plugin/playground.lua
  cat /Users/dewoller/.config/nvim/after/plugin/treesitter-playground.lua
  ```
  Both reference `nvim-treesitter/playground` which is already commented out in packer.lua. Mark both for deletion in Task 9.

- [ ] **Step 3: Inspect `after/plugin/yoink.lua`**

  ```bash
  cat /Users/dewoller/.config/nvim/after/plugin/yoink.lua
  ```
  Yoink is being **kept** — this file stays. Just confirm no surprise side-effects in it.

- [ ] **Step 4: Inspect `lua/dennis/functions.lua` for cross-references**

  ```bash
  grep -nE "feline|luasnip|nvim-r|workspaces|oil|gitsigns|autopairs|better-escape|sideways|copilot|claude-code|textobj-|indent-tools|arshlib" /Users/dewoller/.config/nvim/lua/dennis/functions.lua || echo "no references"
  ```
  Expected: `no references`. If anything matches, note the line and address inside the relevant prune task below.

- [ ] **Step 5: Inspect `scripts/` directory**

  ```bash
  ls /Users/dewoller/.config/nvim/scripts/ 2>/dev/null && head -5 /Users/dewoller/.config/nvim/scripts/* 2>/dev/null
  ```
  Per spec: `scripts/` is R-related (radian) and harmless to leave. Confirm contents are R-only; if so, do nothing. If mixed, surface and ask.

- [ ] **Step 6: Record verification outcomes**

  Write findings to `/tmp/nvim-prune-baseline.txt`:
  ```
  codeGPT.lua:  <orphan|kept-plugin>
  playground.lua:  orphan (delete)
  treesitter-playground.lua:  orphan (delete)
  yoink.lua:  kept
  functions.lua:  <clean|references found: …>
  scripts/:  <R-only|mixed>
  ```

No commit yet — verification is read-only.

---

## Task 2: Archive the LuaSnip snippet file

**Files:**
- Create: `archive/after-plugin-luasnip.lua.bak`
- Delete: `after/plugin/luasnip.lua`

The file contains a hand-written `%>%` snippet that the user may want later. Move, don't delete.

- [ ] **Step 1: Create archive directory**

  ```bash
  mkdir -p /Users/dewoller/.config/nvim/archive
  ```

- [ ] **Step 2: Move the file**

  ```bash
  mv /Users/dewoller/.config/nvim/after/plugin/luasnip.lua \
     /Users/dewoller/.config/nvim/archive/after-plugin-luasnip.lua.bak
  ```

- [ ] **Step 3: Confirm move**

  ```bash
  ls /Users/dewoller/.config/nvim/archive/
  ls /Users/dewoller/.config/nvim/after/plugin/luasnip.lua 2>&1 | grep "No such"
  ```
  Expected: archive file present; original gone.

- [ ] **Step 4: Verify nvim still loads (LuaSnip plugin still installed at this point, so config absence is fine)**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output.

- [ ] **Step 5: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/archive/after-plugin-luasnip.lua.bak
  git add -A -- /Users/dewoller/.config/nvim/after/plugin/luasnip.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): archive luasnip snippet file before plugin removal

Preserves the hand-written %>% snippet for possible future restoration.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 3: Remove R stack

**Files:**
- Modify: `lua/dennis/packer.lua` (remove `use{"jalvesaq/Nvim-R"}` block and `{'jalvesaq/cmp-nvim-r', after = "nvim-cmp"}` nested entry inside `lsp-zero` requires)
- Delete: `after/plugin/nvim-r.lua`

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — remove Nvim-R block**

  Locate and delete (exact match):
  ```lua
  use{"jalvesaq/Nvim-R"}
  ```

- [ ] **Step 2: Edit `lua/dennis/packer.lua` — remove cmp-nvim-r source**

  Inside the `lsp-zero.nvim` `requires` block, delete the line:
  ```lua
  { "jalvesaq/cmp-nvim-r" , after = "nvim-cmp" },
  ```

- [ ] **Step 3: Delete the after/plugin config**

  ```bash
  rm /Users/dewoller/.config/nvim/after/plugin/nvim-r.lua
  ```

- [ ] **Step 4: Verify nvim still loads (Nvim-R plugin still on disk, but config gone is fine)**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output.

- [ ] **Step 5: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua
  git add -A -- /Users/dewoller/.config/nvim/after/plugin/nvim-r.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop Nvim-R and cmp-nvim-r

R workflow no longer used in this nvim config.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 4: Remove AI assistants (claude-code.nvim + Copilot)

**Files:**
- Modify: `lua/dennis/packer.lua` (remove `greggh/claude-code.nvim` block, ~lines 37–87)
- Modify: `lua/dennis/mappings.lua` (remove `M.claudecode` block AND the Copilot vim.g + vim.api.nvim_set_keymap lines)

Note: the `M.claudecode` table contains terminal-paste keymaps (`<C-v>`, `<C-S-v>`, `<C-Esc>`). Per spec, these are dropped wholesale. If the user wants them later, the git history preserves them.

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — delete entire claude-code.nvim block**

  Delete the block starting:
  ```lua
  use {
      'greggh/claude-code.nvim',
      requires = {
  ```
  …through its closing `}` (the `use {}` block ending with `}`). This is the ~50-line block configuring window, command, keymaps for claude-code.nvim.

- [ ] **Step 2: Edit `lua/dennis/mappings.lua` — delete `M.claudecode` table**

  Remove the entire block from `M.claudecode={` through its closing `}`.

- [ ] **Step 3: Edit `lua/dennis/mappings.lua` — delete Copilot lines**

  Delete these two lines:
  ```lua
  vim.g.copilot_no_tab_map = true

  vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Accept("<CR>")', { silent = true, expr = true, noremap = true })
  ```

- [ ] **Step 4: Verify nvim still loads**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output. If you see "module 'claude-code' not found" — the `use{}` removal succeeded but nvim hasn't re-compiled. Run `/opt/homebrew/bin/nvim --headless "+PackerCompile" "+qa" 2>&1`.

- [ ] **Step 5: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua /Users/dewoller/.config/nvim/lua/dennis/mappings.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop claude-code.nvim and Copilot mappings

Neither AI assistant is used inside nvim; AI work happens elsewhere.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 5: Remove statusline (feline + nvim-web-devicons + feline_util)

**Files:**
- Modify: `lua/dennis/packer.lua` (remove `feline-nvim/feline.nvim` block)
- Delete: `after/plugin/feline.lua`
- Delete: `lua/dennis/feline_util.lua`

`nvim-web-devicons` is listed only as a dep of feline, so it goes with the parent block automatically.

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — delete feline block**

  Delete:
  ```lua
  use {
      'feline-nvim/feline.nvim',
      requires = {
          'nvim-tree/nvim-web-devicons',
      },
  }
  ```

- [ ] **Step 2: Delete the config files**

  ```bash
  rm /Users/dewoller/.config/nvim/after/plugin/feline.lua
  rm /Users/dewoller/.config/nvim/lua/dennis/feline_util.lua
  ```

- [ ] **Step 3: Verify nvim still loads (default statusline reappears)**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output.

- [ ] **Step 4: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua
  git add -A -- /Users/dewoller/.config/nvim/after/plugin/feline.lua /Users/dewoller/.config/nvim/lua/dennis/feline_util.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop feline statusline + nvim-web-devicons

Revert to nvim's default statusline.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 6: Remove LuaSnip stack

**Files:**
- Modify: `lua/dennis/packer.lua` (remove the LuaSnip entries in the lsp-zero `requires` block, the duplicate `L3MON4D3/LuaSnip` standalone block, and `benfowler/telescope-luasnip.nvim` block)
- Modify: `lua/dennis/mappings.lua` (drop the `<c-p>` Telescope luasnip mappings from `M.telescope`)

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — drop LuaSnip from lsp-zero requires**

  Inside the `lsp-zero.nvim` `requires` block, delete:
  ```lua
  -- Snippets
  {'L3MON4D3/LuaSnip'},
  ```
  (The commented-out `cmp_luasnip` and `friendly-snippets` lines can also go for cleanliness.)

- [ ] **Step 2: Edit `lua/dennis/packer.lua` — delete telescope-luasnip block**

  Delete:
  ```lua
  use {
      "benfowler/telescope-luasnip.nvim",
      module = "telescope._extensions.luasnip",  -- if you wish to lazy-load
  }
  ```

- [ ] **Step 3: Edit `lua/dennis/packer.lua` — delete the duplicate standalone LuaSnip block**

  Delete:
  ```lua
  use {
      'L3MON4D3/LuaSnip',
      after = 'nvim-cmp',
      -- config = function() require('config.snippets') end,
  }
  ```

- [ ] **Step 4: Edit `lua/dennis/mappings.lua` — remove luasnip mappings from M.telescope**

  In the `M.telescope` `n` submap, delete:
  ```lua
  ["<c-p>"] = {"<cmd>Telescope luasnip<cr>","luasnip"},
  ```

  In the `M.telescope` `i` submap, delete the entire `<c-p>` entry (the function block that calls `Telescope luasnip`):
  ```lua
  ["<c-p>"] = {
      function()
          print( vim.fn.expand("<cword>"))
          require('functions').send_keystrokes( vim.fn.expand("<cword>"))
          vim.api.nvim_command( "Telescope luasnip<cr>")
      end
  },
  ```

  In the `M.telescope` `v` submap, delete:
  ```lua
  ["<c-p>"] = {"<cmd>Telescope luasnip<cr>","luasnip"},
  ```

- [ ] **Step 5: Verify nvim still loads**

  ```bash
  /opt/homebrew/bin/nvim --headless "+PackerCompile" "+qa" 2>&1
  ```
  Expected: empty output. If you see references to `luasnip` from a remaining cmp source, that means an cmp source still expects it; remove that source.

- [ ] **Step 6: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua /Users/dewoller/.config/nvim/lua/dennis/mappings.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop LuaSnip + telescope-luasnip

Snippet file already archived; mappings rerouted to nothing.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 7: Remove textobject plugins (7 entries)

**Files:**
- Modify: `lua/dennis/packer.lua` (delete 7 `use{}` lines)

Kept: `nvim-treesitter/nvim-treesitter-textobjects` and `RRethy/nvim-treesitter-textsubjects` (modern treesitter ones).

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — delete legacy textobject blocks**

  Delete these 7 lines:
  ```lua
  use{'kana/vim-textobj-user'}
  use{'coachshea/vim-textobj-markdown'}
  use{'kana/vim-textobj-entire'}
  use{'glts/vim-textobj-comment'}
  use{ 'michaeljsmith/vim-indent-object'}
  use{'beloglazov/vim-textobj-quotes'}
  use{'Julian/vim-textobj-variable-segment'}
  ```

- [ ] **Step 2: Verify nvim still loads**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output.

- [ ] **Step 3: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop 7 legacy vim-textobj-* plugins

Replaced by nvim-treesitter-textobjects + textsubjects (already installed).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 8: Remove navigation/UI (workspaces, oil, indent-tools, arshlib, sideways)

**Files:**
- Modify: `lua/dennis/packer.lua` (delete 4 `use{}` blocks — indent-tools has its arshlib dep nested inside it)
- Modify: `lua/dennis/mappings.lua` (drop `M.workspaces` and `M.sideways` tables)
- Delete: `after/plugin/workspaces.lua`

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — delete workspaces.nvim**

  Delete:
  ```lua
  use{"natecraddock/workspaces.nvim"}
  ```

- [ ] **Step 2: Edit `lua/dennis/packer.lua` — delete oil.nvim block**

  Delete:
  ```lua
  use {
      'stevearc/oil.nvim',
      config = function() require('oil').setup() end
  }
  ```

- [ ] **Step 3: Edit `lua/dennis/packer.lua` — delete indent-tools (and its arshlib dep)**

  Delete the whole block:
  ```lua
  use({
      "arsham/indent-tools.nvim",
      requires = { "arsham/arshlib.nvim" },
      config = function()
          require("indent-tools").config({})
      end,
      keys = { "]i", "[i", { "v", "ii" }, { "o", "ii" } },
  })
  ```

- [ ] **Step 4: Edit `lua/dennis/packer.lua` — delete sideways.vim**

  Delete:
  ```lua
  use{"AndrewRadev/sideways.vim"}
  ```

- [ ] **Step 5: Edit `lua/dennis/mappings.lua` — delete M.workspaces and M.sideways**

  Delete these blocks entirely:
  ```lua
  M.workspaces = {
      n={
          ["<Leader>tw"] = {":Telescope workspaces<cr>" },
          ["<Leader>wa"] = { function() require('workspaces').add() end
          },
      }
  }
  ```
  And:
  ```lua
  M.sideways = {
      n={
          ["[p"] = {":SidewaysRight<cr>"},
          ["]p"] = {":SidewaysLeft<cr>"},
      },
      o={
          ["aa"] = {'<Plug>SidewaysArgumentTextobjA'},
          ["ia"] = {'<Plug>SidewaysArgumentTextobjI'},
      },
      x={
          ["aa"] = {'<Plug>SidewaysArgumentTextobjA'},
          ["ia"] = {'<Plug>SidewaysArgumentTextobjI'},
      },
  }
  ```

- [ ] **Step 6: Delete after/plugin/workspaces.lua**

  ```bash
  rm /Users/dewoller/.config/nvim/after/plugin/workspaces.lua
  ```

- [ ] **Step 7: Verify nvim still loads**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output.

- [ ] **Step 8: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua /Users/dewoller/.config/nvim/lua/dennis/mappings.lua
  git add -A -- /Users/dewoller/.config/nvim/after/plugin/workspaces.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop workspaces, oil, indent-tools, sideways

None of these were exercised in daily workflow.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 9: Remove comfort plugins (gitsigns, better-escape, autopairs) + lua-async-await + orphans

**Files:**
- Modify: `lua/dennis/packer.lua`
- Delete: any orphan files identified in Task 1 (likely `after/plugin/playground.lua`, `after/plugin/treesitter-playground.lua`, possibly `after/plugin/codeGPT.lua`)

- [ ] **Step 1: Edit `lua/dennis/packer.lua` — delete gitsigns block**

  Delete:
  ```lua
  use{
      "lewis6991/gitsigns.nvim",
      config = function()
          require("gitsigns").setup()
      end
  }
  ```

- [ ] **Step 2: Edit `lua/dennis/packer.lua` — delete better-escape**

  Delete:
  ```lua
  use{"max397574/better-escape.nvim"}
  ```

- [ ] **Step 3: Edit `lua/dennis/packer.lua` — delete nvim-autopairs block**

  Delete:
  ```lua
  use {
      "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
  }
  ```

- [ ] **Step 4: Edit `lua/dennis/packer.lua` — delete lua-async-await**

  Delete:
  ```lua
  use{ 'ms-jpq/lua-async-await' }
  ```

- [ ] **Step 5: Delete orphan after/plugin files (from Task 1 outcomes)**

  Based on Task 1 verification (`/tmp/nvim-prune-baseline.txt`):
  ```bash
  rm /Users/dewoller/.config/nvim/after/plugin/playground.lua
  rm /Users/dewoller/.config/nvim/after/plugin/treesitter-playground.lua
  ```
  Only run the next line if Task 1 Step 1 marked codeGPT.lua as orphan:
  ```bash
  rm /Users/dewoller/.config/nvim/after/plugin/codeGPT.lua
  ```
  If Task 1 found codeGPT.lua references a kept plugin, skip its deletion and add a one-line comment in `/tmp/nvim-prune-baseline.txt` noting it stays.

- [ ] **Step 6: Verify nvim still loads**

  ```bash
  /opt/homebrew/bin/nvim --headless "+qa" 2>&1
  ```
  Expected: empty output.

- [ ] **Step 7: Commit**

  ```bash
  git add /Users/dewoller/.config/nvim/lua/dennis/packer.lua
  git add -A -- /Users/dewoller/.config/nvim/after/plugin/playground.lua /Users/dewoller/.config/nvim/after/plugin/treesitter-playground.lua /Users/dewoller/.config/nvim/after/plugin/codeGPT.lua
  git commit -m "$(cat <<'EOF'
prune(nvim): drop gitsigns/better-escape/autopairs + lua-async-await + orphan after/plugin files

Removes comfort plugins not used and dangling configs for previously-removed plugins.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```

---

## Task 10: PackerClean + final verification

**Files:** none modified.

- [ ] **Step 1: Recompile packer**

  ```bash
  /opt/homebrew/bin/nvim --headless "+PackerCompile" "+qa" 2>&1
  ```
  Expected: empty output (or a "Compiled" message on stdout, fine).

- [ ] **Step 2: Run PackerClean**

  PackerClean is interactive (prompts for confirmation), so do it from inside nvim:
  ```bash
  /opt/homebrew/bin/nvim
  ```
  Inside nvim: `:PackerClean` → review the proposed removals → confirm. Then `:qa`.

  Expected proposed removals: every plugin we dropped (Nvim-R, claude-code.nvim, feline.nvim, nvim-web-devicons, LuaSnip, telescope-luasnip.nvim, all 7 vim-textobj-*, workspaces.nvim, oil.nvim, indent-tools.nvim, arshlib.nvim, sideways.vim, gitsigns.nvim, better-escape.nvim, nvim-autopairs, lua-async-await, cmp-nvim-r). Compare to spec list.

- [ ] **Step 3: Snapshot post-state**

  ```bash
  ls ~/.local/share/nvim/site/pack/packer/start/ > /tmp/packer-after.txt
  wc -l /tmp/packer-after.txt
  diff /tmp/packer-before.txt /tmp/packer-after.txt
  ```
  Expected: ~20 plugins removed, diff shows the dropped names.

- [ ] **Step 4: Snapshot post startup time**

  ```bash
  /opt/homebrew/bin/nvim --startuptime /tmp/nvim-startup-after.log "+qa"
  echo "after: $(tail -1 /tmp/nvim-startup-after.log)" >> /tmp/nvim-prune-baseline.txt
  cat /tmp/nvim-prune-baseline.txt
  ```
  Expected: startup time lower than before (no hard threshold; report the delta to user).

- [ ] **Step 5: Smoke-test interactively**

  Open nvim normally:
  ```bash
  /opt/homebrew/bin/nvim /Users/dewoller/.config/nvim/lua/dennis/packer.lua
  ```
  Verify by manually checking each:
  - Telescope: `<leader>ff` opens find_files
  - Treesitter highlighting active on the Lua buffer
  - LSP attaches (try a Python file too)
  - Hop: press `;` then 2 chars to jump
  - Neogit: `<LocalLeader>rg` opens
  - Comment.nvim: `gcc` toggles a line comment
  - Mundo: `<leader>m` opens undo tree
  - Surround: `saiw"` wraps a word in quotes
  - Cutlass: `dd` deletes without filling default register (`"` register stays as before)

  If any breaks, find the cause (likely a kept-plugin's after/plugin config still referencing a removed module) and fix.

- [ ] **Step 6: No commit**

  Task 10 only runs `:PackerClean` (which mutates `~/.local/share/nvim/site/pack/packer/start/` outside the repo) and does not modify repo files. No commit needed.

---

## Self-Review Notes

- Spec sections covered: workflows (Task 3), AI (Task 4), statusline (Task 5), snippets (Task 2 + 6), textobjects (Task 7), navigation/UI (Task 8), comfort plugins + lua-async-await (Task 9), open verification items (Task 1), post-edit verification (Task 10).
- No `--no-verify` or destructive force flags anywhere.
- Every `git add` enumerates explicit paths under `.config/nvim/` — never `-A` or `.` at top level. (Single uses of `-A` are scoped with `--` and an explicit path list, which is safe in the home-monorepo.)
- The `M.claudecode` block is removed wholesale per spec; if the user later wants the generic terminal-paste mappings back, they live in git history at the pre-Task-4 commit.

---

## Post-implementation: cleanup choices to offer the user

After Task 10, surface to the user:

1. Whether to also delete `scripts/` (R helpers — currently orphaned by Nvim-R removal but harmless).
2. Whether to convert `~/.config/nvim` into its own git repo (it's currently tracked by the home-dir monorepo, which makes per-config history noisy).
