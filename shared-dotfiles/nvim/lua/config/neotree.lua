local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local set_map = require("core.keymaps").set_keymap

require("neo-tree").setup({
  -- General settings
  close_if_last_window = false, -- Close Neo-tree if it's the last window open
  popup_border_style = "rounded", -- Border style for popups (rounded, single, double)
  enable_git_status = true, -- Enable git status integration
  enable_diagnostics = true, -- Enable diagnostics (e.g., linting info)
  enable_modified_markers = true, -- Show markers for files with unsaved changes.
  enable_opened_markers = true, -- Enable tracking of opened files. Required for `components.name.highlight_opened_files`
  enable_refresh_on_write = true, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.
  enable_cursor_hijack = true, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
  git_status_async = true,
  log_level = "info", -- "trace", "debug", "info", "warn", "error", "fatal"
  open_files_in_last_window = true, -- false = open files in top left window
  open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" }, -- when opening files, do not use windows containing these filetypes or buftypes

  use_popups_for_input = false, -- If false, inputs will use vim.ui.input() instead of custom floats.
  use_default_mappings = true,

  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    indent = {
      indent_size = 2, -- Set the indent size for items in the tree
      padding = 1, -- Padding around items
      -- indent guides
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "", -- Icon for closed folders
      folder_open = "", -- Icon for open folders
      folder_empty = "", -- Icon for empty folders
      folder_empty_open = "󰷏",
    },
  },

  window = {
    position = "float",
    width = 40,
    popup = {
      size = {
        height = "80%",
        width = "50%",
      },
      position = "50%",
      popup_border_style = "rounded", -- Border style for popups (rounded, single, double)
      title = function(state) -- format the text that appears at the top of a popup window
        return "Neo-tree " .. state.name:gsub("^%l", string.upper)
      end,
      -- you can also specify border here, if you want a different setting from
      -- the global popup_border_style.
    },
    mappings = {
      ["<esc>"] = "cancel", -- close preview or floating neo-tree window
      ["P"] = {
        "toggle_preview",
        config = {
          use_float = true,
          use_snacks_image = true,
          use_image_nvim = true,
          title = "Preview", -- You can define a custom title for the preview floating window.
        },
      },
      ["<CR>"] = { desc = "open (new tab)", "open_tabnew" },
      ["o"] = "open",
      ["/"] = "none", -- remove fuzzyfind in neotree menu
    },
  },

  source_selector = {
    winbar = true,
    statusline = false,
  },
  event_handlers = {
    {
      event = "file_opened",
      handler = function(file_path)
        --auto close
        require("neo-tree.command").execute({ action = "close" })
      end,
    },
  },
})

-- Neotree (file/buf-explorer)
local ntree_maps = {

  { mode = "n", keys = "<C-n>", cmd = ":Neotree toggle reveal_force_cwd=true<CR>", desc = "Open File Explorer" },
  -- { mode = "n", keys = "<C-n>", cmd = ":NeoTree toggle<cr>", desc = "Open File Explorer" },
  -- {
  --   mode = "n",
  --   keys = "<C-bn",
  --   cmd = ":Neotree source=buffers float reveal action=focus<CR>",
  --   desc = "Open Buf Explorer",
  --   noremap = true,
  -- },
}

set_map(ntree_maps)

-- map(
--   "n",
--   "<C-n>",
--   ":Neotree toggle reveal_force_cwd=true<CR>",
--   vim.tbl_extend("force", opts, { desc = "Open File explorer" })
-- )

-- map("n", "<C-n>", "<cmd>NeoTree toggle<cr>", opts, { desc = "Open File Explorer"} )
-- map("n", "-", "<cmd>Neotree source=buffers float reveal action=focus<cr>"
