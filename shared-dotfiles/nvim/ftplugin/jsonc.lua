if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true
vim.treesitter.start()

require("lsp.init").start({
  name = "jsonls",
  cmd = { "vscode-json-language-server", "--stdio" },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { "package.json", ".git" },
  settings = {
    json = {
      schemas = require("schemastore").json.schemas({
        select = {
          "tsconfig.json",
          "prettierrc.json",
        },
      }),
      format = { enable = true },
      validate = { enable = true },
    },
  },
  disable_fmt = false,
  replace_on_attach = false,
  -- on_attach = function(client, bufnr) end,
})
