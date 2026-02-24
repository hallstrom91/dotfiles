return {
	"stevearc/conform.nvim",
	event = { "InsertEnter" },
	init = function()
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("kjs.format", { clear = true }),
			desc = "format buf with conform (on save/write)",
			pattern = "*",
			callback = function(args)
				local bufnr = args.buf
				if vim.bo[bufnr].filetype == "hyprlang" then
					local view = vim.fn.winsaveview()
					vim.cmd("silent keepjumps keepmarks normal! gg=G")
					vim.fn.winrestview(view)
					return
				end

				require("conform").format({
					bufnr = args.buf,
					lsp_format = "fallback",
					timeout_ms = 500,
					stop_after_first = true,
					async = false,
				})
			end,
		})
	end,
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
			yaml = { "yamlfmt", "prettierd" },
			sh = { "shfmt" },
			-- csharp = { 'csharpier' },
		},
		notify_no_formatters = true,
	},
}
