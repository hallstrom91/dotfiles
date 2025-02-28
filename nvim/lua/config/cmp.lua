local cmp = require('cmp')
local tailwind_formatter = require('tailwindcss-colorizer-cmp').formatter
local lspkind = require('lspkind')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

local source_mapping = {
  nvim_lsp = '[LSP]',
  nvim_lua = '[LUA]',
  luasnip = '[SNIP]',
  buffer = '[BUF]',
  path = '[PATH]',
}

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      ----> tailwind formatter
      vim_item = tailwind_formatter(entry, vim_item)

      ----> show icons from lspkind
      vim_item = lspkind.cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
        ellipsis_char = '...',
      })(entry, vim_item)

      vim_item.abbr = vim_item.abbr:gsub('%$%d', '')

      vim_item.menu = source_mapping[entry.source.name] or ''
      return vim_item
    end,
  },
  performance = {
    max_view_entries = 15, -- number of suggestion displayed
  },
  window = {
    completion = {
      border = 'rounded',
      winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
    },
    documentation = {
      border = 'rounded',
      winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
    },
  },

  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),

    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),

    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },

  sources = cmp.config.sources({
    {
      name = 'nvim_lsp',
      -- entry_filter = function(entry, _)
      --   local kinds_to_ignore = {
      --     cmp.lsp.CompletionItemKind.Module, -- Förhindra att hela moduler föreslås som duplicerade imports
      --     cmp.lsp.CompletionItemKind.Text,
      --   }
      --   return not vim.tbl_contains(kinds_to_ignore, entry:get_kind())
      -- end,
    },
    { name = 'luasnip' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
        keyword_length = 3,
      },
    },
    { name = 'nvim_lua' },

    {
      name = 'dotenv',
      option = {
        path = '.',
        load_shell = false,
        item_kind = cmp.lsp.CompletionItemKind.Variable,
        eval_on_confirm = false,
        show_documentation = true,
        show_content_on_docs = true,
        documentation_kind = 'markdown',
        dotenv_environment = '^%.env.*$', ----> show values of all env-files in project at import
        file_priority = function(a, b)
          return a:upper() < b:upper()
        end,
      },
    },
  }),
  completion = {
    autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged }, ----> Trigger only after typing
    completeopt = 'menu,menuone,noinsert',
  },
  experimental = {
    ghost_text = false,
  },
  enabled = function()
    local context = require('cmp.config.context')
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype -- test

    if buftype == 'prompt' then
      return false
    end

    -- remove below?
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    end

    -- Test no completion in non-code files like .md
    local disabled_filetypes = {
      'markdown',
      'text',
      'gitcommit',
      'gitrebase',
      'csv',
      'log',
    }

    if vim.tbl_contains(disabled_filetypes, filetype) then
      return false
    end

    ----> remove suggestions on comment lines
    return not context.in_treesitter_capture('comment') and not context.in_syntax_group('Comment')
  end,
})

----> for ":" (cmdline)
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline', keyword_length = 1 },
  }),
  --  matching = { disallow_symbol_nonprefix_matching = false },
})

-- For `/` (search)
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- vim.api.nvim_set_hl(0, 'Pmenu', { bg = '#2E3440', fg = '#D8DEE9' })
-- vim.api.nvim_set_hl(0, 'PmenuSel', { bg = '#4C566A', fg = '#D8DEE9' })
-- vim.api.nvim_set_hl(0, 'PmenuSbar', { bg = '#3B4252' })
-- vim.api.nvim_set_hl(0, 'PmenuThumb', { bg = '#4C566A' })
