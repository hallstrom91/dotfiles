return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local icons = require("utils.icons")
			local remap = {
				add = "added",
				change = "modified",
				delete = "removed",
				topdelete = "removed",
				changedelete = "modified",
				untracked = "added",
			}

			local signs = icons.remap_icons(icons.git.nf_md, remap, { pr = 1 })

			return {
				signs = {
					add = { text = signs.add },
					change = { text = signs.change },
					delete = { text = signs.delete },
					topdelete = { text = signs.topdelete },
					changedelete = { text = signs.changedelete },
					untracked = { text = signs.untracked },
				},
				attach_to_untracked = false,
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
		-- 	opts = {
		-- 		signs = {
		-- 			add = { text = "┃" },
		-- 			change = { text = "┃" },
		-- 			delete = { text = "_" },
		-- 			topdelete = { text = "‾" },
		-- 			changedelete = { text = "~" },
		-- 			untracked = { text = "┆" },
		-- 		},
		-- 		signs_staged = {
		-- 			add = { text = "┃" },
		-- 			change = { text = "┃" },
		-- 			delete = { text = "_" },
		-- 			topdelete = { text = "‾" },
		-- 			changedelete = { text = "~" },
		-- 			untracked = { text = "┆" },
		-- 		},
		-- 		signs_staged_enable = true,
		-- 		signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
		-- 		numhl = false,
		-- 		linehl = false,
		--
		-- 		word_diff = false,
		-- 		watch_gitdir = {
		-- 			follow_files = true,
		-- 		},
		--
		-- 		auto_attach = true,
		-- 		attach_to_untracked = true,
		-- 		current_line_blame = true,
		-- 		current_line_blame_opts = {
		-- 			virt_text = true,
		-- 			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		-- 			delay = 1000,
		-- 			ignore_whitespace = false,
		-- 			virt_text_priority = 100,
		-- 			use_focus = true,
		-- 		},
		-- 		current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
		-- 		sign_priority = 6,
		-- 		update_debounce = 100,
		-- 		status_formatter = nil,
		-- 		max_file_length = 40000,
		-- 		preview_config = {
		-- 			border = "single",
		-- 			style = "minimal",
		-- 			relative = "cursor",
		-- 			row = 0,
		-- 			col = 1,
		-- 		},
		-- 	},
	},
}
