local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

capabilities.textDocument.signatureHelp = {
  dynamicRegistration = false,
  signatureInformation = {
    documentationFormat = { "markdown", "plaintext" },
    parameterInformation = { labelOffsetSupport = true },
  },
}

capabilities.textDocument.completion = {
  completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    },
  },
}

return require("cmp_nvim_lsp").default_capabilities(capabilities)

-- return require("cmp_nvim_lsp").default_capabilities({
--   textDocument = {
--     foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
--     signatureHelp = {
--       dynamicRegistration = false,
--       signatureInformation = {
--         documentationFormat = { "markdown", "plaintext" },
--         parameterInformation = { labelOffsetSupport = true },
--       },
--     },
--     completion = {
--       completionItem = {
--         documentationFormat = { "markdown", "plaintext" },
--         snippetSupport = true,
--         resolveSupport = {
--           properties = { "documentation", "detail", "additionalTextEdits" },
--         },
--       },
--     },
--   },
-- })
