local M = {}

------------------------------------------------------
---> utils/icons.lua -> Icon table(s)
---------------------------------------

---ICONS: For completion-menu (nvim-cmp) rendering
M.cmp = {
	Text = "", -- nf-cod-text_size || alt: nf-cod-symbol_key: 
	Method = "", -- nf-cod-symbol_method
	Function = "󰡱", -- nf-md-function_variant
	Constructor = "", -- nf-cod-settings_gear
	Field = "", -- nf-cod_symbol_field
	Variable = "󰫧", --nf-md-variable || alt: nf-cod-symbol_variable: 
	Class = "", --nf-cod-symbol_class
	Interface = "", -- nf-cod-symbol_interface
	Module = "󰆧", -- nf-md-cube_outline
	Property = "", --nf-cod-tag || alt: nf-cod-symbol_property: 
	Unit = "", --nf-cod-symbol_ruler
	Value = "󰎠", --nf-cod-numeric || alt: nf-cod-symbol_numeric: 
	Enum = "", --nf-cod-symbol_enum
	Keyword = "", -- nf-cod-whole_word || alt: nf-cod-symbol_keyword: 
	Snippet = "", -- nf-cod-symbol_snippet || alt: nf-cod-file-code:   || alt2: nf-cod-code: 
	Color = "", --nf-cod-symbol_color || alt:
	File = "", --nf-cod-file
	Reference = "", -- nf-cod-link || alt: nf-cod-link_external: 
	Folder = "", -- nf-cod-new_folder
	EnumMember = "", -- nf-cod-symbol_enum_member || alt: nf-cod-list_ordered: 
	Constant = "", -- nf-cod-symbol_constant
	Struct = "", -- nf-cod-symbol_structure
	Event = "", --nf-cod-symbol_event
	Operator = "", --nf-cod-symbol_operator
	TypeParameter = "", --nf-cod-symbol_parameter
}

---ICONS: For diagnostic (dx) level
---ok|hint|info|warn|error
M.dx = {
	nf_md = {
		ok = "󰄬", --nf-md-check || alt: nf-fa-circle_check:   || nf-fa-square_check 
		hint = "󱒄", -- nf-md-laser_pointer || alt: nf-md-cursor_pointer: 󰆽  || alt2: nf-fa-hand_poiter 
		info = "󰙎", -- nf-md-information_variant || alt: nf-md-information_outline
		warn = "󰈅", -- nf-md-exclamation || alt: nf-md-bullet 󰳳 || alt2: nf-md-fuse 󰲅
		error = "󰆣", --nf-md-crosshairs || alt
	},
	nf_cod = {
		ok = "", --nf-cod-check || alt: nf-cod-pass 
		hint = "", --nf-cod-heart
		info = "", --nf-cod-info
		warn = "", --nf-cod-warn || alt: nf-cod-issues: 
		error = "", --nf-cod-error
	},
}

---ICONS: For filesystem
M.fs = {
	folder = "󰉋", --nf-md-folder
	folder_open = "󰝰", --nf-md-folder_open
	folder_check = "󱥾", --nf-md-folder_check
	folder_cog = "󱁿", --nf-md-folder_cog
	folder_marker = "󱉭", --nf-md-folder_marker
	folder_symlink = "󱧬", --nf-md-folder_arrow_left_right
	file = "󰈔", --nf-md-file
	file_edit = "󱇧", --nf-md-file_edit
	file_find = "󰈞", --nf-md-file_find
	file_link = "󱅷", --nf-md-file_link
	file_mark = "󱝴", --nf-md-file_marker
}

---ICONS: for git
M.git = {
	nf_fa_git = "",
	nf_dev_git = "",
	nf_dev_git_branch = "",
	nf_dev_git_commit = "",
	nf_cod = {
		added = "", --nf-cod-add
		modified = "", --nf-cod-edit
		removed = "", --nf-cod-remove || alt: nf-cod-close: 
		diff_added = "", --nf-cod-diff_added
		diff_modified = "", --nf-cod-diff_modified
		diff_removed = "", --nf-cod-diff_removed
	},
	nf_md = {
		added = "󰐕", --nf-md-plus
		removed = "󰍴", --nf-md-minus
		diff_added = "󰐖", --nf-md-plus_box
		diff_modified = "󰆖", --nf-md-contrast_box || alt: nf-md-approximately_equal_box: 󰾟
		diff_removed = "󰍵", --nf-md-minus_box
		git = "󰊢", --nf-md-git
	},
}

