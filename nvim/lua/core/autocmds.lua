local autocmd = vim.api.nvim_create_autocmd

local augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

--> Format on save
autocmd('BufWritePre', {
  group = augroup('AutoFormat'),
  pattern = { '*', '*.md' },
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})

--> open help window in vertical mode
autocmd('FileType', {
  group = augroup('HelpWindow'),
  pattern = 'help',
  command = 'wincmd L',
})

-- Auto update Treesitter Parsers
autocmd('VimEnter', {
  group = augroup('TreesitterUpdate'),
  pattern = 'VeryLazy',
  callback = function()
    vim.cmd('TSUpdate')
  end,
})

-- Recognize .bash_* files
autocmd({ 'BufRead', 'BufNewFile' }, {
  group = augroup('BashFiles'),
  pattern = '.bash_*',
  command = 'set filetype=bash',
})

autocmd('CursorMoved', {
  group = augroup('CursorHighlight'),
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

--> Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('HighlightYank'),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup('ClosePlugin'),
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})
