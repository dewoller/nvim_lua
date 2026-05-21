# Nvim Lazy.nvim Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Rewrite `~/.config/nvim` into the lazy.nvim spec layout (one file per plugin under `lua/plugins/`, plain `lua/config/` for non-plugin config) while preserving identical behaviour for all 16 kept plugins.

**Architecture:** Side-by-side build in a git worktree at `~/.config/nvim-lazy/` on branch `migrate-lazy`. Test in parallel with the existing config via `NVIM_APPNAME=nvim-lazy nvim`. Merge to `main` only when daily-driver-ready.

**Tech Stack:** lua, lazy.nvim, nvim ≥0.9, `/opt/homebrew/bin/nvim`.

**Spec:** [`docs/superpowers/specs/2026-05-22-nvim-lazy-migration-design.md`](../specs/2026-05-22-nvim-lazy-migration-design.md)

---

## Prereqs

- Working dir for the plan: `/Users/dewoller/.config/nvim`
- Worktree dir for the build: `/Users/dewoller/.config/nvim-lazy`
- Branch to land on: `migrate-lazy`, merged into `main` at the end
- Verification command used after every plugin spec added:
  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  ```
  Expected: empty output. (The probe file must exist — create `/tmp/probe.py` once with one print statement.)
- The implementer **may** call `:Lazy sync` and `:Lazy reload` from inside `NVIM_APPNAME=nvim-lazy nvim` to settle plugin state. Plugin downloads on first sync take ~30s.

---

## File Map (worktree contents at end)

```
~/.config/nvim-lazy/   (worktree, branch migrate-lazy)
├── .gitignore                       # preserved
├── archive/                         # preserved (luasnip backup)
├── docs/                            # preserved (spec + plan)
├── CLAUDE.md  AGENTS.md             # preserved
├── init.lua                         # REWRITTEN (3 lines)
├── lua/
│   ├── ginit.lua                    # preserved (GUI font tweaks, called via pcall)
│   ├── config/
│   │   ├── lazy.lua                 # NEW
│   │   ├── options.lua              # NEW (port of lua/settings.lua)
│   │   ├── keymaps.lua              # NEW (port of non-plugin keys from lua/dennis/mappings.lua)
│   │   └── autocmds.lua             # NEW (port of lua/dennis/functions.lua + trim-whitespace)
│   └── plugins/
│       ├── colorscheme.lua          # NEW
│       ├── telescope.lua            # NEW
│       ├── treesitter.lua           # NEW
│       ├── lsp.lua                  # NEW
│       ├── completion.lua           # NEW
│       ├── neogit.lua               # NEW
│       ├── hop.lua                  # NEW
│       ├── mundo.lua                # NEW
│       ├── comment.lua              # NEW
│       └── editing.lua              # NEW
└── ftplugin/                        # preserved (Python/R filetype tweaks)
```

**Deleted on `migrate-lazy`:**
- `lua/dennis/` (all 5 files)
- `lua/settings.lua` (contents moved into `lua/config/options.lua`)
- `after/plugin/*.lua` (entire directory)
- `plugin/packer_compiled.lua` (gitignored anyway, but removed if present)
- `scripts/` is **kept** — out of scope for this migration.
- `lua/config/codegpt.lua` was already deleted in the prune.

---

## Task 0: Worktree setup + probe file

- [ ] **Step 1: Create the worktree**
  ```bash
  cd /Users/dewoller/.config/nvim
  git worktree add ../nvim-lazy -b migrate-lazy
  ls -la /Users/dewoller/.config/nvim-lazy/.git 2>&1 | head -3
  ```
  Expected: `.git` is a file (worktree gitfile), not a directory.

- [ ] **Step 2: Create a probe file for headless verification**
  ```bash
  printf 'print("ok")\n' > /tmp/probe.py
  ls -la /tmp/probe.py
  ```

- [ ] **Step 3: Confirm baseline parallel state**
  ```bash
  /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1 | head -5
  echo "---"
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1 | head -5
  echo "---"
  ls -la ~/.local/share/nvim-lazy/ 2>&1 | head -3
  ```
  Expected: first command empty (existing config still works). Second command will complain (no init.lua at `~/.config/nvim-lazy/lua/...`) — that's fine; we're about to build it. The data dir at `~/.local/share/nvim-lazy/` doesn't exist yet and will be created on first launch — also fine.

---

## Task 1: Skeleton — init.lua + lua/config/

All work happens **inside the worktree** (`cd /Users/dewoller/.config/nvim-lazy`). Commits land on `migrate-lazy`.

- [ ] **Step 1: Remove the old files in the worktree**
  ```bash
  cd /Users/dewoller/.config/nvim-lazy
  rm -rf lua/dennis lua/settings.lua after/plugin plugin/packer_compiled.lua init.lua
  git add -A -- lua/dennis lua/settings.lua after/plugin plugin/packer_compiled.lua init.lua
  git status -sb | head -20
  ```
  Expected: lots of `D` (deleted) lines.

- [ ] **Step 2: Write `init.lua`**

  ```lua
  -- init.lua: bootstrap and load the modular config.
  require("config.lazy")
  require("config.keymaps")
  require("config.autocmds")
  ```

- [ ] **Step 3: Write `lua/config/lazy.lua`**

  ```lua
  -- Bootstrap lazy.nvim and load all plugin specs from lua/plugins/.
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
      "git", "clone", "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Options must be loaded before lazy.setup so mapleader is set before plugins map keys.
  require("config.options")

  require("lazy").setup({
    spec = { { import = "plugins" } },
    change_detection = { notify = false },
  })
  ```

- [ ] **Step 4: Write `lua/config/options.lua`**

  Port the entire contents of the previous `lua/settings.lua` verbatim. The mapleader/maplocalleader/swapfile/backup/undofile blocks all move over. Keep the ipynb/jinja filetype.add calls and the `<F5>` NotebookConvertIPynb mapping (it's a global key, fits in options.lua because it shares the filetype context).

  Source content (from `lua/settings.lua` as it stood at commit 5362b20):

  ```lua
  -- Filetype + ipynb support
  vim.api.nvim_set_keymap('n', '<F5>', '<cmd>NotebookConvertIPynb<CR>', { noremap = true })
  vim.filetype.add({
    extension = { j2 = "jinja" },
  })
  vim.api.nvim_command('autocmd BufNewFile,BufReadPost *.ipynb set filetype=vim-notebook')
  vim.api.nvim_command('autocmd BufNewFile,BufReadPost *.jinja set filetype=jinja')

  -- Leaders (must be set before plugins load)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ','

  -- True color
  vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
  if vim.fn.has('termguicolors') and (vim.fn.has('mac') or vim.fn.has('win32')) then
    vim.opt.termguicolors = true
  end

  -- Backup / swap / undo
  vim.opt.swapfile = true
  vim.opt.backup = true
  vim.opt.undofile = true
  vim.g.isWindows = (vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1)
  vim.g.os_linux = (package.config:sub(1, 1) == '/')

  if vim.g.isWindows then
    vim.g.VIMHOME = vim.env.USERPROFILE .. "/.cache/vimbackup"
  else
    vim.g.VIMHOME = vim.env.HOME .. "/.cache/vimbackup"
  end

  local function ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then vim.fn.mkdir(path, 'p') end
  end
  vim.opt.backupdir = vim.g.VIMHOME .. '/backup/'
  vim.opt.directory = vim.g.VIMHOME .. '/swap/'
  vim.opt.undodir   = vim.g.VIMHOME .. '/undo/'
  ensure_dir(vim.g.VIMHOME)
  ensure_dir(vim.g.VIMHOME .. '/backup')
  ensure_dir(vim.g.VIMHOME .. '/swap')
  ensure_dir(vim.g.VIMHOME .. '/undo')

  -- Editing behaviour
  vim.opt.autoread = true
  vim.opt.autowrite = true
  vim.opt.autowriteall = true
  vim.opt.confirm = true
  vim.opt.splitright = true
  vim.opt.splitbelow = true
  vim.opt.encoding = "UTF-8"
  vim.opt.laststatus = 2
  vim.opt.history = 2000
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.cmdheight = 2
  vim.opt.timeoutlen = 1000
  vim.opt.ttimeoutlen = 10
  vim.opt.backspace = "indent,eol,start"
  vim.opt.copyindent = true
  vim.opt.shiftround = true
  vim.opt.hidden = true
  vim.opt.signcolumn = "yes"
  vim.opt.list = false
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
  vim.opt.wrapscan = true
  vim.opt.showmatch = true
  vim.opt.matchtime = 1
  vim.opt.cpoptions:remove("m")
  vim.opt.grepprg = "rg --vimgrep $*"
  vim.opt.wildignore:append("*.so,*~,*/.git/*,*/.svn/*,*/.DS_Store,*/tmp/*")
  vim.o.background = "dark"
  vim.opt.showmode = false
  vim.opt.title = true
  vim.opt.clipboard = "unnamedplus"
  vim.opt.cursorline = true
  vim.opt.shiftwidth = 2
  vim.opt.smartindent = true
  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.fillchars = { eob = " " }
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.mouse = "a"
  vim.opt.numberwidth = 2
  vim.opt.ruler = false
  vim.opt.updatetime = 250
  vim.opt.whichwrap:append "<>[]hl"

  vim.g.python3_host_prog = vim.fn.stdpath('config') .. '/.venv/bin/python'

  -- Defensive default left over from removed Copilot support
  vim.g.copilot_no_tab_map = true
  ```

- [ ] **Step 5: Write `lua/config/keymaps.lua`**

  Port all the non-plugin tables from the old `lua/dennis/mappings.lua` (`M.general`, `M.buffer`, `M.next_buffer`, `M.general_programming`, `M.os`) into a single flat sequence of `vim.keymap.set(...)` calls. Also include the tnoremap window-nav block.

  ```lua
  -- Non-plugin keymaps. Plugin-owned keymaps live inside each lua/plugins/*.lua spec.

  local map = vim.keymap.set

  -- Insert-mode shortcuts
  map("i", "<C-C>",  "<Esc>")
  map("i", "<C-d>",  "<Esc>:bp<bar>sp<bar>bn<bar>bd<CR>")
  map("i", "<C-S>",  "<c-o>:update<CR><Esc>")
  map("i", "<C-q>",  "<ESC>:q<cr>")

  -- Window navigation (normal + visual + terminal)
  for _, mode in ipairs({ "n", "v" }) do
    map(mode, "<C-h>", "<C-w>h")
    map(mode, "<C-j>", "<C-w>j")
    map(mode, "<C-k>", "<C-w>k")
    map(mode, "<C-l>", "<C-w>l")
    map(mode, "<C-u>", "<C-^>")
    map(mode, "<C-d>", "<Esc>:bp<bar>sp<bar>bn<bar>bd<CR>")
  end
  vim.cmd([[
    tnoremap <C-h> <C-\><C-N><C-w>h
    tnoremap <C-l> <C-\><C-N><C-w>l
    tnoremap <C-j> <C-\><C-N><C-w>j
    tnoremap <C-k> <C-\><C-N><C-w>k
  ]])

  -- Window resize
  for _, mode in ipairs({ "n", "v" }) do
    map(mode, "+", "30<C-W>>")
    map(mode, "-", "30<C-W><")
  end

  -- Yank file path / clear hl / quit
  map({ "n", "v" }, "<leader>y", ":let @+ = expand('%')<CR>")
  map("n", "<CR>", "<cmd>noh<cr><cr>")
  map("n", "<c-q>", ":q<cr>")

  -- Buffer cycling
  map("n", "[b", ":bn<CR>")
  map("n", "]b", ":bp<CR>")

  -- Quickfix
  map("n", "<F7>", ":cprevious<cr>")
  map("n", "<F8>", ":cnext<cr>")

  -- Macros + misc
  map("n", "<F1>", "qq")
  map("n", "<F2>", "q")
  map("n", "<F3>", "@q")
  map("n", "E", ":ed<cr>G")
  map("n", ",ru", ":vs#<cr><c-w>x<c-w>h")
  map("n", "<kMinus>", "<C-x>")
  map("n", "<kPlus>", "<C-a>")
  map("n", "Y", "y$")
  map("n", "j", "gj")
  map("n", "k", "gk")
  map("v", "j", "gj")
  map("v", "k", "gk")
  map("n", "<C-S>", ":update<CR>")
  map("v", "<C-s>", "<c-c>:update<CR>gv")
  map("n", "q:", "<Nop>")

  -- File rename + cd
  map("n", "<leader>n", ":call RenameFile()<cr>")
  map("n", "<Leader>cd", ":cd %:h<CR>")
  map("n", "<LocalLeader>rc", ":s/,/,\\r/g<cr>:noh<cr>=ip")
  map("n", "<LocalLeader>r,", ":s/,/,\\r/g<cr>:noh<cr>=ip")

  -- Open Finder (macOS only)
  if package.config:sub(1, 1) == "/" then
    map("n", "<leader>e", ":! cd \"%:p:h:8\"; open .&>/dev/null<cr>", { desc = "explorer" })
  end
  ```

- [ ] **Step 6: Write `lua/config/autocmds.lua`**

  Port from `lua/dennis/functions.lua` and `after/plugin/trim-whitespace.lua`.

  ```lua
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  -- GUI font tweaks (nvim-qt only)
  autocmd("UIEnter", {
    once = true,
    callback = function()
      if vim.fn.exists(":GuiFont") == 2 then
        pcall(require, "ginit")
      end
    end,
  })

  -- File-changed-on-disk notice
  autocmd("FileChangedShellPost", {
    pattern = "*",
    command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None]],
  })

  -- Autosave modified buffers on focus loss
  autocmd({ "BufLeave", "FocusLost" }, {
    callback = function(event)
      local buf = event.buf
      local bo = vim.bo[buf]
      if not bo.modified or bo.readonly or bo.buftype ~= "" or not bo.modifiable then
        return
      end
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! update")
      end)
    end,
  })

  -- Restore cursor position on file reopen
  autocmd("BufReadPost", {
    pattern = "*",
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]],
  })

  -- Trim trailing whitespace on save
  local trim_group = augroup("TrimWhitespace", { clear = true })
  local function trim_trailing_whitespace()
    local save_cursor = vim.api.nvim_win_get_cursor(0)
    local save_search = vim.fn.getreg("/")
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.setreg("/", save_search)
    vim.api.nvim_win_set_cursor(0, save_cursor)
  end
  autocmd("BufWritePre", {
    group = trim_group,
    pattern = "*",
    callback = trim_trailing_whitespace,
    desc = "Remove trailing whitespace on save",
  })
  vim.api.nvim_create_user_command("TrimWhitespace", trim_trailing_whitespace, {
    desc = "Remove trailing whitespace from current buffer",
  })

  -- RenameFile() vimscript function (used by <leader>n)
  vim.cmd([[
  function! RenameFile()
      let old_name = expand('%')
      let new_name = input('New file name: ', expand('%'), 'file')
      if new_name != '' && new_name != old_name
          exec ':saveas ' . new_name
          if filereadable(old_name)
            if delete(old_name) != 0
              echohl WarningMsg | echom 'Unable to delete ' . old_name | echohl None
            endif
          endif
          redraw!
      endif
  endfunction
  ]])
  ```

- [ ] **Step 7: Smoke-test the skeleton**

  Lazy.nvim isn't installed yet, but launching nvim should bootstrap it.

  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1 | head -30
  ```

  Expected: lazy.nvim downloads, no plugins loaded yet (because `lua/plugins/` is empty), exit 0. There may be a brief delay on first run. If you see "module 'plugins' not found" — that's because lazy expects `lua/plugins/` to exist as a directory; it's fine for it to be empty BUT you'll need at least one `lua/plugins/*.lua` file. Create a stub `lua/plugins/colorscheme.lua` with `return {}` if needed, or proceed to Task 2 immediately and the import resolves.

- [ ] **Step 8: Commit skeleton**

  ```bash
  cd /Users/dewoller/.config/nvim-lazy
  git add init.lua lua/config/
  git add -A -- lua/dennis lua/settings.lua after/plugin plugin/packer_compiled.lua
  git commit -m "$(cat <<'EOF'
  migrate(nvim): skeleton — init.lua + lua/config/, drop dennis/packer files

  Drops the lua/dennis/ namespace, lua/settings.lua, after/plugin/*, and
  plugin/packer_compiled.lua. Adds the lazy.nvim bootstrap and config skeleton:
  options/keymaps/autocmds. No plugins installed yet — that's Tasks 2–11.

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 2: Colorscheme — `lua/plugins/colorscheme.lua`

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("tokyonight")
      end,
    },
  }
  ```

- [ ] **Step 2: Verify**

  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  ```
  Expected: empty (after lazy installs tokyonight on first run). The first invocation will install — that's OK; it returns exit 0. Re-run if there's "installing" output to ensure stability.

- [ ] **Step 3: Commit**

  ```bash
  git add lua/plugins/colorscheme.lua
  git commit -m "migrate(nvim): add tokyonight colorscheme spec

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

## Task 3: Telescope — `lua/plugins/telescope.lua`

- [ ] **Step 1: Write the spec**

  Pull the `defaults`, `pickers`, and `extensions_list` blocks verbatim from the old `after/plugin/telescope.lua` (post-fix-up state). Move all keymaps from `M.telescope` and `M.next_buffer` into `keys = {}`.

  ```lua
  return {
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.4",
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release",
        },
      },
      cmd = "Telescope",
      keys = {
        { "<leader>ff",  "<cmd>Telescope find_files<cr>",        desc = "find_files" },
        { "<leader>fr",  "<cmd>Telescope live_grep<cr>",         desc = "live_grep" },
        { "<leader>b",   "<cmd>Telescope buffers<cr>",           desc = "buffers" },
        { "<leader>fh",  "<cmd>Telescope help_tags<cr>",         desc = "help_tags" },
        { "<Leader>fo",  "<cmd>Telescope oldfiles<CR>",          desc = "oldfiles" },
        { "<leader>fF",  function() vim.api.nvim_command("Telescope git_files default_text=" .. vim.fn.expand("<cword>")) end, desc = "git_files word" },
        { "<leader>gf",  function() vim.api.nvim_command("edit " .. vim.fn.expand("<cword>")) end, desc = "edit cword" },
        { "<leader>fw",  function() vim.api.nvim_command("Telescope live_grep default_text=" .. vim.fn.expand("<cword>")) end, desc = "live_grep word" },
        { "<leader>jR",  "<cmd>Telescope lsp_references<cr>",       desc = "lsp_references" },
        { "<leader>jD",  "<cmd>Telescope lsp_definitions<cr>",      desc = "lsp_definitions" },
        { "<leader>ji",  "<cmd>Telescope lsp_incoming_calls<cr>",   desc = "lsp_incoming_calls" },
        { "<leader>jo",  "<cmd>Telescope lsp_outgoing_calls<cr>",   desc = "lsp_outgoing_calls" },
        { "<leader>gt",  "<cmd>Telescope git_commits<cr>",          desc = "git_commits" },
        { "<leader>gs",  "<cmd>Telescope git_status<cr>",           desc = "git_status" },
        { "<leader>tc",  "<cmd>Telescope colorscheme<cr>",          desc = "colorscheme" },
        { "<leader>tq",  "<cmd>Telescope quickfix<cr>",             desc = "quickfix" },
        { "<leader>th",  "<cmd>Telescope quickfixhistory<cr>",      desc = "quickfixhistory" },
        { "<leader>tl",  "<cmd>Telescope loclist<cr>",              desc = "loclist" },
        { "<leader>ts",  "<cmd>Telescope search_history<cr>",       desc = "search_history" },
        { "<leader>tr",  "<cmd>Telescope resume<cr>",               desc = "telescope resume" },
        { "<leader>to",  "<cmd>Telescope vim_options<cr>",          desc = "vim_options" },
        { "<leader>tm",  "<cmd>Telescope marks<cr>",                desc = "marks" },
        { "<leader>tk",  "<cmd>Telescope keymaps<cr>",              desc = "keymaps" },
        { "<leader>ta",  "<cmd>Telescope autocommands<cr>",         desc = "autocommands" },
        { "<bslash>",    "<cmd>Telescope buffers<cr>",              mode = { "n", "v" } },
      },
      config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
          defaults = {
            vimgrep_arguments = {
              "rg", "--color=never", "--no-heading", "--with-filename",
              "--line-number", "--column", "--smart-case",
            },
            prompt_prefix = "   ",
            selection_caret = "  ",
            entry_prefix = "  ",
            initial_mode = "insert",
            selection_strategy = "reset",
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = {
              horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
              },
              vertical = { mirror = false },
              width = 0.87,
              height = 0.80,
              preview_cutoff = 120,
            },
            file_ignore_patterns = { "node_modules" },
            path_display = { "truncate" },
            winblend = 0,
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            color_devicons = true,
            set_env = { ["COLORTERM"] = "truecolor" },
            mappings = {
              n = {
                ["<c-d>"] = actions.delete_buffer,
                ["q"]     = actions.close,
              },
              i = {
                ["<C-h>"] = "which_key",
                ["<c-d>"] = actions.delete_buffer,
              },
            },
          },
          pickers = {
            buffers = {
              ignore_current_buffer = true,
              sort_lastused = true,
            },
          },
        })
        require("telescope").load_extension("fzf")
      end,
    },
  }
  ```

- [ ] **Step 2: Verify**
  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  ```
  Expected: empty (after lazy installs telescope + plenary + fzf-native).

- [ ] **Step 3: Commit**
  ```bash
  git add lua/plugins/telescope.lua
  git commit -m "migrate(nvim): add telescope spec with fzf-native + all keymaps

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

## Task 4: Treesitter — `lua/plugins/treesitter.lua`

- [ ] **Step 1: Write the spec**

  Port the `nvim-treesitter`, `nvim-treesitter-textobjects`, and `nvim-treesitter-textsubjects` configs into one spec file. The current `after/plugin/treesitter.lua` is the source.

  ```lua
  return {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "RRethy/nvim-treesitter-textsubjects",
      },
      event = { "BufReadPost", "BufNewFile" },
      config = function()
        local options = {
          sync_install = true,
          auto_install = true,
          highlight = {
            enable = true,
            use_languagetree = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
          filetype_to_parsername = { jinja = "jinja" },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection    = "<CR>",
              scope_incremental = "<CR>",
              node_incremental  = "<TAB>",
              node_decremental  = "<S-TAB>",
            },
          },
          ensure_installed = {
            "lua", "vim", "vimdoc", "javascript", "python",
            "r", "markdown", "c", "jinja", "html",
          },
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ar"] = "@parameter.outer",
                ["ir"] = "@parameter.inner",
              },
            },
          },
        }

        -- Skip jinja if the parser config isn't registered (matches old behaviour)
        local parsers_ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if parsers_ok then
          local configs = parsers.get_parser_configs()
          if not configs.jinja then
            options.ensure_installed = vim.tbl_filter(function(lang)
              return lang ~= "jinja"
            end, options.ensure_installed)
            options.ignore_install = options.ignore_install or {}
            table.insert(options.ignore_install, "jinja")
            options.filetype_to_parsername.jinja = nil
          end
        end

        require("nvim-treesitter.configs").setup(options)

        -- Textsubjects setup (was inline in lua/dennis/packer.lua use{} block)
        require("nvim-treesitter-textsubjects").configure({
          prev_selection = ",",
          keymaps = {
            ["."]   = "textsubjects-smart",
            [";"]   = "textsubjects-container-outer",
            ["i;"]  = "textsubjects-container-inner",
          },
        })
      end,
    },
  }
  ```

  Note: textsubjects' `;` keymap conflicts with hop.nvim's `;` keymap. Both are normal-mode `;`. In the OLD config they coexisted because hop's mapping went through dennis/mappings.lua and textsubjects was configured separately — last-one-wins applied. This must be preserved: hop's `;` is the one we use globally, textsubjects' `;` is only for visual-mode container expansion. The hop spec uses `keys = { ";" }` for normal+visual; textsubjects' `;` is registered via its own setup which uses operator-pending and visual-mode mapping internally. The plugin's own configure() call should not stomp the normal-mode mapping; if it does, drop the textsubjects `;` to `"<leader>;"` or remove that entry.

- [ ] **Step 2: Verify**
  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  ```

- [ ] **Step 3: Commit**
  ```bash
  git add lua/plugins/treesitter.lua
  git commit -m "migrate(nvim): add treesitter + textobjects + textsubjects spec

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

## Task 5: LSP — `lua/plugins/lsp.lua`

- [ ] **Step 1: Write the spec**

  Port from old `after/plugin/lsp-zero.lua` (top half) + `after/plugin/mason-lspconfig.lua`. cmp setup goes to Task 6.

  ```lua
  return {
    {
      "VonHeikemen/lsp-zero.nvim",
      branch = "v4.x",
      dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
      },
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        local lsp = require("lsp-zero")

        lsp.on_attach(function(_, bufnr)
          lsp.default_keymaps({
            buffer = bufnr,
            omit = { "gs", "K" }, -- mapped in lua/config/keymaps.lua / lspzero block
          })
        end)

        require("mason").setup({
          ui = {
            icons = {
              package_installed   = "✓",
              package_pending     = "➜",
              package_uninstalled = "✗",
            },
          },
        })

        local mason_lspconfig = require("mason-lspconfig")
        local lspconfigs = require("lspconfig.configs")

        mason_lspconfig.setup({
          ensure_installed = {
            "lua_ls", "pyright", "ts_ls", "bashls", "jsonls", "yamlls", "marksman",
          },
          automatic_installation = true,
        })

        lsp.setup()

        local function setup_server(name, opts)
          pcall(require, "lspconfig.configs." .. name)
          local cfg = lspconfigs[name]
          if cfg and cfg.setup then cfg.setup(opts or {}) end
        end

        local function setup_all()
          for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
            local config_name = server == "tsserver" and "ts_ls" or server
            if config_name == "lua_ls" then
              setup_server("lua_ls", {
                settings = {
                  Lua = {
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                      library = vim.api.nvim_get_runtime_file("", true),
                      checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                  },
                },
              })
            else
              setup_server(config_name, {})
            end
          end
        end

        setup_all()

        vim.api.nvim_create_autocmd("User", {
          pattern = "MasonToolsUpdateCompleted",
          callback = setup_all,
        })

        -- LSP keymaps that the old config kept in M.lspzero
        local fmt = function(cmd) return function(str) return cmd:format(str) end end
        local lspf = fmt("<cmd>lua vim.lsp.%s<cr>")
        local diag = fmt("<cmd>lua vim.diagnostic.%s<cr>")
        local map = vim.keymap.set
        map("n", "<leader>r", lspf("buf.rename()<cr>"))
        map("n", "K",   lspf("buf.hover()"))
        map("n", "gi",  lspf("buf.implementation()"))
        map("n", "gt",  lspf("buf.type_definition()"))
        map("n", "gr",  lspf("buf.references()"))
        map("n", "gl",  diag("open_float()"))
        map("n", "[d",  diag("goto_prev()"))
        map("n", "]d",  diag("goto_next()"))
      end,
    },
  }
  ```

- [ ] **Step 2: Verify**
  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  ```

- [ ] **Step 3: Commit**
  ```bash
  git add lua/plugins/lsp.lua
  git commit -m "migrate(nvim): add lsp-zero + mason + mason-lspconfig spec

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

## Task 6: Completion — `lua/plugins/completion.lua`

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    {
      "hrsh7th/nvim-cmp",
      event = { "InsertEnter", "CmdlineEnter" },
      dependencies = {
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-cmdline",
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          sources = {
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer", keyword_length = 3 },
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"]      = cmp.mapping.confirm({ select = true }),
            ["<C-e>"]     = cmp.mapping.abort(),
            ["<C-d>"]     = cmp.mapping.scroll_docs(-4),
            ["<C-u>"]     = cmp.mapping.scroll_docs(4),
          }),
          preselect = "item",
          completion = { completeopt = "menu,menuone,noinsert" },
          experimental = { ghost_text = false },
        })

        cmp.setup.cmdline("/", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = { { name = "buffer" } },
        })

        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources(
            { { name = "path" } },
            { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
          ),
        })
      end,
    },
  }
  ```

- [ ] **Step 2: Verify + commit**
  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  git add lua/plugins/completion.lua
  git commit -m "migrate(nvim): add nvim-cmp spec with path/buffer/lsp/lua/cmdline sources

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

## Task 7: Neogit — `lua/plugins/neogit.lua`

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    {
      "NeogitOrg/neogit",
      branch = "master",
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = "Neogit",
      keys = {
        { "<LocalLeader>rg", "<cmd>Neogit<cr>", desc = "Neogit" },
      },
      opts = {
        disable_commit_confirmation = true,
      },
    },
  }
  ```

- [ ] **Step 2: Verify + commit**

---

## Task 8: Hop — `lua/plugins/hop.lua`

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    {
      "smoka7/hop.nvim",
      version = "*",
      keys = {
        { ";", "<cmd>HopChar2MW<cr>", mode = { "n", "v" } },
      },
      opts = {},
    },
  }
  ```

- [ ] **Step 2: Verify + commit**

---

## Task 9: Mundo — `lua/plugins/mundo.lua`

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    {
      "simnalamburt/vim-mundo",
      cmd = "MundoToggle",
      keys = {
        { "<leader>m", "<cmd>MundoToggle<cr>", desc = "MundoToggle" },
      },
    },
  }
  ```

- [ ] **Step 2: Verify + commit**

---

## Task 10: Comment.nvim — `lua/plugins/comment.lua`

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    {
      "numToStr/Comment.nvim",
      event = { "BufReadPost", "BufNewFile" },
      opts = {},
    },
  }
  ```

- [ ] **Step 2: Verify + commit**

---

## Task 11: Editing cluster — `lua/plugins/editing.lua`

Six plugins as a single file. Use the `init`/`opts`/`config`/`keys` lazy.nvim conventions appropriately for each. Yoink needs `vim.g.yoink*` set in `init` (before plugin loads) and its `p`/`P`/`<c-p>` mappings in `keys`.

- [ ] **Step 1: Write the spec**

  ```lua
  return {
    -- tpope trio
    { "tpope/vim-surround", event = "VeryLazy" },
    { "tpope/vim-repeat",   event = "VeryLazy" },
    { "tpope/vim-unimpaired", event = "VeryLazy" },

    -- Cutlass — separate delete from cut
    {
      "gbprod/cutlass.nvim",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        exclude = { "nd", "nD", "xd", "ndd" },
      },
    },

    -- Yoink — yank ring
    {
      "svermeulen/vim-yoink",
      event = "VeryLazy",
      init = function()
        vim.g.yoinkSavePersistently = 1
        vim.g.yoinkIncludeDeleteOperations = 1
      end,
      keys = {
        { "p",     "yoink#canSwap() ? '<plug>(YoinkPostPasteSwapBack)' : '<plug>(YoinkPaste_p)'", expr = true, mode = "n" },
        { "P",     "yoink#canSwap() ? '<plug>(YoinkPostPasteSwapForward)' : '<plug>(YoinkPaste_P)'", expr = true, mode = "n" },
        { "<c-p>", "<plug>(YoinkPostPasteSwapForward)", mode = "n" },
        { "y",     "<plug>(YoinkYankPreserveCursorPosition)", mode = { "n", "x" } },
      },
    },

    -- Subversive — substitute with register
    {
      "svermeulen/vim-subversive",
      event = "VeryLazy",
      keys = {
        { "s",   "<plug>(SubversiveSubstitute)", mode = "n" },
        { "ss",  "<plug>(SubversiveSubstituteLine)", mode = "n" },
        { "S",   "<plug>(SubversiveSubstituteToEndOfLine)", mode = "n" },
        { "gs",  "<plug>(SubversiveSubstituteRange)", mode = { "n", "x" } },
        { "gss", "<plug>(SubversiveSubstituteWordRange)", mode = "n" },
        { "s",   "<plug>(SubversiveSubstitute)", mode = "x" },
        { "p",   "<plug>(SubversiveSubstitute)", mode = "x" },
        { "P",   "<plug>(SubversiveSubstitute)", mode = "x" },
      },
    },

    -- vim-textobj-user is gone (none of the legacy textobj-* plugins kept)
    -- operator-surround keymaps from M.surround used <Plug>(operator-surround-*)
    -- but the actual plugin "osyo-manga/vim-operator-surround" was never installed.
    -- Those keymaps were dead in the old config; do not migrate them.
  }
  ```

  Note: the old `M.surround` mappings (`sa`/`sd`/`sr`) referenced `<Plug>(operator-surround-*)` from `osyo-manga/vim-operator-surround`, which was **never declared in packer.lua**. They were dead mappings. We're following Step 1's spec by *not* re-creating them — `tpope/vim-surround` uses different defaults (`ys`/`ds`/`cs`). If the user later wants the old `sa/sd/sr` bindings back on tpope's surround, that's a follow-up.

- [ ] **Step 2: Verify + commit**

---

## Task 12: Final sweeps + smoke test

- [ ] **Step 1: Run `:Lazy sync`**

  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
  ```
  Expected: lazy installs/updates all 16 plugins, no errors. The `!` makes it non-interactive.

- [ ] **Step 2: Run `:checkhealth lazy`**

  ```bash
  NVIM_APPNAME=nvim-lazy /opt/homebrew/bin/nvim --headless "+checkhealth lazy" "+qa" 2>&1 | tail -20
  ```
  Expected: no errors. Warnings about optional dependencies (e.g., luarocks) are acceptable.

- [ ] **Step 3: Interactive smoke test (user-driven)**

  Surface to the user:
  ```
  Open: NVIM_APPNAME=nvim-lazy nvim
  Verify: <leader>ff, ;, gcc, <leader>m, ysiw" (or saiw"), <LocalLeader>rg, dd vs nd, p (yoink), LSP attaches on Python.
  ```
  If anything breaks, address it in a fix commit on `migrate-lazy` before merging.

---

## Task 13: Merge to main

- [ ] **Step 1: Final state inspection**

  ```bash
  cd /Users/dewoller/.config/nvim-lazy
  git log --oneline main..migrate-lazy
  ```
  Expected: ~13 commits (Tasks 1–12).

- [ ] **Step 2: Merge**

  ```bash
  cd /Users/dewoller/.config/nvim
  git checkout main
  git merge --no-ff migrate-lazy -m "merge: lazy.nvim migration"
  ```

- [ ] **Step 3: Validate post-merge launch**

  ```bash
  /opt/homebrew/bin/nvim --headless /tmp/probe.py "+qa" 2>&1
  ```
  Expected: empty. (No more `NVIM_APPNAME` — this IS the config now.)

- [ ] **Step 4: Remove the worktree**

  ```bash
  git worktree remove ../nvim-lazy
  ```

- [ ] **Step 5: Clean up packer's stale plugin dir (optional)**

  ```bash
  ls -d ~/.local/share/nvim/site/pack/packer/start/ 2>&1
  echo "If empty/unneeded, you can: rm -rf ~/.local/share/nvim/site/pack/packer/"
  ```
  Surface this to the user — don't auto-delete.

---

## Self-review notes

- Spec sections covered: lazy bootstrap (Task 1), options (Task 1), keymaps (Task 1), autocmds (Task 1), all 16 plugins (Tasks 2–11), final sweep (Task 12), merge (Task 13).
- Special cases handled inline: yoink `init`, textsubjects `;` collision noted, dead `M.surround` mappings flagged.
- All `git add` commands enumerate explicit paths.
- No `--no-verify` anywhere.

## Out of scope

- Switching `tpope/vim-surround` → `kylechui/nvim-surround`.
- Cleaning up `scripts/` R helpers.
- Re-implementing `M.surround` `sa/sd/sr` keybindings against tpope's surround interface (the user never had these wired up to a real plugin).
- Removing `~/.local/share/nvim/site/pack/packer/` plugin dir (surfaced to user in Task 13 Step 5).
