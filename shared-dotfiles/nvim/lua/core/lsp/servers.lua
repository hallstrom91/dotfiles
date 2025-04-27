local util = require("lspconfig.util")

return {
  ----| TypeScript & JavaScript |----
  ts_ls = {
    root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
    cmd = { "typescript-language-server", "--stdio" },
    init_options = require("modules.ts_ls_init_opts").get_ts_ls_init_options(),
    settings = {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    },
  },

  ----| CSS |----
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    settings = {
      css = { validate = true, lint = { unknownAtRules = "ignore" } },
      scss = { validate = true },
      less = { validate = true },
    },
  },

  ----| HTML |----
  html = { filetypes = { "html" } },

  ----| LUA |----
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim" },
          -- disable = {"undefined-field"},
        },
        workspace = {
          library = {
            --  vim.env.VIMRUNTIME,
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
          },
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        completion = { enable = true, callSnippet = "Replace", keywordSnippet = "Both" },
        hint = {
          enable = true,
          setType = false,
          paramType = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
      },
    },
    filetypes = { "lua" },
  },

  ----| Markdown |----
  marksman = { filetypes = { "markdown" } },

  ----| JavaScript Linting |----
  -- quick_lint_js = {
  --   filetypes = { "javascript", "javascriptreact", "typescriptreact", "typescript" },
  -- },

  ----| Vimscript |----
  vimls = { filetypes = { "vim" } },

  ----| YAML |----
  yamlls = { filetypes = { "yaml", "yml" } },

  ----| CSS Modules |----
  cssmodules_ls = {
    filetypes = { "javascript", "javascriptreact", "javascript.jsx" },
    camelCase = true,
  },

  ----| Bash |----
  bashls = { filetypes = { "sh", "bash" } },

  ----| JSON |----
  jsonls = {
    root_dir = util.root_pattern("package.json", ".git", "."),
    filetypes = { "json", "jsonc" },
  },

  ----| C# .NET |----
  csharp_ls = {
    cmd = { "csharp-ls" },
    root_dir = function(fname)
      return util.root_pattern("*.sln")(fname) or util.root_pattern("*.csproj")(fname)
    end,
    filetypes = { "cs" },
    init_options = {
      AutomaticWorkspaceInit = true,
    },
    handlers = {
      ["textDocument/definition"] = require("csharpls_extended").handler,
      ["textDocument/typeDefinition"] = require("csharpls_extended").handler,
    },
    settings = {
      csharp = {
        enableCodeLens = true,
        semanticTokens = { enabled = true },
        inlayHints = {
          parameters = { enabled = true },
          typeHints = { enabled = true },
        },
        formatting = { enabled = true },
        hover = { enabled = true },
      },
    },
  },
}
