local lspkind = require('lspkind')
local tailwind_formatter = require('tailwindcss-colorizer-cmp').formatter

return {
  format = function(entry, vim_item)
    vim_item = tailwind_formatter(entry, vim_item)

    vim_item = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
    })(entry, vim_item)

    vim_item.abbr = vim_item.abbr:gsub('%$%d', '')

    local menu_labels = {
      nvim_lsp = '[LSP]',
      nvim_lsp_signature_help = '[SIGN]',
      luasnip = '[SNIP]',
      buffer = '[BUF]',
      path = '[PATH]',
      nvim_lua = '[LUA]',
      dotenv = '[ENV]',
    }

    vim_item.menu = menu_labels[entry.source.name] or 'UNK'

    return vim_item
  end,
}
