local cmp = require('cmp')
local lspkind = require('lspkind')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local tailwind_formatter = require('tailwindcss-colorizer-cmp').formatter

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

local source_mapping = {
  nvim_lsp = '[LSP]',
  nvim_lsp_signature_help = '[SIG]', -- Signature Help
  luasnip = '[SNIP]',
  buffer = '[BUF]',
  path = '[PATH]',
  git = '[GIT]', -- Git-autocomplete
  conventionalcommits = '[COMMITS]', -- Conventional Commits
  -- cmdline = '[CMD]', -- Command-line autocomplete
  -- latex_symbols = '[LATEX]', -- Latex/Unicode symbols
  dotenv = '[ENV]',
}

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      vim_item = tailwind_formatter(entry, vim_item)
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
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      function(entry1, entry2)
        local kind1 = entry1:get_kind()
        local kind2 = entry2:get_kind()
        if kind1 ~= kind2 then
          if kind1 == cmp.lsp.CompletionItemKind.Keyword then
            return false
          end
          if kind2 == cmp.lsp.CompletionItemKind.Keyword then
            return true
          end
        end
      end,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  performance = {
    max_view_entries = 15,
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
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
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
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'nvim_lsp_signature_help', priority = 900 }, -- 🔹 Signature Help
    { name = 'luasnip', priority = 750 },
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 250 },
    { name = 'git', priority = 700 }, -- 🔹 Git-autocomplete
    { name = 'conventionalcommits', priority = 600 }, -- 🔹 Conventional Commits
    --{ name = 'cmdline', priority = 550 }, -- 🔹 Command-line autocomplete
    --{ name = 'latex_symbols', priority = 300 }, -- 🔹 Latex/Unicode symbols
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
        dotenv_environment = '^%.env.*$',
        file_priority = function(a, b)
          return a:upper() < b:upper()
        end,
      },
    },
  }),

  completion = {
    autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
    completeopt = 'menu,menuone,noinsert',
  },
  experimental = {
    ghost_text = false,
  },
  enabled = function()
    local context = require('cmp.config.context')
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype

    if buftype == 'prompt' then
      return false
    end
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    end

    local disabled_filetypes = { 'markdown', 'text', 'gitcommit', 'gitrebase', 'csv', 'log' }
    if vim.tbl_contains(disabled_filetypes, filetype) then
      return false
    end

    return not context.in_treesitter_capture('comment') and not context.in_syntax_group('Comment')
  end,
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path', priority = 500 },
    { name = 'cmdline', priority = 1000 },
  }),
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    {
      name = 'buffer',
      priority = 750,
      option = {
        keyword_pattern = [[\k\+]],
        keyword_length = 3,
      },
    },
  },
})
