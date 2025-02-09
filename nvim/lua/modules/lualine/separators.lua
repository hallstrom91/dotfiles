local M = {}
local colors = require('modules.ui.colors').vsc_dark_modern

M.left_lualine = function(color_fg)
  return {
    function()
      return ''
      --	return ""
    end,
    color = { fg = color_fg },
    padding = { left = 0, right = 0 },
  }
end

M.right_lualine = function(color_fg)
  return {
    function()
      return ''
      --	return ""
    end,
    color = { fg = color_fg },
    padding = { left = 0, right = 0 },
  }
end

return M
