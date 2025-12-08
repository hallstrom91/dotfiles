return {
	"stevearc/oil.nvim",
	---@module 'oil'
	keys = {
		{ "<leader>-", "<CMD>Oil ./<CR>", { desc = "Open parent directory" } },
		-- { "<leader>n", "<CMD>Oi:"}
	},
	opts = {},
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	lazy = false,
}
