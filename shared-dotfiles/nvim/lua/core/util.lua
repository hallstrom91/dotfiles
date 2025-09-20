local U = {}

function U.safe_require(modname, opts)
  opts = opts or {}
  local desc = opts.desc or modname
  local on_ok = opts.on_ok -- function() ... end
  local silent = opts.silent or false
  local level = opts.level or vim.log.levels.INFO

  local notify = function(msg, lvl)
    vim.schedule(function()
      vim.notify(msg, lvl, { title = "init" })
    end)
  end

  local ok, mod_or_error = pcall(require, modname)
  if not ok then
    if not silent then
      notify(("Could not load %s\n%s"):format(desc, mod_or_error), vim.log.levels.WARN)
    end
    return nil
  end

  if on_ok then
    local ok2, err = pcall(on_ok, mod_or_error)
    if not ok2 and not silent then
      notify(("Something wrong in on_ok for %s\n%s"):format(desc, err), vim.log.levels.ERROR)
    end
  else
    if vim.g.init_verbose then
      notify("Loaded" .. desc, level)
    end
  end
  return mod_or_error
end

function U.mason_bin_path()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
  local function path_contains(pathlist, p)
    for s in string.gmatch(pathlist, "([^" .. sep .. "]+)") do
      if s == p then
        return true
      end
    end
    return false
  end
  if vim.uv and vim.uv.fs_stat and vim.uv.fs_stat(mason_bin) and not path_contains(vim.env.PATH or "", mason_bin) then
    vim.env.PATH = mason_bin .. sep .. (vim.env.PATH or "")
  end
end

return U
