local M = {}


local api = vim.api

--*****************************************************************************
-- Send keystrokes to the editor

function M.send_keystrokes(keys)
  api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, true, true), 'n', false)
end
--
--*****************************************************************************
-- Capture the last N messages from the message buffer


function M.put_error_messages_in_buffer()
    -- Create a new buffer
    vim.cmd('new')
    -- Set the buffer name to "Error Messages"
    vim.api.nvim_buf_set_name(0, "Error Messages")
    -- Get the error messages using the :messages command
    local error_messages = vim.api.nvim_exec("messages", true)
    -- Put the error messages in the buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(error_messages, "\n"))
end

--*****************************************************************************
-- Get the text of the current visual selection

function M.get_visual_selection()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
	lines[1] = string.sub(lines[1], s_start[3], -1)
	if n_lines == 1 then
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
	else
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
	end
	return table.concat(lines, '\n')
end



function M.send_motion_chunk()
    vim.call('cmdline#SendSelection')
end

--*****************************************************************************
-- Delete a file

function M.delete_file( filename )
	-- check if the file exists
	local f = io.open(filename, "r")
	if f then
		f:close()
		-- delete the file
		os.remove(filename)
	end
end


--*****************************************************************************
-- Wait for a file to exist

function M.wait_for_file( filename )

	local n=0
	while true do
		local file = io.open(filename, "r")
		if file ~= nil then
			io.close(file)
			break
		end
		-- if file not found, wait for 1 second before checking again
		os.execute("sleep 1")
		n=n+1
		if n > 10 then
			break
		end
	end
end



--*****************************************************************************
-- Print the coordinates of the current visual selection
function   M.PrintSelectionCoordinates() -- Get the line numbers of the start and end of the selection
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")

	-- Get the column numbers of the start and end of the selection
	local start_col = vim.fn.col("'<")
	local end_col = vim.fn.col("'>")

--*****************************************************************************
-- Get the text of the current visual selection


	print(start_line, start_col, end_line, end_col )
end


function M.GetSelectedText(strip_comments)
	-- If strip_comments is not provided, default to false
	strip_comments = strip_comments or false

	-- Get the line numbers of the start and end of the selection
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")

	-- Get the column numbers of the start and end of the selection
	local start_col = vim.fn.col("'<")
	local end_col = vim.fn.col("'>")

	-- Get the lines of text in the selection
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- If the selection is on a single line, get the part of the line that is selected
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col - 1)
	else
		-- If the selection spans multiple lines, get the selected part of the first and last line
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col - 1)
	end

	if strip_comments then
		for i, line in ipairs(lines) do
			-- If there's a comment in the line, remove it
			lines[i] = string.gsub(line, "#.*$", "")
		end
	end

	-- Join the lines into a single string
	local text = table.concat(lines, "\n")

--*****************************************************************************
-- Get the text of the current visual selection

	-- Print the selected text
	return(text)
end




function M.GetTextChunk( start_pos, end_pos)
	-- Get the line numbers of the start and end of the selection
	local start_line = start_pos[1]
	local end_line = end_pos[1]

	-- Get the column numbers of the start and end of the selection
	local start_col = start_pos[2] + 1
	local end_col = end_pos[2] + 1

	--
	-- Get the lines of text in the selection
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- If the selection is on a single line, get the part of the line that is selected
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col )
	else
		-- If the selection spans multiple lines, get the selected part of the first and last line
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col )
	end

	-- Join the lines into a single string
	local text = table.concat(lines, "\n")

	-- Print the selected text
	return(text)
end


function M.sleep(n)
    local timer = vim.loop.new_timer()
    local co = coroutine.running()
    timer:start(n * 1000, 0, vim.schedule_wrap(function()
        timer:stop()
        timer:close()
        coroutine.resume(co)
    end))
    coroutine.yield()
end


return M
