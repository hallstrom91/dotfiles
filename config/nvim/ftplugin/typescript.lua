-- Guard: run only once per buf
if vim.b.did_ftplugin_typescript then
	return
end
vim.b.did_ftplugin_typescript = true

-- Enable: extensions, plugins or require files
vim.treesitter.start()

-- Opts:
vim.b.minicomment_disable = true -- in favor of ts-comments
vim.opt_local.suffixesadd:append({ ".ts", ".tsx", ".mts", ".cts" })
