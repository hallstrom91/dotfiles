-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/qmlls.lua
---@type vim.lsp.Config
return {
	cmd = { "qmlls" },
	filetypes = { "qml", "qmljs" },
	root_markers = { ".git", "shell.qml" },
}
