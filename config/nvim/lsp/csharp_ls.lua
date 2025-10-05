-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/csharp_ls.lua
-- https://github.com/razzmatazz/csharp-language-server
---@type vim.lsp.Config
return {
	cmd = { "csharp-ls" },
	filetypes = { "cs" },
	root_markers = { "*.sln", "*.csproj", ".git", "global.json", ".editorconfig" },
	init_options = { AutomaticWorkspaceInit = true },
}
