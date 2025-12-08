---> print current value from cmdline, use:
---> `:lua =vim.*.value` OR `:lua print(vim.*.value)`

--> vim.o.value, e.g. : vim.o.cursorlineopt = "screenline,number"
--> vim.opt.value/table, e.g. : vim.opt.cursorlineopt = { "screenline", "number" }

--> `:help list` | `:help listchars` | `:help lua-options` | `:help lua-options-guide`
--> or just `:options`

--------------------------------------
--> vim globals
--------------------------------------
vim.g.mapleader = " " --> Spacebar | "<leader>"
vim.g.maplocalleader = "\\" --> backslash | "<localleader>"
vim.g.have_nerd_font = true --> Nerd fonts --> https://www.nerdfonts.com/

--> disable external providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

--> internal plugins
vim.g.loaded_matchparens = 0 -- match/highlight {} () []

--------------------------------------
--> vim options
--------------------------------------
--> :options >> 2) moving around, searching and patterns
vim.o.startofline = true -- move cursor to start-of-line pos
vim.o.ignorecase = true -- ignore search case
vim.o.smartcase = true -- dont ignore search case, IF: Capital letter
vim.o.incsearch = true -- show match for partly typed search cmds

vim.o.winblend = 3
vim.o.pumblend = 3

--> :options >> no.4) displaying text
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

--> :options >> 5) syntax, hl and spell
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

--> :options >> 10) messages and info
-- vim.o.visualbell = true
-- vim.opt.cmdwinheight = 10 -- default: 7
vim.o.showcmd = false
vim.o.showmode = false -- already shown in plugin lualine

vim.opt.shortmess:append({ -- :h shortmess
	W = true, -- no 'written'-msg
	A = true, -- no 'ATTENTION' when swap-file exists
	I = true, -- no 'intro'-msg on startup
	T = true, -- truncate file msg if to long to fit cmd-line.
	c = true, -- no 'ins-cmp-menu', 'pattern not found'-msg etc
})

--> 11) Selecting text
-- vim.o.selectmode = "cmd"
vim.schedule(function()
	vim.o.clipboard = "unnamedplus" -- :help clipboard - value based on OS
end)

--> 12) Editing text
vim.o.undofile = true
vim.o.completeopt = "menu,menuone,noinsert,preview"

--> 13) Tabs and indenting
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
-- vim.opt.winborder = "rounded" -- test
-- vim.o.winborder = "rounded"

--- 24) Various
vim.o.exrc = true
vim.o.secure = true

vim.opt.guicursor = { -- cursor shape in different modes
	"n-v-c:hor25",
	"i-ci-ve:ver25",
	"c:ver25",
	-- "n:blinkwait1000-blinkoff600-blinkon300-Cursor/lCursor",
}

--- add custom fold UI
vim.schedule(function()
	require("utils.folds")
	vim.opt.foldtext = "v:lua.custom_foldtext()"
end)
