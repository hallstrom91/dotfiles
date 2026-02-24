local find_root = require("config.utils").find_root
-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/bashls.lua
-- https://github.com/bash-lsp/bash-language-server
---@type vim.lsp.Config
return {
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh" },
	-- root_dir = function(bufnr, on_dir)
	-- 	local fname = vim.api.nvim_buf_get_name(bufnr)
	-- 	local root = vim.fs.root(fname, { ".git" })
	-- 	if root then
	-- 		on_dir(root) -- lsp active: time 2 fight errors
	-- 	end
	-- end,
	-- root_dir = root.get_lsp_rootdir({
	-- 	".git",
	-- }),
    root_dir = find_root({".git"}),
	settings = {
		bashIde = {
			globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
		},
	},
	single_file_support = true,
}
