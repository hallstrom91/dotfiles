local M = {}

M.setup = function(bufnr)
  local function nmap(keys, command, desc)
    vim.keymap.set('n', keys, command, { buffer = bufnr, noremap = true, silent = true, desc = desc })
  end

  local telescope = require('telescope.builtin')

  local function vsplit_definitions()
    telescope.lsp_definitions({ jump_type = 'vsplit' })
  end

  local function vsplit_references()
    telescope.lsp_references({ jump_type = 'vsplit' })
  end

  local function vsplit_implementations()
    telescope.lsp_implementations({ jump_type = 'vsplit' })
  end

  local function vsplit_type_definitions()
    telescope.lsp_type_definitions({ jump_type = 'vsplit' })
  end

  local keymaps = {
    { 'K', vim.lsp.buf.hover, 'LSP Hover Documentation' },
    { 'gd', vsplit_definitions, 'LSP Go to Definition' },
    { 'gr', vsplit_references, 'LSP Find References' },
    { 'gi', vsplit_implementations, 'LSP Go to Implementation' },
    { 'gt', vsplit_type_definitions, 'LSP Type Definitions' },
    { '<leader>li', '<cmd>LspInfo<CR>', 'Lsp Info' },
    { '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', 'Lsp Diagnostics' },
  }

  for _, keymap in ipairs(keymaps) do
    nmap(keymap[1], keymap[2], keymap[3])
  end
end

return M

-- local M = {}
--
-- M.setup = function(bufnr)
--   local function nmap(keys, command, desc)
--     vim.keymap.set('n', keys, command, { buffer = bufnr, noremap = true, silent = true, desc = desc })
--   end
--
--   local telescope = require('telescope.builtin')
--
--   local keymaps = {
--     { 'K', vim.lsp.buf.hover, 'LSP Hover Documentation' },
--     { 'gd', '<cmd>Telescope lsp_definitions<CR>', 'LSP Go to Definition' },
--     { 'gr', '<cmd>Telescope lsp_references<CR>', 'LSP Find References' },
--     { 'gi', '<cmd>Telescope lsp_implementations<CR>', 'LSP Go to Implementation' },
--     { 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'LSP Type Definitions' },
--     { '<leader>li', '<cmd>LspInfo<CR>', 'Lsp Info' },
--     { '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', 'Lsp Diagnostics' },
--   }
--
--   for _, keymap in ipairs(keymaps) do
--     nmap(keymap[1], keymap[2], keymap[3])
--   end
-- end
--
-- return M
