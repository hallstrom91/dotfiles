local root = require("utils.root")

--- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/yamlls.lua
--- https://github.com/redhat-developer/yaml-language-server
---@type vim.lsp.Config
return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yam.docker-compose", "yaml.gitlab" },
	root_dir = root({
		"git",
	}),
	single_file_support = true,
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = { format = { true } },
	},
}
