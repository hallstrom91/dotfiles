local M = {}

M.setup = function()
  local Rule = require("nvim-autopairs.rule")
  local npairs = require("nvim-autopairs")
  local ts_conds = require("nvim-autopairs.ts-conds")

  -- DEBUG:
  --local cond = require("nvim-autopairs.conds")
  --print(vim.inspect(cond))

  npairs.setup({
    enable_check_bracket_line = true,
    check_ts = true,
    --fast_wrap = {},
    disable_filetype = {
      "TelescopePrompt",
      "spectre_panel",
      "neo-tree",
      -- "snacks_picker_input"
    },
  })

  -- BEFORE: (item)=
  -- INSERT: >
  -- AFTER: (item)=> { }
  npairs.add_rules({
    Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript" })
      :use_regex(true)
      :set_end_pair_length(2),
  })

  -- add trailing commas to "'} inside Lua tables
  npairs.add_rules({
    Rule("{", "},", "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
    Rule("'", "',", "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
    Rule('"', '",', "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
  })
end

return M
