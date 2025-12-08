local M = {}

local utils_keymap = require("utils.keymap")
local lsp_mappings = require("core.lsp.lsp_mappings").lsp_mappings

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

	utils_keymap.map(final_maps)

	if #unsupported > 0 then
		local lines = { ("LSP (%s) - Missing method(s):"):format(client.name) }

		for _, m in ipairs(unsupported) do
			table.insert(lines, (" [%s] %s"):format(m.lhs, m.desc or "(no desc)"))
		end

		vim.notify(table.concat(lines, "\n"), vim.log.levels.DEBUG)
	end
end

return M
