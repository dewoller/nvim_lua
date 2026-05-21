vim.g.yoinkSavePersistently=1
vim.g.yoinkIncludeDeleteOperations=1

vim.api.nvim_set_keymap('n', 'p', "yoink#canSwap() ? '<plug>(YoinkPostPasteSwapBack)' : '<plug>(YoinkPaste_p)'", {expr = true, noremap = true})
vim.api.nvim_set_keymap('n', 'P', "yoink#canSwap() ? '<plug>(YoinkPostPasteSwapForward)' : '<plug>(YoinkPaste_P)'", {expr = true, noremap = true})

-- vim.cmd[[
-- nmap <expr> p yoink#canSwap() ? '<plug>(YoinkPostPasteSwapBack)' : '<plug>(YoinkPaste_p)'
-- nmap <expr> P yoink#canSwap() ? '<plug>(YoinkPostPasteSwapForward)' : '<plug>(YoinkPaste_P)'
-- ]]
