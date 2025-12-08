local M = {}

local path = require("utils.path")
local icons = require("utils.icons")

local DEFAULT_IC_LSP = icons.get_icon("general", "cog", { pr = 1 })
local DEFAULT_IC_DIR = icons.get_icon("fs", "folder_marker", { pr = 1 })
local LSP_IC = icons.get_icon_tbl("lsp", { pr = 1 })

--> find icon for active buf lsp
local function _icon_for(client_name, bufnr)
	local entry = LSP_IC[client_name]
	if not entry then
		return DEFAULT_IC_LSP
	end

	if type(entry) == "table" then
		local ft = vim.bo[bufnr or 0].filetype or ""
		if ft:find("^typescript") then
			return entry.ts
		end
		if ft:find("^javascript") then
			return entry.js
		end
		return entry.ts or entry.js or DEFAULT_IC_LSP
	end
	return entry
end

-- ===== Helpers: Priority ===== --

local PRIORITY = {
	"vtsls",
	"ts_ls",
	"lua_ls",
	"bashls",
	"cssls",
	"jsonls",
	"yamlls",
	"html",
	"csharp_ls",
}

--> show by priority
local function _by_priority(a, b)
	local pos = {}
	for i, name in ipairs(PRIORITY) do
		pos[name] = i
	end
	local ia = pos[a.name] or 999
	local ib = pos[b.name] or 999
	if ia == ib then
		return a.name < b.name
	end
	return ia < ib
end

-- ===== Helpers: Uri  ===== --
--> uri to path
local function _uri_to_path(uri)
	if type(uri) ~= "string" or uri == "" then
		return ""
	end
	if uri:sub(1, 7) == "file://" then
		return vim.uri_to_fname(uri) -- uri -> path
	end
	return uri
end

-- ===== Helpers: WS ===== --

--> normalize ws
local function _normalize_ws_entry(ws)
	if type(ws) == "table" then
		-- some lsp send { uri=..., name=... }
		return _uri_to_path(ws.uri) ~= "" and _uri_to_path(ws.uri) or (ws.name or "")
	end
	return _uri_to_path(ws)
end

-- ===== Helpers: Ignore  ===== --
local IGNORE = {
	["eslint"] = true,
	["copilot"] = true,
	["null-ls"] = true,
}

-- ====================================================== --
-- ===== show active `lsp client workspace/rootdir` ===== --
function M.lsp_active_workspace()
	if not (vim.lsp and vim.lsp.get_clients) then
		return "" -- nothing to show
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if #clients == 0 then
		return "" -- no lsp attached to buf
	end

	-- filter ignored
	local filter = {}
	for _, c in ipairs(clients) do
		if not IGNORE[c.name] then
			table.insert(filter, c)
		end
	end
	if #filter == 0 then
		return "" -- all ignored
	end

	table.sort(filter, _by_priority)
	local client = filter[1]

	-- get rootdir
	local raw_root = client.root_dir or (client.config and client.config.root_dir) or ""
	local root = path.norm(raw_root) or ""

	local ws_list = {}
	local seen = {}
	local folders = client.workspace_folders or (client.config and client.config.workspace_folders) or {}
	for _, ws in ipairs(folders) do
		local p = path.norm(_normalize_ws_entry(ws) or "")
		-- local p = _normalize_ws_entry(ws)
		if p and p ~= "" and not seen[p] then
			seen[p] = true
			table.insert(ws_list, p)
		end
	end

	local display_root = root ~= "" and root or (ws_list[1] or "")
	if display_root == "" then
		return string.format("%s %s", DEFAULT_IC_DIR, client.name)
	end

	local extra = 0
	for _, p in ipairs(ws_list) do
		if p ~= display_root then
			extra = extra + 1
		end
	end

	local p_str = path.fmt_path(display_root, { shorten_width = 40 })
	local plus = (extra > 0) and (" (+" .. extra .. ")") or ""
	return string.format("%s %s%s", DEFAULT_IC_DIR, p_str, plus)
end

-- ==================================================== --
-- ===== show active `lsp clients` in current buf ===== --
function M.lsp_clients()
	if not (vim.lsp and vim.lsp.get_clients) then
		return "LSP: none"
	end

	local function unique_names(clients)
		local seen = {}
		local names = {}

		for _, c in ipairs(clients or {}) do
			local name = c.name
			if name and not seen[name] and not IGNORE[name] then
				seen[name] = true
				names[#names + 1] = name
			end
		end
		table.sort(names)
		return names, seen
	end

	local buf_names, buf_seen = unique_names(vim.lsp.get_clients({ bufnr = 0 }))
	local all_names = unique_names(vim.lsp.get_clients())

	-- no lsp active at all
	if #buf_names == 0 and #all_names == 0 then
		return "LSP: none"
	end

	-- count 'other' unique clients (not connect to cur buf)
	local others = 0
	for _, name in ipairs(all_names) do
		if not buf_seen[name] then
			others = others + 1
		end
	end

	-- no lsp in buf, but global
	if #buf_names == 0 then
		return ("LSP: -%s"):format(others > 0 and (" (+" .. others .. ")") or "")
	end

	local primary = buf_names[1]
	local icon = _icon_for(primary, 0)

	return ("%s %s%s"):format(icon, primary, (others > 0) and (" (+" .. others .. ")") or "")
end

return M
