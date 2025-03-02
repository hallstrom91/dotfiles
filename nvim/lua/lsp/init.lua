local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

require('lsp.capabilities') -- Importerar capabilities
require('lsp.keymaps') -- Importerar LSP keybinds
local servers = require('lsp.servers') -- Importerar server-lista
local on_attach = require('lsp.on_attach')

mason.setup()
mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers), -- Installerar alla definierade servrar
  automatic_installation = true,
})

for server, config in pairs(servers) do
  lspconfig[server].setup(vim.tbl_deep_extend('force', {
    on_attach = on_attach,
    capabilities = require('lsp.capabilities'),
    flags = { debounce_text_changes = 150 },
  }, config))
end
