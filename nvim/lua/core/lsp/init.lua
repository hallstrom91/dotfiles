local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

require('core.lsp.timeout')
local capabilities = require('core.lsp.capabilities')
local servers = require('core.lsp.servers')
local on_attach = require('core.lsp.on_attach').on_attach

require('mason').setup({
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
