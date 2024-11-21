local M = {}

local buf_id = nil
local win_id = nil

-- In-memory storage for content
local content_storage = {}

function M.setup(opts)
	opts = opts or {}
	M.toggle(opts)
end

local function create_win_config(opts)
	local height = opts.height or 25
	local width = opts.width or 80

	return {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		focusable = true,
		border = "rounded",
		title = opts.title or "Collect",
		title_pos = opts.title_pos or "left",
	}
end

local function save_buffer_to_memory(key)
	if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
		return
	end

	-- Get the buffer lines and store them in the content_storage table
	local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
	content_storage[key] = lines
end

local function load_memory_to_buffer(key)
	if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
		return
	end

	-- Retrieve content from memory storage
	local lines = content_storage[key] or {}
	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
end

local function resize_window(opts)
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		local config = create_win_config(opts)
		vim.api.nvim_win_set_config(win_id, config)
	end
end

local function setup_resize_autocmd(opts)
	-- Adjust the window when the terminal is resized
	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			resize_window(opts)
		end,
	})
end

local function open_window(opts, memory_key)
	-- If already open, bring the window into focus
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_set_current_win(win_id)
		return
	end

	buf_id = vim.api.nvim_create_buf(false, true)
	local config = create_win_config(opts)

	-- Configure buffer options
	vim.api.nvim_buf_set_option(buf_id, "buftype", "acwrite") -- Enable custom write behavior
	vim.api.nvim_buf_set_option(buf_id, "bufhidden", "wipe") -- Wipe buffer on close
	vim.api.nvim_buf_set_option(buf_id, "modifiable", true) -- Allow editing

	-- Load content from memory
	load_memory_to_buffer(memory_key)

	-- Create the floating window
	win_id = vim.api.nvim_open_win(buf_id, true, config)

	-- Automatically save content to memory when the window is closed
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf_id,
		callback = function()
			save_buffer_to_memory(memory_key)
			buf_id = nil
			win_id = nil
		end,
	})

	-- Set up resize autocmd to make the buffer responsive
	setup_resize_autocmd(opts)
end

local function close_window(memory_key)
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		save_buffer_to_memory(memory_key)
		vim.api.nvim_win_close(win_id, true)
		win_id = nil
		buf_id = nil
	end
end

function M.toggle(opts)
	local memory_key = "collect_data"

	vim.keymap.set("n", opts.toggleKeymap or "<leader>cn", function()
		if win_id and vim.api.nvim_win_is_valid(win_id) then
			close_window(memory_key)
		else
			open_window(opts, memory_key)
		end
	end)
end

return M
