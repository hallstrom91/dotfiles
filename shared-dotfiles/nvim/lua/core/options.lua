local opt = vim.opt

opt.number = true -- Show line numbers
opt.relativenumber = false
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 4 -- Indentation width
opt.tabstop = 4 -- Tab width
opt.termguicolors = true -- Enable true colors
opt.splitbelow = false
opt.splitright = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"
opt.foldenable = true
opt.foldexpr = 'v:lua.require("ufo").foldexpr()'
opt.foldmethod = "expr"
opt.linebreak = true
opt.wrap = false -- disable line wrap
opt.smoothscroll = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.spelllang = { "en" }
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- trigger whichkey faster
opt.confirm = false -- confirm to save changes before exiting buffer
opt.showmatch = true
opt.matchtime = 3

vim.g.markdown_recommended_style = 0 -- test ?
vim.g.loaded_netrw = 1 -- disable netrw
vim.g.loaded_netrwPlugin = 1 -- disable netrw
--vim.g.loaded_matchparen = 1
-- vim.bo.syntax = 0

opt.guicursor = {
  -- Normal mode: horizontal line _
  "n-v-c:hor25",
  -- Insert mode: vertical thin line |
  "i-ci-ve:ver25",
  -- Command line - vertical
  "c:ver25",
}

-- Disable providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
