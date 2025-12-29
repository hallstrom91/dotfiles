-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/hyprls.lua
-- https://github.com/hyprland-community/hyprls
---@type vim.lsp.Config
return {
	cmd = { "hyprls", "--stdio" },
	filetypes = { "hyprlang" },
	root_markers = { ".git" },
}
