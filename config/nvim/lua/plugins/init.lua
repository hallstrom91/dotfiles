return {
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons" },
	{ "b0o/schemastore.nvim", ft = { "json", "jsonc", "yaml" } },
	{ "folke/which-key.nvim", event = "VeryLazy", opts = { show_help = true, show_keys = true } },
	{ "rcarriga/nvim-notify", lazy = true, opts = { background_colour = "#44444E", timeout = 3000 } },

	require("plugins.neotree"),
	require("plugins.treesitter"),
	require("plugins.rendermd"),
	require("plugins.telescope"),
}
