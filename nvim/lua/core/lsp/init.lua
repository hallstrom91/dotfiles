local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

require('core.lsp.timeout')
local capabilities = require('core.lsp.capabilities').capabilities
local servers = require('core.lsp.servers')
local on_attach = require('core.lsp.on_attach').on_attach

mason.setup({
  registries = {
    'github:Crashdummyy/mason-registry',
    'github:mason-org/mason-registry',
  },
})

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true,
})

for server, config in pairs(servers) do
  lspconfig[server].setup(vim.tbl_deep_extend('force', {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = { debounce_text_changes = 150 },
  }, config))
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})
