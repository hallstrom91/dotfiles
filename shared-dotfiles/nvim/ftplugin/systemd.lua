if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true

pcall(vim.treesitter.start)

require("lsp.init").start({
  name = "systemd",
  cmd = { "systemd-language-server" },
  single_file_support = true,
  disable_fmt = true,
  replace_on_attach = false,
  -- on_attach = function(client, bufnr) end,
})
