local M = {}

local ok_wk, wk = pcall(require, "which-key")
if not ok_wk then
	wk = { add = function(_) end }
end

---@class KjsKeymap
---@field mode? string|string[]
---@field lhs string										-- keybinds
---@field rhs? string|function					-- lua-func or "command"
---@field expr? boolean									-- expr
---@field desc? string									-- description
---@field remap? boolean								-- remap
---@field group? string									-- groups for `which-key` plugin
---@field buffer? integer								-- buflocal(id) keymaps
---@field opts? table										-- extra vim.keymap.set opts
---@field cond? boolean|fun():boolean		-- conditional enable

---Internal: normalize single keymap or tbl of keymaps
---@param maps table|KjsKeymap
local function _normalize_maps(maps)
	if not maps then
		return {}
	end

	-- backward comp (until i change my tbls)
	-- if maps.lhs then
	if maps.lhs or maps.keys then
		return { maps } -- single mapping
	end
	return maps -- already (?) a list/tbl
end

--------------------------
---Apply one mapping
---@param m KjsKeymap
local function apply_keymap(m)
	if not m or not m.lhs then
		return
	end

	-- condition: e.g. buflocal LSP-keymaps
	if m.cond ~= nil then
		local ok = (type(m.cond) == "function") and m.cond() or m.cond
		if not ok then
			return
		end
	end

	local mode = m.mode or "n"
	local lhs = m.lhs
	local rhs = m.rhs

	-- Only create keymaps IF `rhs` exists
	if rhs then
		local base_opts = {
			silent = true,
			expr = m.expr,
			desc = m.desc,
			buffer = m.buffer,
		}

		if m.remap ~= nil then
			base_opts.remap = m.remap
		end

		local opts = vim.tbl_extend("force", base_opts, m.opts or {})
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	-- register to whichkey, no 'rhs', avoid creating duplicates.
	wk.add({
		{
			lhs,
			desc = m.desc,
			mode = mode,
			group = m.group,
		},
	})
end

---Public API: create keymap and add specs to `which-key`.
--Config helper for keymaps
---Modes: | :h vim-modes-intro
--- "n" Normal
--- "i" Insert
--- "v" Visual (+ Select)
--- "x" Visual (only)
--- "s" Select
--- "o" Operator-pending
--- "t" Terminal
--- "c" Cmdline
---@param maps table|KjsKeymap
function M.map(maps)
	for _, m in ipairs(_normalize_maps(maps)) do
		apply_keymap(m)
	end
end

return M
