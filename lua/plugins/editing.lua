return {
  -- tpope trio — load at startup; vimscript plugins that register VimEnter autocmds
  { "tpope/vim-surround",   lazy = false },
  { "tpope/vim-repeat",     lazy = false },
  { "tpope/vim-unimpaired", lazy = false },

  -- Cutlass — separate delete from cut
  {
    "gbprod/cutlass.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      exclude = { "nd", "nD", "xd", "ndd" },
    },
  },

  -- Yoink — yank ring. Must load at startup: plugin/yoink.vim registers a
  -- VimEnter autocmd (yoink#onVimEnter) that initialises the paste machinery.
  -- Lazy-loading it post-VimEnter leaves yoink#paste/opfunc state uninitialised
  -- and `p` becomes a silent no-op.
  {
    "svermeulen/vim-yoink",
    lazy = false,
    init = function()
      vim.g.yoinkSavePersistently = 1
      vim.g.yoinkIncludeDeleteOperations = 1
    end,
    keys = {
      { "p",     "<plug>(YoinkPaste_p)",                       remap = true, mode = "n" },
      { "P",     "<plug>(YoinkPaste_P)",                       remap = true, mode = "n" },
      { "<c-p>", "<plug>(YoinkPostPasteSwapForward)",          remap = true, mode = "n" },
      { "<c-n>", "<plug>(YoinkPostPasteSwapBack)",             remap = true, mode = "n" },
      { "y",     "<plug>(YoinkYankPreserveCursorPosition)",    remap = true, mode = { "n", "x" } },
    },
  },

  -- Subversive — substitute with register. Also vimscript, also safest at startup.
  {
    "svermeulen/vim-subversive",
    lazy = false,
    keys = {
      { "s",   "<plug>(SubversiveSubstitute)",            remap = true, mode = "n" },
      { "ss",  "<plug>(SubversiveSubstituteLine)",        remap = true, mode = "n" },
      { "S",   "<plug>(SubversiveSubstituteToEndOfLine)", remap = true, mode = "n" },
      { "gs",  "<plug>(SubversiveSubstituteRange)",       remap = true, mode = { "n", "x" } },
      { "gss", "<plug>(SubversiveSubstituteWordRange)",   remap = true, mode = "n" },
      { "s",   "<plug>(SubversiveSubstitute)",            remap = true, mode = "x" },
      { "p",   "<plug>(SubversiveSubstitute)",            remap = true, mode = "x" },
      { "P",   "<plug>(SubversiveSubstitute)",            remap = true, mode = "x" },
    },
  },

  -- vim-textobj-user is gone (none of the legacy textobj-* plugins kept)
  -- operator-surround keymaps from M.surround used <Plug>(operator-surround-*)
  -- but the actual plugin "osyo-manga/vim-operator-surround" was never installed.
  -- Those keymaps were dead in the old config; do not migrate them.
}
