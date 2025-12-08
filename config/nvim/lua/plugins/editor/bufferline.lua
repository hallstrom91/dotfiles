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
				-- numbers = "ordinal", -- (can be "none", "ordinal", "buffer_id", or "both")
				close_command = "bdelete! %d",
				middle_mouse_command = nil,
				right_mouse_command = "bdelete! %d",
				-- indicator = {
				-- 	icon = require("utils.icons").get_icon("general", "location", { p = 1 }),
				-- 	-- icon = "▎󰸞 ", -- indicator for active buffer
				-- 	style = "icon", -- can be 'icon', 'underline', or 'none'
				-- },
				-- max_name_length = 15,
				max_prefix_length = 10,
				tabsize = 25,
				-- separator_style = "slant",

				-- bline: dx
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				diagnostics_update_on_event = true,
				-- offsets = {
				-- 	{
				-- 		filetype = "neo-tree",
				-- 		text = "File Explorer",
				-- 		-- text = function()
				-- 		--   return " " .. git.get_current_branch()
				-- 		-- end,
				-- 		highlight = "Directory",
				-- 	},
				-- },
				color_icons = true,
				-- groups = {
				-- 	options = {
				-- 		toggle_hidden_on_enter = true,
				-- 	},
				-- 	items = {
				-- 		{
				-- 			name = "Docs",
				-- 			highlight = { undercurl = true, sp = "blue" },
				-- 			auto_close = false,
				-- 			matcher = function(buf)
				-- 				return buf.filename:match("%.md") or buf.filename:match("%.txt")
				-- 			end,
				-- 			separator = {
				-- 				style = require("bufferline.groups").separator.tab,
				-- 			},
				-- 		},
				-- 	},
				-- },
			},
		}
	end,
}
