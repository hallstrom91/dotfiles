require('lazy').setup({
  spec = {
    { import = 'plugins' },
  },
  install = { colorscheme = { 'habamax' } },
  -- automatically check for plugin updates
  checker = { enabled = true, frequency = 86400 },
  opts = {
    rocks = {
      enabled = false,
      hererocks = false,
    },
  },
})

local user_grp = vim.api.nvim_create_augroup('LazyUserGroup', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lazy',
  desc = 'Quit lazy with <esc>',
  callback = function()
    vim.keymap.set('n', '<esc>', function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = true, nowait = true })
  end,
  group = user_grp,
})
