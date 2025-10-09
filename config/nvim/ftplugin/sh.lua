-- Guard: run only once per buf
if vim.b.did_ftplugin_sh then
	return
end
vim.b.did_ftplugin_did_ftplugin_sh = true

--Enable: extensions, plugins or require files
pcall(vim.treesitter.start)

--Opts: Buffer specific
-- if vim.b.is_bash then
-- 	vim.opt_local.shell = "bash"
-- end
