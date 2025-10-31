---> print value from cmdline
---> :lua = vim.*.value

-- reminder: vim.o |VS| vim.opt
-- vim.o equals set (in vimL)
-- vim.opt is the same, but with syntactic sugar such as conversion from Lua array to VimL list.
-- e.g. vim.o.cursorlineopt = "screenline, number" |OR| vim.opt.cursorlineopt = { "screenline", "number" }

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"

vim.opt.wrap = false
vim.opt.smoothscroll = true
vim.opt.showtabline = 2 -- always show tabline

vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

vim.opt.spell = false
vim.opt.spelllang = { "en" }
vim.opt.timeoutlen = 500 -- wait for keymap-kombo (in ms)
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.guicursor = {
	"n-v-c:hor25",
	"i-ci-ve:ver25",
	"c:ver25",
}

-- Experimental stuff
-- vim.opt.winborder = "rounded" -- test
-- vim.o.winborder = "rounded"

-- disable external providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- internal plugins
vim.g.loaded_matchparens = 0
