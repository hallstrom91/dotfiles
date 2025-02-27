return {
  {

    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'famiu/bufdelete.nvim',
    },
    event = 'BufWinEnter',
    config = function()
      require('config.bufferline')
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-web-devicons' },
    event = 'BufWinEnter',
    config = function()
      require('config.lualine')
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('config.indent-blankline')
    end,
  },

  {
    'NvChad/nvim-colorizer.lua',
    ft = { 'css', 'scss', 'html', 'javascript', 'typescript', 'lua', 'typescriptreact', 'javascriptreact' },
    config = function()
      require('colorizer').setup({
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          css = true,
          css_fn = true,
          mode = 'background',
          tailwind = true,
          always_update = true,
          virtualtext = '■',
        },
      })
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = 'markdown',
    config = function()
      require('render-markdown').setup({
        latex = { enabled = false },
        heading = {
          icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
          signs = { '󰜴 ' },
          border = true,
          above = '▄',
          below = '▀',
        },
      })
    end,
  },

  {
    'rockyzhang24/arctic.nvim',
    branch = 'v2',
    dependencies = { 'rktjmp/lush.nvim' },
    enabled = false, -- put true if you want to use
    config = function()
      vim.cmd('colorscheme arctic')
    end,
  },

  {
    'askfiy/visual_studio_code',
    priority = 100,
    enabled = false, -- change to false if you want another theme
    config = function()
      vim.cmd([[colorscheme visual_studio_code]])
      require('visual_studio_code').setup({
        mode = 'dark', -- dark / light
        preset = true, -- Whether to load all color schemes
        transparent = true, -- Whether to enable background transparency
        expands = {
          -- Whether to apply the adapted plugin
          hop = false,
          dbui = false,
          lazy = true,
          aerial = false,
          null_ls = false,
          nvim_cmp = true,
          gitsigns = true,
          which_key = true,
          nvim_tree = false,
          lspconfig = true,
          telescope = true,
          bufferline = true,
          nvim_navic = false,
          nvim_notify = true,
          vim_illuminate = false,
          nvim_treesitter = true,
          nvim_ts_rainbow = false,
          nvim_scrollview = true,
          nvim_ts_rainbow2 = false,
          indent_blankline = true,
          vim_visual_multi = false,
        },
        hooks = {
          before = function(conf, colors, utils) end,
          after = function(conf, colors, utils) end,
        },
      })
    end,
  },

  {
    'petertriho/nvim-scrollbar',
    event = { 'BufReadPost', 'BufWinEnter' },
    config = function()
      require('config.scrollbar')
    end,
  },

  {
    'mg979/vim-visual-multi',
    branch = 'master',
    enabled = false,
    config = function()
      -- add config here if enabled
    end,
  },

  -- theme development - testing
  {
    dir = '~/.local/share/nvim/lazy/webdever-theme',
    enabled = true,
    config = function()
      --   vim.cmd([[colorscheme webdever-theme]])
      require('webdever-theme').setup({
        mode = 'dark',
        cmp = true,
        telescope = true,
        whichkey = true,
        rainbow = true,
        ibl = true,
        neotree = true,
        bufferline = false,
      })
    end,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    enable = false,
    priority = 1000,
    config = function()
      --vim.cmd([[colorscheme catppuccin-macchiato]]) --> latte, frappe, macchiato, mocha

      require('catppuccin').setup({
        flavor = 'auto', --> latte, frappe, macchiato, mocha
        background = { -- :h background
          light = 'latte',
          dark = 'frappe',
        },
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { 'italic' }, -- Change the style of comments
          conditionals = { 'italic' },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
          -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          neotree = true,
          treesitter_context = true,
          ts_rainbow = true,
          window_picker = true,
          render_markdown = true,
          which_key = true,
          rainbow_delimiters = true,
          indent_blankline = {
            enabled = true,
            scope_color = 'lavender', -- catppuccin color (eg. `lavender`) Default: text
            colored_indent_levels = false, -- false default
          },
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
            ok = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
            ok = { 'underline' },
          },
          inlay_hints = {
            background = true,
          },
        },
      })
    end,
  },

  { 'nvim-tree/nvim-web-devicons', lazy = true },
}
