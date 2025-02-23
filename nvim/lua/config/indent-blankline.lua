local highlight = {
  'RainbowRed',
  'RainbowYellow',
  'RainbowBlue',
  'RainbowOrange',
  'RainbowGreen',
  'RainbowViolet',
  'RainbowCyan',
}

local hooks = require('ibl.hooks')
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
  vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
  vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
  vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
  vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
  vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
  vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
end)

require('ibl').setup({
  indent = {
    char = '', -- Tecknet som används för indents
    highlight = highlight,
  },
  scope = {
    enabled = true,
    char = '󰞷', -- Tecknet som används för scope
    highlight = highlight,
  },
  whitespace = {
    highlight = highlight,
    remove_blankline_trail = false,
  },
  exclude = {
    filetypes = { 'dashboard' }, -- Exkludera filtyper
    buftypes = { 'nofile' }, -- Exkludera buffer-typer
  },
})

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

-----| Config for personal theme |-----
-- require('ibl').setup({
--   indent = {
--     char = '', -- Tecknet som används för indents
--     highlight = {
--       'IndentLevel1', -- Motsvarar första nivån
--       'IndentLevel2', -- Andra nivån
--       'IndentLevel3', -- Tredje nivån
--       'IndentLevel4', -- Fjärde nivån
--       'IndentLevel5', -- Femte nivån
--       'IndentLevel6', -- Sjätte nivån
--       'IndentLevel7', -- Sjunde nivån
--     },
--   },
--   scope = {
--     enabled = true,
--     char = '󰞷', -- Tecknet som används för scope
--     highlight = {
--       'IndentLevel1',
--       'IndentLevel2',
--       'IndentLevel3',
--       'IndentLevel4',
--       'IndentLevel5',
--       'IndentLevel6',
--       'IndentLevel7',
--     },
--   },
--   exclude = {
--     filetypes = { 'dashboard' }, -- Exkludera filtyper
--     buftypes = { 'nofile' }, -- Exkludera buffer-typer
--   },
-- })

-----| Options for indent-blankline |------
-- indent char = "" or "" or "󰇙"
-- scope char = "" or "󰞷" or "󰇘"
--	indent = { highlight = highlight, char = "󰇙" },
--	scope = { highlight = highlight, enabled = true, char = "" },
