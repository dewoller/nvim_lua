return {
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v4.x",
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lsp = require("lsp-zero")

      -- Keymaps go on LspAttach, buffer-local. lsp-zero's on_attach() only
      -- fires for servers set up through lspconfig's legacy setup(); with
      -- mason-lspconfig v2 servers start via vim.lsp.enable(), so it never ran.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(event)
          local bufnr = event.buf
          lsp.default_keymaps({
            buffer = bufnr,
            omit = { "gs", "K" }, -- gs is vim-subversive; K is mapped below
          })

          -- LSP keymaps that the old config kept in M.lspzero
          local map = function(lhs, rhs)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr })
          end
          map("<leader>r", vim.lsp.buf.rename)
          map("K",  vim.lsp.buf.hover)
          map("gi", vim.lsp.buf.implementation)
          map("gt", vim.lsp.buf.type_definition)
          map("gr", vim.lsp.buf.references)
          map("gl", vim.diagnostic.open_float)
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end)
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end)
        end,
      })

      require("mason").setup({
        ui = {
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- Per-server settings. mason-lspconfig v2 enables installed servers with
      -- vim.lsp.enable(), which reads these.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls", "bashls", "jsonls", "yamlls", "marksman",
        },
        automatic_enable = {
          -- R workflow was dropped in the May 2026 prune, and the server
          -- segfaults (signal 11) on open.
          exclude = { "r_language_server" },
        },
      })
    end,
  },
}
