local M = {}

function M.on_attach(client, bufnr)
	local mod = require("utils.lsp_utils")
	local ok_t, builtin = pcall(require, "telescope.builtin")
	-- base keymaps
	mod.set_lsp_keymap(client, bufnr, "K", vim.lsp.buf.hover, { desc = "Hover", requires = "textDocument/hover" })
	mod.set_lsp_keymap(
		client,
		bufnr,
		"<leader>e",
		vim.diagnostic.open_float,
		{ desc = "Diagnostic", requires = "textDocument/publishDiagnostics" }
	)

	-- basic telescope lsp pickers
	if ok_t then
		mod.set_lsp_keymap(
			client,
			bufnr,
			"<leader>gd",
			builtin.lsp_definitions,
			{ desc = "Definition", requires = "textDocument/definition" }
		)
		mod.set_lsp_keymap(
			client,
			bufnr,
			"<leader>gr",
			builtin.lsp_references,
			{ desc = "References", requires = "textDocument/references" }
		)
		mod.set_lsp_keymap(
			client,
			bufnr,
			"<leader>gi",
			builtin.lsp_implementations,
			{ desc = "Implementations", requires = "textDocument/implementations" }
		)
		mod.set_lsp_keymap(
			client,
			bufnr,
			"<leader>gt",
			builtin.lsp_type_definitions,
			{ desc = "Type Definition", requires = "textDocument/typeDefinition" }
		)
	end
end

return M
