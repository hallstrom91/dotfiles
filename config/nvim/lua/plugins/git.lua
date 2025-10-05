return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local icons = require(utils.icons_utils)
			local ic_gitsigns = icons.git_signs
			local ic_gitstaged = require
			return {
				signs = ic_gitsigns,
				signs_staged_enable = ic_gitstaged,
				-- signs = icons.git_signs,
				-- signs_staged = icons.git_signs_staged,
				signs_staged_enable = true,
				signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
				numhl = false,
				linehl = false,
				word_diff = false,
				watch_gitdir = {
					follow_files = true,
				},
				auto_attach = true,
				attach_to_untracked = true,
				current_line_blame = true,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
					delay = 1000,
					ignore_whitespace = false,
					virt_text_priority = 100,
					use_focus = true,
				},
				current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil,
				max_file_length = 40000,
				preview_config = {
					border = "single",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
			}
		end,
	},
}
