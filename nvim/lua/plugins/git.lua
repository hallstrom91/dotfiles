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
}
