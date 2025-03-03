local cmp = require('cmp')
local luasnip = require('luasnip')
luasnip.config.set_config({
  enable_autosnippets = true,
  store_selection_keys = '<Tab>',
})

require('luasnip.loaders.from_vscode').lazy_load({ paths = vim.fn.stdpath('data') .. '/lazy/friendly-snippets/' })

-- Ladda egna snippets (om du har egna LuaSnip-snippets)
require('luasnip.loaders.from_lua').load({ paths = vim.fn.stdpath('config') .. '/lua/snippets/' })
