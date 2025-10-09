return {
	----| default |----
	{
		"nvim-mini/mini.comment",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},

	----| webdev |----
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		ft = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"tsx",
			"jsx",
		},
		opts = {},
	},
}
