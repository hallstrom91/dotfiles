require("lazy").setup({
	spec = {
		{ import = "plugins.init" },
		-- { import = "plugins.ft" },
	},
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = false, frequency = 86400 },
	ui = { border = "rounded" },
})
