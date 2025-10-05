-- Guard: run only once per buf
vim.b.did_ftplugin_javascriptreact then return end
vim.b.did_ftplugin_javascriptreact = true

-- Extended from:
vim.cmd("runtime! ftplugin/javascript.lua")
