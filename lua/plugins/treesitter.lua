-- Parsers to install, and the filetypes that should use them.
local ts_parsers = {
  "lua", "vim", "vimdoc", "javascript", "typescript", "tsx", "python",
  "r", "markdown", "c", "html", "css", "json", "yaml", "bash",
}
local ts_filetypes = {
  "lua", "vim", "vimdoc", "javascript", "javascriptreact", "typescript",
  "typescriptreact", "python", "r", "markdown", "c", "html", "css", "json",
  "yaml", "sh", "bash",
}

return {
  -- nvim-treesitter v1 (major rewrite, requires nvim >= 0.12)
  -- Does NOT support lazy-loading per upstream README.
  -- Parsers are installed via :TSInstall / build hook, not on every startup.
  -- v1 lives on the `main` branch; `master` is the archived pre-v1 API.
  -- v1 parser builds need the tree-sitter CLI (brew install tree-sitter-cli).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      -- Install parsers on first install / :Lazy build
      require("nvim-treesitter").install(ts_parsers):wait(300000)
    end,
    config = function()
      -- v1: setup() only takes install_dir override; defaults are fine
      require("nvim-treesitter").setup({})

      -- Enable treesitter highlighting + indentation for supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ts_filetypes,
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- textobjects: new standalone setup API (no longer via configs.setup)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- The version installed against nvim-treesitter v1 ships either a
      -- top-level setup() OR a per-submodule API depending on the upstream
      -- branch. Probe both, wire keymaps only if select API exists.
      pcall(function()
        require("nvim-treesitter-textobjects").setup({
          select = {
            lookahead = true,
            include_surrounding_whitespace = false,
          },
        })
      end)

      local sel_ok, sel = pcall(require, "nvim-treesitter-textobjects.select")
      if sel_ok and sel.select_textobject then
        local map = vim.keymap.set
        map({ "x", "o" }, "af", function() sel.select_textobject("@function.outer", "textobjects") end, { desc = "outer function" })
        map({ "x", "o" }, "if", function() sel.select_textobject("@function.inner", "textobjects") end, { desc = "inner function" })
        -- ac/ic intentionally left for vim-textobj-comment (legacy textobj)
        map({ "x", "o" }, "ar", function() sel.select_textobject("@parameter.outer", "textobjects") end, { desc = "outer parameter" })
        map({ "x", "o" }, "ir", function() sel.select_textobject("@parameter.inner", "textobjects") end, { desc = "inner parameter" })
      end
    end,
  },

  -- NOTE: RRethy/nvim-treesitter-textsubjects is incompatible with current
  -- nvim-treesitter v1 (requires the removed nvim-treesitter.query module).
  -- Dropped; hop.nvim's ';' provides the primary motion keymap.
}
