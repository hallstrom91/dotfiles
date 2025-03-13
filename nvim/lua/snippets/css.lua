local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

  s('cssreset', {
    t({ '*::before,', '*::after {' }),
    t({ '', '  box-sizing: border-box;' }),
    t({ '', '}' }),
    t({ '', '', 'html,' }),
    t({ '', 'body {' }),
    t({ '', '  margin: 0;' }),
    t({ '', '  padding: 0;' }),
    t({ '', '}' }),
  }),
}
