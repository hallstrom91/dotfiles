require("lazy").setup({
	spec = {

		{ import = "plugins.init" },
		{ import = "plugins.lsp" },
		{ import = "plugins.code" },
		{ import = "plugins.editor" },
	},
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = false, frequency = 86400 },
	ui = { border = "rounded" },
})
