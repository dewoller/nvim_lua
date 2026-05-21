-- ABOUTME: Automatically removes trailing whitespace from lines when saving files
-- ABOUTME: Preserves cursor position and only modifies lines with trailing spaces

-- Create autocommand group for whitespace trimming
local trim_group = vim.api.nvim_create_augroup("TrimWhitespace", { clear = true })

-- Function to trim trailing whitespace
local function trim_trailing_whitespace()
    -- Save current cursor position
    local save_cursor = vim.api.nvim_win_get_cursor(0)

    -- Save the current search register
    local save_search = vim.fn.getreg('/')

    -- Perform the substitution silently
    -- %s removes from all lines, \s\+$ matches spaces at end of line
    vim.cmd([[silent! %s/\s\+$//e]])

    -- Restore the search register
    vim.fn.setreg('/', save_search)

    -- Restore cursor position
    vim.api.nvim_win_set_cursor(0, save_cursor)
end

-- Set up autocommand to run on BufWritePre (before saving)
vim.api.nvim_create_autocmd("BufWritePre", {
    group = trim_group,
    pattern = "*",
    callback = trim_trailing_whitespace,
    desc = "Remove trailing whitespace on save"
})

-- Optional: Add command to manually trigger whitespace trimming
vim.api.nvim_create_user_command("TrimWhitespace", trim_trailing_whitespace, {
    desc = "Remove trailing whitespace from current buffer"
})