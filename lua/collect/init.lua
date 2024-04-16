local M = {}

-- Another way of adding a method to lua table
-- function M.setup()
-- end
--

M.setup = function (opts)
	-- validate the options table
	opts = opts or {}

	vim.keymap.set("n", "<Leader>h", function()
		if opts.name then
			print("hello, " .. opts.name)
		else
			print("hello")
		end
	end)
end


return M
