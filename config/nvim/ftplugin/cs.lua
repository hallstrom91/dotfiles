-- Guard: run only once per buf
if vim.b.did_ftplugin_csharp then
	return
end
vim.b.did_ftplugin_csharp = true

-- enable treesitter
vim.treesitter.start()

-- Opts: buffer specific
-- vim.opt_local.?
