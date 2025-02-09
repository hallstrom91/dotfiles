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

return M
