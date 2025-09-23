local cmp = require("cmp")
local lspkind = require("lspkind")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
-- local tailwind_formatter = require("tailwindcss-colorizer-cmp").formatter
local handlers = require("nvim-autopairs.completion.handlers")

local tailwind_fmt = (function()
  local ok, m = pcall(require, "tailwind-colorizer-cmp")
  if ok and m and m.formatter then
    return m.formatter
  end
  return function(_, item)
    return item
  end
end)()

require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.local/share/nvim/lazy/friendly-snippets/" })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })

local function ts_current_node()
  if vim.treesitter and vim.treesitter.get_node then
    local ok, node = pcall(vim.treesitter.get_node, { win = 0 })
  end
  return nil
end

local TS_NODE_TYPES = {
  -- ECMA imports
  named_imports = true,
  import_specifier = true,
  import_clause = true,

  -- JSX/TSX
  jsx_opening_element = true,
  jsx_self_closing_element = true,
  jsx_attribute = true,
  jsx_element = true,
  jsx_fragment = true,
}
local function autopairs_disabled_context()
  local node = ts_current_node()
  if not node then
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before = vim.api.nvim_get_current_line():sub(1, col)
    if before:match("<%s*[%w_][%w_%.%-]*$") or before:match("^%s*impor%s+{[^]}*$") then
      return true
    end
    return false
  end
  while node do
    local t = node:type()
    if TS_NODE_TYPES[t] then
      return true
    end
    node = node:parent()
  end
  return false
end

local default_handler = cmp_autopairs.filetypes["*"]["("].handler
cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done({
    filetypes = {
      ["*"] = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method,
          },
          handler = function(char, item, bufnr, rules, commit_character)
            if autopairs_disabled_context() then
              if item and item.data then
                item.data.funcParensDisabled = true
              else
                char = ""
              end
            end
            default_handler(char, item, bufnr, rules, commit_character)
          end,
        },
      },
    },
  })
)

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
      vim_item = tailwind_fmt(entry, vim_item) -- NO-OP if tailwind.formatter is disabled

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

  performance = {
    max_view_entries = 20,
  },

  window = {
    completion = {
      border = "rounded",
    },
    documentation = {
      border = "rounded",
      --   winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
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
    -- order of sources determines-> completion order
    -- higher group_index value -> dont show if lower exist
    { name = "nvim_lsp", keyword_length = 1, group_index = 1 },
    { name = "css-variables", group_index = 1 },
    { name = "luasnip", keyword_length = 2, group_index = 2 },
    { name = "buffer", keyword_length = 3, group = 1 },
    { name = "path", keyword_length = 3, group = 1 },
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
    { name = "path", keyword_length = 1 },
    { name = "cmdline" },
  }),
  matching = { disallow_symbol_nonprefix_matching = false },
})

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    {
      name = "buffer",
      option = {
        keyword_length = 2,
      },
    },
  },
})
