if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true
vim.treesitter.start()

require("lsp.init").start({
  name = "cssls",
  cmd = { "vscode-css-language-server", "--stdio" },
  init_options = { provideFormatter = true },
  root_markers = { "package.json", ".git" },
  settings = {
    css = { validate = true },
  },
  disable_fmt = true,
  replace_on_attach = false,
  --  on_attach = function(client, bufnr) end,
})
