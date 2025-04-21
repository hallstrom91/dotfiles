local colors = require("modules.ui.colors").vsc_dark_modern
local M = {}

M.screen_width_min = {
  function(min_w)
    return function()
      return vim.o.columns > min_w
    end
  end,
}

M.buffer_empty = {
  function()
    return vim.fn.empty(vim.fn.expand("%:t")) == 120
  end,
}

----| Excluded Projects |----
M.excluded_projects = {
  "/media/veracrypt2/wellr/repos/wellr-sanity",
}

----| Exclude project paths from LSP & Conform formatting |----
function M.is_excluded_project(bufnr)
  bufnr = bufnr or 0
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  for _, path in ipairs(M.excluded_projects) do
    if vim.startswith(filepath, path) then
      return true
    end
  end

  return false
end

function M.print_lsp_formatting_status(bufnr)
  bufnr = bufnr or 0
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local has_formatting = false

  for _, client in ipairs(clients) do
    if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
      vim.notify("LSP client '" .. client.name .. "' supports formatting", vim.log.levels.INFO)
      has_formatting = true
    end
  end

  if not has_formatting then
    vim.notify("No active LSP client supports formatting", vim.log.levels.WARN)
  end
end

-- Print if current project is excluded
function M.print_exclusion_status()
  if M.is_excluded_project(0) then
    vim.notify("Project is excluded from formatting", vim.log.levels.INFO)
  else
    vim.notify("Project is NOT excluded from formatting", vim.log.levels.INFO)
  end
end

----| Get correct Node-version |----
function M.get_node_version()
  local handle = io.popen("node -v")
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  if result then
    return result:gsub("^v", ""):gsub("%s+", "")
  end
end

function M.get_styled_plugin_location()
  local version = M.get_node_version()
  if not version then
    vim.notify("node" .. version .. "cant be found..", vim.log.levels.WARN)
    return nil
  end

  local home = os.getenv("HOME")
  local path = home .. "/.nvm/versions/node/v" .. version .. "/lib/node_modules/@styled/typescript-styled-plugin"

  vim.notify("Node: " .. version .. " found for ts-styled-plugin")
  return path
end

function M.get_ts_ls_init_options()
  local plugin_path = M.get_styled_plugin_location()
  if not plugin_path or vim.fn.isdirectory(plugin_path) ~= 1 then
    vim.notify("[styled-plugin] Plugin path missing or invalid: " .. (plugin_path or "nil"), vim.log.levels.WARN)
    return {}
  end

  vim.notify("[styled-plugin] Loaded from: " .. plugin_path, vim.log.levels.INFO)

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

-- for nvims builtin tabs
function M.tabline()
  local s = ""
  local tabs = vim.api.nvim_list_tabpages()
  local current_tab = vim.api.nvim_get_current_tabpage()

  for idx, tab in ipairs(tabs) do
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    local active_win = vim.api.nvim_tabpage_get_win(tab)
    local active_buf = vim.api.nvim_win_get_buf(active_win)
    local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(active_buf), ":t")

    if bufname == "" then
      bufname = "[No Name]"
    end

    local extra_buffers = #wins - 1
    if extra_buffers > 0 then
      bufname = bufname .. " +" .. extra_buffers
    end

    if tab == current_tab then
      s = s .. "%#TabLineSel# " .. idx .. ": " .. bufname .. " %#TabLine#"
    else
      s = s .. "%#TabLine# " .. idx .. ": " .. bufname .. " "
    end
  end

  s = s .. "%#TabLineFill#%="
  return s
end

local function find_tab_for_buf(bufnr)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        return tab
      end
    end
  end
  return nil
end

function M.tab_name_formatter(buf)
  local tab = find_tab_for_buf(buf.bufnr)
  if not tab then
    return "[No Tab]"
  end

  local wins_in_tab = vim.api.nvim_tabpage_list_wins(tab)
  local buffer_count = #wins_in_tab

  local name = vim.fn.fnamemodify(buf.name, ":t")
  if name == "" then
    name = "[No Name]"
  end

  if buffer_count > 1 then
    name = string.format("%s +%d", name, buffer_count - 1)
  end

  return name
end

return M
