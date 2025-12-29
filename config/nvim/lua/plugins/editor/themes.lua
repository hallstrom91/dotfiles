return {
	{
		"Mofiqul/vscode.nvim",
		enabled = false,
		priority = 1000,
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
		-- config = function()
		-- require("nordic").load()
		-- end,
	},
	{
		"navarasu/onedark.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		enabled = false,
		config = function()
			require("onedark").setup({
				style = "darker", -- or "cool"
				-- transparent = true,
				-- term_colors = true,
				lualine = { transparent = true },
				diagnostics = {
					darker = true,
					undercurl = true,
					background = true,
				},
			})
			require("onedark").load()
		end,
	},

	-- {
	-- 	dir = "/media/veracrypt2/ws/lua/modern-north.nvim",
	-- 	dev = true,
	-- 	opts = {
	-- 		transparent = false,
	-- 		styles = {
	-- 			comments = "italic",
	-- 			keywords = "italic",
	-- 			functions = "NONE",
	-- 			strings = "NONE",
	-- 		},
	-- 		plugins = {
	-- 			gitsigns = true,
	-- 			telescope = true,
	-- 			neotree = true,
	-- 			rainbow_delimiters = true,
	-- 			cmp = true,
	-- 			ibl = true,
	-- 			ts_context = true,
	-- 			whichkey = true,
	-- 		},
	-- 	},
	-- 	init = function()
	-- 		vim.cmd.colorscheme("modern-north")
	-- 	end,
	-- 	priority = 1000,
	-- },

	{
		"catppuccin/nvim",
		enabled = true, 
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavor = "auto",
		},
		init = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
