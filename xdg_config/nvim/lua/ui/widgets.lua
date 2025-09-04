local icons = require("ui.icons")

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

  local global_only = {}
  for _, name in ipairs(all_names) do
    if not buf_seen[name] then
      table.insert(global_only, name)
    end
  end

  local function fmt(label, names)
    if #names == 0 then
      return nil
    end
    if #names == 1 then
      return string.format("%s %s", label, names[1])
    else
      return string.format("%s %s +%d", label, names[1], #names - 1)
    end
  end

  if #buf_names == 0 and #all_names == 0 then
    return "LSP 󰇙 none"
  end

  local parts = {}
  local b = fmt("(b)", buf_names)
  local g = fmt("(g)", global_only)
  if b then
    table.insert(parts, b)
  end
  if g then
    table.insert(parts, g)
  end

  return " LSP " .. table.concat(parts, " | ")
end

return M
