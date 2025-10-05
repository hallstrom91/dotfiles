return {
	{
		"nvim-telescope/telescope.nvim",
		-- tag = "0.1.8",
		keys = {
			{ "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Telescope: Commands" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Telescope: Keymaps" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope: Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope: Live grep" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Telescope: Old files" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope: Buffers" },
			{ "<leader>hh", "<cmd>Telescope man_pages<cr>", desc = "Telescope: Man pages" },
			{ "<leader>fw", "<cmd>Telescope grep_string<cr>", "Telescope: desc = Grep string (word)" },
			{ "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Telescope: Quickfix" },
			{ "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Telescope: Git branches" },
			{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Telescope: Git commits" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Telescope: Git status" },
		},
		-- dependencies = {
		-- 	"nvim-lua/plenary.nvim",
		-- },
		opts = function()
			--	require("telescope").load_extension("fzf")
			--	require("telescope").load_extension("noice")
			return {
				defaults = {
					-- prompt_prefix = ""
					-- selection_caret = ""
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
