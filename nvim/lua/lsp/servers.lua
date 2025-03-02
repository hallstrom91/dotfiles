local util = require('lspconfig.util')
local rootpath = os.getenv('HOME')

return {
  --> TypeScript & JavaScript
  ts_ls = {
    root_dir = util.root_pattern('tsconfig.json', 'package.json', '.git'),
    cmd = { 'typescript-language-server', '--stdio' },
    init_options = {
      plugins = {
        {
          name = '@styled/typescript-styled-plugin',
          location = rootpath .. '/.nvm/versions/node/v18.20.7/lib/node_modules/@styled/typescript-styled-plugin',
          languages = {
            'javascript',
            'typescript',
            'javascriptreact',
            'typescriptreact',
            'javascript.jsx',
            'typescript.tsx',
            '.tsx',
            '.ts',
          },
        },
      },
    },
    settings = {
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    },
  },

  --> CSS
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    settings = {
      css = { validate = true, lint = { unknownAtRules = 'ignore' } },
      scss = { validate = true },
      less = { validate = true },
    },
  },

  --> HTML
  html = { filetypes = { 'html' } },

  --> Lua
  lua_ls = {
    settings = {
      Lua = {
        format = { enable = false }, -- Vi använder conform för formatering
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.stdpath('config') .. '/lua'] = true,
          },
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },

  --> Markdown
  marksman = { filetypes = { 'markdown' } },

  --> JavaScript Linting
  quick_lint_js = {
    filetypes = { 'javascript', 'javascriptreact', 'typescriptreact', 'typescript' },
  },

  --> Vimscript
  vimls = { filetypes = { 'vim' } },

  --> YAML
  yamlls = { filetypes = { 'yaml', 'yml' } },

  --> CSS Modules
  cssmodules_ls = {
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx' },
    camelCase = true,
  },

  --> Bash
  bashls = { filetypes = { 'sh', 'bash' } },

  --> JSON
  jsonls = {
    root_dir = util.root_pattern('package.json', '.git', '.'),
    filetypes = { 'json', 'jsonc' },
  },

  --> C# .NET med OmniSharp
  omnisharp = {
    cmd = { 'dotnet', vim.fn.stdpath('data') .. '/mason/packages/omnisharp/libexec/OmniSharp.dll' },
    filetypes = { 'cs' },
    root_dir = util.root_pattern('*.sln', '*.csproj', '.git'),
    settings = {
      FormattingOptions = { EnableEditorConfigSupport = true, OrganizeImports = true },
      MsBuild = { LoadProjectsOnDemand = true },
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
        EnableImportCompletion = true,
        AnalyzeOpenDocumentsOnly = true,
      },
      Sdk = { IncludePrereleases = false },
    },
  },
}

-- return {
--   tsserver = {
--     root_dir = util.root_pattern('tsconfig.json', 'package.json', '.git'),
--     cmd = { 'typescript-language-server', '--stdio' },
--     settings = {
--       filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
--     },
--   },
--
--   cssls = {
--     cmd = { 'vscode-css-language-server', '--stdio' },
--     filetypes = { 'css', 'scss', 'less' },
--     settings = {
--       css = { validate = true, lint = { unknownAtRules = 'ignore' } },
--       scss = { validate = true },
--       less = { validate = true },
--     },
--   },
--
--   html = { filetypes = { 'html' } },
--   pyright = { filetypes = { 'python' } },
--   lua_ls = {
--     settings = {
--       Lua = {
--         diagnostics = { globals = { 'vim' } },
--         workspace = {
--           library = { [vim.fn.expand('$VIMRUNTIME/lua')] = true },
--         },
--         telemetry = { enable = false },
--       },
--     },
--   },
--
--   omnisharp = {
--     cmd = { 'dotnet', vim.fn.stdpath('data') .. '/mason/packages/omnisharp/libexec/OmniSharp.dll' },
--     filetypes = { 'cs' },
--     root_dir = util.root_pattern('*.sln', '*.csproj', '.git'),
--   },
-- }
