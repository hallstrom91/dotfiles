return {
	{
		"Mofiqul/vscode.nvim",
		enable = true,
		opts = {
			style = "dark",
			transparent = false,
			italic_comments = true,
			italic_inlayhints = true,
			disable_nvimtree_bg = true,
		},
	},
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		enable = false,
		priority = 1000,
		opts = {
			telescope = { style = "classic" },
		},
		config = function()
			require("nordic").load()
		end,
	},
}
