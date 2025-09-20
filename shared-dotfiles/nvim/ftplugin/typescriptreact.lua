if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true
vim.treesitter.start()

require("lsp.init").start({
  name = "vtsls",
  cmd = { "vtsls", "--stdio" },
  root_markers = {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml",
    "bun.lockb",
    "bun.lock",
  },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      -- enableMoveToFileCodeAction = false, -- default
    },
  },
  tsserver = {
    globalPlugins = {},
  },
  typescript = {
    format = { enable = false },
  },
  replace_on_attach = false,
  disable_fmt = true,
  --  on_attach = function(client, bufnr) end,
})
