if vim.b.did_ftplugin_javascript then
	return
end
vim.b.did_ftplugin_javascript = true

-- Enable: extensions, plugins or require files
vim.treesitter.start()

-- Opts:
vim.b.minicomment_disable = true
vim.opt_local.suffixesadd:append({ ".js", ".jsx", ".mjs", ".cjs" })
