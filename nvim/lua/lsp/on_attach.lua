return function(client, bufnr)
  -- LSP servers som INTE ska formattera
  local exclude_formatting = {
    'ts_ls',
    'html',
    'cssls',
    'lua_ls',
    'pyright',
    'yamlls',
    'marksman',
    'jsonls',
    'omnisharp',
  }

  if vim.tbl_contains(exclude_formatting, client.name) then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.document_range_formatting = false
  end

  -- Keybinds läggs till automatiskt
  require('lsp.keymaps').setup(bufnr)
end
