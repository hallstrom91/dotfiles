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
    yaml = { "prettierd" },
    bash = { "shfmt" },
    -- csharp = { 'csharpier' },
  },
  notify_no_formatters = true,
})
