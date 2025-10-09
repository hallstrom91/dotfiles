-- Guard: run only once per buf
if vim.b.did_ftplugin_markdown then
	return
end
vim.b.did_ftplugin_markdown = true

--Enable: extensions, plugins or require files
pcall(vim.treesitter.start)

--Opts: Buffer specific
-- vim.opt_local.markdown_folding = 1 -- enable
-- vim.opt_local.markdown_recommended_style = 0
