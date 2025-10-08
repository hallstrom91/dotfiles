-- To see the capabilities for a given server, try this in a LSP-enabled buffer:
--     :lua =vim.lsp.get_clients()[1].server_capabilities
local ok, cmp = pcall(require, "cmp_nvim_lsp")
local on_attach = require("core.lsp.attach")
-- local lsp_utils = require("utils.lsp_utils")

local base = vim.lsp.protocol.make_client_capabilities()
local capabilities = ok and cmp.default_capabilities(base) or base

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
})

vim.lsp.config("*", {
	capabilities = capabilities,
	on_attach = on_attach,
	root_markers = { ".git" },
})

vim.lsp.enable({ "lua_ls" })
