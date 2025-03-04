return {

  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim', 'williamboman/mason.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('core.lsp.init')
    end,
  },
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    lazy = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = true,
  },
  -- {
  --   'williamboman/mason.nvim',
  --   build = ':MasonUpdate',
  --   config = function()
  --     require('mason').setup({
  --       ui = {
  --         icons = {
  --           package_installed = ' ',
  --           package_pending = ' ',
  --           package_uninstalled = ' ',
  --         },
  --       },
  --     })
  --   end,
  -- },
  --
  -- {
  --   'williamboman/mason-lspconfig.nvim',
  --   dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
  --   config = function()
  --     require('mason-lspconfig').setup({
  --       ensure_installed = vim.tbl_keys(require('lsp.servers')),
  --       automatic_installation = true,
  --     })
  --   end,
  -- },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',
      'SergioRibera/cmp-dotenv',
    },
    config = function()
      require('core.cmp.init')
    end,
  },

  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    build = 'make install_jsregexp',
  },

  {
    'Hoffs/omnisharp-extended-lsp.nvim',
    ft = 'cs',
    lazy = true,
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
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('config.autopairs').setup()
    end,
  },

  {
    'hinell/lsp-timeout.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      require('core.lsp.timeout').setup()
    end,
  },

  {
    'linrongbin16/lsp-progress.nvim',
    dependencies = { 'nvim-lualine/lualine.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('lsp-progress').setup()
    end,
  },

  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'InsertEnter',
    config = function()
      require('core.lsp.ts_autotag').setup()
    end,
  },

  -- lazy.nvim
  -- {
  --   'GustavEikaas/easy-dotnet.nvim',
  --   -- 'nvim-telescope/telescope.nvim' or 'ibhagwan/fzf-lua'
  --   -- are highly recommended for a better experience
  --   dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  --   config = function()
  --     local function get_secret_path(secret_guid)
  --       local path = ''
  --       local home_dir = vim.fn.expand('~')
  --       if require('easy-dotnet.extensions').isWindows() then
  --         local secret_path = home_dir
  --           .. '\\AppData\\Roaming\\Microsoft\\UserSecrets\\'
  --           .. secret_guid
  --           .. '\\secrets.json'
  --         path = secret_path
  --       else
  --         local secret_path = home_dir .. '/.microsoft/usersecrets/' .. secret_guid .. '/secrets.json'
  --         path = secret_path
  --       end
  --       return path
  --     end
  --
  --     local dotnet = require('easy-dotnet')
  --     -- Options are not required
  --     dotnet.setup({
  --       --Optional function to return the path for the dotnet sdk (e.g C:/ProgramFiles/dotnet/sdk/8.0.0)
  --       -- easy-dotnet will resolve the path automatically if this argument is omitted, for a performance improvement you can add a function that returns a hardcoded string
  --       -- You should define this function to return a hardcoded path for a performance improvement 🚀
  --       get_sdk_path = get_sdk_path,
  --       ---@type TestRunnerOptions
  --       test_runner = {
  --         ---@type "split" | "float" | "buf"
  --         viewmode = 'float',
  --         enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
  --         noBuild = true,
  --         noRestore = true,
  --         icons = {
  --           passed = '',
  --           skipped = '',
  --           failed = '',
  --           success = '',
  --           reload = '',
  --           test = '',
  --           sln = '󰘐',
  --           project = '󰘐',
  --           dir = '',
  --           package = '',
  --         },
  --         mappings = {
  --           run_test_from_buffer = { lhs = '<leader>r', desc = 'run test from buffer' },
  --           filter_failed_tests = { lhs = '<leader>fe', desc = 'filter failed tests' },
  --           debug_test = { lhs = '<leader>d', desc = 'debug test' },
  --           go_to_file = { lhs = 'g', desc = 'got to file' },
  --           run_all = { lhs = '<leader>R', desc = 'run all tests' },
  --           run = { lhs = '<leader>r', desc = 'run test' },
  --           peek_stacktrace = { lhs = '<leader>p', desc = 'peek stacktrace of failed test' },
  --           expand = { lhs = 'o', desc = 'expand' },
  --           expand_node = { lhs = 'E', desc = 'expand node' },
  --           expand_all = { lhs = '-', desc = 'expand all' },
  --           collapse_all = { lhs = 'W', desc = 'collapse all' },
  --           close = { lhs = 'q', desc = 'close testrunner' },
  --           refresh_testrunner = { lhs = '<C-r>', desc = 'refresh testrunner' },
  --         },
  --         --- Optional table of extra args e.g "--blame crash"
  --         additional_args = {},
  --       },
  --       ---@param action "test" | "restore" | "build" | "run"
  --       terminal = function(path, action, args)
  --         local commands = {
  --           run = function()
  --             return string.format('dotnet run --project %s %s', path, args)
  --           end,
  --           test = function()
  --             return string.format('dotnet test %s %s', path, args)
  --           end,
  --           restore = function()
  --             return string.format('dotnet restore %s %s', path, args)
  --           end,
  --           build = function()
  --             return string.format('dotnet build %s %s', path, args)
  --           end,
  --         }
  --
  --         local command = commands[action]() .. '\r'
  --         vim.cmd('vsplit')
  --         vim.cmd('term ' .. command)
  --       end,
  --       secrets = {
  --         path = get_secret_path,
  --       },
  --       csproj_mappings = true,
  --       fsproj_mappings = true,
  --       auto_bootstrap_namespace = {
  --         --block_scoped, file_scoped
  --         type = 'block_scoped',
  --         enabled = true,
  --       },
  --       -- choose which picker to use with the plugin
  --       -- possible values are "telescope" | "fzf" | "basic"
  --       picker = 'telescope',
  --     })
  --
  --     -- Example command
  --     vim.api.nvim_create_user_command('Secrets', function()
  --       dotnet.secrets()
  --     end, {})
  --
  --     -- Example keybinding
  --     vim.keymap.set('n', '<C-p>', function()
  --       dotnet.run_project()
  --     end)
  --   end,
  -- },
}
