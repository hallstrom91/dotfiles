local lspconfig = require('lspconfig')
local util = require('lspconfig.util')
local mason_omnisharp_path = vim.fn.stdpath('data') .. '/mason/packages/omnisharp/libexec/OmniSharp.dll' ----> To get correct version of .NET in command "LspInfo"

----> LSP Capabilities
local init_capabilities = vim.lsp.protocol.make_client_capabilities()
local ufo_capabilities = vim.lsp.protocol.make_client_capabilities()

----> CMP & UFO
init_capabilities = require('cmp_nvim_lsp').default_capabilities(init_capabilities)
ufo_capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
init_capabilities = vim.tbl_deep_extend('keep', init_capabilities, ufo_capabilities)

local lsp_flags = { debounce_text_changes = 150 }

local manual_servers = {
  'tailwindcss',
  'css_variables',
}

----| TEST
--local tsserver_cmd = { vim.fn.stdpath('data') .. '/mason/bin/typescript-language-server', '--stdio' }

----> List of LSP servers - Auto start @ correct filetype
local servers = {
  ----> Typescript & JavaScript
  ts_ls = {

    root_dir = util.root_pattern('tsconfig.json', 'jsconfig.json', 'package.json', '.git'),
    -- cmd = { 'typescript-language-server', '--stdio' },
    init_options = {
      plugins = {
        {
          name = '@styled/typescript-styled-plugin',
          location = '/home/simon/.nvm/versions/node/v20.18.0/lib/node_modules/@styled/typescript-styled-plugin',
          languages = {
            --[[ 'javascript', 'typescript', ]]
            'javascriptreact',
            'typescriptreact',
          },
        },
      },
    },
    settings = {
      completions = {
        completeFunctionCalls = false,
      },
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      },
      typescript = {
        -- preferences = {
        --   importModuleSpecifierPreference = 'relative', --> OR "non-relative"
        --   importModuleSpecifierEnding = 'minimal',
        --   autoImportFileExcludePatterns = { '**/*.spec.ts', '**/*.test.ts' },
        -- },
        suggest = {
          autoImports = false,
        },
        organizeImports = false,
      },
      javascript = {
        suggest = {
          autoImports = false,
        },
      },
    },
  },

  ----> CSS
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = {
      -- 'typescript',
      -- 'typescriptreact',
      -- 'javascriptreact',
      -- 'javascript',
      'css',
      'scss',
      'less',
    },
    settings = {
      css = {
        validate = true,
        lint = { unknownAtRules = 'ignore' },
        completion = { completePropertyWithSemicolon = true, triggerPropertyValueCompletion = true },
      },
      scss = { validate = true, lint = { unknownAtRules = 'ignore' } },
      less = { validate = true, lint = { unknownAtRules = 'ignore' } },
    },
  },
  ----> HTML
  html = { filetypes = { 'html' } },
  ----> Python
  pyright = { filetypes = { 'python' } },
  ----> Lua
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          globals = {
            'vim',
            'get_application_name', --> devilspie2
            'set_workspace', --> devilspie2
            'set_window_geometry', --> devilspie2
            'minimize', --> devilspie2
            'maximize', --> devilspie2
            'debug_print', --> devilspie2
          },
          -- disable = {"undefined-field"},
        },
        workspace = {
          library = {
            vim.env.VIMRUNTIME,
            --[[ 		[vim.fn.stdpath("config") .. "/lua"] = true,
						[vim.fn.stdpath("data") .. "/lazy"] = true, ]]
          },
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        completion = { enable = true, callSnippet = 'Replace' },
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

  ----> Markdown (github readme etc)
  marksman = {
    filetypes = { 'markdown' },
  },
  ----> JavaScript Linting
  quick_lint_js = {
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescriptreact',
      'typescript',
    },
  },
  ----> Vim
  vimls = {
    filetypes = {
      'vim',
    },
  },
  ----> YAML
  yamlls = {
    filetypes = { 'yaml', 'yml' },
  },
  ----> CSS modules
  cssmodules_ls = {
    filetypes = {
      --	"typescript",
      --	"typescriptreact",
      'javascript',
      'javascriptreact',
      'javascript.jsx',
    },
    camelCase = true,
  },

  ----> Bash (.sh -files)
  bashls = {
    filetypes = { 'sh', 'bash' },
  },
  ----> JSON
  jsonls = {
    root_dir = util.root_pattern('package.json', '.git', '.'),
    filetypes = { 'json', 'jsonc' },
  },
  ----> C# .NET
  omnisharp = {
    cmd = { 'dotnet', mason_omnisharp_path },
    filetypes = { 'cs' },
    root_dir = util.root_pattern('*.sln', '*.csproj', '.git'),
    settings = {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = true,
      },
      MsBuild = {
        LoadProjectsOnDemand = true,
      },
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
        EnableImportCompletion = true,
        AnalyzeOpenDocumentsOnly = true,
      },
      Sdk = {
        IncludePrereleases = false,
      },
    },
  },
}

---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
  ----> Use prettierd instead of LSP formatter
  local exclude_formatting = {
    'ts_ls',
    'html',
    'cssls',
    'lua_ls',
    'pyright',
    'yamlls',
    'marksman',
    'jsonls',
    'omnisharp',
  }

  if vim.tbl_contains(exclude_formatting, client.name) then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.document_range_formatting = false
  end

  --deactive semantic tokens from omnisharp (fix treesitter color)
  --[[   if client.name == 'omnisharp' then
    client.server_capabilities.semanticTokensProvider = nil
  end ]]
end

----> Auto start LSP servers
for server, config in pairs(servers) do
  lspconfig[server].setup(vim.tbl_deep_extend('force', {
    on_attach = on_attach,
    capabilities = init_capabilities,
    flags = lsp_flags,
  }, config))
end

----> Manual start for specific LSP server
vim.api.nvim_create_user_command('StartLsp', function(opts)
  local server_name = opts.args
  if lspconfig[server_name] then
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = init_capabilities,
      flags = lsp_flags,
    })
    print('Started LSP server for ' .. server_name)
  else
    print('LSP server ' .. server_name .. ' is not configured.')
  end
end, {
  nargs = 1,
  complete = function()
    return manual_servers
  end,
})

----> Restart All LSP servers and CMP
vim.api.nvim_create_user_command('RestartLsp', function()
  vim.cmd('LspStop')
  vim.cmd('LspStart')
  --require('cmp').setup()
  print('All LSP servers and CMP restarted!')
end, {})

----> LSP related keybinds
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

----> LSP keymaps
map(
  'n',
  'gd',
  '<cmd>lua vim.lsp.buf.definition()<CR>',
  vim.tbl_extend('force', opts, { desc = 'LSP Go to definition' })
)
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', vim.tbl_extend('force', opts, { desc = 'LSP Find references' }))
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', vim.tbl_extend('force', opts, { desc = 'LSP Hover documentation' }))
