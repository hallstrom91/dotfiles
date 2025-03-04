local M = {}

M.setup = function(bufnr, server_name)
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- 🔹 OmniSharp
  if bufnr and server_name == 'omnisharp' then
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end
    nmap('gd', require('omnisharp_extended').lsp_definition, '[G]oto [D]efinition')
    nmap('gr', require('omnisharp_extended').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('omnisharp_extended').lsp_implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', require('omnisharp_extended').lsp_type_definition, 'Type [D]efinition')
  end

  local keymaps = {
    { 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'LSP Hover documentation' },
    { 'n', 'gd', '<cmd>Telescope lsp_definitions<CR>', 'LSP Go to Definition' },
    { 'n', 'gr', '<cmd>Telescope lsp_references<CR>', 'LSP Find References' },
    { 'n', 'gi', '<cmd>Telescope lsp_implementations<CR>', 'LSP Go to Implementation' },
    { 'n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'LSP Type Definitions' },
  }

  for _, keymap in ipairs(keymaps) do
    map(keymap[1], keymap[2], keymap[3], { desc = keymap[4], noremap = true, silent = true, buffer = bufnr })
  end
end

return M
