return {
	"stevearc/conform.nvim",
	event = { "InsertEnter" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			html = { "prettierd" },
			css = { "prettierd" },
			markdown = { "prettierd" },
			yaml = { "prettierd" },
			sh = { "shfmt" },
			-- csharp = { 'csharpier' },
		},
		notify_no_formatters = true,
	},
}
