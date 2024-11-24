local M = {}
local Path = require("plenary.path")
local constants = require("collect.constants")
local data_path = vim.fn.stdpath("data")

-- Get the current directory (project root)
local current_dir = vim.fn.getcwd()

-- Use the project-specific path (current directory)
local cache_config = string.format("%s/%s_collect.json", data_path, vim.fn.fnamemodify(current_dir, ":p:h:t"))

local buf_id = nil
local win_id = nil

-- In-memory storage for content
local content_storage = {}
local memory_key = "collect_data"

--- Configuration options for the module
--- @class CollectOptions
--- @field title string? The title displayed in the window (default: "Collect").
--- @field title_pos string? Position of the title, either "left", "center", or "right" (default: "left").
--- @field height number? Height of the floating window (default: 15).
--- @field width number? Width of the floating window (default: 70).
--- @field toggle_keymap string? Keymap for toggling the window (default: "<leader>cn").

--- Sets up the module with the given options.
--- @param opts CollectOptions
function M.setup(opts)
	opts = opts or {}
	M.toggle(opts)
end

-- Save content to a file
local function save_to_file()
	local json_data = vim.fn.json_encode(content_storage)
	local path = Path:new(cache_config)

	-- Ensure the directory exists before saving
	path:parent():mkdir({ recursive = true })

	-- Write the data to the file
	path:write(json_data, "w")
end

-- Load content from the file (persistent storage)
local function load_from_file()
	local path = Path:new(cache_config)
	if path:exists() then
		local json_data = path:read()
		local decoded = vim.fn.json_decode(json_data)
		if decoded then
			content_storage = decoded
		end
	end
end

local function create_win_config(opts)
	local height = opts.height or 15
	local width = opts.width or 70

	return {
		relative = "editor",
		row = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		focusable = true,
		border = "single",
		title = opts.title or "Collect",
		title_pos = opts.title_pos or "left",
		style = "minimal",
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

local function close_window()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		save_buffer_to_memory(memory_key)
		save_to_file()

		-- Restore all close key mappings before closing the window
		for _, value in ipairs(constants.close_keys) do
			-- Remove our buffer-local mapping
			vim.keymap.del(value.mode, value.key, { buffer = buf_id })
		end

		vim.api.nvim_win_close(win_id, true)
		win_id = nil
		buf_id = nil
	end
end

local function check_for_buf_close()
	for _, value in ipairs(constants.close_keys) do
		-- Set buffer-local mappings
		vim.keymap.set(value.mode, value.key, function()
			close_window()
		end, vim.tbl_extend("force", value.opts or {}, { buffer = buf_id }))
	end
end

local function open_window(opts)
	-- If already open, bring the window into focus
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_set_current_win(win_id)
		return
	end

	-- Create a new buffer and window
	buf_id = vim.api.nvim_create_buf(false, true)
	local config = create_win_config(opts)

	-- Configure buffer options
	vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf_id })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf_id })
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf_id })

	-- Create the floating window
	win_id = vim.api.nvim_open_win(buf_id, true, config)

	-- Enable line numbers for the window
	vim.api.nvim_win_set_option(win_id, "number", true)

	-- Load content from memory
	load_memory_to_buffer(memory_key)

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf_id,
		callback = function()
			save_buffer_to_memory(memory_key)
			save_to_file()
			buf_id = nil
			win_id = nil
		end,
	})

	-- Set up resize autocmd to make the buffer responsive
	setup_resize_autocmd(opts)

	check_for_buf_close()
end

function M.toggle(opts)
	vim.keymap.set("n", opts.toggle_keymap or "<leader>cn", function()
		if win_id and vim.api.nvim_win_is_valid(win_id) then
			close_window()
		else
			open_window(opts)
		end
	end, { desc = "Toggle collect.nvim" })
end

-- On startup, load content from file
load_from_file()

return M
