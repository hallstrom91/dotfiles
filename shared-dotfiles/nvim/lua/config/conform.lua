require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    markdown = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    yaml = { "prettierd" },
    -- csharp = { 'csharpier' },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = false,
  },
})
