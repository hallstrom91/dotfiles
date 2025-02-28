local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local git_actions = require('modules.git.git_actions')

vim.fn.sign_define('DiagnosticSignError', { text = ' ', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = ' ', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '󰌵', texthl = 'DiagnosticSignHint' })

require('neo-tree').setup({
  -- General settings
  close_if_last_window = false, -- Close Neo-tree if it's the last window open
  popup_border_style = 'rounded', -- Border style for popups (rounded, single, double)
  enable_git_status = true, -- Enable git status integration
  enable_diagnostics = true, -- Enable diagnostics (e.g., linting info)
  enable_modified_markers = true, -- Show markers for files with unsaved changes.
  enable_opened_markers = true, -- Enable tracking of opened files. Required for `components.name.highlight_opened_files`
  enable_refresh_on_write = true, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.
  enable_cursor_hijack = false, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
  git_status_async = true,
  log_level = 'info', -- "trace", "debug", "info", "warn", "error", "fatal"
  open_files_in_last_window = true, -- false = open files in top left window
  open_files_do_not_replace_types = { 'terminal', 'Trouble', 'qf', 'edgy' }, -- when opening files, do not use windows containing these filetypes or buftypes

  use_popups_for_input = true, -- If false, inputs will use vim.ui.input() instead of custom floats.
  use_default_mappings = true,
  -- Default UI settings
  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    indent = {
      indent_size = 2, -- Set the indent size for items in the tree
      padding = 1, -- Padding around items
      -- indent guides
      with_markers = true,
      indent_marker = '│',
      last_indent_marker = '└',
      highlight = 'NeoTreeIndentMarker',
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    icon = {
      folder_closed = '', -- Icon for closed folders
      folder_open = '', -- Icon for open folders
      folder_empty = '', -- Icon for empty folders
      folder_empty_open = '󰷏',

      provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
        if node.type == 'file' or node.type == 'terminal' then
          local success, web_devicons = pcall(require, 'nvim-web-devicons')
          local name = node.type == 'terminal' and 'terminal' or node.name
          if success then
            local devicon, hl = web_devicons.get_icon(name)
            icon.text = devicon or icon.text
            icon.highlight = hl or icon.highlight
          end
        end
      end,
      default = '*',
      highlight = 'NeoTreeFileIcon',
    },

    --    Git status settings
    git_status = {
      symbols = {
        -- Change type
        added = '✚', -- Symbol for added files
        modified = '', -- Symbol for modified files
        deleted = '✖', -- Symbol for deleted files
        renamed = '󰁕', -- Symbol for renamed files
        -- Statustype
        untracked = '', -- Symbol for untracked files
        ignored = '', -- Symbol for ignored files
        unstaged = '󰄱', -- Symbol for unstaged changes
        staged = '', -- Symbol for staged changes
        conflict = '', -- Symbol for merge conflicts
      },
    },
    --		    File name settings
    name = {
      trailing_slash = false, -- Show trailing slash after folder names
      use_git_status_colors = true, -- Color file names based on git status
      highlight = 'NeoTreeFileName', -- Highlight group for file names
    },
    -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
    file_size = {
      enabled = true,
      width = 12, -- width of the column
      required_width = 64, -- min width of window required to show this column
    },
    type = {
      enabled = true,
      width = 10, -- width of the column
      required_width = 110, -- min width of window required to show this column
    },
    last_modified = {
      enabled = true,
      width = 20, -- width of the column
      required_width = 88, -- min width of window required to show this column
      format = '%Y-%m-%d %I:%M %p', -- format string for timestamp (see `:h os.date()`)
      -- or use a function that takes in the date in seconds and returns a string to display
      --format = require("neo-tree.utils").relative_date, -- enable relative timestamps
    },
    created = {
      enabled = false,
      width = 20, -- width of the column
      required_width = 120, -- min width of window required to show this column
      format = '%Y-%m-%d %I:%M %p', -- format string for timestamp (see `:h os.date()`)
      -- or use a function that takes in the date in seconds and returns a string to display
      --format = require("neo-tree.utils").relative_date, -- enable relative timestamps
    },
    symlink_target = {
      enabled = false,
      text_format = ' ➛ %s', -- %s will be replaced with the symlink target's path.
    },
  }, -- End of default component configs

  -- Filesystem settings
  filesystem = {
    filtered_items = {
      visible = false, -- Show hidden items with a different style
      hide_dotfiles = false, -- Hide dotfiles by default
      hide_gitignored = true, -- Hide gitignored files
      hide_hidden = true, -- Hide hidden files (on Windows only)
      hide_by_name = { -- Specify items to hide by name
        'node_modules',
        'next',
        '.git',
        '.yarn',
      },
      always_show = { -- Always show these items
        '.gitignored',
        '*.log',
      },
      always_show_by_pattern = { -- Always show items matching these patterns
        '.env*',
      },
    },
    -- Automatically follow the current file
    follow_current_file = {
      enabled = true, -- Follow the currently active file
      leave_dirs_open = false, -- Close directories when navigating away
    },
    use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
  }, -- End of filesystem settings

  -- Neo-tree window settings
  window = {
    position = 'left',
    width = 40,
    popup = {
      size = {
        height = '80%',
        width = '50%',
      },
      position = '50%',
      popup_border_style = 'rounded', -- Border style for popups (rounded, single, double)
    },

    -- git commands from fileexplorer menu!
    mappings = {
      ['<leader>'] = {
        'toggle_node',
        nowait = false,
      },
      ['gu'] = { desc = 'Git unstaged file', 'git_unstage_file' },
      ['ga'] = { desc = 'Git add and commit (or just add) file/folder', git_actions.git_add_and_commit },
      ['gd'] = { desc = 'Git delete and auto commit file/folder', git_actions.git_delete_and_commit },
      ['gz'] = { desc = 'Git commit file(s)', git_actions.git_commit },
      ['gr'] = {
        desc = 'Git restore file',
        git_actions.git_restore,
      },
      ['gmv'] = {
        git_actions.git_move_file,
        desc = 'Git move file (no folders)',
      },
      ['gp'] = { desc = 'Git Push', 'git_push' },
      ['P'] = {
        'toggle_preview',
        config = {
          use_float = false,
          use_image_nvim = true,
          title = 'Neo-tree Previewer',
        },
      },
    },
  }, -- End of window settings

  -- Buffer management settings
  buffers = {
    follow_current_file = {
      enabled = true, -- Follow the currently active buffer
      leave_dirs_open = false, -- Close directories when switching buffers
    },
  }, -- End of Buffer management
  source_selector = {
    winbar = true,
    statusline = false,
  },
  event_handlers = {
    {
      event = 'file_open_requested',
      handler = function()
        require('neo-tree.command').execute({ action = 'close' })
      end,
    },
    -- {
    --   event = 'neo_tree_buffer_leave',
    --   handler = function()
    --     local wins = vim.api.nvim_list_wins()
    --
    --     for _, win in ipairs(wins) do
    --       local config = vim.api.nvim_win_get_config(win)
    --       if config.relative ~= '' then
    --         return -- Avbryt om en popup är öppen
    --       end
    --     end
    --
    --     -- Om ingen popup är aktiv, stäng Neo-tree
    --     require('neo-tree.command').execute({ action = 'close' })
    --   end,
    -- },
    -- {
    --   event = 'neo_tree_buffer_leave',
    --   handler = function()
    --     require('neo-tree.command').execute({ action = 'close' })
    --   end,
    -- },
  },
})

-- Ctrl + n: Toggle Neo-tree file explorer
map(
  'n',
  '<C-n>',
  ':Neotree toggle reveal_force_cwd=true<CR>',
  vim.tbl_extend('force', opts, { desc = 'Open File explorer' })
)
