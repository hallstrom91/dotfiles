-- Load my default settings for nvim
vim.o.number = true -- Show line numbers
vim.o.relativenumber = false -- Relative line numbers (very annoying)
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.shiftwidth = 4 -- Indentation width
vim.o.tabstop = 4 -- Tab width
vim.o.termguicolors = true -- Enable true colors
vim.o.splitbelow = false -- Open windows horizontal
vim.o.splitright = true -- Open windows vertical
vim.g.loaded_netrw = 1 -- disable netrw
vim.g.loaded_netrwPlugin = 1 -- disable netrw
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldcolumn = '1'
vim.o.foldenable = true
vim.o.foldexpr = 'v:lua.require("ufo").foldexpr()'
vim.o.foldmethod = 'expr'
-- vim.o.mousemoveevent = true -- "true" to activate hoover on buffertabs
--vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.opt.clipboard = 'unnamedplus' -- sync clipboard actions with system clipboard
--vim.opt.guicursor = "n-v-c-i:ver25" -- changes all cursor markers to thin |

vim.opt.guicursor = {
  -- Normal mode: horizontal line _
  'n-v-c:hor25',
  -- Insert mode: vertical thin line |
  'i-ci-ve:ver25',
  -- Command line - vertical
  'c:ver25',
}

-- Disable providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
