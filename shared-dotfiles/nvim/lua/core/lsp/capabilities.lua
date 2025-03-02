return require("cmp_nvim_lsp").default_capabilities({
  textDocument = {
    foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
    signatureHelp = {
      dynamicRegistration = false,
      signatureInformation = {
        documentationFormat = { "markdown", "plaintext" },
        parameterInformation = { labelOffsetSupport = true },
      },
    },
    completion = {
      completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits" },
        },
      },
    },
  },
})
