
local M = {}

local function start_local_R()
	-- cd directory
	-- StartR
	-- source .Rprofile if exists
	-- source _targets.R if exists
	--
	local directory=  vim.fn.getcwd()
	vim.schedule(function() vim.call('StartR', 'R') end)
	-- busywait until R is started
	local i=0
	while ((vim.g.SendCmdToR==nil or vim.g.SendCmdToR ~= "function('SendCmdToR_fake')") and (i<10000)) do
		print( vim.g.SendCmdToR)
		i=i+1
	end

	vim.schedule( function() vim.call("SendCmdToR",'setwd("' .. directory .. "\")" ) end)
	vim.schedule( function() vim.call("SendCmdToR",'source(".Rprofile")') end)
	vim.schedule( function() vim.call("SendCmdToR",'source("_targets.R")') end)

	return('')
end



M.nvim_r={
	n={
		[ "KT" ] = { function() pipeline2R('str()') end } ,
		[ "KP" ] = { function() pipeline2R('paint::paint()') end } ,
		[ "KV" ] = { function() pipeline2R('datapasta::vector_paste()') end } ,
		[ "KR" ] = { function() pipeline2R('datapasta::tribble_paste()') end } ,
		[ "KS" ] = { function() pipeline2R('datapasta::dpasta()') end } ,
		[ "Q" ] = { function() pipeline2R( ) end } ,
		[ "Z" ] = {function() pipeline2R('DT::datatable()') end} ,
		[ "V" ] = {function() pipeline2R('View() ') end} ,
		[ "L" ] = {function() pipeline2R('listviewer::jsonedit() ') end} ,
		[ "X" ] = {function() pipeline2R('clipr::write_clip()') end} , 
		["<LocalLeader>r7" ] = {':bu _targets.R<cr>', ''},
		["<LocalLeader>qq"] = {':s/^\\W*/"/<cr>:s/\\W*$/"/<cr>:s/\\W\\W*/", "/g<cr>:noh<cr>', ''},
		["<LocalLeader>r;"] = {":call BackgroundMakeAndEditLog()<CR>"},
		["<LocalLeader>r1"] = {":call SetWD_R()<CR>"},
		["<LocalLeader>rs"] = {function() RStop() end},
		["<LocalLeader>rr"] = {function() QuitDebug() end},
		["<LocalLeader>rk"] = {function() RenderRmarkdown() end},
		["<LocalLeader>ry"] = {function() RunRmarkdown() end},
		["<LocalLeader>sh"] = {function() RunShinyApp() end},
		["<LocalLeader>li"] = {function() RInsertWord() end},
		["<LocalLeader>rl"] = {":call RAction('listviewer::jsonedit')<CR>"} ,
		["<LocalLeader>ri"] = {":call RAction('targets::tar_load')<CR>"},
		["<LocalLeader>rc"] = {":call RAction('class')<CR>"},
		["<LocalLeader>rd"] = {":call RAction('debug')<CR>"},
		["<LocalLeader>lg"] = {":call RAction('dplyr::glimpse')<CR>"},
		["<LocalLeader>lp"] = {":call RAction('paint::paint')<CR>"},
		["<LocalLeader>ld"] = {":call RAction('datapasta::df_paste')<CR>"},
		["<LocalLeader>ls"] = {":call RAction('summary')<CR>"},
		["<LocalLeader>lt"] = {":call RAction('str')<CR>"},
		["<LocalLeader>lk"] = {":call RAction('skimr::skim')<CR>"},
		["<LocalLeader>le"] = {":call RAction('terse::terse')<CR>"},
		["<LocalLeader>lv"] = {":call RAction('DT::datatable')<CR>"},
		["<LocalLeader>rm"] = {":call g:SendCmdToR( 'targets::tar_make()')<CR>"},
		["<LocalLeader>tb"] = {":call g:SendCmdToR( 'traceback()')<CR>"},
		["<LocalLeader>td"] = {":call g:SendCmdToR( 'stackdump()')<CR>"},
		["<LocalLeader>eb"] = {":call g:SendCmdToR( 'options(error=browseOnce())')<CR>"},
		["<LocalLeader>er"] = {":call g:SendCmdToR( 'options(error=recover())')<CR>"},
		["<LocalLeader>en"] = {":call g:SendCmdToR( 'options(error=NULL)')<CR>"},
		["<LocalLeader>aa"] = {":call SendFileToR('silent')<CR>"},
		["<LocalLeader>d"] = {":call SendLineToR('down')<CR>"},
		["<LocalLeader>l"] = {":call SendLineToR('stay')<CR>"},
		["<LocalLeader>m"] = {":set opfunc=SendMotionToR<CR>g@"},
		["<LocalLeader>ff"] = {":call SendFunctionToR('silent', 'stay')<CR>"},
		["<LocalLeader>kh"] = {":call RMakeRmd('html_document')<CR>"},
		["<LocalLeader>kl"] = {":call RMakeRmd('beamer_presentation')<CR>"},
		["<LocalLeader>ko"] = {":call RMakeRmd('odt_document')<CR>"},
		["<LocalLeader>kp"] = {":call RMakeRmd('pdf_document')<CR>"},
		["<LocalLeader>kr"] = {":call RMakeRmd('default')<CR>"},
		["<LocalLeader>kw"] = {":call RMakeRmd('word_document')<CR>"},
		["<LocalLeader>o"] = {":call SendLineToRAndInsertOutput()<CR>0"},
		["<LocalLeader>ra"] = {":call RAction('args')<CR>"},
		["<LocalLeader>re"] = {":call RAction('example')<CR>"},
		["<LocalLeader>rf"] = {":call StartR(\"R\")<CR>"},
		["<LocalLeader>rn"] = {":call RAction('nvim.names')<CR>"},
		["<LocalLeader>rp"] = {":call RAction('print')<CR>"},
		["<LocalLeader>rq"] = {":call RQuit('nosave')<CR>"},
		["<LocalLeader>rt"] = {":call RAction(\"str\")<CR>"},
		["<LocalLeader>vv"] = {":call RAction('viewobj')<CR>"},
		["<LocalLeader>pp"] = {":call SendParagraphToR('silent', 'stay')<CR>"},
		["<LocalLeader>pd"] = {":call SendParagraphToR('silent', 'down')<CR>"},
		["<LocalLeader>ch"] = {":call SendFHChunkToR()<CR>"},
		["<leader>jd"] = { function() vim.api.nvim_command( "edit R/" .. vim.fn.expand("<cword>") .. ".R") end },
		["<leader>jt"] = { function() vim.api.nvim_command( "edit tests/testthat/test-" .. vim.fn.expand("<cword>") .. ".R") end },
		["<LocalLeader>rh"] = { function() vim.fn.SendCmdToR_Buffer('help(' .. vim.fn.expand("<cword>") .. ")") end },
	},
	v={
		["<LocalLeader>li"] = {function() RInsertSelection() end},
		["<LocalLeader>ss"] = {"<Esc>:call SendSelectionToR(\"silent\", \"stay\")<CR>"},
		["<LocalLeader>rm"] = { function() vim.api.nvim_command( "g:SendCmdToR( 'targets::tar_make(" .. require('functions').get_visual_selection() .. ")' )") end},
	}
}


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
