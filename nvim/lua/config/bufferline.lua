local map = vim.keymap.set
local lsp_actions = require('modules.diagnostics.lsp_actions')
local git = require('modules.git.git_info')
local tabs = require('modules.bufferline.tabs')
local bufdelete = require('bufdelete')

require('bufferline').setup({
  options = {
    mode = 'tabs', -- show buffers instead of tabs
    style_preset = require('bufferline').style_preset.default,
    themable = true,
    numbers = 'ordinal', -- (can be "none", "ordinal", "buffer_id", or "both")
    -- numbers = 'buffer_id',
    diagnostics = 'nvim_lsp',
    diagnostics_update_on_event = true,

    --left_mouse_command = 'tabnext %d',
    --middle_mouse_command = nil, -- no action on middle-click

    -- if mode = "tabs"
    --  right_mouse_command = 'tabclose',
    close_command = 'tabclose',
    middle_mouse_command = 'vertical sbuffer %d',
    left_mouse_command = function(clicked_tab_id)
      tabs.left_mouse_open_tab(clicked_tab_id)
    end,

    right_mouse_command = 'tabclose',

    -- if mode = "buffers" -- use below
    -- close_command = 'bdelete! %d',
    -- right_mouse_command = 'bdelete! %d',
    -- left_mouse_command = 'buffer %d',
    --color_icons = true,

    diagnostics_indicator = lsp_actions.diagnostics_indicator,
    offsets = {
      {
        filetype = 'neo-tree',
        text = function()
          return ' ' .. git.get_current_branch()
        end,
        highlight = 'Directory',
      },
    },
    hover = {
      enabled = true,
      delay = 200, -- value in ms
      reveal = { 'close' },
    },

    -- Indicator for the active buffer
    indicator = {
      icon = '▎󰸞 ', -- indicator for active buffer
      style = 'icon', -- can be 'icon', 'underline', or 'none'
    },

    -- Icons for closing and modified buffers
    buffer_close_icon = '󰅖', -- icon for closing buffers
    modified_icon = '󰷫', -- icon for modified buffers
    close_icon = '', -- icon for completely closing the bufferline (when relevant)
    left_trunc_marker = '', -- icon to indicate more buffers to the left
    right_trunc_marker = '', -- icon to indicate more buffers to the right

    -- Other options
    show_buffer_close_icons = true, -- show close icon on each buffer
    show_tab_indicators = true, -- show indicators for active tabs
    persist_buffer_sort = true, -- maintain buffer sorting between sessions
    separator_style = 'thick', -- options: "slant", "thick", "thin", etc.
    enforce_regular_tabs = false, -- prevent irregular tabs
    always_show_bufferline = true, -- always show bufferline even with one buffer open
  },
})

-- Keybinds for "buffers"-mode
map('n', '<Tab>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })

-- Keybinds for "tabs"-mode
--map('n', '<Tab>', ':tabnext<CR>', { desc = 'Next tab' })
--map('n', '<S-Tab>', ':tabprevious<CR>', { desc = 'Previous tab' })
map('n', '<leader>tn', ':tabnew<CR>', { desc = 'Open a new tab' })
map('n', '<leader>tc', ':tabclose<CR>', { desc = 'Close current tab' })

-- works, but cant close empty with leader+q
--[[ vim.keymap.set('n', '<leader>q', function()
  vim.cmd('enew')
  local new_buf = vim.api.nvim_get_current_buf()

  require('bufdelete').bufdelete(0, true, { new_buf })
end, { noremap = true, silent = true, desc = 'Close tabs, bufs, etc..' }) ]]

vim.keymap.set('n', '<leader>q', function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tab)

  local buffers_in_tab = {} -- Lista över buffrar i tabben
  local no_name_bufs = {} -- Lista över `[No Name]` buffrar
  local total_windows = #windows -- Antal fönster i tabben

  -- Loopa genom alla fönster i tabben och hämta buffrarna
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      table.insert(buffers_in_tab, buf)

      if vim.bo[buf].buftype == '' and vim.fn.bufname(buf) == '' then
        table.insert(no_name_bufs, buf)
      end
    end
  end

  if #buffers_in_tab == #no_name_bufs then
    vim.cmd('tabclose') -- Stänger hela tabben
    return
  end

  if vim.bo[current_buf].buftype == '' and vim.fn.bufname(current_buf) == '' then
    vim.cmd('close')
    return
  end

  vim.cmd('enew')
  local new_buf = vim.api.nvim_get_current_buf()

  bufdelete.bufdelete(current_buf, true, { new_buf })
end, { noremap = true, silent = true, desc = 'Close buffer, window, or tab' })
