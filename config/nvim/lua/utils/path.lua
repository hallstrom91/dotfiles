local M = {}

local uv = vim.uv -- or vim.loop for older nvim-version
local fs = vim.fs

-------------------------------------------
---Internal helper to `lua/utils/path.lua`
local function _path_sep()
	return (package.config:sub(1, 1) == "\\") and ";" or ":"
end

------------------------------------------------------
---Prepend dir to $PATH, only if:
---valid/existing `dir`and value not already in $PATH
---@param dir string
---@return boolean modified
function M.prepend_to_path(dir)
	local st = uv.fs_stat(dir)

	if not st or st.type ~= "directory" then
		return false
	end

	local path = vim.env.PATH or ""
	local sep = _path_sep()

	local haystack = sep .. path .. sep
	local needle = sep .. dir .. sep
	if haystack:find(needle, 1, true) then
		return false
	end

	vim.env.PATH = dir .. (path ~= "" and (sep .. path) or "")
	return true
end

------------------------------
---Prepend Mason bin to `$PATH`, Usage:
--- if 'mason plugin' is lazy loaded, `$PATH` will not be set automatic.
--- to make LSP servers, linters, formatters etc work correctly.
---@return boolean modified
function M.mason_bin_path()
	local bin = vim.fn.stdpath("data") .. "/mason/bin"
	return M.prepend_to_path(bin)
end

---------------------------
---Absolute +  Normalized path
---@param p string|nil
---@return string|nil
function M.norm(p)
	-- if type(p) ~= "string" or p == "" then
	-- 	return nil
	-- end
	if not p or p == "" then
		return ""
	end

	p = vim.fn.fnamemodify(p, ":p")
	p = fs.normalize(p)

	if p:sub(-1) == "/" then
		p = p:sub(1, -2)
	end
	return p
end

------------------------------------------
---Absolute + normalized buf-path (or "")
---@param bufnr? integer
---@return string|nil
function M.bufpath(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(bufnr)
	-- if name == "" then
	-- 	return nil
	-- end
	return M.norm(name)
	-- local abs = fs.abspath(name)
	-- return fs.normalize(abs)
end

-----------------------
---Safe current working dir (CWD)
---@return string
function M.cwd()
	return uv.cwd() or "/"
end

----------------------------------------------
---Format path for UI (short path with tilde)
---@param p string|nil
---@param opts? { shorten_width?: integer}
---@return string
function M.fmt_path(p, opts)
	opts = opts or {}
	local max_w = opts.shorten_width or 40

	if not p or p == "" then
		return ""
	end

	-- p = fs.normalize(fs.fs.abspath(p))

	p = vim.fn.fnamemodify(p, ":~")

	if vim.fn.strdisplaywidth(p) > max_w then
		p = vim.fn.pathshorten(p)
	end

	return p
end

return M
