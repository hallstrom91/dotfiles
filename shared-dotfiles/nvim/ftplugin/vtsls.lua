-- shared cfg for javascript, typescript, javascriptreact, typescriptreact files

local lsp = require("lsp.init")

return function()
  lsp.start({
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
      vtsls = { autoUseWorkspaceTsdk = true },
    },
    replace_on_attach = false,
    disable_fmt = true,
    --    on_attach = function(client, bufnr) end,
  })
end
