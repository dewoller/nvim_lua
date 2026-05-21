local M = {}


--------------------------------------------------------------------------------



M.hop = {
	n={
		[";"] = {":HopChar2MW<cr>",""},
	},
	v={
		[";"] = {":HopChar2MW<cr>",""},
	}
}

M.workspaces = {
	n={
		["<Leader>tw"] = {":Telescope workspaces<cr>" },
		["<Leader>wa"] = { function() require('workspaces').add() end
		},
	}
}




M.surround = {
	n={
		["sa"] = {"<Plug>(operator-surround-append)",""},
		["sd"] = {"<Plug>(operator-surround-delete)",""},
		["sr"] = {"<Plug>(operator-surround-replace)",""},
	}
}

M.sideways = {
	n={
		["[p"] = {":SidewaysRight<cr>"},
		["]p"] = {":SidewaysLeft<cr>"},
	},
	o={
		["aa"] = {'<Plug>SidewaysArgumentTextobjA'},
		["ia"] = {'<Plug>SidewaysArgumentTextobjI'},
	},
	x={
		["aa"] = {'<Plug>SidewaysArgumentTextobjA'},
		["ia"] = {'<Plug>SidewaysArgumentTextobjI'},
	},
}

M.buffer = {
	n={
		["c-l"] = {":bn<cr>"},
		["c-h"] = {":bp<cr>"},
	},
	o={
		["c-l"] = {":bn<cr>"},
		["c-h"] = {":bp<cr>"},
	},
	x={
		["c-l"] = {":bn<cr>"},
		["c-h"] = {":bp<cr>"},
	},
}


-- M.cutlass={
--   n={
--     ["gd"] = {"d",""},
--     ["gD"] = {"D",""},
--     ["gdd"] = {"dd",""},
--   },
--   x={
--     ["gd"] = {"d",""},
--     ["gD"] = {"D",""},
--   }
-- }


M.next_buffer={
	n={
		['<bslash>'] =  {":Telescope buffers<cr>",""},
	} ,
	v={
		['<bslash>'] =  {":Telescope buffers<cr>",""},
	}
}


M.substitute={
	n={
		["s"] = {"<plug>(SubversiveSubstitute)",""},
		["ss"] = {"<plug>(SubversiveSubstituteLine)",""},
		["S"] = {"<plug>(SubversiveSubstituteToEndOfLine)",""},
		['gs'] = {"<plug>(SubversiveSubstituteRange)",""},
		['gss'] = {"<plug>(SubversiveSubstituteWordRange)",""},
	},
	x={
		['gs'] = {"<plug>(SubversiveSubstituteRange)",""},
		["s"] = {"<plug>(SubversiveSubstitute)",""},
		["p"] = {"<plug>(SubversiveSubstitute)",""},
		["P"] = {"<plug>(SubversiveSubstitute)",""},
	},
}

--

M.yoink={
	n={
		['<c-p>'] = {"<plug>(YoinkPostPasteSwapForward)",""},
		["y"] = {"<plug>(YoinkYankPreserveCursorPosition)",""},
	},
	x={
		["y"] = {"<plug>(YoinkYankPreserveCursorPosition)",""},
	}
}



