local M = {}

M.close_keys = {
	{
		mode = "n",
		key = "q",
		opts = {},
	},
	{
		mode = "n",
		key = "ZZ",
		prevAction = "<cmd>qa!<cr>",
		opts = {},
	},
	{
		mode = "n",
		key = "<Esc>",
		opts = {},
	},
}

return M
