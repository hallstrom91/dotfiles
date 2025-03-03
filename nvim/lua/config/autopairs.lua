local M = {}

M.setup = function()
  local autopairs = require('nvim-autopairs')
  local Rule = require('nvim-autopairs.rule')

  autopairs.setup({
    disable_filetype = { 'TelescopePrompt', 'dashboard' },
    check_ts = true,
  })

  autopairs.add_rules({
    Rule('{', '}'):with_pair(function(opts)
      local line = opts.line
      return not line:match('^%s*import%s*{.*')
    end),

    Rule(';', ''):with_pair(function(opts)
      local line = opts.line
      return line:match('^%s*import%s+.*;$') ~= nil
    end),
  })

  local cmp_status, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
  if cmp_status then
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end
end

return M
