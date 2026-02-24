return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "VimEnter",
	keys = {
		{ "<leader>btp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin", silent = true },
		{
			"<leader><tab>s",
			function()
				require("bufferline").sort_by("tabs")
			end,
			desc = "Sort by tabs",
		},
		{
			"<leader>bs",
			function()
				require("bufferline").sort_by("extension")
			end,
			desc = "Sort by extension",
		},
	},
	opts = function()
		local bfl = require("bufferline")

		return {
			options = {
				mode = "buffers",
				style_preset = bfl.style_preset.default,
				themable = true,
				numbers = "none",
				close_command = "bdelete! %d",
				middle_mouse_command = nil,
				right_mouse_command = "bdelete! %d",
				max_prefix_length = 10,
				tabsize = 25,
				-- separator_style = "slant",

				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				diagnostics_update_on_event = true,
				color_icons = true,
			
            },
		}
	end,
}
