local M = {}

M.setup = function()
  local autopairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")

  autopairs.setup({
    disable_filetype = { "TelescopePrompt", "dashboard" },
    check_ts = true,
  })

  autopairs.add_rules({
    Rule("{", "}"):with_pair(function(opts)
      local line = opts.line
      return not line:match("^%s*import%s*{.*")
    end),

    Rule(";", ""):with_pair(function(opts)
      local line = opts.line
      return line:match("^%s*import%s+.*;$") ~= nil
    end),
  })

  -- Stoppa () i import-rader
  autopairs.get_rule("("):with_pair(function(opts)
    local line = opts.line
    return not line:match("^%s*import%s*{")
  end)
end

return M
