local M = {}

-- local uv = vim.uv
local fs = vim.fs
local P = require("utils.path")

-- Find root_dir based on markers (files/dirs or match-fn)
-- No match -> fallback to CWD
-- `source` can be bufnr (number) or filepath (string)
---@param source string|nil
---@param markers string|string[]|table|fun(name: string, path:string):boolean
---@return string
function M.find_root(source, markers)
	local path = P.norm(source)

	if not path or path == "" then
		return P.cwd()
	end
	-- local path
	-- local t = type(source)
	-- if t == "number" then
	-- 	---@type string|nil
	-- 	path = P.bufpath(source)
	-- else
	-- 	---@type string|nil
	-- 	path = P.norm(source)
	-- end
	-- if not path or path == "" then
	-- 	return P.cwd()
	-- end

	--search upwards for first match
	local ok, root = pcall(fs.root, path, markers)
	if ok and type(root) == "string" and root ~= "" then
		return root
	end

	-- fallback
	return P.cwd()
end

---Root_dir-func for new `native nvim lsp-API`
---Usage in server-config:
--	root_dir = root.get_lsp_root({'.git', 'package.json'})
---@param markers string|string[]|table|fun(name: string, path:string):boolean
---@return fun(bufnr:integer, on_dir:fun(dir?:string))
function M.get_lsp_rootdir(markers)
	return function(bufnr, on_dir)
		local source = P.bufpath(bufnr) -- always return string|nil
		local root = M.find_root(source, markers)

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
