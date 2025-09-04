local cmp = require("cmp")
local lspkind = require("lspkind")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local tailwind_formatter = require("tailwindcss-colorizer-cmp").formatter

require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.local/share/nvim/lazy/friendly-snippets/" })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

local source_mapping = {
  nvim_lsp = "[LSP]",
  luasnip = "[SNIP]",
  buffer = "[BUF]",
  path = "[PATH]",
}

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  formatting = {
    format = function(entry, vim_item)
      vim_item = tailwind_formatter(entry, vim_item)
      vim_item = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "...",
      })(entry, vim_item)

      vim_item.abbr = vim_item.abbr:gsub("%$%d", "")

      local kind = require("cmp.types").lsp.CompletionItemKind
      if (vim_item.kind == kind.Function or vim_item.kind == kind.Method) and entry.source.name == "nvim_lsp" then
        vim_item.abbr = vim_item.abbr:gsub("%b()", "()")
      end

      vim_item.menu = source_mapping[entry.source.name] or ""
      return vim_item
    end,
  },

  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.score,
      cmp.config.compare.exact,
      cmp.config.compare.locality,
      cmp.config.compare.recently_used,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },

  performance = {
    max_view_entries = 15,
  },

  window = {
    completion = {
      border = "rounded",
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    },
    documentation = {
      border = "rounded",
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    },
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        require("luasnip").expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        require("luasnip").jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", keyword_length = 1 },
    { name = "luasnip", keyword_length = 3 },
    { name = "buffer", keyword_length = 2 },
    { name = "path", keyword_length = 5 },
  }),

  completion = {
    autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
    completeopt = "menu,menuone,noinsert",
  },
  experimental = {
    ghost_text = false,
  },
  enabled = function()
    local context = require("cmp.config.context")
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype

    if buftype == "prompt" then
      return false
    end
    if vim.api.nvim_get_mode().mode == "c" then
      return true
    end

    local disabled_filetypes = { "text", "gitcommit", "gitrebase", "csv", "log" }
    if vim.tbl_contains(disabled_filetypes, filetype) then
      return false
    end

    return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
  end,
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path", keyword_length = 3 },
    { name = "cmdline" },
  }),
})

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    {
      name = "buffer",
      option = {
        keyword_pattern = [[\k\+]],
        keyword_length = 3,
      },
    },
  },
})
