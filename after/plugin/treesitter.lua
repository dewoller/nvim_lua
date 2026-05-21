local present, treesitter = pcall(require, "nvim-treesitter.configs")

if not present then
  return
end


local options = {
	sync_install = true,
	auto_install = true,
	highlight = {
		enable = true,
		use_languagetree = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true
	},
	filetype_to_parsername = {
		jinja = "jinja",
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = '<CR>',
			scope_incremental = '<CR>',
			node_incremental = '<TAB>',
			node_decremental = '<S-TAB>',
		},
	},
	ensure_installed = { "lua",
		"vim",
		"vimdoc",
		"javascript",
		"python" ,
		"r",
		"markdown",
		"c",
		"jinja",
		"html"},
	debug = true, -- Enable debug mode
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["ar"] = "@parameter.outer",
				["ir"] = "@parameter.inner",
			},
		},
	},
}

local parsers_ok, parsers = pcall(require, "nvim-treesitter.parsers")
if parsers_ok then
	local configs = parsers.get_parser_configs()
	if not configs.jinja then
		options.ensure_installed = vim.tbl_filter(function(lang)
			return lang ~= "jinja"
		end, options.ensure_installed)
		options.ignore_install = options.ignore_install or {}
		table.insert(options.ignore_install, "jinja")
		options.filetype_to_parsername.jinja = nil
	end
end


treesitter.setup(options)


