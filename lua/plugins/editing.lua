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
      { "p",     "yoink#canSwap() ? '<plug>(YoinkPostPasteSwapBack)' : '<plug>(YoinkPaste_p)'",    expr = true, remap = true, mode = "n" },
      { "P",     "yoink#canSwap() ? '<plug>(YoinkPostPasteSwapForward)' : '<plug>(YoinkPaste_P)'", expr = true, remap = true, mode = "n" },
      { "<c-p>", "<plug>(YoinkPostPasteSwapForward)",          remap = true, mode = "n" },
      { "y",     "<plug>(YoinkYankPreserveCursorPosition)",    remap = true, mode = { "n", "x" } },
    },
  },

  -- Subversive — substitute with register
  {
    "svermeulen/vim-subversive",
    event = "VeryLazy",
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
