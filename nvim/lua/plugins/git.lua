return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gstatus', 'Gcommit', 'Gpush', 'Gpull' },
    config = function()
      -- add config here or load config if needed
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('config.gitsigns')
      require('scrollbar.handlers.gitsigns').setup()
    end,
  },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
      'nvim-telescope/telescope.nvim', -- optional
    },
    cmd = { 'Neogit' },
    --keys = { '<C-ng>' },
    config = function()
      require('config.neogit')
    end,
  },
}
