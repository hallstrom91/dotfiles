return {
	{
		"nvim-telescope/telescope.nvim",
		version = false,
		-- tag = "0.2.0",
		keys = {
			--- Telescope Search pickers
			{ "<leader>sh", require("telescope.builtin").help_tags, desc = "Telescope: Search Help" },
			{ "<leader>sk", require("telescope.builtin").keymaps, desc = "Telescope: Search Keymaps" },
			{ "<leader>ss", require("telescope.builtin").builtin, desc = "Telescope: Search Telescope " },
			{ "<leader>sd", require("telescope.builtin").diagnostics, desc = "Telescope: Search Diagnostics" },
			{ "<leader>sr", require("telescope.builtin").resume, desc = "Telescope: Search Resume" },

			--- Telescope Find
			{ "<leader>ff", require("telescope.builtin").find_files, desc = "Telescope: Find files" },
			{ "<leader>fg", require("telescope.builtin").live_grep, desc = "Telescope: Live grep" },
			{ "<leader>fr", require("telescope.builtin").oldfiles, desc = "Telescope: Old files" },
			{ "<leader>fb", require("telescope.builtin").buffers, desc = "Telescope: Buffers" },

			--- Telescope git pickers
			{ "<leader>gs", require("telescope.builtin").git_status, desc = "Telescope: Git status" },
			{ "<leader>gb", require("telescope.builtin").git_branches, desc = "Telescope: Git branches" },
		},
		opts = function()
			require("telescope").load_extension("fzf")
			-- require("telescope").load_extension("noice")
			local icons = require("utils.icons")
			local ic_search = icons.get_icon("general", "search", { pr = 1 })
			local ic_caret = icons.get_icon("general", "caret_right", { pr = 1 })

			return {
				defaults = {
					prompt_prefix = ic_search,
					selection_caret = ic_caret,

					path_display = { "truncate" },
					file_ignore_patterns = { "node_modules", ".git/" },
					-- mappings = {
					-- 	i = {}
					-- 	n = {}
					-- }
				},
				pickers = {
					find_files = {
						theme = "dropdown",
					},
					live_grep = {
						theme = "dropdown",
					},
					oldfiles = {
						only_cwd = true,
					},
					help_tags = {
						theme = "dropdown",
					},
				},
				extension = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			}
		end,
	},

	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}
