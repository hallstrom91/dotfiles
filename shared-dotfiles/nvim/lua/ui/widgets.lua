local icons = require("core.icons")

local M = {}

function M.clock()
  return os.date("%H:%M:%S")
end

function M.mode_with_icon()
  local current_mode = vim.fn.mode():sub(1, 1)
  local mode_map = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    R = "REPLACE",
    c = "COMMAND",
  }
  local mode_name = mode_map[current_mode] or "NORMAL"
  return icons.mode_icons[mode_name] .. mode_name
end

function M.lsp_clients()
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  local all_clients = vim.lsp.get_clients()

  local function extract_names(clients)
    local seen = {}
    local names = {}

    for _, client in ipairs(clients) do
      if client.name and not seen[client.name] then
        seen[client.name] = true
        table.insert(names, client.name)
      end
    end
    return names, seen
  end

  local buf_names, buf_seen = extract_names(buf_clients)
  local all_names, _ = extract_names(all_clients)

  local global_only_names = {}
  for _, name in ipairs(all_names) do
    if not buf_seen[name] then
      table.insert(global_only_names, name)
    end
  end

  if #buf_names == 0 and #all_names == 0 then
    return " LSP 󰇙 none active"
  elseif #buf_names > 0 and #global_only_names == 0 then
    return " LSP 󰇙 (buf) " .. table.concat(buf_names, ", ")
  elseif #buf_names == 0 and #global_only_names > 0 then
    return " LSP 󰇙 (global) " .. table.concat(global_only_names, ", ")
  else
    return string.format(
      " LSP 󰇙 (buf) [%s] 󰇙 (global) [%s]",
      table.concat(buf_names, ", "),
      table.concat(global_only_names, ", ")
    )
  end
end

return M
