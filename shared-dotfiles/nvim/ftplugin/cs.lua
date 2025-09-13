if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true

vim.treesitter.start()

require("core.lsp").start({
  name = "csharp_ls",
  cmd = { "csharp-ls" },
  root_markers = { ".git", "global.json", ".editorconfig" },
  init_options = { AutomaticWorkspaceInit = true },
})
