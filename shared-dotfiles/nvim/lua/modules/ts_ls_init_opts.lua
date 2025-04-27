local M = {}

function M.get_node_version()
  local handle = io.popen("node -v")
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result and result:gsub("^v", ""):gsub("%s+", "") or nil
end

function M.get_styled_plugin_location()
  local version = M.get_node_version()
  if not version then
    return nil
  end
  return os.getenv("HOME") .. "/.nvm/versions/node/v" .. version .. "/lib/node_modules/@styled/typescript-styled-plugin"
end

function M.get_ts_ls_init_options()
  local plugin_path = M.get_styled_plugin_location()
  local is_valid = plugin_path and vim.fn.isdirectory(plugin_path) == 1

  vim.schedule(function()
    vim.notify(
      is_valid and "[ts-styled-plugin] loaded" or "[ts-styled-plugin] not found",
      is_valid and vim.log.levels.INFO or vim.log.levels.WARN
    )
  end)

  if not is_valid then
    return {}
  end

  return {
    plugins = {
      {
        name = "@styled/typescript-styled-plugin",
        location = plugin_path,
        languages = {
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
        },
      },
    },
  }
end

return M
