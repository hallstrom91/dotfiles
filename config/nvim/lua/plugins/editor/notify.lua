return {

	{
		"nvim-mini/mini.notify",
		version = "*",
		opts = function()
			vim.notify = require("mini.notify").make_notify()
			return {}
		end,
	},
}
