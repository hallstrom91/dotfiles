return {
	"nvim-lualine/lualine.nvim",
	event = "BufWinEnter",
	opts = function()
		local editor_utils = require("utils.editor_utils")
		local clock = editor_utils.clock
		local lsp_clients = editor_utils.lsp_clients

		return {
			options = {
				theme = "vscode",
				component_separators = "",
				section_separators = { left = " ", right = " " },
				always_divide_middle = true,
				disabled_filetypes = {
					statusline = { "neo-tree", "git", "fugitive", "trouble", "dashboard" },
					winbar = { "neo-tree", "DiffviewFiles", "git", "dashboard" },
				},
			},
			winbar = {
				lualine_a = {
					{
						"filetype",
						colored = true,
						icon_only = false,
						icon = { align = "left" },
					},
					{
						"filename",
						file_status = true,
						path = 1,
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {
					{
						lsp_clients,
					},
				},
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
