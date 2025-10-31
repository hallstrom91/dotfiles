local colors = {
	-- nord0-3 = polar night
	nord0 = "#2E3440", -- bg
	nord1 = "#3B4252", -- bg alt
	nord2 = "#434C5E",
	nord3 = "#4C566A",
	-- nord4-6 = snow storm
	nord4 = "#D8DEE9", -- fg (dim)
	nord5 = "#E5E9F0", -- fg (alt)
	nord6 = "#ECEFF4", -- fg (primary)
	-- nord7-10 = frost
	nord7 = "#8FBCBB", -- primary accent
	nord8 = "#88C0D0", -- primary accent
	nord9 = "#81A1C1",
	nord10 = "#5E81AC",
	-- nord11-13 = aurora
	nord11 = "#BF616A", -- error
	nord12 = "#D08770", -- warn
	nord13 = "#EBCD8B", -- hint
	nord14 = "#A3BE8C", -- info (primary)
	nord15 = "#B48EAD", -- info (alt)
}

local nord_fork_theme = {
	normal = {
		a = { fg = colors.nord1, bg = colors.nord10, gui = "bold" },
		b = { fg = colors.nord5, bg = colors.nord1 },
		c = { fg = colors.nord5, bg = colors.nord3 },
		-- x-y-z = inherits
	},

	insert = {
		a = { fg = colors.nord1, bg = colors.nord6, gui = "bold" },
	},

	visual = {
		a = { fg = colors.nord1, bg = colors.nord7, gui = "bold" },
	},

	replace = {
		a = { fg = colors.nord1, bg = colors.nord8, gui = "bold" },
	},

	command = {
		a = { fg = colors.nord6, bg = colors.nord9, gui = "bold" },
	},
}

return {
	"nvim-lualine/lualine.nvim",
	event = "BufWinEnter",
	opts = function()
		local editor_utils = require("utils.editor_utils")
		local clock = editor_utils.clock
		local lsp_clients = editor_utils.lsp_clients
		local lsp_active_ws = editor_utils.lsp_active_workspace
		return {
			options = {
				theme = nord_fork_theme,
				-- theme = "nord",
				component_separators = "",
				section_separators = { left = "", right = "" },
				always_divide_middle = true,
				always_show_tabline = true,
				disabled_filetypes = {
					statusline = { "neo-tree", "git", "fugitive", "trouble", "dashboard" },
					winbar = { "neo-tree", "DiffviewFiles", "git", "dashboard" },
				},
			},
			sections = {
				lualine_a = {
					{
						"mode",
						icon = { "", align = "left" },
						separator = { left = "", right = "" },
						padding = 2,
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "",
						color = { bg = colors.nord0, fg = colors.nord4, gui = "italic" },
						separator = { left = "", right = "" },
						padding = 1,
					},
					{
						"diff",
						symbols = {
							added = "",
							modified = "",
							removed = "",
						},
						color = { bg = colors.nord1, fg = colors.nord6 },
						separator = { left = "", right = "" },
						padding = 2,
					},
				},
				lualine_c = {}, -- empty
				lualine_x = {}, -- empty
				lualine_y = {
					{
						"searchcount",
						color = { bg = colors.nord1, fg = colors.nord6 },
						separator = { left = "" },
						padding = 2,
					},
					{
						"diagnostics",
						sections = { "error", "warn", "info", "hint" },
						color = { bg = colors.nord0, fg = colors.nord4 },
						separator = { left = "" },
						padding = 2,
						always_visible = true,
					},
				},
				lualine_z = {
					{
						"location",
						icon = { "", align = "left" },
						separator = { left = "", right = "" },
						right_padding = 2,
					},
				},
			},

			winbar = {
				lualine_a = {
					{
						lsp_clients,
					},
				},
				lualine_b = {
					{
						lsp_active_ws,
						color = { bg = colors.nord0, fg = colors.nord4, gui = "italic" },
						separator = { right = "" },
						padding = 2,
					},
					{
						"filename",
						file_status = true,
						path = 0,
						color = { bg = colors.nord1, fg = colors.nord6 },
						separator = { right = "" },
						padding = 2,
					},
				},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {
					{
						clock,
						icon = " ",
					},
				},
			},
		}
	end,
}
