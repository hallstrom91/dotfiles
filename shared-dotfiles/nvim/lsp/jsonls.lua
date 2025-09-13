---@type vim.lsp.Config

return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { ".git" },
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
}
