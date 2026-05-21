-- ABOUTME: Configures lsp-zero v4 with Mason integration for LSP support
-- ABOUTME: Sets up autocompletion and keymaps for LSP functionality

local lsp = require('lsp-zero')

-- Configure LSP attach behavior
lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({
		buffer = bufnr,
		omit = {'gs', 'K'},  -- Omit these as they're mapped in lua/dennis/mappings.lua
	})
end)

-- Initialize Mason first (package manager)
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})

-- Mason-lspconfig is configured in mason-lspconfig.lua
-- It will handle server installation and setup

-- Setup lsp-zero after Mason
lsp.setup()


local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

cmp.setup({
	sources = {
		{name = 'nvim_lsp'},
		{name = 'path'},
		{name = 'buffer', keyword_length = 3},
		{name = 'luasnip', keyword_length = 2},
	},
	mapping = cmp.mapping.preset.insert({
		['<C-f>'] = cmp_action.luasnip_jump_forward(),
		['<C-b>'] = cmp_action.luasnip_jump_backward(),
		['<Tab>'] = cmp_action.luasnip_supertab(),
		['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<C-e>'] = cmp.mapping.abort(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-u>'] = cmp.mapping.scroll_docs(4),
	}),
	preselect = 'item',
	completion = {
		completeopt = 'menu,menuone,noinsert'
	},
	experimental = {
		ghost_text = false
	},
})

-- Setup autopairs integration
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- R language completion source (if it exists)
pcall(function()
	table.insert(cmp.get_config().sources, 1, { name = 'cmp_nvim_r' })
end)

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})


-- `:` cmdline setup.
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources(
		{ { name = 'path' } },
		{
			{
				name = 'cmdline',
				option = {
					ignore_cmds = { 'Man', '!' }
				}
			}
		})
})