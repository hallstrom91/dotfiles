local opt = vim.opt -- G

opt.number = true
opt.relativenumber = false
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.termguicolors = true
opt.splitbelow = false
opt.splitright = true

-- Folding (treesitter)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"
opt.foldenable = true
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldmethod = "expr"
-- vim.bo.syntax = 0
vim.o.winborder = "rounded"

-- Wrapping
opt.wrap = false -- disable line wrap
--opt.linebreak = true -- if wrap = true | uncomment line
opt.smoothscroll = true

opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.spelllang = { "en" }
opt.spell = false

opt.timeoutlen = vim.g.vscode and 1000 or 300 -- trigger whichkey faster
opt.confirm = false -- confirm to save changes
opt.showmatch = true
opt.matchtime = 3

vim.o.exrc = true
vim.o.secure = true
-- do
--   local ok = pcall(require, "conform")
--   if ok then
--     vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
--   else
--     vim.o.formatexpr = ""
--   end
-- end

vim.g.markdown_recommended_style = 0
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.guicursor = {
  "n-v-c:hor25",
  "i-ci-ve:ver25",
  "c:ver25",
}

-- Disable external providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
