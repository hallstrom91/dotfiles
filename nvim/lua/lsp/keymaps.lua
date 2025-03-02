local M = {}

M.setup = function(bufnr)
  local map = vim.api.nvim_buf_set_keymap
  local opts = { noremap = true, silent = true }

  local keymaps = {
    { 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'LSP Hover documentation' },
    { 'n', 'gd', '<cmd>Telescope lsp_definitions<CR>', 'LSP go to definition' },
    { 'n', 'gr', '<cmd>Telescope lsp_references<CR>', 'LSP find references' },
    { 'n', 'gi', '<cmd>Telescope lsp_implementations<CR>', 'LSP Implementations' },
    { 'n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'LSP type definitions' },
  }

  for _, keymap in ipairs(keymaps) do
    map(bufnr, keymap[1], keymap[2], keymap[3], { desc = keymap[4], noremap = true, silent = true })
  end
end

return M
