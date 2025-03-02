local map = vim.keymap.set
local lsp_actions = require("modules.diagnostics.lsp_actions")
local git = require("modules.git.git_info")
local tabs = require("modules.bufferline.tabs")
local bufdelete = require("bufdelete")
--local render = require("modules.utils").tabline
--local tab_names = require("modules.utils").tab_name_formatter

require("bufferline").setup({
  options = {
    mode = "tabs", ----> show buffers instead of tabs
    style_preset = require("bufferline").style_preset.default,
    themable = true,
    numbers = "ordinal", -- (can be "none", "ordinal", "buffer_id", or "both")

    -- numbers = 'buffer_id',
    diagnostics = "nvim_lsp",
    diagnostics_update_on_event = true,

    -- if mode = "tabs"
    close_command = "tabclose",
    middle_mouse_command = "vertical sbuffer %d",
    right_mouse_command = "tabclose",
    left_mouse_command = function(clicked_tab_id)
      tabs.left_mouse_open_tab(clicked_tab_id)
    end,

    --- Fix this - reacts to to many "buffers"
    --  name_formatter = tab_names,

    -- tab names
    tab_size = 22,
    truncate_names = true, -- whether or not tab names should be truncated
    custom_filter = function(buf_number, _)
      -- dont let specific type of buffers "hijack" tab-name
      local ft = vim.bo[buf_number].filetype
      local name = vim.fn.bufname(buf_number)

      local exclude_ft = {
        "TelescopePrompt",
        "neo-tree",
        "spectre_panel",
        --  "NvimTree",
        "qf",
        "help",
        "",
      }

      for _, v in ipairs(exclude_ft) do
        if ft == v then
          return false
        end
      end

      if name == "" or name:match("^%[No Name%]$") then
        return false
      end

      return true
    end,

    diagnostics_indicator = lsp_actions.diagnostics_indicator,
    offsets = {
      {
        filetype = "neo-tree",
        text = function()
          return " " .. git.get_current_branch()
        end,
        highlight = "Directory",
      },
    },
    hover = {
      enabled = true,
      delay = 200, -- value in ms
      reveal = { "close" },
    },

    ----> Indicator for the active buffer
    indicator = {
      icon = "▎󰸞 ", -- indicator for active buffer
      style = "icon", -- can be 'icon', 'underline', or 'none'
    },

    ----> Icons for closing and modified buffers
    buffer_close_icon = "󰅖",
    modified_icon = "󰷫",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    ----> Other options
    show_buffer_close_icons = true,
    show_tab_indicators = true,
    persist_buffer_sort = true,
    separator_style = "thick", -- options: "slant", "thick", "thin", etc.
    enforce_regular_tabs = false,
    always_show_bufferline = true,
  },
})

----> Keybinds - Switch between buffertabs
vim.keymap.set("n", "<Tab>", function()
  require("bufferline").cycle(1)
end, { desc = "Next buffer", silent = true })

vim.keymap.set("n", "<S-Tab>", function()
  require("bufferline").cycle(-1)
end, { desc = "Prev buffer", silent = true })

----> Keybinds - create new buffer

vim.keymap.set("n", "<leader>tn", function()
  vim.cmd.tabnew()
end, { desc = "Open a new tab", silent = true })

vim.keymap.set("n", "<leader>tc", function()
  vim.cmd.tabclose()
end, { desc = "Close current tab", silent = true })
-- map("n", "<leader>tn", ":tabnew<CR>", { desc = "Open a new tab" })
-- map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
-- map("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
-- map("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "Prev buffer" })

vim.keymap.set("n", "<leader>q", function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tab)

  local buffers_in_tab = {}
  local no_name_bufs = {}
  local total_windows = #windows

  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      table.insert(buffers_in_tab, buf)

      if vim.bo[buf].buftype == "" and vim.fn.bufname(buf) == "" then
        table.insert(no_name_bufs, buf)
      end
    end
  end

  if #buffers_in_tab == #no_name_bufs then
    vim.cmd("tabclose")
    return
  end

  if vim.bo[current_buf].buftype == "" and vim.fn.bufname(current_buf) == "" then
    vim.cmd("close")
    return
  end

  vim.cmd("enew")
  local new_buf = vim.api.nvim_get_current_buf()

  bufdelete.bufdelete(current_buf, true, { new_buf })
end, { noremap = true, silent = true, desc = "Close buffer, window, or tab" })
