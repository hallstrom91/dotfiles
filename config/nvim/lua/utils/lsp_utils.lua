local M = {}

------------------------
-- LSP keymaps
------------------------
function M.set_lsp_keymap(client, bufnr, lhs, rhs, o)
	o = o or {}
	local desc = o.desc and ("LSP " .. o.desc) or nil
	local modes = o.mode or "n"
	local opts = { buffer = bufnr, silent = true, noremap = true, desc = desc }

	if o.requires and not client:supports_method(o.requires) then
		vim.keymap.set(modes, lhs, function()
			vim.notify(("LSP: %s not supported by %s"):format(o.requires, client.name), vim.log.levels.WARN)
		end, opts)
		return
	end

	vim.keymap.set(modes, lhs, rhs, opts)
end

------------------------
-- LspDetach / Autostop
------------------------
local timers = {} -- client_id -> uv_timer_t

function M.is_orphan(client)
	for bufnr in pairs(client.attached_buffers or {}) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
			return false
		end
	end
	return true
end

-- Kill client IF orphan after * delay_ms
function M.kill_or_spare_client(client_id, delay_ms)
	local client = vim.lsp.get_client_by_id(client_id)
	if not client then
		return
	end

	if timers[client_id] then
		timers[client_id]:stop()
		timers[client_id]:close()
		timers[client_id] = nil
	end

	local t = vim.uv.new_timer()
	timers[client_id] = t

	t:start(delay_ms or 1500, 0, function()
		vim.schedule(function()
			local c = vim.lsp.get_client_by_id(client_id)
			if c and M.is_orphan(c) then
				pcall(function()
					c:stop()
				end)
			end

			if timers[client_id] then
				timers[client_id]:stop()
				timers[client_id]:close()
				timers[client_id] = nil
			end
		end)
	end)
end

------------------------
-- find root dir / cwd
------------------------
function M.get_lsp_cfg(path)
	local chunk, err = loadfile(path)
	if not chunk then
		vim.notify(("LSP: loadfile(%s) error: %s"):format(path, err), vim.log.levels.ERROR, { title = "LSP" })
		return nil
	end
	local ok, spec = pcall(chunk)
	if not ok then
		vim.notify(("LSP: exec(%s) error: %s"):format(path, spec), vim.log.levels.ERROR, { title = "LSP" })
		return nil
	end
	if type(spec) ~= "table" then
		vim.notify(("LSP: %s did not return a table"):format(path), vim.log.levels, { title = "LSP" })
		return nil
	end
	return spec
end

function M.root_dir_fn(markers)
	return function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		if fname == "" then
			return
		end
		local hit = vim.fs.find(markers, { upward = true, path = fname })[1]
		if hit then
			on_dir(vim.fs.dirname(hit))
		end
	end
end

return M
