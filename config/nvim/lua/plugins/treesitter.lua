return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- latest
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			-- install parsers
			ts.install({
				"bash",
				-- "csharp",
				"css",
				"dockerfile",
				"gitcommit",
				"git_config",
				"gitignore",
				"git_rebase",
				"html",
				"javascript",
				"json",
				-- "jsonc",
				"regex",
				"tsx",
				"typescript",
				"yaml",
				"hyprlang",
				"qmljs",
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true,
			multiwindow = false,
			max_lines = 0, --> 0 => no limit
			min_window_height = 10, --> 0 => no limit
			line_numbers = true,
			multiline_threshold = 20, --> max-num of lines to show for a single context
			trim_scope = "outer", --> alt: 'inner'
			mode = "cursor", --> alt: 'topline'
			separator = nil, -- single char string, like: '-'
			-- separator = "_",
			zindex = 20,
			on_attach = nil, --> (fun(buf: int): boolean) -> return false to disable attach
		},
		config = function(_, opts)
			local ts_ctx = require("treesitter-context")
			ts_ctx.setup(opts)

			vim.keymap.set("n", "[c", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { silent = true, desc = "Go to context" })
		end,
	},
}
