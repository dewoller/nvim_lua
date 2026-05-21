

local set = vim.opt
local g = vim.g

-- Set the mapping to convert ipynb to vim-notebook buffer
vim.api.nvim_set_keymap('n', '<F5>', '<cmd>NotebookConvertIPynb<CR>', { noremap = true })

-- In your init.lua or a separate filetype.lua file
vim.filetype.add({
  extension = {
    j2 = "jinja",
  },
})
-- Set the default file type for .ipynb files to vim-notebook
vim.api.nvim_command('autocmd BufNewFile,BufReadPost *.ipynb set filetype=vim-notebook')
vim.api.nvim_command('autocmd BufNewFile,BufReadPost *.jinja set filetype=jinja')



-- Set the mapping to save and convert the buffer back to ipynb
-- vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>NotebookSave<CR>', { noremap = true })

g.mapleader=' '
g.maplocalleader=','

vim.env.NVIM_TUI_ENABLE_TRUE_COLOR=1
if vim.fn.has('termguicolors') and (vim.fn.has('mac') or vim.fn.has('win32')) then
  set.termguicolors=true
end


-- Auto-backup files and .swp files don't go to pwd
set.swapfile=true
set.backup=true
set.undofile=true
-- set.backupdir=vim.env.HOME .. "/vimtmp"
-- set.directory=vim.env.HOME .. "/vimtmp"
-- set.undodir=vim.env.HOME .. "/vimtmp"
g.isWindows = (vim.fn.has('win32')==1 or vim.fn.has ('win64')==1)
g.os_linux = (package.config:sub(1,1)=='/')


local getPath=function(str)
  sep='/'
  if( g.isWindows) then
    sep = '\\'
  end
    return str:match("(.*"..sep..")") .. sep
end

g.scripts = getPath( vim.env.MYVIMRC )  .. 'scripts'

if (g.isWindows)  then
    g.VIMHOME = vim.env.USERPROFILE .. "/.cache/vimbackup"
else
    g.VIMHOME = vim.env.HOME .. "/.cache/vimbackup"
end

-- Ensure backup directories exist
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, 'p')
  end
end

set.backupdir=g.VIMHOME .. '/backup/'
set.directory=g.VIMHOME .. '/swap/'
set.undodir=g.VIMHOME .. '/undo/'

-- Create directories if they don't exist
ensure_dir(g.VIMHOME)
ensure_dir(g.VIMHOME .. '/backup')
ensure_dir(g.VIMHOME .. '/swap')
ensure_dir(g.VIMHOME .. '/undo')

set.autoread=true
set.autowrite=true
set.confirm=true
set.splitright=true
set.encoding="UTF-8"
set.laststatus=2

set.history=2000
set.number=true
set.cmdheight=2
set.timeoutlen=1000
set.ttimeoutlen=10


set.relativenumber=true

set.backspace="indent,eol,start"

set.copyindent=true
set.shiftround=true



set.hidden=true
-- set.shortmess="aFc"
set.signcolumn="yes"
-- set.list=true
-- set.listchars="tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
-- set.listchars="tab:┌┬┐,trail:·"
-- set.listchars="tab:nbsp:+,trail:·"
set.list=false

set.hlsearch=true
set.incsearch=true


set.wrapscan=true
set.showmatch=true
set.matchtime=1
set.cpoptions:remove("m")
set.grepprg="rg --vimgrep $*"
set.wildignore:append("*.so,*~,*/.git/*,*/.svn/*,*/.DS_Store,*/tmp/*")

set.autowriteall=true


vim.o.background = "dark" -- or "light" for light mode




set.showmode = false

set.title = true
set.clipboard = "unnamedplus"
set.cursorline = true

-- Indenting
set.shiftwidth = 2
set.smartindent = true
set.tabstop = 2
set.softtabstop = 2

set.fillchars = { eob = " " }
set.ignorecase = true
set.smartcase = true
set.mouse = "a"

-- Numbers
set.numberwidth = 2
set.ruler = false

-- disable nvim intro
-- set.shortmess:append "sI"

set.splitbelow = true

set.updatetime = 250

set.whichwrap:append "<>[]hl"

g.python3_host_prog = vim.fn.stdpath('config') .. '/.venv/bin/python'
