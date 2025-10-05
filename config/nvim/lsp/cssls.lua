-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/cssls.lua
-- https://github.com/hrsh7th/vscode-langservers-extracted
---@type vim.lsp.Config
return {
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css" },
	init_options = { provideFormatter = true },
	root_markers = { "package.json", ".git" },
	settings = {
		css = { validate = true },
		scss = { validate = true },
		less = { validate = true },
	},
}
