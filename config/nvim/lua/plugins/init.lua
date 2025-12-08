return {

	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "MunifTanjim/nui.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	{ "b0o/schemastore.nvim", ft = { "json", "jsonc", "yaml" } },
	{ "onsails/lspkind.nvim" },
	require("plugins.oil"),
	require("plugins.treesitter"),
	require("plugins.telescope"),
	require("plugins.nvim_cmp"),
	require("plugins.mason"),
}
