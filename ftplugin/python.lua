-- --
--     -- called MotionSend but works with textobjects as well
    vim.keymap.set("v", "<LocalLeader>ss", "<Plug>SlimeRegionSend", { remap = true, silent = false })
    vim.keymap.set("n", "gz", "<Plug>SlimeMotionSend", { remap = true, silent = false })
--     vim.keymap.set("n", "gzz", "<Plug>SlimeLineSend", { remap = true, silent = false })
    vim.keymap.set("n", "gzc", "<Plug>SlimeConfig", { remap = true, silent = false })


-- Define additional Lua functions as needed
local M = {
	general = {
		n = {
			["<LocalLeader>rf"] = {":vertical new |  terminal .venv/bin/python<cr><c-w>h", "Open REPL"},
			-- ["gz"] = {"<Plug>(SlimeMotionSend)", "Send motion to REPL"},
			["<LocalLeader>l"] = {"<Plug>SlimeLineSend", ""},
			-- ["<LocalLeader>d"] = {"<Plug>SlimeRegionSend", "Send line to REPL"},
			["<LocalLeader>rq"] = { function() vim.cmd("SlimeSend1 " .. "quit()") end,"" },
			["<LocalLeader>pl"] = { function() vim.cmd("SlimeSend1 " .. "locals()") end,"" },
			["<LocalLeader>pg"] = { function() vim.cmd("SlimeSend1 " .. "globals()") end,"" },
			["<LocalLeader>rp"] = {
				function()
					vim.cmd("SlimeSend1 " .. "print(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>rh"] = {
				function()
					vim.cmd("SlimeSend1 " .. "help(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>pt"] = {
				function()
					vim.cmd("SlimeSend1 " .. "type(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>rv"] = {
				function()
					vim.cmd("SlimeSend1 " .. "view_in_datatable(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>pi"] = {
				function()
					vim.cmd("SlimeSend1 " .. "dir(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
				["<LocalLeader>pv"] = {
				function()
					vim.cmd("SlimeSend1 " .. "vars(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>ri"] = {
				function()
					vim.cmd("SlimeSend1 " .. "" .. vim.fn.expand("<cword>") .. ".__dict__") 
				end,""
			},
			["<LocalLeader>pn"] = {
				function()
					vim.cmd("SlimeSend1 " .. "" .. vim.fn.expand("<cword>") .. ".info()") 
				end,""
			},
				["<LocalLeader>rl"] = {
				function()
					vim.cmd("SlimeSend1 " .. "import importlib; importlib.reload(" 
					.. vim.fn.expand("<cword>") 
					.. ")") 
				end,""
			},
				["<LocalLeader>ra"] = {
				function()
					vim.cmd("SlimeSend1 " .. "import inspect; signature = inspect.signature(" 
					.. vim.fn.expand("<cword>") 
					.. "); [print(param.name, param.default, param.annotation, param.kind) for param in signature.parameters.values()]") 
				end,""
			},
				["<LocalLeader>rn"] = {
				function()
					vim.cmd("SlimeSend1 " .. "" .. vim.fn.expand("<cword>") .. ".columns") 
				end,""
			},
			["<LocalLeader>pc"] = {
				function()
					vim.cmd("SlimeSend1 " .. "" .. vim.fn.expand("<cword>") .. ".__class__") 
				end,""
			},
			["<LocalLeader>ps"] = {
				function()
					vim.cmd("SlimeSend1 " .. "import inspect; inspect.getmembers(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>pr"] = {
				function()
					vim.cmd("SlimeSend1 " .. "import pprint; pprint.pprint(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>pj"] = {
				function()
					vim.cmd("SlimeSend1 " .. "import json; json.dumps(" .. vim.fn.expand("<cword>") .. ")") 
				end,""
			},
			["<LocalLeader>ch"]  = { "gzgg","" },
			-- 	-- lines
			["<LocalLeader>l"]  = { "V,ss","" },
			--file
			["<LocalLeader>aa"]  = { "gzae","" },
			--pararaphs
			["<LocalLeader>pp"] = { "gzip","" },
			["<LocalLeader>pd"] = { "gzip))","" },
			["<LocalLeader>rd"] = {"Oimport pdb; pdb.set_trace()<Esc>", ""},
			["<LocalLeader>rq"] = {
				function()
					vim.cmd("SlimeSend1 quit()") 
					vim.api.nvim_command("normal! <c-w><c-l>:bdelete<cr>")
				end,""
			},
		},
		v = {
		}
	}
}


setupKeyBindings = function(bindings)
  for section, section_values in pairs(bindings) do
    for mode, mode_values in pairs(section_values) do
      for keybind, mapping_info in pairs(mode_values) do
        local opts = {}
        opts.desc = mapping_info[2]
        vim.keymap.set(mode, keybind, mapping_info[1], {silent=FALSE})
      end
    end
  end
end

setupKeyBindings(M)



