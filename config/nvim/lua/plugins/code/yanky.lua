--- https://github.com/gbprod/yanky.nvim
return {
	"gbprod/yanky.nvim",
	keys = {
		{ "<leader>ty", ":Telescope yank_history<CR>", desc = "Telescope Yanky" },
	},
	opts = {
		picker = {
			select = {
				action = nil, -- nil to use default put action
			},
			telescope = {
				use_default_mappings = true,
				mappings = nil, -- nil to use default mappings
			},
			highlight = {
				on_put = true,
				on_yank = false,
				timer = 200,
			},
		},
	},
}
