if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true
vim.treesitter.start()

require("lsp.init").start({
  name = "lua_ls",
  cmd = { "lua-language-server" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        },
      },
      telemetry = { enable = false },
      completion = { enable = true, callSnippet = "Replace" },
      hint = {
        enable = true,
        setType = false,
        paramType = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
    },
  },
  disable_fmt = true,
  replace_on_attach = false,
  --on_attach = function(client, bufnr)
  --end
})
