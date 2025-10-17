-- INFO: print value from cmdline =
-- :lua = vim.*.value
local opt = vim.opt
local o = vim.o -- :set (buf/win only)

-- defaults (g)
opt.termguicolors = true
opt.number = true
opt.relativenumber = false
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.splitbelow = true
opt.splitright = true
opt.wrap = false
opt.smoothscroll = true
opt.showtabline = 2 -- always show tabline
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.spell = false
opt.spelllang = { "en" }
opt.timeoutlen = 1000 or 300
opt.guicursor = {
	"n-v-c:hor25",
	"i-ci-ve:ver25",
	"c:ver25",
}

-- defaults (buf/win)
o.exrc = true
o.secure = true
o.winborder = "rounded"
o.cursorline = true
-- o.cursorcolumn = "cursorcolumn"
o.cursorlineopt = "both"
-- o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- o.foldmethod = "expr"
-- o.foldenable = false -- switch with keys: zi
-- o.foldcolumn = 1
-- o.foldlevelstart = 99

-- external providers (disable = 0)
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
