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

  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          globals = { 'vim' },
          -- disable = {"undefined-field"},
        },
        workspace = {
          library = {
            --  vim.env.VIMRUNTIME,
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.stdpath('config') .. '/lua'] = true,
          },
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        completion = { enable = true, callSnippet = 'Replace', keywordSnippet = 'Both' },
        hint = {
          enable = true,
          setType = false,
          paramType = 'Disable',
          semicolon = 'Disable',
          arrayIndex = 'Disable',
        },
      },
    },
    filetypes = { 'lua' },
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
  -- omnisharp = {
  --   cmd = { 'dotnet', vim.fn.stdpath('data') .. '/mason/packages/omnisharp/libexec/OmniSharp.dll' },
  --   filetypes = { 'cs' },
  --   root_dir = util.root_pattern('*.sln', '*.csproj', '.git'),
  --   settings = {
  --     FormattingOptions = { EnableEditorConfigSupport = true, OrganizeImports = false },
  --     MsBuild = {
  --       LoadProjectsOnDemand = true,
  --       EnableMSBuildLoadProjectsOnDemand = false,
  --       ProvideSingleFileIntellisense = true,
  --     },
  --     RoslynExtensionsOptions = {
  --       EnableAnalyzersSupport = true,
  --       EnableImportCompletion = true,
  --       AnalyzeOpenDocumentsOnly = true,
  --       EnableDecompilationSupport = true,
  --     },
  --     Sdk = { IncludePrereleases = false },
  --   },
  --   Rules = {
  --     ['IDE0008'] = 'none',
  --   },
  --   -- handlers = {
  --   --   ['textDocument/definition'] = function(...)
  --   --     return require('omnisharp_extended').handler(...)
  --   --   end,
  --   -- },
  --   handlers = {
  --     ['textDocument/definition'] = require('omnisharp_extended').definition_handler,
  --     ['textDocument/typeDefinition'] = require('omnisharp_extended').type_definition_handler,
  --     ['textDocument/references'] = require('omnisharp_extended').references_handler,
  --     ['textDocument/implementation'] = require('omnisharp_extended').implementation_handler,
  --   },
  -- },
}