M.telescope={
	n={
		["<leader>ff"] = {"<cmd>Telescope find_files<cr>","find_files"},
		["<leader>fr"] = {"<cmd>Telescope live_grep<cr>","live_grep"},
		["<leader>b"] = {"<cmd>Telescope buffers<cr>","buffers"},
		["<leader>fh"] = {"<cmd>Telescope help_tags<cr>","help_tags"},
		["<Leader>fo"] = {"<cmd>Telescope oldfiles<CR>","oldfiles"},
		-- ["<leader>fF1"] = {":execute 'Telescope git_files default_text=' .  expand('<cword>')<cr>","git_files"},
		-- ["<leader>jg1"] = {":execute 'Telescope live_grep default_text=' . expand('<cword>')<cr>","live_grep"},
		["<leader>fF"] = { function() vim.api.nvim_command( "Telescope git_files default_text=" .. vim.fn.expand("<cword>") ) end },
		["<leader>gf"] = { function() vim.api.nvim_command( "edit " .. vim.fn.expand("<cword>") ) end },
		["<leader>fw"] = { function() vim.api.nvim_command( "Telescope live_grep default_text=" .. vim.fn.expand("<cword>") .. "") end },
		["<leader>jR"] = {"<cmd>Telescope lsp_references<cr>","lsp_references"},
		["<leader>jD"] = {"<cmd>Telescope lsp_definitions<cr>","lsp_definitions"},
		["<leader>ji"] = {"<cmd>Telescope lsp_incoming_calls<cr>","lsp_incoming_calls"},
		["<leader>jo"] = {"<cmd>Telescope lsp_outgoing_calls<cr>","lsp_outgoing_calls"},
		["<leader>gt"] = {"<cmd>Telescope git_commits<cr>","git_commits"},
		["<leader>gs"] = {"<cmd>Telescope git_status<cr>","git_status"},
		["<leader>tc"] = {"<cmd>Telescope colorscheme<cr>","colorscheme"},
		["<leader>tq"] = {"<cmd>Telescope quickfix<cr>","quickfix"},
		["<leader>th"] = {"<cmd>Telescope quickfixhistory<cr>","quickfixhistory"},
		["<leader>tl"] = {"<cmd>Telescope loclist<cr>","loclist"},
		["<leader>ts"] = {"<cmd>Telescope search_history<cr>","search_history"},
		["<c-p>"] = {"<cmd>Telescope luasnip<cr>","luasnip"},
		["<leader>tr"] = {"<cmd>Telescope resume<cr>","telescope resume"},
		["<leader>to"] = {"<cmd>Telescope vim_options<cr>","vim_options"},
		["<leader>tm"] = {"<cmd>Telescope marks<cr>","marks"},
		["<leader>tk"] = {"<cmd>Telescope keymaps<cr>","keymaps"},
		["<leader>ta"] = {"<cmd>Telescope autocommands<cr>","autocommands"},
	},
	i={
		["<c-p>"] = {
			function()
				print( vim.fn.expand("<cword>"))
				require('functions').send_keystrokes( vim.fn.expand("<cword>"))
				vim.api.nvim_command( "Telescope luasnip<cr>")
			end
		},
	},
	v={
		["<c-p>"] = {"<cmd>Telescope luasnip<cr>","luasnip"},
	},
}




local fmt = function(cmd) return function(str) return cmd:format(str) end end
local lsp = fmt('<cmd>lua vim.lsp.%s<cr>')
local diagnostic = fmt('<cmd>lua vim.diagnostic.%s<cr>')

M.lspzero ={
	n={
		["<leader>r"]={lsp "buf.rename()<cr>",""},
		[ "K"]={ lsp 'buf.hover()',""},
		[ "gi"]={ lsp 'buf.implementation()',""},
		[ "gt"]={ lsp 'buf.type_definition()',""},
		[ "gr"]={ lsp 'buf.references()',""},
		[ "gl"]={ diagnostic 'open_float()'},
		[ "[d"]={ diagnostic 'goto_prev()'},
		[ "]d"]={ diagnostic 'goto_next()'},
	},
}

M.general_programming = {
	n={
		["<LocalLeader>rc" ] = {':s/,/,\\r/g<cr>:noh<cr>=ip', ''},
		["<LocalLeader>r," ] = {':s/,/,\\r/g<cr>:noh<cr>=ip', ''},
		["<LocalLeader>rg"] = {":Neogit<cr>"},
		["<Leader>cd"] = {':cd %:h<CR>'},
	}
}


