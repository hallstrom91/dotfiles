local M = {}

-- check for file in cwd
---@param fname string
---@return boolean
local function exists(fname)
	return vim.loop.fs_stat(vim.fn.getcwd() .. "/" .. fname) ~= nil
end

-- check if any file in list exists in cwd
---@param files string[]
---@return boolean
local function exists_any(files)
	for _, f in ipairs(files) do
		if exists(f) then
			return true
		end
	end
	return false
end

function M.is_webdev()
	return exists_any({
		"package.json",
		"pnpm-lock.yaml",
		"yarn.lock",
		"rsbuild.config.js",
		"rsbuild.config.ts",
		"vite.config.ts",
		"vite.config.js",
		"next.config.js",
		"tsconfig.json",
		"jsconfig.json",
	})
end

function M.has_tailwind()
	return exists_any({
		"tailwind.config.js",
		"tailwind.config.ts",
	})
end

local WEBDEV_FTS = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	jsx = true,
	tsx = true,
	html = true,
	css = true,
}

function M.is_webdev_ft(ft)
	return WEBDEV_FTS[ft or vim.bo.filetype] or false
end

-- function M.profile(name)
-- 	return vim.env.NVIM_PROFILE == name
-- end
return M
