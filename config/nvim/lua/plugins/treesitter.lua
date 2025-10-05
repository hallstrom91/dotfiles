return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- latest
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			ts.install({
				"html",
				"css",
				"javascript",
				"typescript",
				"tsx",
				"bash",
				"json",
				"jsonc",
				"csharp",
				"gitcommit",
				"git_rebase",
				"git_config",
				"gitignore",
				-- "regex",
			}):wait(300000) -- 5min -- no-op if already install
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true,
			multiwindow = true,
			max_lines = 10,
			min_window_height = 50,
			line_number = true,
		},
	},
}