M.general = {
	i={
		--  command line alias
		["<C-C>"] = {"<ESC>",""},
		["<C-d>"] = {"<Esc>:bp<bar>sp<bar>bn<bar>bd<CR>",""},
		["<C-S>"] = {"<c-o>:update<CR><Esc>",""},
		["<C-q>"] = {"<ESC>:q<cr>",""},
		-- ["<C-l>"] = { 'copilot#Accept("<CR>")', 'Accept Copilot suggestion' },
		-- ["<C-]>"] = {function() require("copilot.suggestion").next() end,""},
		-- ["<C-[>"] = {function() require("copilot.suggestion").prev() end,""},
	},
	--n
	n={
		["+"] = {'30<C-W>>","'},
		["-"] = {'30<C-W><","'},
		["<leader>y"] = {":let @+ = expand('%')<CR>"},
		["<CR>"] = {"<cmd>noh<cr><cr>",""},
		["<c-q>"] = {":q<cr>",""},
		["<leader>n"] = {":call RenameFile()<cr>",""},
		["<F1>"] = {"qq",""},
		["<F2>"] = {"q",""},
		["<F3>"] = {"@q",""},
		["E"] = {":ed<cr>G",""},
		["[b"] = {":bn<CR>",""},
		["]b"] = {":bp<CR>",""},
		[",ru"] = {":vs#<cr><c-w>x<c-w>h",""},
		["<C-d>"] = {":bp<bar>sp<bar>bn<bar>bd<CR>",""},
		["<C-h>"] = {"<C-w>h",""},
		["<C-j>"] = {"<C-w>j",""},
		["<C-k>"] = {"<C-w>k",""},
		["<C-l>"] = {"<C-w>l",""},
		["<C-u>"] = {"<C-^>",""},
		["<F7>"] = {":cprevious<cr>",""},
		["<F8>"] = {":cnext<cr>",""},
		["<kMinus>"] = {"<C-x>",""},
		["<kPlus>"] = {"<C-a>",""},
		["<leader>m"] = {":MundoToggle<CR>",""},
		["Y"] = {"y$",""},
		["j"] = {"gj",""},
		["k"] = {"gk",""},
		["<C-S>"] = {":update<CR>",""},
		["q:"] = {"<Nop>",""},
	},
	v={
		--v
		["<leader>y"] = {":let @+ = expand('%')<CR>"},
		["<C-d>"] = {"<Esc>:bp<bar>sp<bar>bn<bar>bd<CR>",""},
		["<C-h>"] = {"<C-w>h",""},
		["<C-j>"] = {"<C-w>j",""},
		["<C-k>"] = {"<C-w>k",""},
		["<C-l>"] = {"<C-w>l",""},
		["<C-u>"] = {"<C-^>",""},
		["<C-s>"] = {"<c-c>:update<CR>gv",""},
		["j"] = {"gj",""},
		["k"] = {"gk",""},
		["+"] = {'30<C-W>>","'},
		["-"] = {'30<C-W><","'},
	}
}


if( (package.config:sub(1,1)=="/") ) then
	M.os = {
		n={
			["<leader>e"] = {":! cd \"%:p:h:8\"; open .&>/dev/null<cr>","explorer"},
		}
	}
end

vim.cmd[[
"switch window
tnoremap <C-h> <C-\><C-N><C-w>h
tnoremap <C-l> <C-\><C-N><C-w>l
tnoremap <C-j> <C-\><C-N><C-w>j
tnoremap <C-k> <C-\><C-N><C-w>k
]]










setupKeyBindings = function(bindings)
	for section, section_values in pairs( bindings ) do
		--- throw away section
		for mode, mode_values in pairs( section_values ) do
			for  keybind, mapping_info in pairs( mode_values ) do
				--		print( mode, keybind, mapping_info )
				local opts =  {}
				mapping_info.opts, opts.mode = nil, nil
				opts.desc = mapping_info[2]
				vim.keymap.set(mode, keybind, mapping_info[1], opts)
			end
		end
	end
end

setupKeyBindings(M)

