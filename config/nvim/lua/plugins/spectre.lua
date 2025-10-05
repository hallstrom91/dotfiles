return {
	"nvim-pack/nvim-spectre",
	keys = {
		{
			"<leader>sw",
			function()
				require("spectre").open_visual({ select_word = true })
			end,
			desc = "Spectre Search Current Word",
			mode = "n",
		},
		{
			"<leader>sw",
			function()
				require("spectre").open_visual()
			end,
			desc = "Spectre Search Current Word (visual)",
			mode = "v",
		},
		{
			"<leader>sp",
			function()
				require("spectre").open_file_search({ select_word = true })
			end,
			desc = "Spectre Search in file",
		},
	},
	opts = {},
}
