return {
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		opts = function()
			vim.keymap.set("n", "<leader>w", function()
				local pick_win_id = require("window-picker").pick_window()

				if pick_win_id then
					vim.api.nvim_set_current_win(pick_win_id)
				else
					vim.notify("Action aborted", vim.log.levels.DEBUG)
				end
			end, { desc = "Window picker" })

			return {
				hint = "floating-big-letter",
				selection_chars = "FJDKSLA;CMRUEIWQP",
				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					bo = {
						filetype = { "neo-tree-popup", "notify", "telescope" },
						buftype = { "terminal", "quickfix", "spectre", "bqf", "telescope" },
					},
				},
			}
		end,
	},
}
