local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup({
  registries = {
    "github:Crashdummyy/mason-registry",
    "github:mason-org/mason-registry",
  },
})

local servers = require("core.lsp.servers")
mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true,
})

local common_opts = {
  on_attach = require("core.lsp.on_attach"),
  capabilities = require("core.lsp.capabilities"),
  flags = { debounce_text_changes = 150 },
}

for server, opts in pairs(servers) do
  opts = vim.tbl_deep_extend("force", common_opts, opts)
  lspconfig[server].setup(opts)
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

require("core.lsp.timeout")
require("core.lsp.utils").patch_make_position_params()
