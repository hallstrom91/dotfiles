return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      's1n7ax/nvim-window-picker',
    },

    config = function()
      require('config.neotree')
    end,
  },

  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    config = function()
      vim.keymap.set('n', '<leader>w', function()
        local picked_window_id = require('window-picker').pick_window()
        if picked_window_id then
          vim.api.nvim_set_current_win(picked_window_id)
        else
          print('Aborted - No window picked!')
        end
      end, { desc = 'Window Picker' })
      require('window-picker').setup({
        hint = 'floating-big-letter',
        selection_chars = 'FJDKSLA;CMRUEIWOQP',

        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { 'neo-tree-popup', 'notify', 'telescope' },
            buftype = { 'terminal', 'quickfix', 'spectre', 'bqf', 'telescope' },
          },
        },
      })
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = { '<leader>f', '<leader>p' },
    config = function()
      require('config.telescope')
    end,
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    dependencies = { 'nvim-telescope/telescope.nvim' },
  },
}
