local cmp = require('cmp')
--cmp.register_source('easy-dotnet', require('easy-dotnet').package_completion_source)

return cmp.config.sources({
  { name = 'nvim_lsp' },
  -- { name = 'nvim_lsp_signature_help' },
  { name = 'easy-dotnet' },
  { name = 'luasnip' },
  { name = 'buffer' },
  { name = 'nvim_lua' },
  { name = 'path' },
  {
    name = 'dotenv',
    option = {
      path = '.',
      load_shell = false,
      item_kind = require('cmp').lsp.CompletionItemKind.Variable,
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
})
