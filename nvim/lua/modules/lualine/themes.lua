local colors = require('modules.ui.colors')
local colors_vsc_dark = colors.vsc_dark_modern

local custom_theme = {}

custom_theme.vsc_dark_lualine = {

  normal = {
    a = {
      bg = colors_vsc_dark.darkblue,
      fg = colors_vsc_dark.fg,
      gui = 'bold',
    },
    b = {
      bg = colors_vsc_dark.bg,
      fg = colors_vsc_dark.fg,
    },
    c = {
      bg = colors_vsc_dark.bg,
      fg = colors_vsc_dark.fg,
    },
    -- add x/y/z if needed for custom colors
  },

  insert = {
    a = {
      bg = colors_vsc_dark.green,
      fg = colors_vsc_dark.fg,
      gui = 'bold',
    },
  },
  visual = {
    a = {
      bg = colors_vsc_dark.violet,
      fg = colors_vsc_dark.fg,
      gui = 'bold',
    },
  },
  replace = {
    a = {
      bg = colors_vsc_dark.red,
      fg = colors_vsc_dark.fg,
      gui = 'bold',
    },
  },
  command = {
    a = {
      bg = colors_vsc_dark.yellow,
      fg = colors_vsc_dark.fg,
      gui = 'bold',
    },
  },
}

return custom_theme
