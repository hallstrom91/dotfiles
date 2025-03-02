local M = {}
local colors = require('modules.ui.colors').vsc_dark_modern

M.clock = {
  function()
    return os.date('%H:%M:%S') -- (24-hour format)
  end,
  icon = ' ',
  color = {
    fg = colors.fg,
    bg = colors.darkblue,
    gui = 'bold',
  },
}

-- icons for current mode
local mode_icons = {
  NORMAL = ' ',
  INSERT = '󱓥 ',
  VISUAL = '󱘣 ',
  REPLACE = '󰛈 ',
  COMMAND = ' ',
}

-- get the current mode
function M.mode_with_icon()
  local current_mode = vim.fn.mode():sub(1, 1)
  local mode_map = {
    n = 'NORMAL',
    i = 'INSERT',
    v = 'VISUAL',
    R = 'REPLACE',
    c = 'COMMAND',
  }
  local mode_name = mode_map[current_mode] or 'NORMAL'
  return mode_icons[mode_name] .. mode_name
end

return M
