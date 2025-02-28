return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('config.dashboard')
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },

  {
    'folke/noice.nvim',
    event = { 'BufReadPre', 'BufNewFile' }, -- test
    opts = {},
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup({
        lsp = {
          signature = {
            enabled = true,
          },
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = false,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({})
    end,
  },

  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    enabled = false,
    config = function()
      require('config.bqf')
    end,
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'lua', 'html', 'css', 'json', 'jsonc' },
    config = function()
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      })
    end,
  },

  {
    'nvim-pack/nvim-spectre',
    config = function()
      require('config.spectre')
    end,
  },

  {
    'tpope/vim-surround',
  },
}
