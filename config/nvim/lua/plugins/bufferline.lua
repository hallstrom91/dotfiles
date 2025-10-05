return {
	"akinsho/bufferline.nvim",
	version = "*",
	keys = {
		{ "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer", mode = "n", silent = true },
		{ "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer", mode = "n", silent = true },
		{ "<leader>tn" "<cmd>tabnew<cr>", desc = "New tab", mode = "n", silent = true },
	},
	opts = {
			options = {
				mode = "tabs",
				style_preset = require("bufferline").style_preset.default,
				themable = true,
				numbers = "ordinal", -- (can be "none", "ordinal", "buffer_id", or "both")
				diagnostics = "nvim_lsp",
				diagnostics_update_on_event = true,
				close_command = "tabclose",
				middle_mouse_command = "vertical sbuffer %d",
				right_mouse_command = "tabclose",
				offsets = {
					{
						filetype = "neo-tree",
						text = "FS Explorer",
						-- text = function()
						--   return " " .. git.get_current_branch()
						-- end,
						highlight = "Directory",
					},
				},
				indicator = {
					icon = "▎󰸞 ", -- indicator for active buffer
					style = "icon", -- can be 'icon', 'underline', or 'none'
				},
			},
		},
}
