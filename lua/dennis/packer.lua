
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()


vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	--
	-- Packer can manage itself
	use {
		'wbthomason/packer.nvim',
		auto_clean = true,
	}

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.4',
		requires = { {'nvim-lua/plenary.nvim'} }
	}


	use {
		'nvim-telescope/telescope-fzf-native.nvim',
		run =  'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release'
	}

	use {
		'greggh/claude-code.nvim',
		requires = {
			'nvim-lua/plenary.nvim', -- Required for git operations
		},
		config = function()
require("claude-code").setup({
  -- Terminal window settings
  window = {
    split_ratio = 0.5,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
    position = "vertical",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
    enter_insert = false,    -- Whether to enter insert mode when opening Claude Code
    hide_numbers = true,    -- Hide line numbers in the terminal window
    hide_signcolumn = true, -- Hide the sign column in the terminal window
    -- Floating window configuration (only applies when position = "float")
    float = {
      width = "100%",        -- Width: number of columns or percentage string
      height = "100%",       -- Height: number of rows or percentage string
      row = "center",       -- Row position: number, "center", or percentage string
      col = "center",       -- Column position: number, "center", or percentage string
      relative = "editor",  -- Relative to: "editor" or "cursor"
      border = "rounded",   -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    },
  },
 -- Command settings
  command = "[ ! -d .venv ] && uv venv; source .venv/bin/activate; claude --dangerously-skip-permissions ",        -- Command used to launch Claude Code
  -- Command variants
  command_variants = {
    -- Conversation management
    continue = "--continue", -- Resume the most recent conversation
    resume = "--resume",     -- Display an interactive conversation picker

    -- Output options
    verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
  },
  -- Keymaps
  keymaps = {
    toggle = {
      normal = "<C-,>",       -- Normal mode keymap for toggling Claude Code, false to disable
      terminal = "<C-,>",     -- Terminal mode keymap for toggling Claude Code, false to disable
      variants = {
        continue = "<leader>co", -- Normal mode keymap for Claude Code with continue flag
        verbose = "<leader>cr",  -- Normal mode keymap for Claude Code with verbose flag
      },
    },
    window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
    scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
  }
})
		end
	}

	use{ 'ms-jpq/lua-async-await' }

	use{'kana/vim-textobj-user'}
	use{'coachshea/vim-textobj-markdown'}
	use{'kana/vim-textobj-entire'}
	use{'glts/vim-textobj-comment'}
	use{ 'michaeljsmith/vim-indent-object'}
	use{'beloglazov/vim-textobj-quotes'}

	use{'Julian/vim-textobj-variable-segment'}


	use {
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		-- event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- Treesitter context
			-- 'romgrk/nvim-treesitter-context',

		},
	}

	use( 'nvim-treesitter/nvim-treesitter-textobjects')

	use{ 'RRethy/nvim-treesitter-textsubjects',
		config=function()
			require('nvim-treesitter-textsubjects').configure({
				prev_selection = ',',
				keymaps = {
					['.'] = 'textsubjects-smart',
					[';'] = 'textsubjects-container-outer',
					['i;'] = 'textsubjects-container-inner',
				},
			})
		end
	}


	-- use{ 'nvim-treesitter/playground'}
	use{ "simnalamburt/vim-mundo" }

	use{
		"NeogitOrg/neogit",
		branch = "nightly",
		config=function()
			require('neogit').setup({
				disable_commit_confirmation = true,
			})
		end
	}

	use {
			'VonHeikemen/lsp-zero.nvim',
			branch='v4.x',
			requires = {
				-- LSP Support
				{'neovim/nvim-lspconfig'},
				{'williamboman/mason.nvim'},
				{'williamboman/mason-lspconfig.nvim'},


			-- Autocompletion
			{'hrsh7th/nvim-cmp'},
			{ "hrsh7th/cmp-path", after = "nvim-cmp" },
			{ "hrsh7th/cmp-buffer", after = "nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
			-- {'saadparwaiz1/cmp_luasnip'},
			{'hrsh7th/cmp-nvim-lsp', after = "nvim-cmp" },
			{'hrsh7th/cmp-nvim-lua', after = "nvim-cmp" },

			{'hrsh7th/cmp-cmdline'},
			-- Snippets
			{'L3MON4D3/LuaSnip'},
			-- {'rafamadriz/friendly-snippets'},
		}
	}

	use {
		"benfowler/telescope-luasnip.nvim",
		module = "telescope._extensions.luasnip",  -- if you wish to lazy-load
	}

	use {
		'L3MON4D3/LuaSnip',
		after = 'nvim-cmp',
		-- config = function() require('config.snippets') end,
	}

	use({
		"arsham/indent-tools.nvim",
		requires = { "arsham/arshlib.nvim" },
		config = function()
			require("indent-tools").config({})
		end,
		keys = { "]i", "[i", { "v", "ii" }, { "o", "ii" } },
	})

		use {
			'feline-nvim/feline.nvim',
			requires = {
				'nvim-tree/nvim-web-devicons',
			},
		}

	-- git stuff
	use{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end
	}

	use {
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	}



	use {
		'smoka7/hop.nvim',
		tag = '*',
		config = function()
			require('hop').setup {  }
		end
	}

	use {
		'stevearc/oil.nvim',
		config = function() require('oil').setup() end
	}

	use{"natecraddock/workspaces.nvim"}
	use({
		"gbprod/cutlass.nvim",
		config = function()
			require("cutlass").setup({
				exclude= { "nd" ,
					"nD",
					"xd",
					"ndd",
				}
			})
		end
	})
	use{"tpope/vim-surround"}
	use{"tpope/vim-repeat"}
	use{"tpope/vim-unimpaired"}
	use{"AndrewRadev/sideways.vim"}
	use{"svermeulen/vim-yoink"}
	use{"svermeulen/vim-subversive"}
	-- use{"tpope/vim-fugitive"}
	use{"max397574/better-escape.nvim"}


	use {
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup {} end
	}



	-- colors
	use {'folke/tokyonight.nvim'}

end)
