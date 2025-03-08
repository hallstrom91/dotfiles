return {

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'williamboman/mason.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
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

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- lsp, signature, bufs, filesys, cmd
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      -- snippets
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      -- extra
      'onsails/lspkind.nvim',
      'SergioRibera/cmp-dotenv',
      'petertriho/cmp-git', -- Git commit & branches
      'davidsierradz/cmp-conventionalcommits', -- Conventional commits
      'amarakon/nvim-cmp-lua-latex-symbols', -- Latex/Unicode symbols
    },
    config = function()
      require('config.cmp')
    end,
  },

  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    build = 'make install_jsregexp',
  },

  {
    'seblyng/roslyn.nvim',
    ft = 'cs',
    opts = {
      config = {
        cmd = {
          'dotnet',
          '--fx-version',
          '8.0.13',
          vim.fn.stdpath('data') .. '/mason/packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer.dll',
        },
        args = {
          '--logLevel=Information',
          '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
        },
        filewatching = false, --> false for performance
        settings = {
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
          },
          ['csharp|completion'] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ['csharp|background_analysis'] = {
            background_analysis_dotnet_compiler_diagnostics_scope = 'openFilesOnly', --> "fullSolution" or "openFilesOnly"
          },
          ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = true,
          },
        },
      },
    },
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
}
