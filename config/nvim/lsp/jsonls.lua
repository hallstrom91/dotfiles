-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/jsonls.lua
-- https://github.com/hrsh7th/vscode-langservers-extracted
---@type vim.lsp.Config
return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	init_options = {
		provideFormatter = true,
	},
	root_markers = { "package.json", ".git" },
	single_file_support = true,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas({
				select = {
					"tsconfig.json",
					"prettierrc.json",
				},
			}),
			format = { enable = true },
			validate = { enable = true },
		},
	},
}
