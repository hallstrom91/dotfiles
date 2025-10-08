-- Guard: run only once per buf
if vim.b.did_ftplugin_typescript then
	return
end
vim.b.did_ftplugin_typescript = true

-- Enable: extensions, plugins or require files
vim.treesitter.start()
vim.b.minicomment_disable = true -- in favor of ts-comments

-- Opts:
vim.opt_local.suffixesadd:append({ ".ts", ".tsx", ".mts", ".cts" })
-- vim.opt_local.shiftwidth = 2
-- vim.opt_local.tabstop = 2
