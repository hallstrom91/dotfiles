return {
	"NvChad/nvim-colorizer.lua",
	ft = { "css", "lua", "typescriptreact", "javascriptreact", "dosini", "i3config" },
	config = function()
		require("colorizer").setup({
			user_default_options = {
				RGB = true,
				RRGGBB = true,
				names = false,
				css = true,
				css_fn = true,
				mode = "background",
				tailwind = true,
				always_update = true,
				virtualtext = "■",
			},
		})
	end,
}
