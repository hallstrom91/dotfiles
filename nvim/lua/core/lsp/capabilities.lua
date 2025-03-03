local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }

capabilities.textDocument.completion.completionItem.snippetSupport = true

capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { 'documentation', 'detail', 'additionalTextEdits' },
}

return capabilities

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
--
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
--
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
-- capabilities.textDocument.completion.completionItem.resolveSupport = {
--   properties = { 'documentation', 'detail', 'additionalTextEdits' },
-- }
--
-- return capabilities
--
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
--
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- capabilities.textDocument.foldingRange = {
--   dynamicRegistration = false,
--   lineFoldingOnly = true,
-- }
--
-- return capabilities
