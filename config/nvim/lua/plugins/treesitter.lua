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
				"regex", -- for cmdline hl
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
				"yaml",
				-- "regex",
			}):wait(300000) -- 5min -- no-op if already install
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true,
			multiwindow = false,
			max_lines = 10,
			min_window_height = 50,
			line_number = true,
		},
	},

	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},

	"windwp/nvim-ts-autotag",
	ft = { "html", "xml", "javascript", "typescript", "typescriptreact", "javascriptreact" },
	opts = {
		opts = { enable_close = true, enable_rename = false, enable_close_on_slash = true },
	},
}
