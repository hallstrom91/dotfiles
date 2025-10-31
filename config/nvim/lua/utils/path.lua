local M = {}

local uv = vim.uv

local notify = vim.schedule_wrap(function(msg, lvl, title)
	vim.notify(msg, lvl or vim.log.levels.INFO, { title = title or "init setup" })
end)

-- Prepend Mason bin to `PATH` | if present & not already included.
---@return boolean modified -- true if `PATH` was changed.
function M.mason_bin_path()
	local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
	local st = uv.fs_stat(mason_bin)

	if not st or st.type ~= "directory" then
		return false
	end

	local path = vim.env.PATH or ""
	local sep = (package.config:sub(1, 1) == "\\") and ";" or ":"

	local haystack = sep .. path .. sep
	local needle = sep .. mason_bin .. sep
	if haystack:find(needle, 1, true) then
		return false
	end

	vim.env.PATH = mason_bin .. (path ~= "" and (sep .. path) or "")
	return true
end

---@class safeRequireOpts
---@field desc? string
---@field title? string
---@field silent? boolean
---@field level? integer
---@field on_ok? fun(mod:any)

-- Safe require wrapper for init/bootstrap
---@param modname string
---@param opts? safeRequireOpts
---@return boolean ok, any mod
function M.safe(modname, opts)
	opts = opts or {}
	local desc = opts.desc or modname
	local title = opts.title or "init setup"
	local level = opts.level or vim.log.levels.INFO

	local ok, mod_or_error = pcall(require, modname)
	if not ok then
		if not opts.silent then
			notify(("Could not load %s\n%s"):format(desc, mod_or_error), vim.log.levels.WARN, title)
		end
		return false, nil
	end

	if opts.on_ok then
		local ok2, err = pcall(opts.on_ok, mod_or_error)
		if not ok2 and not opts.silent then
			notify(("Something wrong in on_ok for %s\n%s"):format(desc, err), vim.log.levels.ERROR, title)
		end
	elseif vim.g.init_verbose then
		notify("Loaded" .. desc, level, title)
	end

	return true, mod_or_error
end

setmetatable(M, {
	__call = function(_, ...)
		return M.safe(...)
	end,
})

return M
