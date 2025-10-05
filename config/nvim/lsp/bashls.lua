-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/bashls.lua
-- https://github.com/bash-lsp/bash-language-server
---@type vim.lsp.Config
return {
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh" },
	settings = {
		bashIde = {
			globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
		},
	},
	single_file_support = true,
}
