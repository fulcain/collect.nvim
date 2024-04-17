local M = {}

-- local collect_group = vim.api.nvim_create_augroup("CollectaGroup", { clear = true })

function M.setup(opts)
	-- Validate table
	opts = opts or {}

	M.open(opts)
end

local create_win_config = function(opts)
	-- local ui = vim.api.nvim_list_uis()[1]
	-- local col = 12

	-- if ui ~= nil then
	-- 	col = math.max(ui.width - 13, 0)
	-- end

	local height = opts.height or 15
	local width = opts.win_id or 60

	return {
		relative = 'editor',
		row = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		focusable = true,
		border = "rounded",
		title = opts.title or "Collect",
		title_pos = opts.title_pos or "left"
	}
end

local create_window = function(opts)
	local buf_id = vim.api.nvim_create_buf(false, true)
	local config = create_win_config(opts)
	local win_id = vim.api.nvim_open_win(buf_id, true, config)

	return buf_id, win_id
end

-- Opens a buffer that is called the collect buffer
---@class Open
---@field title string 
---@field title_pose string 
function M.open(opts)
	vim.keymap.set("n", "<leader>cn", function()
		create_window(opts)
	end)
end


return M
