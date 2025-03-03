local cmp_status, cmp = pcall(require, 'cmp')
if not cmp_status then
  return {}
end

return {
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
  completion = {
    autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
    --autocomplete = { cmp.TriggerEvent.TextChanged },
    completeopt = 'menu,menuone,noinsert',
  },
  experimental = {
    ghost_text = false,
  },
  performance = {
    max_view_entries = 15,
  },

  enabled = function()
    local context = require('cmp.config.context')
    local buftype = vim.bo.buftype

    if buftype == 'prompt' then
      return false
    end

    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    end

    return not context.in_treesitter_capture('comment') and not context.in_syntax_group('Comment')
  end,
}
