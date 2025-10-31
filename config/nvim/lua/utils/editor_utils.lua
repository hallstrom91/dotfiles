local M = {}

-- ===== Helpers ===== --

local DEFAULT_IC_LSP = "" -- nf-fa-cog
local DEFAULT_IC_DIR = "" -- nf-cod-root_folder

----> active lsp in cur buf for lualine
local LSP_IC = {
	bashls = "󱆃", --nf-md-bash
	lua_ls = "󰢱", -- nf-md-language_lua
	vtsls = { js = "", ts = "" }, -- nf-seti-java/typescript
	ts_ls = { js = "", ts = "" }, -- nf-seti-java/typescript
	cssls = "󰌜", -- nf-md-language_css3
	jsonls = "", -- nf-seti-json
	yamlls = "", -- nf-dev-yaml
	csharp_ls = "󰌛", -- nf-md-language_csharp
}

-- ignore opts - if any are used
local IGNORE = {
	["eslint"] = true,
	["copilot"] = true,
	["null-ls"] = true,
}

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
-- find icon for active buf lsp
local function icon_for(client_name, bufnr)
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

local function by_priority(a, b)
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

local function uri_to_path(uri)
	if type(uri) ~= "string" then
		return nil
	end

	if uri:sub(1, 7) == "file://" then
		return vim.uri_from_fname(uri)
	end

	return uri
end

local function normalize_ws_entry(ws)
	if type(ws) == "table" then
		return (uri_to_path(ws.uri) or ws.name or "")
	end
	return uri_to_path(ws) or ""
end

local function fmt_path(p)
	if not p or p == "" then
		return ""
	end
	-- ~shortpath
	p = vim.fn.fnamemodify(p, ":~")

	if vim.fn.strdisplaywidth(p) > 40 then
		p = vim.fn.pathshorten(p)
	end
	return p
end

-- ===== show active `lsp client workspace/rootdir` -- =====
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

	table.sort(filter, by_priority)
	local client = filter[1]

	-- get rootdir
	local root = client.root_dir or (client.config and client.config.root_dir) or ""

	-- gather ws_dirs
	local ws_list = {}
	local seen = {}
	local folders = client.workspace_folders or (client.config and client.config.workspace_folders) or {}
	for _, ws in ipairs(folders) do
		local p = normalize_ws_entry(ws)
		if p ~= "" and not seen[p] then
			seen[p] = true
			table.insert(ws_list, p)
		end
	end

	local display_root = root ~= "" and root or ws_list[1] or ""
	local extras = 0
	if display_root ~= "" then
		-- how many others?
		for _, p in ipairs(ws_list) do
			if p ~= display_root then
				extras = extras + 1
			end
		end
	elseif #ws_list > 1 then
		-- no root, but extras
		display_root = ws_list[1]
		extras = #ws_list - 1
	end

	if display_root == "" then
		-- last fallback, show only client-name
		return string.format("%s %s", DEFAULT_IC_DIR, client.name)
	end

	local path_str = fmt_path(display_root)
	local plus = extras > 0 and (" (+" .. extras .. ")") or ""

	-- output e.g. " ~/src/active-buf-lsp_ws (+3)"
	return string.format("%s %s%s", DEFAULT_IC_DIR, path_str, plus)
end

-- ===== show active `lsp clients` in current buf ===== --
function M.lsp_clients()
	if not (vim.lsp and vim.lsp.get_clients) then
		return "LSP: none"
	end

	-- `true` to hide
	local ignore = {
		["null-ls"] = false,
		["copilot"] = false,
		-- ["eslint"] = false,
	}

	local function unique_names(clients)
		local seen = {}
		local names = {}

		for _, c in ipairs(clients or {}) do
			local name = c.name
			if name and not seen[name] and not ignore[name] then
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
	local icon = icon_for(primary, 0)

	return ("%s %s%s"):format(icon, primary, (others > 0) and (" (+" .. others .. ")") or "")
	-- return ("LSP: %s%s"):format(primary, (others > 0) and (" (+" .. others .. ")") or "")
end

function M.clock()
	return os.date("%H:%M:%S")
end

--
-- -- TEST: display active WS for LSP (lualine)
-- function M.lsp_active_workspace()
-- 	local bufnr = vim.api.nvim_get_current_buf()
-- 	local clients = vim.lsp.get_clients({ bufnr = bufnr })
--
-- 	if #clients == 0 then
-- 		return
-- 	end
--
-- 	for _, client in ipairs(clients) do
-- 		local root = client.config.root_dir or ""
-- 		local workspaces = client.config.workspace_folders or {}
-- 		local folders = {}
--
-- 		for _, ws in ipairs(workspaces) do
-- 			folders[#folders + 1] = ws.name or ws.uri or ws
-- 		end
--
-- 		local msg = {
-- 			("LSP: %s (id: %d)"):format(client.name, client.id),
-- 			(" ws: %s"):format(root),
-- 		}
-- 	end
-- end

return M
