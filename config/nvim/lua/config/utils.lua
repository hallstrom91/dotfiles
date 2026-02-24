local M = {}

--- LSP ROOT DIR
-- root_dir = function(bufnr, on_dir)
-- 		local fname = vim.api.nvim_buf_get_name(bufnr)
-- 		local root = vim.fs.root(fname, { ".git" })
-- 		if root then
-- 			on_dir(root) -- lsp active: time 2 fight errors
-- 		end
-- 	end,

---@param source string|nil
---@param markers string|string[]|table|fun(name: string, path:string):boolean
---@return string
function M.find_root(source, markers)
	local path = P.norm(source)

	if not path or path == "" then
		return P.cwd()
	end

	--search upwards for first match
	local ok, root = pcall(fs.root, path, markers)
	if ok and type(root) == "string" and root ~= "" then
		return root
	end

	-- fallback
	return P.cwd()
end

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


function M.find_root(markers)
    return function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
            return end

            local root = vim.fs.root(name, markers)
            if root then
                on_dir(vim.fs.normalize(root))
            end
        end
    end



return M
