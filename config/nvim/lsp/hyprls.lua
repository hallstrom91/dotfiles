-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/hyprls.lua
-- https://github.com/hyprland-community/hyprls
---@type vim.lsp.Config
return {
	cmd = { "hyprls" },
	filetypes = { "hyprlang" },
	-- root_markers = { ".git" },
	root_dir = vim.fn.getcwd(),
	settings = {
		hyprls = {
			preferIgnoreFile = true,
			ignore = { "hyprlock.conf", "hypridle.conf" },
		},
	},
}
