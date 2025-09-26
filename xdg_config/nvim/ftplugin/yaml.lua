-- https://starship.rs/config-schema.json

if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true
vim.treesitter.start()

require("lsp.init").start({
  name = "yamlls",
  cmd = { "yaml-language-server", "--stdio" },
  root_markers = { "package.json", ".git" }, -- fix
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = true },
      schemas = {
        -- ["https://starship.rs/config-schema.json"] = "/starship/starship.toml", -- wrong server
      },
    },
  },
  disable_fmt = false,
  replace_on_attach = false,
  -- on_attach = function(client, bufnr) end,
})
