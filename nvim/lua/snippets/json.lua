local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

  s("loggingconfig", {
    t({
      "{",
      '  "Logging": {',
      '    "LogLevel": {',
      '      "Default": "Information",',
      '      "Microsoft.AspNetCore": "Warning"',
      "    }",
      "  },",
    }),
    t({ "", '  "System": {', '    "GC": {', '      "Server": ' }),
    i(1, "false"),
    t({ ",", '      "Concurrent": ' }),
    i(2, "false"),
    t({ "", "    }", "  }", "}" }),
  }),
}
