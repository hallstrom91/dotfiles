local autocmd = vim.api.nvim_create_autocmd

-- Format on save
autocmd('BufWritePre', {
  pattern = { '*', '*.md' },
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})

-- open help window in vertical mode
autocmd('FileType', {
  pattern = 'help',
  command = 'wincmd L',
})

-- Auto update Treesitter Parsers
autocmd('VimEnter', {
  pattern = 'VeryLazy',
  callback = function()
    vim.cmd('TSUpdate')
  end,
})

-- Recognize .bash files
autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '.bash_*',
  command = 'set filetype=bash',
})

autocmd('CursorMoved', {
  callback = function()
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
    if buftype == '' then
      vim.cmd('highlight CursorJump guibg=#88C0D0 guifg=#31363F')
      vim.cmd('setlocal cursorline')
      vim.defer_fn(function()
        vim.cmd('setlocal nocursorline')
      end, 300)
    end
  end,
})
