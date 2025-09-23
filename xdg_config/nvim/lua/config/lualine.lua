local widgets = require("ui.widgets")

require("lualine").setup({
  options = {
    theme = "vscode",
    component_separators = "",
    section_separators = { left = " ", right = " " },
    always_divide_middle = true,
    disabled_filetypes = {
      statusline = { "neo-tree", "git", "fugitive", "trouble", "dashboard" },
      winbar = { "neo-tree", "DiffviewFiles", "git", "dashboard" },
    },
  },
  winbar = {
    lualine_a = {
      {
        "filetype",
        colored = true,
        icon_only = false,
        icon = { align = "left" },
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
        widgets.lsp_clients,
      },
    },
    lualine_z = {
      {
        widgets.clock,
        icon = " ",
      },
    },
  },
})
