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

      lsp.on_attach(function(_, bufnr)
        lsp.default_keymaps({
          buffer = bufnr,
          omit = { "gs", "K" }, -- mapped in lua/config/keymaps.lua / lspzero block
        })
      end)

      require("mason").setup({
        ui = {
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      local mason_lspconfig = require("mason-lspconfig")
      local lspconfigs = require("lspconfig.configs")

      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls", "bashls", "jsonls", "yamlls", "marksman",
        },
        automatic_installation = true,
      })

      lsp.setup()

      local function setup_server(name, opts)
        pcall(require, "lspconfig.configs." .. name)
        local cfg = lspconfigs[name]
        if cfg and cfg.setup then cfg.setup(opts or {}) end
      end

      local function setup_all()
        for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
          local config_name = server == "tsserver" and "ts_ls" or server
          if config_name == "lua_ls" then
            setup_server("lua_ls", {
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
          else
            setup_server(config_name, {})
          end
        end
      end

      setup_all()

      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = setup_all,
      })

      -- LSP keymaps that the old config kept in M.lspzero
      local fmt = function(cmd) return function(str) return cmd:format(str) end end
      local lspf = fmt("<cmd>lua vim.lsp.%s<cr>")
      local diag = fmt("<cmd>lua vim.diagnostic.%s<cr>")
      local map = vim.keymap.set
      map("n", "<leader>r", lspf("buf.rename()<cr>"))
      map("n", "K",   lspf("buf.hover()"))
      map("n", "gi",  lspf("buf.implementation()"))
      map("n", "gt",  lspf("buf.type_definition()"))
      map("n", "gr",  lspf("buf.references()"))
      map("n", "gl",  diag("open_float()"))
      map("n", "[d",  diag("goto_prev()"))
      map("n", "]d",  diag("goto_next()"))
    end,
  },
}
