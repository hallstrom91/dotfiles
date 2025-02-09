local colors = require('modules.ui.colors').vsc_dark_modern
local custom_theme = require('modules.lualine.themes').vsc_dark_lualine
local lsp = require('modules.diagnostics.lsp_actions')
local system = require('modules.lualine.system')
local logo = require('modules.ui.logo')
local separators = require('modules.lualine.separators')

-- LSP diagnostics
local lsp_diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbol = { error = '  ', warn = ' ', info = ' ', hint = ' ' },
  color = {
    error = colors.red,
    warn = colors.yellow,
    info = colors.blue,
    hint = colors.cyan,
  },
  on_click = function()
    lsp.open_diagnostics_with_telescope()
  end,
}

require('lualine').setup({

  options = {
    theme = custom_theme,
    --	component_separators = { left = "", right = "" },
    --	component_separators = {left = '', right = ''}
    --	section_separators = { left = "", right = "" },
    --	component_separators = { left = "󰇙", right = "󰇙" },
    component_separators = '',
    section_separators = { left = ' ', right = ' ' },
    always_divide_middle = true,
    disabled_filetypes = {
      statusline = { 'neo-tree', 'git', 'fugitive', 'trouble', 'dashboard' },
      winbar = { 'neo-tree', 'DiffviewFiles', 'git', 'dashboard' },
    },
  },

  sections = {

    lualine_a = {
      {
        system.mode_with_icon,
        padding = { left = 1, right = 1 },
      },
    },
    lualine_b = {
      {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 0, -- 1 =  filename, 2: filename with path, 3: full path
        color = {
          bg = colors.visual_color,
          gui = 'italic',
        },
      },
      { 'location', color = { bg = colors.visual_color } },
      separators.left_lualine(colors.visual_color),
    },

    lualine_c = {
      {
        'branch',
        icon = ' ',
        color = {
          fg = colors.cyan,
          gui = 'bold',
        },
      },
      {
        'diff',
        symbols = {
          added = '✚ ',
          modified = '✎ ',
          removed = '✖ ',
          color_added = colors.green,
          color_modified = colors.orange,
          color_removed = colors.red,
        },
        color = { gui = 'italic' },
      },
    },

    lualine_x = {
      { 'selectioncount' },
      { 'searchcount' },
      -- nvim_logo_and_version,
      logo.nvim_logo_and_version_color,
    },

    lualine_y = {
      lsp.lsp_progress,
      separators.right_lualine(colors.bg_local),
      { 'filetype', color = { bg = colors.bg_local } },
      lsp_diagnostics,
    },

    lualine_z = {
      system.clock,
    },
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
})

vim.api.nvim_create_augroup('lualine_augroup', { clear = true })
vim.api.nvim_create_autocmd('User', {
  group = 'lualine_augroup',
  pattern = 'LspProgressStatusUpdated',
  callback = require('lualine').refresh,
})
