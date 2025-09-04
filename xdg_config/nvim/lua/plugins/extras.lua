return {

  ----| Neotree (File explorer) |----
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "s1n7ax/nvim-window-picker",
    },

    config = function()
      require("config.neotree")
    end,
  },

  ----| Window Picker |----
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      vim.keymap.set("n", "<leader>w", function()
        local picked_window_id = require("window-picker").pick_window()
        if picked_window_id then
          vim.api.nvim_set_current_win(picked_window_id)
        else
          print("Aborted - No window picked!")
        end
      end, { desc = "Window Picker" })
      require("window-picker").setup({
        hint = "floating-big-letter",
        selection_chars = "FJDKSLA;CMRUEIWOQP",

        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { "neo-tree-popup", "notify", "telescope" },
            buftype = { "terminal", "quickfix", "spectre", "bqf", "telescope" },
          },
        },
      })
    end,
  },

  ----| Bufferline (document 'tabs') |----
  {
    "akinsho/bufferline.nvim",
    version = "*",
    enabled = true,
    dependencies = {
      "famiu/bufdelete.nvim",
    },
    event = "BufWinEnter",
    config = function()
      require("config.bufferline")
    end,
  },

  ----| Lualine (statusbar in bottom) |----
  {
    "nvim-lualine/lualine.nvim",
    event = "BufWinEnter",
    dependencies = "Mofiqul/vscode.nvim",
    config = function()
      require("config.lualine")
    end,
  },

  ----| Colorizer (display colors #123456) |----
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "lua", "typescriptreact", "javascriptreact" },
    config = function()
      require("colorizer").setup({
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          css = true,
          css_fn = true,
          mode = "background",
          tailwind = true,
          always_update = true,
          virtualtext = "■",
        },
      })
    end,
  },

  ----| Markdown |----
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    -- ft = { "markdown", "mdx" }, -- test
    ft = "markdown",
    config = function()
      require("render-markdown").setup({
        latex = { enabled = false },
        heading = {
          icons = { " 󰲡 ", " 󰲣 ", " 󰲥 ", " 󰲧 ", " 󰲩 ", " 󰲫 " },
          signs = { "󰜴 " },
          border = true,
          above = "▄",
          below = "▀",
        },
      })
    end,
  },

  ----| Scrollbar |----
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufWinEnter" },
    config = function()
      require("config.scrollbar")
    end,
  },

  ----| Multiline cursor |----
  {
    "mg979/vim-visual-multi",
    branch = "master",
    enabled = false,
    config = function()
      -- add config here if enabled
    end,
  },

  ----| Comment |----
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },

  ----| Gitsigns  |----
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.gitsigns")
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },

  ----| TS Error Translator |----
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "typescriptreact" },
    config = function()
      require("ts-error-translator").setup()
    end,
  },

  ----| Git Conflict |----
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup({
        --default_mappings = true, -- disable buffer local mapping created by this plugin
        default_commands = true, -- disable commands created by this plugin
        disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
        list_opener = "copen", -- command or function to open the conflicts list
        highlights = { -- They must have background color, otherwise the default color will be used
          incoming = "DiffAdd",
          current = "DiffText",
        },
        -- keymaps
        default_mappings = {
          ours = "o",
          theirs = "t",
          none = "0",
          both = "b",
          next = "n",
          prev = "p",
        },
      })
    end,
  },
}
