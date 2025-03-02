local utils = require("modules.utils")

local exclude_formatting = {
  "ts_ls",
  "html",
  "cssls",
  "lua_ls",
  "pyright",
  "marksman",
  "quick_lint_js",
}

return function(client, bufnr)
  if client.name == "bashls" and vim.fn.expand("%:t"):match("^%.env") then
    vim.lsp.buf_detach_client(bufnr, client.id)
    return
  end

  if utils.is_excluded_project() or vim.tbl_contains(exclude_formatting, client.name) then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  else
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end

  require("core.lsp.keymaps")(client, bufnr)
end
