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
    "tailwind.config.js",
    "tailwind.config.ts",
  })
end

function M.has_tailwind()
  return exists_any({
    "tailwind.config.js",
    "tailwind.config.ts",
  })
end

function M.profile(name)
  return vim.env.NVIM_PROFILE == name
end
return M
