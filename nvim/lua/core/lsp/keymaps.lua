local M = {}

M.setup = function(bufnr, server_name)
  local map = vim.api.nvim_buf_set_keymap
  local opts = { noremap = true, silent = true }

  -- 🔹 Omnisharp-specifika keymaps
  if server_name == 'omnisharp' then
    local telescope_ok = pcall(require, 'telescope')

    if telescope_ok then
      map(bufnr, 'n', 'gd', '', {
        callback = function()
          require('omnisharp_extended').telescope_lsp_definitions()
        end,
        desc = 'OmniSharp: Go to Definition',
        noremap = true,
        silent = true,
      })
    else
      map(bufnr, 'n', 'gd', '', {
        callback = function()
          require('omnisharp_extended').lsp_definition()
        end,
        desc = 'OmniSharp: Go to Definition',
        noremap = true,
        silent = true,
      })
    end

    map(bufnr, 'n', '<leader>D', '', {
      callback = function()
        require('omnisharp_extended').lsp_type_definition()
      end,
      desc = 'OmniSharp: Go to Type Definition',
      noremap = true,
      silent = true,
    })
    map(bufnr, 'n', 'gr', '', {
      callback = function()
        require('omnisharp_extended').lsp_references()
      end,
      desc = 'OmniSharp: Find References',
      noremap = true,
      silent = true,
    })
    map(bufnr, 'n', 'gi', '', {
      callback = function()
        require('omnisharp_extended').lsp_implementation()
      end,
      desc = 'OmniSharp: Go to Implementation',
      noremap = true,
      silent = true,
    })

    return
  end

  -- Standard
  local keymaps = {
    { 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'LSP Hover documentation' },
    { 'n', 'gd', '<cmd>Telescope lsp_definitions<CR>', 'LSP Go to Definition' },
    { 'n', 'gr', '<cmd>Telescope lsp_references<CR>', 'LSP Find References' },
    { 'n', 'gi', '<cmd>Telescope lsp_implementations<CR>', 'LSP Go to Implementation' },
    { 'n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'LSP Type Definitions' },
  }

  for _, keymap in ipairs(keymaps) do
    map(bufnr, keymap[1], keymap[2], keymap[3], { desc = keymap[4], noremap = true, silent = true })
  end
end

return M
