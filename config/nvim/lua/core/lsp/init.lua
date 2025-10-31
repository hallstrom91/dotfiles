-- To see the capabilities for a given server, try this in a LSP-enabled buffer:
--     :lua =vim.lsp.get_clients()[1].server_capabilities

local cmp = require("cmp_nvim_lsp")
local capabilities = cmp.default_capabilities()

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true, -- or 'if_many'
	},
})

vim.lsp.config("*", {
	capabilities = capabilities,
	root_markers = { ".git" }, --> default root_markers
})

vim.lsp.enable({
	"bashls",
	-- "csharp_ls",
	"cssls",
	"jsonls",
	"lua_ls",
	-- "roslyn_ls",
	"vtsls",
	-- "yamlls",
})
