if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true

vim.treesitter.start()

require("lsp.init").start({
  name = "csharp_ls",
  cmd = { "csharp-ls" },
  root_markers = { ".git", "global.json", ".editorconfig" },
  init_options = { AutomaticWorkspaceInit = true },
  disable_fmt = false, -- true if csharpier is installed
  replace_on_attach = false,
  --  on_attach = function(client, bufnr) end,
})
