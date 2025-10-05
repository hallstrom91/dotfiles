-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/vtsls.lua
-- https://github.com/yioneko/vtsls
---@type vim.lsp.Config
return {
	cmd = { "vtsls", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true,
		},
	},
	tsserver = {
		globalPlugins = {},
	},
	typescript = {
		format = { enable = false },
	},
	javascript = {
		format = { enable = false },
	},
	root_markers = { "tsconfig.json", "package.json", "jsconfig" },
	single_file_support = true,
}
