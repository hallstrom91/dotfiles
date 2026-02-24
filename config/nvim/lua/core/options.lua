vim.g.mapleader = " "
vim.g.localleader = "\\"
vim.g.have_nerd_font = true
vim.g.editorconfig = true

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.o.startofline = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true

vim.o.winblend = 3
vim.o.pumblend = 3

vim.o.scroll = 12 -- lines to go up(CTRL+U)/down(CTRL+D)
vim.o.smoothscroll = true
vim.o.scrolloff = 12 -- lines to go down/up @ scroll-action
vim.o.wrap = false
vim.o.breakindent = true
-- vim.o.breakat = ??
-- vim.o.showbreak = ??
vim.o.cmdheight = 1 -- default: 1
vim.o.lazyredraw = true -- disable redraw on macros, search etc.
-- vim.o.redrawtime = 1000 -- default 2000 -> higher value on big files ?
vim.o.number = true -- show numbers in signcolumn
vim.o.relativenumber = true -- relative numbers
vim.o.mouse = "" -- disable mouse || to enable 'all' == "a"
vim.o.conceallevel = 2 -- hide text in some cases. ':help conceallevel'

vim.o.hlsearch = true
vim.o.termguicolors = true -- term supports color
vim.opt.spelllang = { "en" } -- in combo with 'vim.o.spell'
vim.o.timeoutlen = 400 -- wait for keymap-kombo (in ms)
vim.o.updatetime = 250
vim.o.spell = false -- spell check (in combo with vim.opt.spellang = { ... } )
vim.o.spelloptions = "camel"
-- vim.o.spellfile = vim.fn.stdpath("config") .. "/spell/???"

--> :options >> 6) multiple windows
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.splitkeep = "screen"
-- vim.o.equalalways = false -- dont resize windows

vim.schedule(function()
	vim.o.clipboard = "unnamedplus" -- :help clipboard - value based on OS
end)

vim.o.undofile = true
vim.o.completeopt = "menu,menuone,noinsert,preview"

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4


--> 14) Folding
vim.o.foldmethod = "expr"
vim.o.foldlevel = 99 -- or 99 ?
vim.o.foldlevelstart = 99 -- start value for auto-folds
vim.o.foldenable = true -- default
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.fillchars:append({ fold = " " }) --- remove ********** at fold
-- vim.o.foldcolumn = "0"

--> 18) The swap file
vim.o.swapfile = false -- or ?

--> 19) reading and writing files
vim.o.autoread = true -- check if file has changed outside nvim, reload in case. Not if deleted.
vim.o.autowrite = true -- autosave when leaving modified buf

--- 24) Various
-- vim.o.exrc = true
-- vim.o.secure = true

vim.opt.guicursor = { -- cursor shape in different modes
	"n-v-c:hor25",
	"i-ci-ve:ver25",
	"c:ver25",
	-- "n:blinkwait1000-blinkoff600-blinkon300-Cursor/lCursor",
}

vim.filetype.add({
	pattern = { [".*/%.bash/.*"] = "bash" },
})

-- https://github.com/tree-sitter-grammars/tree-sitter-hyprlang
vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

-- vim.filetype.add({
-- 	pattern = { [".*/waybar/.*%.css"] = "scss" },
-- })





--- add custom fold UI
-- vim.schedule(function()
-- 	require("utils.folds")
-- 	vim.opt.foldtext = "v:lua.custom_foldtext()"
-- end)

-- UNKOWNN
-- vim.o.showcmd = false
-- vim.o.showmode = false -- already shown in plugin lualine
--
-- vim.opt.shortmess:append({ -- :h shortmess
-- 	W = true, -- no 'written'-msg
-- 	A = true, -- no 'ATTENTION' when swap-file exists
-- 	I = true, -- no 'intro'-msg on startup
-- 	T = true, -- truncate file msg if to long to fit cmd-line.
-- 	c = true, -- no 'ins-cmp-menu', 'pattern not found'-msg etc
-- })
--

