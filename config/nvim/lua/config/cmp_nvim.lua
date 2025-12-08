local M = {}
local utils_c = require("utils.color")
local utils_hl = require("utils.highlight")

local _cache_cmpkind_hl = {} -- add clear option (2 autocmd also)
------------------------------------------------------------
---Internal helper: enable luadoc's annotations completion in commentrow (only in ft=lua)
----@return boolean
-- local function _lua_doc_comment()
-- 	if vim.bo.filetype ~= "lua" then
-- 		return false
-- 	end
--
-- 	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
-- 	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
-- 	local before = line:sub(1, col + 1) -- col = 0-base
--
-- 	local s = before:find("%-%-+")
-- 	if not s then
-- 		return false
-- 	end
--
-- 	local comment = before:sub(s)
--
-- 	-- allow completion in commentline if syntax is:
-- 	-- '---@'
-- 	-- or
-- 	-- '---'
-- 	if comment:match("^%-%-%-@") then
-- 		return true
-- 	end
--
-- 	if comment:match("^%-%-%-%s") then
-- 		return true
-- 	end
--
-- 	return false -- default: disable completion in comment
-- end

---------------------------------------------------------------------
--- ENABLED: disable 'nvim-cmp' based on buftype/ft/comment
---@param context table -- module from `require("cmp.config.context)`
---@return boolean
function M.enabled(context)
	if vim.bo.buftype == "prompt" then
		return false
	end

	if vim.bo.filetype == "TelescopePrompt" then
		return false
	end

	if context.in_treesitter_capture("comment") or context.in_syntax_group("Comment") then
		return false
	end

	return true -- default: allow completion
end

-- internal helper function
local function _fallback_kind_fg_hex()
	local info = utils_hl.get_hl_with_hex("CmpItemKind", { use_cache = true })
	return info.fg_hex or "#5e81ac" -- TODO: add "global value as fg_hex fallback?"
end

-----------------------------------------------------
-- SOFT_PMENU_SEL: custom 'PmenuSel' highlight group to match current active theme: maybe?
---@param name? string -- name for new hl-group
---@param alpha? number -- Value 0.0 -> 1.0
function M.soft_pmenu_sel(name, alpha)
	name = name or "CmpSelSoft"
	alpha = tonumber(alpha) or 0.6

	local pmenu = utils_hl.get_hl_with_hex("Pmenu", { use_cache = true })
	local pmenu_sel = utils_hl.get_hl_with_hex("PmenuSel", { use_cache = true })
	local normal = utils_hl.get_hl_with_hex("NormalFloat", { use_cache = true })
	if not normal.bg_hex then
		normal = utils_hl.get_hl_with_hex("Normal", { use_cache = true })
	end

	local bg_menu = pmenu.bg_hex or normal.bg_hex

	local bg_sel = pmenu_sel.bg_hex or pmenu.bg_hex or normal.bg_hex

	local fg_sel = pmenu_sel.fg_hex or pmenu.fg_hex or "#f5f5f5"

	if not bg_menu or not bg_sel then
		return
	end

	local soft_bg = utils_c.blend(bg_sel, bg_menu, alpha)

	vim.api.nvim_set_hl(
		0,
		name,
		{ bg = soft_bg, fg = fg_sel, bold = pmenu_sel.bold or false, italic = pmenu_sel.italic or false }
	)
end

----------------------------------------------------
---CMPKIND_HL_BOX: custom highlight of completion item(s) based on current theme
---@param kind string
---@return string group_name
function M.cmpkind_hl_box(kind)
	if _cache_cmpkind_hl[kind] then
		return _cache_cmpkind_hl[kind]
	end

	local src = ("CmpItemKind%s"):format(kind)
	local src_hl = utils_hl.get_hl_with_hex(src, { use_cache = true })

	local fg_hex = src_hl.fg_hex or _fallback_kind_fg_hex()
	local bg_hex = fg_hex
	local txt_hex = (utils_c.luma(bg_hex) > 0.5) and "#1a1a1a" or "#f5f5f5"

	local group = ("CmpItemKind%sBox"):format(kind)
	vim.api.nvim_set_hl(0, group, { bg = bg_hex, fg = txt_hex, bold = true })

	_cache_cmpkind_hl[kind] = group
	return group
end

-- TRUNCATE_LABEL: Function to truncate text to min/max-width
-- TODO: move to utils/??.lua
---@param label string
---@param opts? {ellipsis_char?: string, max_w?: integer, min_w: integer}
---@return string
M.truncate_label = function(label, opts)
	if type(label) ~= "string" then
		vim.notify(("truncate_label(): expected string, got: %s"):format(type(label)), vim.log.levels.WARN)
		return ""
	end
	opts = opts or {}

	local ellipsis = opts.ellipsis_char or "..."
	local max_w = tonumber(opts.max_w) or 30
	local min_w = tonumber(opts.min_w) or 20

	local display_w = vim.fn.strdisplaywidth(label)

	if display_w > max_w then
		local cut = vim.fn.strcharpart(label, 0, max_w - vim.fn.strdisplaywidth(ellipsis))
		return cut .. ellipsis
	end

	if display_w < min_w then
		return label .. string.rep(" ", min_w - display_w)
	end

	return label
end

------------------------------------------------------
-- FMT_MENU: custom function to change UI in nvim-cmp for completion
M.fmt_menu = function(entry, item)
	local icons = require("utils.icons").get_icon
	local kind_box = M.cmpkind_hl_box
	local trunc = M.truncate_label

	local kind = item.kind
	local icon = icons("cmp", kind, { fail = "" })

	-- `kind`: highlighted (bg) box -> left column
	local box = (" %s %s "):format(icon, kind)
	local trunc_kind = trunc(box, { max_w = 15, min_w = 15, ellipsis_char = "" })
	item.kind = trunc_kind
	item.kind_hl_group = kind_box(kind)

	-- `abbr`: search -> suggestions -> center column
	local abbr = item.abbr
	local trunc_abbr = trunc(abbr, { max_w = 30, min_w = 30, ellipsis_char = "..." })
	item.abbr = ("%s "):format(trunc_abbr)

	--> `menu`: show completion from what [SRC] -> right column
	local src = entry.source.name
	local menu_src = ({
		nvim_lsp = "[LSP]",
		luasnip = "[SNIP]",
		path = "[PATH]",
		buffer = "[BUF]",
		["css-variables"] = "[CSS]",
	})[src] or src

	item.menu = ("[ %s ]").format(menu_src)
	if src == "nvim_lsp" then
		item.menu_hl_group = ("CmpItemKind%s"):format(kind)
	elseif src == "luasnip" then
		item.menu_hl_group = "Comment" -- or something else ? TODO: remove italic
	else
		item.menu_hl_group = "CmpItemMenu"
	end

	return item
end

return M
