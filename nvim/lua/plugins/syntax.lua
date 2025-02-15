return {

  {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'vim',
          'lua',
          'bash',
          'markdown',
          'markdown_inline',
          'html',
          'css',
          'javascript',
          'tsx', -- ?
          'typescript',
          'json',
          'jsonc',
          'c_sharp',
        },
        sync_install = false,
        auto_install = false,
        fold = { enable = false }, -- using nvim-ufo for folding
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = 'nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('treesitter-context').setup({
        enable = true,
        multiwindow = true,
      })
      --	custom highlight color for context
      vim.api.nvim_set_hl(0, 'TreesitterContextBottom', {
        underline = true,
        bg = '#3b3b3b', -- bg
        sp = '#909190', -- underline
      })
      -- custom highlight number color for context
      vim.api.nvim_set_hl(0, 'TreesitterContextLineNumberBottom', {
        underline = true,
        bg = '#ffffff', -- bg
        sp = '#67a137', -- underline
      })

      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true })
    end,
  },

  {
    'stevearc/conform.nvim',
    opts = {},
    event = { 'BufWritePre', 'BufWritePost' },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          javascript = { 'prettierd' },
          javascriptreact = { 'prettierd' },
          typescript = { 'prettierd' },
          typescriptreact = { 'prettierd' },
          html = { 'prettierd' },
          css = { 'prettierd' },
          markdown = { 'prettierd' },
          json = { 'prettierd' },
          jsonc = { 'prettierd' },
          csharp = { 'csharpier' },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        },
        options = {
          prefer_local = '.prettierrc', -- priority local (project) prettier config
        },
      })
    end,
  },

  {
    'mattn/emmet-vim',
    ft = { 'html', 'css', 'javascript', 'typescript', 'jsx', 'tsx' },
    config = function()
      vim.g.user_emmet_leader_key = '<C-Z>' -- leaderkey for emmet ctrl+Z
    end,
  },

  {
    'numToStr/Comment.nvim',
    lazy = true,
    keys = {
      { 'gc', mode = { 'n', 'v' }, desc = 'Toggle comment (line)' },
      { 'gb', mode = { 'n', 'v' }, desc = 'Toggle comment (block)' },
    },
    config = function()
      require('Comment').setup({
        opleader = {
          line = 'gc', -- comment on or several rows
          block = 'gb', -- block comment for marked rows
        },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
  },

  {
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          javascript = 'rainbow-parens',
          typescript = 'rainbow-parens',
          tsx = 'rainbow-parens',
          lua = 'rainbow-blocks',
        },
        priority = {
          [''] = 110,
          lua = 210,
        },
      }
    end,
  },
}
