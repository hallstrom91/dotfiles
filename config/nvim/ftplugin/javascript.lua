if vim.b.did_ftplugin_javascript then
	return
end
vim.b.did_ftplugin_javascript = true

-- Enable: extensions, plugins or require files
vim.treesitter.start()
vim.b.minicomment_disable = true

-- Opts:
vim.opt_local.suffixesadd:append({ ".js", ".jsx", ".mjs", ".cjs" })
-- vim.opt_local.shiftwidth = 2
-- vim.opt_local.tabstop = 2
