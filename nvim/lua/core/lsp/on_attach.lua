local M = {}

M.on_attach = function(client, bufnr)
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

  --deactive semantic tokens from omnisharp (fix treesitter color)
  if client.name == 'omnisharp' then
    client.server_capabilities.semanticTokensProvider = nil
  end
  --
  -- option2
  -- if client.name == 'omnisharp' then
  --    local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
  --    for i, v in ipairs(tokenModifiers) do
  --      tokenModifiers[i] = v:gsub(' ', '_')
  --    end
  --    local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
  --    for i, v in ipairs(tokenTypes) do
  --      tokenTypes[i] = v:gsub(' ', '_')
  --    end
  --  end

  require('core.lsp.keymaps').setup(bufnr, client.name)
end

return M
