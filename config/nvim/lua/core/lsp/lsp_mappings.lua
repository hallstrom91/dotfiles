local M = {}

---@class KjsLspMap : KjsKeymap
---@field requires? string|string[]				-- LSP method(s) required

local method = vim.lsp.protocol.Methods
-- local require("telescope.builtin") = require("telescope.builtin")
-- local fzflua = require("fzflua")

M.lsp_mappings = {
	-- Hover
	{
		lhs = "K",
		desc = "Hover",
		rhs = function()
			vim.lsp.buf.hover({
				border = "rounded",
				max_height = 10,
				max_width = 120,
				close_events = { "CursorMoved", "BufLeave", "WinLeave", "LspDetach" },
			})
		end,
		requires = method.textDocument_hover,
	},

	-- Code action
	{
		lhs = "<leader>Gra",
		desc = "Telescope: Code Action",
		rhs = vim.lsp.buf.code_action,
		mode = { "n", "v" },
		requires = method.textDocument_codeAction,
	},

	-- Rename
	{
		lhs = "<leader>Grn",
		desc = "Telescope: Rename (symbol)",
		rhs = vim.lsp.buf.rename,
		requires = method.textDocument_rename,
	},

	{
		lhs = "<leader>Grr",
		desc = "Telescope: Goto references",
		rhs = require("telescope.builtin").lsp_references,
		requires = method.textDocument_references,
	},
	-- Type definition
	{
		lhs = "<leader>Grt",
		desc = "Telescope: Goto type definition",
		rhs = require("telescope.builtin").lsp_type_definitions,
		requires = method.textDocument_typeDefinition,
	},

	-- Implementation
	{
		lhs = "<leader>Gri",
		desc = "Telescope: Goto implementation",
		rhs = require("telescope.builtin").lsp_implementations,
		requires = method.textDocument_implementation,
	},

	-- Document symbols
	{
		lhs = "<leader>GO",
		desc = "Telescope: Document Symbols",
		rhs = require("telescope.builtin").lsp_document_symbols,
		requires = method.textDocument_documentSymbol,
	},

	-- {
	-- 	lhs = "",
	-- 	desc = "",
	-- 	rhs =
	-- 	requires = method.
	-- }
}

M.lsp_maps_fzflua = {
	-- Hover
	{
		lhs = "K",
		desc = "Hover",
		rhs = function()
			vim.lsp.buf.hover({
				border = "rounded",
				max_height = 10,
				max_width = 120,
				close_events = { "CursorMoved", "BufLeave", "WinLeave", "LspDetach" },
			})
		end,
		requires = method.textDocument_hover,
	},

	-- Code action
	{
		lhs = "<leader>Gra",
		desc = "Telescope: Code Action",
		-- rhs = ":lsp_code_action",
		rhs = require("fzf-lua").code_action,
		mode = { "n", "v" },
		requires = method.textDocument_codeAction,
	},

	-- Rename
	{
		lhs = "<leader>Grn",
		desc = "Telescope: Rename (symbol)",
		rhs = vim.lsp.buf.rename,
		requires = method.textDocument_rename,
	},

	{
		lhs = "<leader>Grr",
		desc = "Telescope: Goto references",
		rhs = require("fzf-lua").lsp_references,
		requires = method.textDocument_references,
	},
	-- Type definition
	{
		lhs = "<leader>Grt",
		desc = "Telescope: Goto type definition",
		rhs = require("fzf-lua").lsp_type_definitions,
		requires = method.textDocument_typeDefinition,
	},

	-- Implementation
	{
		lhs = "<leader>Gri",
		desc = "Telescope: Goto implementation",
		rhs = require("fzf-lua").lsp_implementations,
		requires = method.textDocument_implementation,
	},

	-- Document symbols
	{
		lhs = "<leader>GO",
		desc = "Telescope: Document Symbols",
		rhs = require("fzf-lua").lsp_document_symbols,
		requires = method.textDocument_documentSymbol,
	},
}

return M
