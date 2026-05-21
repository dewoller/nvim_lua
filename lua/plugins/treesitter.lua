return {
  -- nvim-treesitter v1 (major rewrite, requires nvim >= 0.12)
  -- Does NOT support lazy-loading per upstream README.
  -- Parsers are installed via :TSInstall / build hook, not on every startup.
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
      -- Install parsers on first install / :Lazy build
      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc", "javascript", "python",
        "r", "markdown", "c", "html",
      }):wait(300000)
    end,
    config = function()
      -- v1: setup() only takes install_dir override; defaults are fine
      require("nvim-treesitter").setup({})

      -- Enable treesitter highlighting + indentation for supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua", "vim", "vimdoc", "javascript", "python",
          "r", "markdown", "c", "html",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- textobjects: new standalone setup API (no longer via configs.setup)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = false,
        },
      })

      local map = vim.keymap.set
      local sel = require("nvim-treesitter-textobjects.select")
      map({ "x", "o" }, "af", function() sel.select_textobject("@function.outer", "textobjects") end, { desc = "outer function" })
      map({ "x", "o" }, "if", function() sel.select_textobject("@function.inner", "textobjects") end, { desc = "inner function" })
      map({ "x", "o" }, "ac", function() sel.select_textobject("@class.outer", "textobjects") end, { desc = "outer class" })
      map({ "x", "o" }, "ic", function() sel.select_textobject("@class.inner", "textobjects") end, { desc = "inner class" })
      map({ "x", "o" }, "ar", function() sel.select_textobject("@parameter.outer", "textobjects") end, { desc = "outer parameter" })
      map({ "x", "o" }, "ir", function() sel.select_textobject("@parameter.inner", "textobjects") end, { desc = "inner parameter" })
    end,
  },

  -- NOTE: RRethy/nvim-treesitter-textsubjects is incompatible with current
  -- nvim-treesitter v1 (requires the removed nvim-treesitter.query module).
  -- Dropped; hop.nvim's ';' provides the primary motion keymap.
}
