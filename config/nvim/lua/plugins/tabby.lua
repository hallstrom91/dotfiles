return {
	"nanozuki/tabby.nvim",
	keys = {
		{ "<leader>tn", ":$tabnew<CR>", desc = "New tab" },
		{ "<leader>tc", ":tabclose<CR>", desc = "Tab close" },
		{ "<leader>to", ":tabonly<CR>", desc = "Tab only" },
		{ "<Tab>", ":tabn<CR>", desc = "Next tab" },
		{ "C-tn", ":tabn<CR>", desc = "Move tab pos(+)" },
		{ "C-tp", ":tabp<CR>", desc = "Move tab pos(-)" },
		{ "<Tab>", ":tabn<CR>", desc = "Next tab" },
		{ "<S-Tab>", ":tabp<CR>", desc = "Prev tab" },
	},
	lazy = false,
	opts = function()
		-- local util = require("tabby.util")
		-- local hl_tline = util.extract_nvim_hl("lualine_b_normal")
		-- local hl_tline_fill = util.extract_nvim_hl("lualine_c_normal")
		-- local hl_tline_sel = util.extract_nvim_hl("lualine_c_normal")

		return {
			preset = "active_wins_at_tail",
			option = {
				nerdfont = true, -- whether use nerdfont
				buf_name = {
					mode = "unique",
				},
			},
		}
	end,
}
