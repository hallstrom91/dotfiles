return {
	----| Always (no cfg) |-----
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons" },
	{ "b0o/schemastore.nvim", ft = { "json", "yaml" } },
	{ "rcarriga/nvim-notify", lazy = true },
	{ "folke/which-key.nvim", event = "VeryLazy", opts = { show_help = true, show_keys = true} },

	----| defaults (standalone w cfg) |----
	require("plugins.autopairs")
-- require("plugins.autotag") -- load in ftplugin/file
	require("plugins.bufferline"),
	require("plugins.cmp"),
	require("plugins.comments"), -- split ts-comments to only load in ftplugin/file ?
	require("plugins.conform"),
	require("plugins.fileexplorer"),
	require("plugins.git"),
	require("plugins.lualine"),
	require("plugins.mason"),
	require("plugins.noice"),
require("plugins.spectre"),
require("plugins.surround"),
require("plugins.telescope"),
require("plugins.treesitter"),



	----| defaults (cluster w cfg) |----
	require("plugins.highlight"),
	require("plugins.themes"),
	-- require("plugins.")
}