---ICONS: general
M.general = {
	search = "", --nf-fa-search
	search_alt = "", --nf-fa-search_plus
	caret_right = "", --nf-fa-caret_right
	caret_left = "", --nf-fa-caret_left
	caret_right_alt = "", --nf-fa-square_caret_right
	caret_left_alt = "", --nf-fa-square_caret_left
	arrow_right = "", --nf-fa-arrow_right
	arrow_left = "", --nf-fa-arrow_left
	arrow_right_alt = "", --nf-fa-arrow_circle_o_right
	arrow_left_alt = "", --nf-fa-arrow_circle_o_left
	target = "", --nf-fa-crosshairs
	clock = "", --nf-fa-clock
	neovim = "", --nf-linux-neovim
	ellipsis = "", --nf-fa-ellipsis
	ellipsis_alt = "", --nf-cod-ellipsis
	cog = "", --nf-fa-cog

	-- TODO: remove below when done...
	sep_round_left = "", -- TODO: remove! moved to M.ple = { ... }
	sep_round_right = "", -- TODO: remove! moved to M.ple = { ... }
	dir_root = "", -- TODO: remove! moved to M.fs = { ... }
	dir_active = "", -- TODO: remove! moved to M.fs = { ... }
}

---ICONS: For active LSP status and ft of active buf.
M.lsp = {
	bashls = "󱆃", --nf-md-bash || alt: nf-dev-bash: 
	lua_ls = "󰢱", -- nf-md-language_lua
	vtsls = { js = "", ts = "" }, -- nf-seti-java/typescript || alt: nf-md-language_java/typescript: 󰌞  󰛦
	ts_ls = { js = "", ts = "" }, -- nf-seti-java/typescript || same...
	cssls = "󰌜", -- nf-md-language_css3 || alt: nf-custom-css: 
	jsonls = "󰘦", --nf-md-code_json || alt: nf-seti-json: 
	yamlls = "", -- nf-dev-yaml
	csharp_ls = "󰌛", -- nf-md-language_csharp || alt: nf-dev-csharp: 
}

---ICONS: For powerline, e.g. 'lualine'-plugin.
M.ple = {
	round_left = "", --nf-ple-left_half_circle_thick
	round_right = "", --nf-ple-right_half_circle_thick
	round_thin_left = "", --nf-ple-left_half_circle_thin
	round_thin_right = "", --nf-ple-right_half_circle_thin
	lego_block = "", --nf-ple-lego_block_facing
	lego_block_side = "", --nf-ple-lego_block_sideways
	pixelated_squares = "", --nf-ple-pixelated_squares_big
	pixelated_squares_mirror = "", --nf-ple-pixelated_squares_big_mirrored
}

------------------------------------------------------
---> utils/icons.lua -> Type Annotations
---@class IconGetOpts
---@field pl? integer -- padding-left[pl]
---@field pr? integer --  padding-right[pr]
---@field p? integer  -- if set: used for both padding-left[pl]/right[pl]
---@field default? string -- fallback if icon is missing

---Internal padding helper
---@param s string
---@param opts IconGetOpts
---@return string
local function _apply_padding(s, opts)
	local p = opts.p or 0
	local pl = opts.pl or p or 0
	local pr = opts.pr or p or 0

	if pl > 0 then
		s = string.rep(" ", pl) .. s
	end

	if pr > 0 then
		s = s .. string.rep(" ", pr)
	end

	return s
end
-- end of test
-------------------------------------------------------------------
-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#basic-customisations
-- M.cmp_icons = {
-- 	Text = "",
-- 	Method = "󰆧",
-- 	Function = "󰊕",
-- 	Constructor = "",
-- 	Field = "󰇽",
-- 	Variable = "󰂡",
-- 	Class = "󰠱",
-- 	Interface = "",
-- 	Module = "",
-- 	Property = "󰜢",
-- 	Unit = "",
-- 	Value = "󰎠",
-- 	Enum = "",
-- 	Keyword = "󰌋",
-- 	Snippet = "",
-- 	Color = "󰏘",
-- 	File = "󰈙",
-- 	Reference = "",
-- 	Folder = "󰉋",
-- 	EnumMember = "",
-- 	Constant = "󰏿",
-- 	Struct = "",
-- 	Event = "",
-- 	Operator = "󰆕",
-- 	TypeParameter = "󰅲",
-- }

-- M.git = {
-- 	added = "", -- nf-cod-add
-- 	added_alt = "", --nf-fa-plus
-- 	modified = "", -- nf-cod-edit
-- 	modified_alt = "",
-- 	modified_tilde = "󰜥",
-- 	removed = "", -- nf-cod-chrome_close
-- 	removed_alt = "",
-- 	git = "", -- nf-dev-git
-- 	branch = "", -- nf-oct-git_branch
-- }

-- M.general = {
-- 	-- icons: nf-fa-*
-- 	search = "",
-- 	search_alt = "",
-- 	caret_right = "",
-- 	caret_right_alt = "",
-- 	caret_left = "",
-- 	caret_left_alt = "",
-- 	target = "󰓾",
-- 	clock = "",
-- 	neovim = "",
-- 	sep_round_left = "",
-- 	sep_round_right = "",
-- 	ellipsis = "",
-- 	cog = "",
-- 	dir_root = "",
-- 	dir_active = "",
-- }

