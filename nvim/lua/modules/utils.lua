local colors = require('modules.ui.colors').vsc_dark_modern
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
    return vim.fn.empty(vim.fn.expand('%:t')) == 120
  end,
}

M.short_path = function(full_path)
  local path_parts = vim.split(full_path, '/')

  if #path_parts >= 2 then
    local folder = path_parts[#path_parts - 1]
    local filename = path_parts[#path_parts]
    return folder .. '/' .. filename
  else
    return path_parts[#path_parts] or '[Empty - Unsaved]'
  end
end

M.sort_by_short_path = function(buffer_a, buffer_b)
  local path_a = M.short_path(buffer_a.path)
  local path_b = M.short_path(buffer_b.path)
  return path_a < path_b
end

local function get_extension(path)
  return path:match('^.+%.([^%.]+)$') or ''
end

M.sort_by_type_and_modified = function(buffer_a, buffer_b)
  local ext_a = get_extension(buffer_a.path)
  local ext_b = get_extension(buffer_b.path)

  if ext_a == ext_b then
    local modified_a = vim.fn.getftime(buffer_a.path)
    local modified_b = vim.fn.getftime(buffer_b.path)
    return modified_a > modified_b
  else
    return ext_a < ext_b
  end
end

return M
