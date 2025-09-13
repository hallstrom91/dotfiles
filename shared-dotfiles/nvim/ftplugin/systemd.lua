if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true

pcall(vim.treesitter.start)

require("core.lsp").start({
  name = "systemd",
  cmd = { "systemd-language-server" },
  single_file_support = true,
})
