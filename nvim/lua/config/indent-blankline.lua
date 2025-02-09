require('ibl').setup({
  indent = {
    char = '', -- Tecknet som används för indents
    highlight = {
      'IndentLevel1', -- Motsvarar första nivån
      'IndentLevel2', -- Andra nivån
      'IndentLevel3', -- Tredje nivån
      'IndentLevel4', -- Fjärde nivån
      'IndentLevel5', -- Femte nivån
      'IndentLevel6', -- Sjätte nivån
      'IndentLevel7', -- Sjunde nivån
    },
  },
  scope = {
    enabled = true,
    char = '󰞷', -- Tecknet som används för scope
    highlight = {
      'IndentLevel1',
      'IndentLevel2',
      'IndentLevel3',
      'IndentLevel4',
      'IndentLevel5',
      'IndentLevel6',
      'IndentLevel7',
    },
  },
  exclude = {
    filetypes = { 'dashboard' }, -- Exkludera filtyper
    buftypes = { 'nofile' }, -- Exkludera buffer-typer
  },
})

-- indent char = "" or "" or "󰇙"
-- scope char = "" or "󰞷" or "󰇘"
--	indent = { highlight = highlight, char = "󰇙" },
--	scope = { highlight = highlight, enabled = true, char = "" },
