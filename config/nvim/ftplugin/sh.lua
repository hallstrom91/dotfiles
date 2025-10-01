if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true
vim.treesitter.start()

require("lsp.init").start({
  cmd = { "bash-language-server", "start" },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
  },
  root_markers = { ".git" },
  disable_fmt = true,
  replace_on_attach = false,
  -- on_attach = function(client, bufnr) end,
})
