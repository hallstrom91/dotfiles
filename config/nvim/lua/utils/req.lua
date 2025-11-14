local M = {}
local notify = vim.schedule_wrap(function(msg, lvl, title)
	vim.notify(msg, lvl or vim.log.levels.INFO, { title = title or "init setup" })
end)

----@class safeRequireOpts
----@field desc? string
----@field title? string
----@field silent? boolean
----@field level? integer
----@field on_ok? fun(mod: any)

---Safe require wrapper for init/bootstrap
---@param modname string
---param opts? SafeRequireOpts
---return boolean ok
---return any mod
function M.safe(modname, opts)
	opts = opts or {}
	local desc = opts.desc or modname
	local title = opts.title or "init setup"
	local level = opts.level or vim.log.levels.INFO

	local ok, mod_or_err = pcall(require, modname)
	if not ok then
		if not opts.silent then
			notify(("Could not load %s\n %s"):format(desc, mod_or_err), vim.log.levels.WARN, title)
		end
		return false, nil
	end

	if opts.on_ok then
		local ok2, err = pcall(opts.on_ok, mod_or_err)
		if not ok2 and not opts.silent then
			notify(("Something went wrong in on_ok for %s\n%s"):format(desc, err), vim.log.levels.ERROR, title)
		end
	elseif vim.g.init_verbose then
		notify("Loaded " .. desc, level, title)
	end

	return true, mod_or_err
end

setmetatable(M, {
	__call = function(_, ...)
		return M.safe(...)
	end,
})

return M
