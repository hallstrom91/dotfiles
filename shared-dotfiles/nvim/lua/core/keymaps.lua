local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymaps = {
  --> Basic
  { mode = "n", keys = ";", cmd = ":", desc = "Enter command mode" },
  { mode = "i", keys = "jk", cmd = "<ESC>", desc = "Exit insert mode" },
  { mode = "n", keys = "<F13>", cmd = ":noh<CR>", desc = "Clear Search Markings" },
  { mode = { "i", "x", "n", "s" }, keys = "<C-s>", cmd = "<cmd>w<cr><esc>", desc = "Save File" },

  --> Move rows
  { mode = "n", keys = "<A-Up>", cmd = ":m .-2<CR>==", desc = "Move row up" },
  { mode = "i", keys = "<A-Up>", cmd = "<Esc>:m .-2<CR>==gi", desc = "Move row up in insert mode" },
  { mode = "v", keys = "<A-Up>", cmd = ":m '<-2<CR>gv=gv", desc = "Move selection up" },
  { mode = "n", keys = "<A-Down>", cmd = ":m .+1<CR>==", desc = "Move row down" },
  { mode = "i", keys = "<A-Down>", cmd = "<Esc>:m .+1<CR>==gi", desc = "Move row down in insert mode" },
  { mode = "v", keys = "<A-Down>", cmd = ":m '>+1<CR>gv=gv", desc = "Move selection down" },

  --> Window resize & split window
  { mode = "n", keys = "<S-w>", cmd = "<cmd>resize +2<cr>", desc = "Increase Window Height" },
  { mode = "n", keys = "<S-s>", cmd = "<cmd>resize -2<cr>", desc = "Decrease Window Height" },
  { mode = "n", keys = "<S-a>", cmd = "<cmd>vertical resize -2<cr>", desc = "Decrease Window Width" },
  { mode = "n", keys = "<S-d>", cmd = "<cmd>vertical resize +2<cr>", desc = "Increase Window Width" },
  { mode = "n", keys = "<leader><Down>", cmd = "<C-W>s", desc = "Horizontal Split Below", remap = true },
  { mode = "n", keys = "<leader><Up>", cmd = ":split<CR>", desc = "Horizontal Split Above", remap = true },
  { mode = "n", keys = "<leader><Right>", cmd = "<C-W>v", desc = "Vertical Split Right", remap = true },
  { mode = "n", keys = "<leader><Left>", cmd = ":vsplit<CR>", desc = "Vertical Split Left", remap = true },
  { mode = "n", keys = "<leader>q", cmd = "<C-W>c", desc = "Close Window", remap = true },
}

for _, keymap in ipairs(keymaps) do
  local key_opts = vim.tbl_extend("force", opts, { desc = keymap.desc })

  if keymap.remap then
    key_opts.remap = true
  end

  map(keymap.mode, keymap.keys, keymap.cmd, key_opts)
end
