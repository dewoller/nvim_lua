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
