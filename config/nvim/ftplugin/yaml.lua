vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

vim.opt_local.list = true
vim.opt_local.listchars = {
	trail = "-",
	eol = "↲",
	tab = "» ",
	space = "·",
}
vim.lsp.enable("yamlls")
pcall(vim.treesitter.start)

vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
