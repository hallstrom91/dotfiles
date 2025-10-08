-- Guard: run only once per buf
if vim.b.did_ftplugin_typescriptreact then
	return
end
vim.b.did_ftplugin_typescriptreact = true

-- Enable: extensions, plugins or require files
vim.treesitter.start()
vim.b.minicomment_disable = true -- in favor of ts-comments

-- Opts:
vim.opt_local.suffixesadd:append({ ".ts", ".tsx", ".mts", ".cts" })
