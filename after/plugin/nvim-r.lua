
local let=vim.g
local nvc=vim.api.nvim_command
local F=require('functions')

-- Ensure vim.g.scripts is defined before using it
if vim.g.scripts then
  if( vim.g.os_linux ) then
    let.R_app = vim.g.scripts .. "/start_radian.sh"
  else
    let.R_app = vim.g.scripts .. "\\start_radian.bat"
  end
end
let.R_cmd = 'R'
let.R_hl_term = 0
let.R_bracketed_paste = 1 -- for radian
-- let.R_bracketed_paste = 0 -- raw r
let.R_assign = 0
let.R_nvim_wd = -1
let.R_auto_start = 0
let.R_clear_line = 1
let.R_debug=0
let.R_rconsole_width = 57
let.R_min_editor_width = 18
let.R_nvimpager = "vertical"
let.R_source_args = 'echo = TRUE'
-- let.R_commented_lines = 1
let.R_user_maps_only = 1
let.LanguageClient_serverCommands = {
     r={'R', '--slave', '-e', 'languageserver::run()'},
   }
-- let.R_auto_omni={}



-- run shiny app
function RunShinyApp()
	vim.cmd('RStop')
	vim.fn.SendCmdToR_Buffer('Q')
	vim.cmd('RStop')
	local cmd = 'shiny::runApp("' .. vim.fn.getcwd() ..  '")'
	print(cmd)
	vim.fn.SendCmdToR_Buffer(cmd)
end

function RStop()
	vim.cmd('RStop')
end


function QuitDebug()
	vim.fn.SendCmdToR_Buffer('Q')
end


-- render Rmarkdown
function RenderRmarkdown()
	vim.cmd('RStop')
  local cmd = 'browseURL( rmarkdown::render(r"(' .. vim.fn.expand('%:p') ..  ')", output_dir="output/"))'
	vim.fn.SendCmdToR_Buffer(cmd)
end

-- run Rmarkdown
function RunRmarkdown()
	vim.cmd('RStop')
  local cmd = 'browseURL( rmarkdown::run(r"(' .. vim.fn.expand('%:p') ..  ')"))'
	vim.fn.SendCmdToR_Buffer(cmd)
end


-- background make and edit log
function BackgroundMakeAndEditLog()
  RAction("tar_make_single")
  local logfile = 'log/single_target_' .. vim.fn.expand("<cword>") .. '.log'
  print(logfile)
  nvc('edit ' .. logfile)
end


function RInsert( to_run )
	F.delete_file( "/tmp/Rinsert" )
  local cmd = 'sink("/tmp/Rinsert"); dput(' .. to_run .. '); sink();'
	vim.fn.SendCmdToR_Buffer( cmd )
	F.wait_for_file( "/tmp/Rinsert" )
end


function RInsertSelection()
	local to_run = F.GetSelectedText(TRUE)
	print(to_run)
	to_run = string.gsub(to_run, "\n", " ")
	print(to_run)

	vim.api.nvim_input('<esc>o')
	RInsert( to_run )
	vim.cmd('read /tmp/Rinsert')
end

function RInsertWord()
	local to_run = vim.fn.expand("<cword>") 

	vim.api.nvim_input('o')
	RInsert( to_run )
	vim.cmd('read /tmp/Rinsert')
end


---
function pipeline2R( to_append )

	local nvc=vim.api.nvim_command


	-- Set a mark at the beginning of the line

	nvc('normal! mz')
	-- Move to the end of the line
	nvc('normal! $')

	-- Search backwards for the last occurrence of %>% or |>
	vim.api.nvim_command("call search('\\zs.\\ze\\(%>%\\||>\\)', 'b')" )
	nvc('nohlsearch')

	local end_pos = vim.api.nvim_win_get_cursor(0)

	-- Start visual selection
	--
	nvc("normal! {")

	-- Get the current line
	local start_pos = vim.api.nvim_win_get_cursor(0)

	-- Get the text of the start line
	local start_line_text = vim.api.nvim_buf_get_lines(0, start_pos[1] , start_pos[1]+1, false)[1]

	start_pos[1] = start_pos[1] + 1

	-- if line ends with =, move down a line
	if start_line_text:match('.*=%s*$') then
		start_pos[1] = start_pos[1] + 1
		start_pos[2] = 0
	end

	local chunk = F.GetTextChunk( start_pos, end_pos )
	if to_append ~= nil then
		chunk = chunk .. ' %>% ' .. to_append
	end
	vim.fn.SendCmdToR_Buffer( chunk )

	--
	--cleanup
	nvc('normal! `z')

end
