-- Guard: run only once per buf
if vim.b.did_ftplugin_javascriptreact then
	return
end
vim.b.did_ftplugin_javascriptreact = true

--Enable: extensions, plugins or require files
pcall(vim.treesitter.start)

--Opts: Buffer specific
vim.b.minicomment_disable = true
vim.opt_local.suffixesadd:append({ ".js", ".jsx", ".mjs", ".cjs" })
