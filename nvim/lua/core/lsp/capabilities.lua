local capabilities = vim.lsp.protocol.make_client_capabilities()
local M = {}

M.capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

M.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

M.capabilities.textDocument.signatureHelp = {
  dynamicRegistration = false,
  signatureInformation = {
    documentationFormat = { 'markdown', 'plaintext' },
    parameterInformation = { labelOffsetSupport = true },
  },
}

M.capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { 'documentation', 'detail', 'additionalTextEdits' },
}

return M
