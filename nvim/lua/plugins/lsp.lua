return {

  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('config.lspconfig')
    end,
  },

  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    config = function()
      local mason = require('mason')

      mason.setup({
        ui = {
          icons = {
            package_installed = ' ',
            package_pending = ' ',
            package_uninstalled = ' ',
          },
        },
        ensured_installed = { 'pip' }, -- python
      })
    end,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      local mason_lspconfig = require('mason-lspconfig')

      mason_lspconfig.setup({
        --> Only LSP servers (auto-install)
        ensure_installed = {
          'ts_ls',
          'html',
          'cssls',
          'pyright',
          'lua_ls',
          'tailwindcss',
          'marksman',
          'quick_lint_js',
          'vimls',
          'yamlls',
          'cssmodules_ls',
          'css_variables',
          'bashls',
          'jsonls',
          'omnisharp',
        },
        automatic_installation = true,
      })
    end,
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          ----> Linters och formatters
          'bash-language-server',
          'bash-debug-adapter',
          'markdownlint-cli2',
          'prettierd',
          --| 'prettier', |---> 'prettierd' is faster.
          'shellcheck',
          'shfmt',
          'stylua',
          'csharpier',
        },
        auto_update = true,
        run_on_start = true,
        start_delay = 3000, -- 3s delay
        debounce_hours = 24, -- 24h between update attempts
        integrations = {
          ['mason-lspconfig'] = true,
          ['mason-null-ls'] = false,
          ['mason-nvim-dap'] = false,
        },
      })
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',
      'SergioRibera/cmp-dotenv',
    },
    config = function()
      require('config.cmp')
    end,
  },

  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    ----> install jsregexp (optional!).
    build = 'make install_jsregexp',
    event = { 'InsertEnter' },
    config = function()
      local luasnip = require('luasnip')

      luasnip.config.set_config({
        enable_autosnippets = true,
        store_selection_keys = '<Tab>',
      })

      require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.local/share/nvim/lazy/friendly-snippets/' })
      require('luasnip.loaders.from_lua').load({ paths = '~/.config/nvim/lua/snippets/' })
    end,
  },

  {
    'hinell/lsp-timeout.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      vim.g.lspTimeoutConfig = {
        stopTimeout = 1000 * 60 * 25, ----> 25min until LSP shutdown if inactive.
        startTimeout = 1000 * 5, ----> 5s to restart LSP for buffer
        silent = false,
        filetypes = {
          ignore = { 'markdown', 'plaintext' },
        },
      }

      local Config = require('lsp-timeout.config').Config
      Config:new(vim.g.lspTimeoutConfig):validate()
    end,
  },

  {
    'roobert/tailwindcss-colorizer-cmp.nvim',
    ft = { 'html', 'javascript', 'typescript', 'css' },
    config = function()
      require('tailwindcss-colorizer-cmp').setup({
        color_square_width = 2,
      })
    end,
  },

  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'InsertEnter',
    config = function()
      require('nvim-ts-autotag').setup({
        enable = true,
        filetype = { 'html', 'xml', 'javascript', 'typescript', 'typescriptreact', 'javascriptreact' },
        opts = {
          enable_close = true,
          enable_rename = false,
          enable_close_on_slash = true,
        },
      })
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local autopairs = require('nvim-autopairs')
      local Rule = require('nvim-autopairs.rule')

      autopairs.setup({
        disable_filetype = { 'TelescopePrompt', 'dashboard' },
        check_ts = true,
      })

      -- test rule - TO NOT add () to imported modules in js,jsx,tsx files
      autopairs.add_rules({
        Rule('{', '}'):with_pair(function(opts)
          local line = opts.line
          return not line:match('^%s*import%s*{.*') -- If row starts with -  import {
        end),

        Rule(';', ''):with_pair(function(opts)
          local line = opts.line
          return line:match('^%s*import%s+.*;$') ~= nil
        end),
      })
    end,
  },

  {
    'linrongbin16/lsp-progress.nvim',
    dependencies = { 'nvim-lualine/lualine.nvim' }, ----> Lualine integration
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('lsp-progress').setup()
    end,
  },
}
