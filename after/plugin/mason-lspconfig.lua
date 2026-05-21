-- ABOUTME: Configures Mason to automatically setup LSP servers
-- ABOUTME: Bridges Mason package manager with nvim-lspconfig

-- Use lspconfig.configs directly to avoid triggering
-- the deprecated require('lspconfig') __index warning on Neovim 0.11.
local lspconfigs = require("lspconfig.configs")
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
    ensure_installed = {
        "lua_ls",           -- Lua
        "pyright",          -- Python
        "ts_ls",            -- TypeScript/JavaScript
        "bashls",           -- Bash
        "jsonls",           -- JSON
        "yamlls",           -- YAML
        "marksman",         -- Markdown
    },
    automatic_installation = true,
})

-- Setup servers after Mason installs them
-- For lsp-zero v4, we configure servers directly
local servers = mason_lspconfig.get_installed_servers()

-- Helper to load a server config module and call setup safely
local function setup_server(name, opts)
    -- Ensure the server configuration is loaded into lspconfig.configs
    pcall(require, "lspconfig.configs." .. name)
    local cfg = lspconfigs[name]
    if cfg and cfg.setup then
        cfg.setup(opts or {})
    end
end

for _, server in ipairs(servers) do
    local config_name = server == "tsserver" and "ts_ls" or server
    if config_name == "lua_ls" then
        setup_server("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                }
            }
        })
    else
        setup_server(config_name, {})
    end
end

-- Ensure servers are setup when installed via Mason
vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    callback = function()
        for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
            local config_name = server == "tsserver" and "ts_ls" or server
            if config_name == "lua_ls" then
                setup_server("lua_ls", {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" }
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false,
                            },
                        }
                    }
                })
            else
                setup_server(config_name, {})
            end
        end
    end,
})
