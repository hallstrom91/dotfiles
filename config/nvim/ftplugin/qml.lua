vim.lsp.enable("qmlls")
pcall(vim.treesitter.start)

-- window/buf options
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
