local M = {}
---@alias IconString string

---@class IconTable
---@field [string] IconString | table<string,any>

---@class IconsRoot
---@field fs IconTable
---@field git IconTable
---@field cmp IconTable
---@field dx IconTable
---@field lsp IconTable
------------------------------------------------------
---> utils/icons.lua -> Icon table(s)
---------------------------------------

---ICONS: For completion-menu (nvim-cmp) rendering
---@type IconTable
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

---ICONS: For diagnostic(dx) levels: ok|hint|info|warn|error
---@type IconTable
M.dx = {
	shapes = {
		circle = "󰧞", --nf-md-circle_medium
		square = "󰨓", --nf-md-square_medium
		circle_arrow = "󰁗", --nf-md-arrow_right_bold_circle_outline
		box_arrow = "󰜶", --nf-md-arrow_right_bold_box_outline
		bold_arrow = "󰜴", --nf-md-arrow_right_bold
		norm_arrow = "󰁔", --nf-md-arrow_right
	},
	nf_md = {
		OK = "󰄬", --nf-md-check || alt: nf-fa-circle_check:   || nf-fa-square_check 
		HINT = "󱒄", -- nf-md-laser_pointer || alt: nf-md-cursor_pointer: 󰆽  || alt2: nf-fa-hand_poiter 
		INFO = "󰙎", -- nf-md-information_variant || alt: nf-md-information_outline
		WARN = "󰈅", -- nf-md-exclamation || alt: nf-md-bullet 󰳳 || alt2: nf-md-fuse 󰲅
		ERROR = "󰆣", --nf-md-crosshairs || alt
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
---@type IconTable
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

---ICONS: For git
---@type IconTable
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

---ICONS: For general|random|lonely usage
---@type IconTable
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
	location = "", --nf-fa-location_dot
	location_alt = "", --nf-fa-location_pin
	location_arrow = "", --nf-fa-location_arrow
}

---ICONS: For LSP status and ft of active buf.
---@type IconTable
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
---@type IconTable
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
---@class IconOpts
---@field pl? integer -- padding-left
---@field pr? integer --  padding-right
---@field p? integer  -- if set: used for both padding-left[pl]/right[pl]
---@field fail? string -- fallback if icon is missing

---------------------------------------------------------------------

local _defaults = {
	pad_char = " ", -- standard padding token, whitespace.
	fail_icon = "󱈸", -- default fallback - if req fails to return requested icon.
}

---Internal helper: used to apply padding to icon(s)
---set padding value with left-side: pl | right-side: pr | both: p
---@param s string
---@param opts IconOpts
---@return string
local function _apply_padding(s, opts)
	-- opts = opts or {}
	if not opts then
		return s
	end

	local pad = opts.p or 0
	local pl = opts.pl or pad or 0
	local pr = opts.pr or pad or 0
	local ch = _defaults.pad_char

	if pl <= 0 and pr <= 0 then
		return s
	end

	if pl > 0 then
		s = string.rep(ch, pl) .. s
	end

	if pr > 0 then
		s = s .. string.rep(ch, pr)
	end

	return s
end

---Internal helper: resolve table argument
---  table -> used direct
---  "dx" -> M.dx
--- "dx.nf_md" -> M.dx.nf_md
---@param tbl string|IconTable
---@return IconTable|nil
local function _resolve_tbl(tbl)
	if type(tbl) == "table" then
		return tbl
	end

	if type(tbl) == "string" then
		--dot-path?
		if tbl:find("%.") then
			local t = M
			for part in string.gmatch(tbl, "[^%.]+") do
				if type(t) ~= "table" then
					return nil
				end
				t = t[part]
			end
			return t
		end

		return M[tbl]
	end
	return nil
end

---------------------------------------------
---Get ONE(1) icon from group-table.
---`table` can be either:
---  * one string that refers to M[tbl] (e.g. "git" -> M.git)
---  * one direct `tbl` (e.g. M.git.nf_cod)
---e.g. usage:
---   M.get("git", "nf_cod", "added", { pr = 1})
---
---@param tbl string|IconTable
---@param key string
---@param opts? IconOpts
---@return string
function M.get_icon(tbl, key, opts)
	opts = opts or {}

	-- local t = type(tbl) == "table" and tbl or M[tbl]
	-- if type(t) ~= "table" then
	-- 	return opts.fail or _defaults.fail_icon
	-- end

	local t = _resolve_tbl(tbl)
	if type(t) ~= "table" then
		return opts.fail or _defaults.fail_icon
	end

	local ic = t[key]
	if type(ic) ~= "string" then
		ic = opts.fail or _defaults.fail_icon
	end
	-- local ic = t[key] or opts.fail or _defaults.fail_icon

	return _apply_padding(ic, opts)
end

-----Remap (rename) icons from internal key --> external key
----Suited for plugin-API that requires other icon names, e.g. usage:
---
---  local map = {
---    added = "diff_added",
---    modified = "diff_modified",
---    removed = "diff_removed",
---  }
---  local symbols = M.remap_icons(M.git.nf_cod, map, { pr = 1})
---
---@param tbl string|IconTable
---@param map table<string,string> -- external_key -> internal_key
---@param opts? IconOpts
---@return table<string,string>
function M.remap_icons(tbl, map, opts)
	-- local t = type(tbl) == "table" and tbl or M[tbl]
	local t = _resolve_tbl(tbl)
	local out = {}

	if type(t) ~= "table" then
		return out
	end

	for ext, internal in pairs(map) do
		out[ext] = M.get_icon(t, internal, opts)
	end

	return out
end

--- Return shallow-copy of icon-tbl with padding applied, e.g. usage:
---
--- local git_cod = M.get_icon_tbl(M.git.nf_cod, { pr =1})
--- -- git_cod.added, git_cod.modified, ...
---
---@param tbl string|IconTable
---@param opts? IconOpts
---@return table<string,string|any>
function M.get_icon_tbl(tbl, opts)
	opts = opts or {}
	-- local t = type(tbl) == "table" and tbl or M[tbl]
	local t = _resolve_tbl(tbl)
	local out = {}

	if type(t) ~= "table" then
		return out
	end

	for k, v in pairs(t) do
		if type(v) == "string" then
			out[k] = _apply_padding(v, opts)
		else
			out[k] = v
		end
	end

	return out
end

return M
