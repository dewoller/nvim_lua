
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
		}
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
	use{"svermeulen/vim-yoink"}
	use{"svermeulen/vim-subversive"}
	-- use{"tpope/vim-fugitive"}

	-- colors
	use {'folke/tokyonight.nvim'}

end)
