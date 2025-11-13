local M = {}

------------------------------------------------------
---> utils/icons.lua -> Icon table(s)

-----------------------------------------
---NF_ICONS: table with all icons for direct use, or thru function to add padding.
---------------------------------------
M.git = {
	added = "", -- nf-cod-add
	added_alt = "", --nf-fa-plus
	modified = "", -- nf-cod-edit
	modified_alt = "",
	modified_tilde = "󰜥",
	removed = "", -- nf-cod-chrome_close
	removed_alt = "",
	git = "", -- nf-dev-git
	branch = "", -- nf-oct-git_branch
}

-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#basic-customisations
M.cmp_icons = {
	Text = "",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "",
	Field = "󰇽",
	Variable = "󰂡",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰅲",
}

M.general = {
	-- icons: nf-fa-*
	search = "",
	search_alt = "",
	caret_right = "",
	caret_right_alt = "",
	caret_left = "",
	caret_left_alt = "",
	target = "󰓾",
	clock = "",
	neovim = "",
	sep_round_left = "",
	sep_round_right = "",
	ellipsis = "",
	cog = "",
	dir_root = "",
	dir_active = "",
}

M.diagnostics = {

	debug = "",
	error = "",
	error_alt = "󰯷",
	warn = "",
	warn_alt = "󰰭",
	info = "",
	info_alt = "󰰃",
	hint = "",
	hint_alt = "󰰀",
}

M.lsp_lng = {
	bashls = "󱆃", --nf-md-bash
	lua_ls = "󰢱", -- nf-md-language_lua
	vtsls = { js = "", ts = "" }, -- nf-seti-java/typescript
	ts_ls = { js = "", ts = "" }, -- nf-seti-java/typescript
	cssls = "󰌜", -- nf-md-language_css3
	jsonls = "", -- nf-seti-json
	yamlls = "", -- nf-dev-yaml
	csharp_ls = "󰌛", -- nf-md-language_csharp
}

------------------------------------------------------
---> utils/icons.lua -> Type Annotations
---@alias PadMode '"none"'|'"left"'|'"right"'|'"both"'|
---@alias PadOpt boolean|PadMode|string|integer|{ left?: string, right?: string }

---@class IconOpts
---@field pad? PadOpt
---@field pad_char? string
---@field fail? string
---@field silent? boolean

------------------------------------------------------
---> utils/icons.lua -> Icon API - default opts
local _defaults = {
	pad = "both", -- "none" | "left" | "right" | "both" | true/false
	pad_char = " ", -- standard padding token
	fail_icon = "󱈸", -- default fallback - if req fails
}

------------------------------------------------------
---> utils/icons.lua -> Icon API - padding resolver
---@param opt PadOpt|nil
---@param char string|nil
---@return string left
---@return string right
local function _res_pad(opt, char)
	char = char or _defaults.pad_char

	if opt == nil or opt == true or opt == "both" then
		return char, char
	end

	if opt == false or opt == "none" then
		return "", ""
	end

	if opt == "left" then
		return char, ""
	end

	if opt == "right" then
		return "", char
	end

	local t = type(opt)

	if t == "number" then
		local s = string.rep(char, opt)
		return s, s
	end

	if t == "table" then
		---@cast opt table
		return opt.left or "", opt.right or ""
	end

	if t == "string" then
		---@cast opt string
		return opt, opt
	end
	return "", ""
end

------------------------------------------------------
---> utils/icons.lua -> Icon API with padding, or not.

---@param tbl string|table<string, any>
---@param key string
---@param opts? IconOpts
---@return string
function M.get_icon(tbl, key, opts)
	opts = opts or {}

	local t = type(tbl) == "table" and tbl or M[tbl]

	if type(t) ~= "table" then
		return (opts.fail or _defaults.fail_ic)
	end

	local ic = t[key] or (opts.fail or _defaults.fail_ic)
	local l, r = _res_pad(opts.pad or _defaults.pad, opts.pad_char or _defaults.pad_char)
	return l .. ic .. r
end

------------------------------------------------------
---> utils/icons.lua -> Icon-table API with padding, or not.

-- Can be used to "rename" icons @ import to match plugin-names of icons
---@param tbl string|table
---@param map table<string,string> -- external_key -> internal_key
---@param opts? IconOpts
---@return table<string,string>
function M.remap_icons(tbl, map, opts)
	local t = type(tbl) == "table" and tbl or M[tbl]
	local out = {}

	for ext, internal in pairs(map) do
		out[ext] = M.get_icon(t, internal, opts)
	end

	return out
end

-- Return shallow-copy of IC-tbl
---@param tbl string|table
---@param opts? IconOpts
---@return table
function M.get_icon_tbl(tbl, opts)
	local t = type(tbl) == "table" and tbl or M[tbl]
	local out = {}

	for k, v in pairs(t) do
		if type(v) == "string" then
			out[k] = M.get_icon(t, k, opts)
		else
			out[k] = v
		end
	end
	return out
end

-- TODO: change to ??
--> make module directly callable:e.g. >> `icons("git", "branch", {pad="left"})`
setmetatable(M, {
	__call = function(_, tbl, key, opts)
		return M.get_icon(tbl, key, opts)
	end,
})

return M
