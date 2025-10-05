--- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/yamlls.lua
--- https://github.com/redhat-developer/yaml-language-server
---@type vim.lsp.Config
return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yam.docker-compise", "yaml.gitlab" },
	root_markers = {}, -- find git (set in vim.lsp.enable @ lua/lsp.lua)
	single_file_support = true,
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = { format = { enable = true } },
	},
}
