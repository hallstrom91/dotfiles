local M = {}

local _cache_hl = {}

-- local _cmp_kind_hlite_box_cache = {} -- cache ? remove ?
function M.get_hl(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	return ok and hl or {}
end

------------------------------
--> highlight helpers

---@param num integer
---@return string
local function _num_to_hex(num)
	return num and string.format("#%06x", num) or nil
end

---@class UsrHlInfo
---@field fg_num? integer
---@field bg_num? integer
---@field fg_hex? string
---@field bg_hex? string
---@field bold? boolean
---@field italic? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field strikethrough? boolean
---@field sp? integer|nil

---@class UserGetHlOpts
---@field link? boolean -- forwarded to nvim_get_hl
---@field use_cache? boolean -- enable/disable cache for each call

---@param name string
---@param opts? UserGetHlOpts
---@return UsrHlInfo
function M.get_hl_with_hex(name, opts)
	opts = opts or {}

	if opts.use_cache and _cache_hl[name] then
		return _cache_hl[name]
	end

	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = opts.link or false })
	if not ok or type(hl) ~= "table" then
		return {}
	end

	local fg_num = hl.fg or nil
	local bg_num = hl.bg or nil

	---@type UsrHlInfo
	local hl_info = {
		fg_num = fg_num,
		bg_num = bg_num,
		fg_hex = fg_num and _num_to_hex(fg_num) or nil,
		bg_hex = bg_num and _num_to_hex(bg_num) or nil,
		bold = hl.bold,
		italic = hl.italic,
		underline = hl.underline,
		undercurl = hl.undercurl,
		strikethrough = hl.strikethrough,
		sp = hl.sp,
	}

	if opts.use_cache then
		_cache_hl[name] = hl_info
	end
	return hl_info
end

---get hl-fg color
---@param name string
---@return string|nil
function M.get_hl_fg(name)
	local hl = M.get_hl(name)
	if not hl or not hl.fg then
		return nil
	end
	return _num_to_hex(hl.fg)
end

-- add to autocmd 'ColorScheme' to clear old cache @ change
function M.clear_hl_cache()
	_cache_hl = {}
end

return M
