local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- open cmd mode with ;
map('n', ';', ':', { desc = 'Enter command mode' })

-- leave insert mode with "jk" or ESC-btn
map('i', 'jk', '<ESC>', { desc = 'Exit insert mode' })

-- Copy with ctrl+c in all modes
map({ 'n', 'v', 'i' }, '<C-c>', '"+y', { desc = 'Copy to system clipboard' })

-- Remove search result markings with ESC-btn x2
map('n', '<Esc><Esc>', ':noh<CR>', vim.tbl_extend('force', opts, { desc = 'Clear Search Markings' }))

-- Save with Ctrl + S and exit insert mode
map('n', '<C-s>', '<cmd> w <cr>', vim.tbl_extend('force', opts, { desc = 'Save file' }))
map(
  'i',
  '<C-s>',
  '<cmd> w <cr><cmd> stopinsert <cr>',
  vim.tbl_extend('force', opts, { desc = 'Save and exit insert mode' })
)
map(
  'v',
  '<C-s>',
  '<cmd> w <cr><cmd> stopinsert <cr>',
  vim.tbl_extend('force', opts, { desc = 'Save and exit insert mode' })
)

-- Move row UP with Alt+Up-arrowkey
map('n', '<A-Up>', ':m .-2<CR>==', vim.tbl_extend('force', opts, { desc = 'Move row up' }))
map('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', vim.tbl_extend('force', opts, { desc = 'Move row up in insert mode' }))
map('v', '<A-Up>', ":m '<-2<CR>gv=gv", vim.tbl_extend('force', opts, { desc = 'Move selection up' }))

-- Move row DOWN with Alt+Down-arrowkey
map('n', '<A-Down>', ':m .+1<CR>==', vim.tbl_extend('force', opts, { desc = 'Move row down' }))
map('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', vim.tbl_extend('force', opts, { desc = 'Move row down in insert mode' }))
map('v', '<A-Down>', ":m '>+1<CR>gv=gv", vim.tbl_extend('force', opts, { desc = 'Move selection down' }))

-- Text Selection - Shift + Arrow keys (Normal)
map('n', '<S-Left>', 'v<Left>', vim.tbl_extend('force', opts, { desc = 'Select text to the left' }))
map('n', '<S-Right>', 'v<Right>', vim.tbl_extend('force', opts, { desc = 'Select text to the right' }))
map('n', '<S-Up>', 'v<Up>', vim.tbl_extend('force', opts, { desc = 'Select text upwards' }))
map('n', '<S-Down>', 'v<Down>', vim.tbl_extend('force', opts, { desc = 'Select text downwards' }))

-- Text Selection - Shift + Arrow keys (Insert)
map('i', '<S-Left>', '<C-o>v<Left>', vim.tbl_extend('force', opts, { desc = 'Select left in insert mode' }))
map('i', '<S-Right>', '<C-o>v<Right>', vim.tbl_extend('force', opts, { desc = 'Select right in insert mode' }))
map('i', '<S-Up>', '<C-o>v<Up>', vim.tbl_extend('force', opts, { desc = 'Select up in insert mode' }))
map('i', '<S-Down>', '<C-o>v<Down>', vim.tbl_extend('force', opts, { desc = 'Select down in insert mode' }))

-- Resize buffer windows - Shift + W-S-A-D keys
map('n', '<S-w>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<S-s>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<S-a>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<S-d>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Mark all text in a file with ctrl+a. Insert, Normal and Visual.
map('n', '<C-a>', 'ggVG', vim.tbl_extend('force', opts, { desc = 'Select all text' }))
map('i', '<C-a>', '<Esc>ggVG', vim.tbl_extend('force', opts, { desc = 'Select all text in insert mode' }))
map('v', '<C-a>', 'ggVG', vim.tbl_extend('force', opts, { desc = 'Select all text in visual mode' }))

-- Split buffer windows
map('n', '<leader><Down>', '<C-W>s', { desc = 'Horizontal Split Below', remap = true })
map('n', '<leader><Up>', ':split<CR>', { desc = 'Horizontal Split Above', remap = true })
map('n', '<leader><Right>', '<C-W>v', { desc = 'Vertical Split Right', remap = true })
map('n', '<leader><Left>', ':vsplit<CR>', { desc = 'Vertical Split Left', remap = true })
map('n', '<leader>q', '<C-W>c', { desc = 'Close Window', remap = true })
