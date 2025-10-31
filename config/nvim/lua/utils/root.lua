local M = {}

local uv = vim.uv
local fs = vim.fs

local function norm(path)
	if not path or path == "" then
		return nil
	end
	return uv.fs_realpath(path) or path
end

local function bufpath(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return norm(name)
end

--- Safe current working directory: always return string
---@return string
local function safe_cwd()
	return uv.cwd() or "/"
end

-- Find root_dir based on markers (files/dirs or match-fn)
-- No match -> fallback to CWD
-- `source` can be bufnr (number) or filepath (string)
---@param source integer|string
---@param markers string|string[]|table|fun(name: string, path:string):boolean
---@return string
function M.find_root(source, markers)
	local path

	if type(source) == "number" then
		path = bufpath(source)
	else
		path = norm(source)
	end

	if not path or path == "" then
		return safe_cwd()
	end

	--search upwards for first match
	local ok, root = pcall(fs.root, path, markers)
	if ok and type(root) == "string" and root ~= "" then
		return root
	end

	-- fallback
	return safe_cwd()
end

-- root_dir-function for new LSP API
-- usage in server-config:
--	root_dir = root.get_lsp_root({'.git', 'package.json'})
---@param markers string|string[]|table|fun(name: string, path:string):boolean
---@return fun(bufnr:integer, on_dir:fun(dir?:string))
function M.get_lsp_rootdir(markers)
	return function(bufnr, on_dir)
		local root = M.find_root(bufnr, markers)
		if root and root ~= "" then
			on_dir(root)
		else
			-- no root_dir, dont start LSP for buf.
			on_dir(nil)
		end
	end
end

-- Make main module `callable`
setmetatable(M, {
	__call = function(_, ...)
		return M.get_lsp_rootdir(...)
	end,
})

return M
