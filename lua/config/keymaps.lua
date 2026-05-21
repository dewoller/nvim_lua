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
