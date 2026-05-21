local cmd = vim.cmd


vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    if vim.fn.exists(':GuiFont') == 2 then
      pcall(require, "ginit")
    end
  end,
})


-- vim.api.nvim_create_autocmd({ "FocusGained","BufEnter","CursorHold","CursorHoldI" }, {
--   pattern = { "*" },
--   command = [[if !bufexists("[Command Line]") | checktime | endif]],
-- })

vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  pattern = { "*" },
  command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None]],
})

-- autosave modified buffers when leaving
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
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

-- " go back to last position when reopening file
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  command = [[if line("'\"") > 1 && line("'\"") <= line("$") |  exe "normal! g`\"" |  endif]],
})


vim.cmd[[
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

]]





