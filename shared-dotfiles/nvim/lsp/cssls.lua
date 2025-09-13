---@type vim.lsp.Config
return {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = {
    "css",
    -- "scss",
    -- "less",
  },
  init_options = { provideFormatter = true }, -- change to prettierd/conform?
  root_markers = { "package.json" },
  settings = {
    css = { validate = true },
    -- scss = { validate = true },
    -- less = { validate = true },
  },
}
