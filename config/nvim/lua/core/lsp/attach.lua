local M = {}
-- local utils_keymap = require("utils.keymap")
local method = vim.lsp.protocol.Methods
--@class KjsLspMap : KjsKeymap

---telescope
function M.lsp_maps_telescope()
	local ok = pcall(require, "telescope.builtin")
	if not ok then
		return
	end

	return {
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
end

---fzf-lua
function M.lsp_maps_fzflua()
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		return
	end

	return {
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
			desc = "fzf-lua: Code Action",
			rhs = fzf.code_action,
			mode = { "n", "v" },
			requires = method.textDocument_codeAction,
		},

		-- Rename
		{
			lhs = "<leader>Grn",
			desc = "fzf-lua: Rename (symbol)",
			rhs = vim.lsp.buf.rename,
			requires = method.textDocument_rename,
		},
		-- References
		{
			lhs = "<leader>Grr",
			desc = "fzf-lua: Goto references",
			rhs = fzf.lsp_references,
			requires = method.textDocument_references,
		},
		{
			lhs = "<leader>Gd",
			desc = "fzf-lua: Goto definition",
			rhs = fzf.lsp_definitions,
			requires = method.textDocument_references,
		},
		-- Type definition
		{
			lhs = "<leader>Grt",
			desc = "fzf-lua: Goto type definition",
			rhs = fzf.lsp_typedefs,
			requires = method.textDocument_typeDefinition,
		},

		-- Implementation
		{
			lhs = "<leader>Gri",
			desc = "fzf-lua: Goto implementation",
			rhs = fzf.lsp_implementations,
			requires = method.textDocument_implementation,
		},

		-- Document symbols
		{
			lhs = "<leader>GO",
			desc = "fzf-lua: Document Symbols",
			rhs = fzf.lsp_document_symbols,
			requires = method.textDocument_documentSymbol,
		},
	}
end

------------------------------------------------
---Track buffer cache for keymaps, for lspdetach event & removal.
-- [bufnr] = { [mode] = { [lhs] = true} }
local _buf_maps = {}

---Internal helper: register (buf) attached keymaps
---@param bufnr integer
---@param mode string|string[]
---@param lhs string
local function _register_buf_map(bufnr, mode, lhs)
	_buf_maps[bufnr] = _buf_maps[bufnr] or {}
	_buf_maps[bufnr][mode] = _buf_maps[bufnr][mode] or {}
	_buf_maps[bufnr][mode][lhs] = true
end

------------------------------------------------
---DEBUG HELPER: print all attached buf-keymaps.
---@param bufnr? integer
function M.debug_buf_maps(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	vim.print({
		bufnr = bufnr,
		maps = _buf_maps[bufnr],
	})
end

------------------------------------------------
---@param bufnr? integer
function M.clear_lsp_buf_maps(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local reg = _buf_maps[bufnr]
	if not reg then
		return
	end

	for mode, lhs_tbl in pairs(reg) do
		for lhs, _ in pairs(lhs_tbl) do
			pcall(vim.keymap.del, mode, lhs, { buffer = bufnr })
		end
	end
	_buf_maps[bufnr] = nil
end

------------------------------------------------
--- Helper: Does client support method?
---@param client vim.lsp.Client
---@param req vim.lsp.protocol.Method|string
---@param bufnr? integer
---@return boolean
local function _supports(client, req, bufnr)
	if not req then
		return true
	end

	if type(req) == "string" then
		return client:supports_method(req, bufnr)
	end

	-- list of methods
	for _, m in ipairs(req) do
		if client:supports_method(m, bufnr) then
			return true
		end
	end
	return false
end

------------------------------------------------
---Default LSP-bufmaps
---@param client vim.lsp.Client
---@param bufnr? integer
function M.lsp_buf_maps(client, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	-- local lsp_mappings = require("core.lsp.lsp_mappings").lsp_mappings
	local lsp_mappings = M.lsp_maps_fzflua()
	if not lsp_mappings then
		return
	end

	local final_maps = {}

	---@type {lhs:string, desc:string|nil, requires:vim.lsp.protocol.Method|string|string[]|nil}[]
	local unsupported = {}

	for _, map in ipairs(lsp_mappings) do
		if _supports(client, map.requires, bufnr) then
			local m = vim.tbl_deep_extend("force", {}, map)
			m.buffer = bufnr

			table.insert(final_maps, m)

			local mode = m.mode or "n"
			local modes = type(mode) == "table" and mode or { mode }

			for _, md in ipairs(modes) do
				_register_buf_map(bufnr, md, m.lhs)
			end
		else
			table.insert(unsupported, map)
		end
	end

	require("utils.keymap").map(final_maps)

	-- utils_keymap.map(final_maps)

	if #unsupported > 0 then
		local lines = { ("LSP (%s) - Missing method(s):"):format(client.name) }

		for _, m in ipairs(unsupported) do
			table.insert(lines, (" [%s] %s"):format(m.lhs, m.desc or "(no desc)"))
		end

		vim.notify(table.concat(lines, "\n"), vim.log.levels.DEBUG)
	end
end

return M
