local M = {}

function M.setup(opts)
	-- Validate table
	opts = opts or {}

	local collect_name = opts.collect_name
	local collectNameParameter = collect_name and collect_name or "collect.lua"

	M.open_collect(collectNameParameter)
end

-- Opens a buffer that is called the collect buffer
function M.open_collect(collect_name)
	vim.keymap.set("n", "<Leader>cn", function()
		vim.cmd(":vsplit " .. collect_name .. ".lua")
	end)
end


return M
