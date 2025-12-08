return {
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		-- ft = { "css", "lua", "typescriptreact", "javascriptreact", "dosini", "i3config" },
		opts = {
			filetypes = {
				"css",
				"lua",
				"typescriptreact",
				"javascriptreact",
				"dosini",
				"i3config",
				"cmp_docs",
				"markdown",
			},
			-- buftypes = {"*"}
			user_default_options = {
				names = false, -- e.g. - "red"
				names_opts = {
					lowercase = true,
					camelcase = true,
					uppercase = false,
					strip_digits = false,
				},
				RGB = true, -- #RGB hex
				RGBA = true, -- #RGBA hex
				RRGGBBAA = true, -- #RRGGBBAA hex
				AARRGGBB = false, -- # 0xAARRGGBBAA hex
				css = true,
				css_fn = true,
				tailwind = false, -- boolean|'normal'|'lsp'|'both'
				mode = "background", -- or 'foreground'
				always_update = true,
				virtualtext = "■",
			},
		},
	},
}
