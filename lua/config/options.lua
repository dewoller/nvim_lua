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
-- Name the Cursor group so the TUI sets the terminal's cursor colour (OSC 12).
-- Without it, terminal nvim (e.g. Claude Code's ctrl-g editor) keeps the
-- terminal's dark cursor, which disappears on tokyonight's cursorline.
vim.opt.guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor,t:block-blinkon500-blinkoff500-TermCursor"
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
