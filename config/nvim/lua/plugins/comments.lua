return {
	----| default |----
	{
		"nvim-mini/mini.comment",
		version = "*",
		event = "VeryLazy",
		-- init = function()
		-- 	vim.api.nvim_create_autocmd("FileType", {
		-- 		pattern = {
		-- 			"javascript",
		-- 			"javascriptreact",
		-- 			"typescript",
		-- 			"typescriptreact",
		-- 			"tsx",
		-- 			"jsx",
		-- 		},
		-- 		callback = function()
		-- 			vim.b.minicomment_disable = true
		-- 		end,
		-- 	})
		-- end,
		opts = {},
	},

	----| webdev |----
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		ft = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"tsx",
			"jsx",
		},
		opts = {},
	},
}