-- M.diagnostics = {
-- 	debug = "",
-- 	error = "",
-- 	error_alt = "󰯷",
-- 	warn = "",
-- 	warn_alt = "󰰭",
-- 	info = "",
-- 	info_alt = "󰰃",
-- 	hint = "",
-- 	hint_alt = "󰰀",
-- }

-- M.lsp_lng = {
-- 	bashls = "󱆃", --nf-md-bash
-- 	lua_ls = "󰢱", -- nf-md-language_lua
-- 	vtsls = { js = "", ts = "" }, -- nf-seti-java/typescript
-- 	ts_ls = { js = "", ts = "" }, -- nf-seti-java/typescript
-- 	cssls = "󰌜", -- nf-md-language_css3
-- 	jsonls = "", -- nf-seti-json
-- 	yamlls = "", -- nf-dev-yaml
-- 	csharp_ls = "󰌛", -- nf-md-language_csharp
-- }

------------------------------------------------------
---> utils/icons.lua -> Type Annotations
------@alias PadMode '"none"'|'"left"'|'"right"'|'"both"'|
------@alias PadOpt boolean|PadMode|string|integer|{ left?: string, right?: string }
---
------@class IconOpts
------@field pad? PadOpt
------@field pad_char? string
------@field fail? string
------@field silent? boolean
---
---------------------------------------------------------
------> utils/icons.lua -> Icon API - default opts
---local _defaults = {
---	pad = "both", -- "none" | "left" | "right" | "both" | true/false
---	pad_char = " ", -- standard padding token
---	fail_icon = "󱈸", -- default fallback - if req fails
---}
---
---------------------------------------------------------
------> utils/icons.lua -> Icon API - padding resolver
------@param opt PadOpt|nil
------@param char string|nil
------@return string left
------@return string right
---local function _res_pad(opt, char)
---	char = char or _defaults.pad_char
---
---	if opt == nil or opt == true or opt == "both" then
---		return char, char
---	end
---
---	if opt == false or opt == "none" then
---		return "", ""
---	end
---
---	if opt == "left" then
---		return char, ""
---	end
---
---	if opt == "right" then
---		return "", char
---	end
---
---	local t = type(opt)
---
---	if t == "number" then
---		local s = string.rep(char, opt)
---		return s, s
---	end
---
---	if t == "table" then
---		---@cast opt table
---		return opt.left or "", opt.right or ""
---	end
---
---	if t == "string" then
---		---@cast opt string
---		return opt, opt
---	end
---	return "", ""
---end
---
---------------------------------------------------------
------> utils/icons.lua -> Icon API with padding, or not.
---
------@param tbl string|table<string, any>
------@param key string
------@param opts? IconOpts
------@return string
---function M.get_icon(tbl, key, opts)
---	opts = opts or {}
---
---	local t = type(tbl) == "table" and tbl or M[tbl]
---
---	if type(t) ~= "table" then
---		return (opts.fail or _defaults.fail_ic)
---	end
---
---	local ic = t[key] or (opts.fail or _defaults.fail_ic)
---	local l, r = _res_pad(opts.pad or _defaults.pad, opts.pad_char or _defaults.pad_char)
---	return l .. ic .. r
---end
---
---------------------------------------------------------
------> utils/icons.lua -> Icon-table API with padding, or not.
---
----- Can be used to "rename" icons @ import to match plugin-names of icons
------@param tbl string|table
------@param map table<string,string> -- external_key -> internal_key
------@param opts? IconOpts
------@return table<string,string>
---function M.remap_icons(tbl, map, opts)
---	local t = type(tbl) == "table" and tbl or M[tbl]
---	local out = {}
---
---	for ext, internal in pairs(map) do
---		out[ext] = M.get_icon(t, internal, opts)
---	end
---
---	return out
---end
---
----- Return shallow-copy of IC-tbl
------@param tbl string|table
------@param opts? IconOpts
------@return table
---function M.get_icon_tbl(tbl, opts)
---	local t = type(tbl) == "table" and tbl or M[tbl]
---	local out = {}
---
---	for k, v in pairs(t) do
---		if type(v) == "string" then
---			out[k] = M.get_icon(t, k, opts)
---		else
---			out[k] = v
---		end
---	end
---	return out
---end
---
----- TODO: change to ??
-----> make module directly callable:e.g. >> `icons("git", "branch", {pad="left"})`
---setmetatable(M, {
---	__call = function(_, tbl, key, opts)
---		return M.get_icon(tbl, key, opts)
---	end,
---})
---
---return M
