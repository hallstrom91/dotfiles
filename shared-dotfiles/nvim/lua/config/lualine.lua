local icons = require("core.icons")
local widgets = require("core.widgets")

local theme_colors = {
  bg = "#1e1e1e",
  fg = "#cccccc",
  bg_secondary = "#252526",
  highlight = "#254F78",
  bg_winbar = "#b9b4c7",
  fg_winbar = "#2d4356",
  insert = "#487e02",
  visual = "#c586c0",
  replace = "#f14c4c",
  command = "#cca700",
}

local custom_theme = {
  normal = {
    a = {
      bg = theme_colors.highlight,
      fg = theme_colors.fg,
      gui = "bold",
    },
    b = {
      bg = theme_colors.bg,
      fg = theme_colors.fg,
    },
    c = {
      bg = theme_colors.bg_secondary,
      fg = theme_colors.fg,
    },
    x = {
      bg = theme_colors.bg,
      fg = theme_colors.fg,
    },
    y = {
      bg = theme_colors.bg,
      fg = theme_colors.fg,
    },
    z = {
      bg = theme_colors.bg,
      fg = theme_colors.fg,
    },
  },

  insert = {
    a = {
      bg = theme_colors.insert,
      fg = theme_colors.fg,
      gui = "bold",
    },
  },

  visual = {
    a = {
      bg = theme_colors.visual,
      fg = theme_colors.fg,
      gui = "bold",
    },
  },

  replace = {
    a = {
      bg = theme_colors.replace,
      fg = theme_colors.fg,
      gui = "bold",
    },
  },

  command = {
    a = {
      bg = theme_colors.command,
      fg = theme_colors.fg,
      gui = "bold",
    },
  },
}

require("lualine").setup({
  options = {
    theme = custom_theme,
    component_separators = "",
    section_separators = { left = " ", right = " " },
    always_divide_middle = true,
    disabled_filetypes = {
      statusline = { "neo-tree", "git", "fugitive", "trouble", "dashboard" },
      winbar = { "neo-tree", "DiffviewFiles", "git", "dashboard" },
    },
  },
  sections = {
    lualine_a = {
      {
        widgets.mode_with_icon,
        padding = { left = 1, right = 1 },
      },
    },

    lualine_b = {
      {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 0, -- 1 =  filename, 2: filename with path, 3: full path
        color = {
          gui = "italic",
        },
      },
      { "location" },
    },

    lualine_c = {
      {
        "branch",
        icon = " ",
        color = {
          fg = theme_colors.highlight,
          gui = "bold",
        },
      },
      {
        "diff",
        symbols = {
          added = icons.git_icons.added,
          modified = icons.git_icons.modified,
          removed = icons.git_icons.removed,
          color_added = theme_colors.insert,
          color_modified = theme_colors.command,
          color_removed = theme_colors.replace,
        },
        color = { gui = "italic" },
      },
    },

    lualine_x = {
      { "selectioncount", icon = "󰄒 ", color = { gui = "italic" } },
      { "searchcount", icon = " ", color = { gui = "bold" } },
    },

    lualine_y = {
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        sections = { "error", "warn", "info", "hint" },
        symbols = { error = " E", warn = " W", info = " I", hint = "󰘥 H" },
        color = { bg = theme_colors.bg_secondary },
      },
      {
        widgets.lsp_clients,
      },
    },

    lualine_z = {},
  },

  inactive_sections = {
    -- to remove defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },

  winbar = {
    lualine_a = {
      {
        "filetype",
        colored = true,
        icon_only = false,
        icon = { align = "left" },
        color = { bg = theme_colors.fg, fg = theme_colors.bg, gui = "bold" },
      },
      {
        "filename",
        file_status = true,
        path = 1,
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      {
        "encoding",
        show_bomb = false,
        icon = " ",
      },
    },
    lualine_z = {
      {
        widgets.clock,
        icon = " ",
        color = {
          fg = theme_colors.fg,
          bg = theme_colors.highlight,
          gui = "bold",
        },
      },
    },
  },
})

vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})
