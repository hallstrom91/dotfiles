local cmp_status, cmp = pcall(require, 'cmp')
if not cmp_status then
  return
end

local luasnip = require('luasnip')
local mappings = require('core.cmp.mappings')
local sources = require('core.cmp.sources')
local formatting = require('core.cmp.formatting')
local settings = require('core.cmp.settings')
local snippets = require('core.cmp.snippets')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = formatting,
  mapping = mappings,
  sources = sources,
  window = settings.window,
  completion = settings.completion,
  experimental = settings.experimental,
  performance = settings.performance,
})

-- For ":" (cmdline)
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline', keyword_length = 1 },
  }),
})

-- For "/" (search
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})

local autopairs_status, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if autopairs_status then
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

-- local cmp = require('cmp')
-- local lspkind = require('lspkind')
-- local tailwind_formatter = require('tailwindcss-colorizer-cmp').formatter
-- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
-- local luasnip = require('luasnip')
--
-- -- Formatteringsinställningar
-- local formatting = {
--   format = function(entry, vim_item)
--     vim_item = tailwind_formatter(entry, vim_item)
--
--     vim_item = lspkind.cmp_format({
--       mode = 'symbol_text',
--       maxwidth = 50,
--       ellipsis_char = '...',
--     })(entry, vim_item)
--
--     vim_item.abbr = vim_item.abbr:gsub('%$%d', '')
--
--     local menu_labels = {
--       nvim_lsp = '[LSP]',
--       luasnip = '[SNIP]',
--       buffer = '[BUF]',
--       path = '[PATH]',
--     }
--
--     vim_item.menu = menu_labels[entry.source.name] or ''
--
--     return vim_item
--   end,
-- }
--
-- -- Källor för CMP
-- local sources = cmp.config.sources({
--   { name = 'nvim_lsp' },
--   { name = 'luasnip' },
--   { name = 'buffer' },
--   { name = 'nvim_lua' },
--   { name = 'path' },
--   {
--     name = 'dotenv',
--     option = {
--       path = '.',
--       load_shell = false,
--       item_kind = cmp.lsp.CompletionItemKind.Variable,
--       eval_on_confirm = false,
--       show_documentation = true,
--       show_content_on_docs = true,
--       documentation_kind = 'markdown',
--       dotenv_environment = '^%.env.*$',
--       file_priority = function(a, b)
--         return a:upper() < b:upper()
--       end,
--     },
--   },
-- })
--
-- -- CMP inställningar
-- cmp.setup({
--   snippet = {
--     expand = function(args)
--       luasnip.lsp_expand(args.body)
--     end,
--   },
--   formatting = formatting,
--   mapping = mappings,
--   sources = sources,
--   window = {
--     completion = {
--       border = 'rounded',
--       winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
--     },
--     documentation = {
--       border = 'rounded',
--       winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
--     },
--   },
--   completion = {
--     autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
--     completeopt = 'menu,menuone,noinsert',
--   },
--   experimental = {
--     ghost_text = false,
--   },
--   performance = {
--     max_view_entries = 15,
--   },
-- })
--
-- -- Integrera CMP med nvim-autopairs
-- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
--
-- -- För ":" (cmdline)
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' },
--   }, {
--     { name = 'cmdline', keyword_length = 1 },
--   }),
-- })
--
-- -- För "/" (sökning)
-- cmp.setup.cmdline('/', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = {
--     { name = 'buffer' },
--   },
-- })
