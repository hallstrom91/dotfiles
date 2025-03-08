local M = {}

M.setup = function(bufnr)
  local function nmap(keys, command, desc)
    vim.keymap.set('n', keys, command, { buffer = bufnr, noremap = true, silent = true, desc = desc })
  end

  local keymaps = {
    { 'K', vim.lsp.buf.hover, 'LSP Hover Documentation' },
    { 'gd', '<cmd>Telescope lsp_definitions<CR>', 'LSP Go to Definition' },
    { 'gr', '<cmd>Telescope lsp_references<CR>', 'LSP Find References' },
    { 'gi', '<cmd>Telescope lsp_implementations<CR>', 'LSP Go to Implementation' },
    { 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'LSP Type Definitions' },
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
--   local map = vim.keymap.set
--   local opts = { noremap = true, silent = true, buffer = bufnr }
--
--   local keymaps = {
--     { 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'LSP Hover documentation' },
--     { 'n', 'gd', '<cmd>Telescope lsp_definitions<CR>', 'LSP Go to Definition' },
--     { 'n', 'gr', '<cmd>Telescope lsp_references<CR>', 'LSP Find References' },
--     { 'n', 'gi', '<cmd>Telescope lsp_implementations<CR>', 'LSP Go to Implementation' },
--     { 'n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'LSP Type Definitions' },
--   }
--
--   for _, keymap in ipairs(keymaps) do
--     map(keymap[1], keymap[2], keymap[3], { desc = keymap[4], noremap = true, silent = true, buffer = bufnr })
--   end
-- end
--
-- return M
