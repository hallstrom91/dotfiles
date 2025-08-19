--- Diagnostics (global)
vim.diagnostic.config({
  virtual_text = true,
  -- virtual_line = {
  --   current_line = true
  -- },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

--- Capabilities (global)
local capabilities = nil
if pcall(require, "cmp_nvim_lsp") then
  capabilities = require("cmp_nvim_lsp").default_capabilities()
end

--- On Attach (global)
local function on_attach(client, bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if client.name == "bashls" and (fname:match("/%.env") or vim.fn.fnamemodify(fname, ":t"):match("^%.env")) then
    vim.lsp.buf_detach_client(bufnr, client.id)
    return
  end

  -- Conform-plugin handles formatting - add LSP exceptions for default
  local allow_formatting = {
    ["jsonls"] = true,
    --["yamlls"] = true,
  }

  local enable_fmt = allow_formatting[client.name] == true
  client.server_capabilities.documentFormattingProvider = enable_fmt
  client.server_capabilities.documentRangeFormattingProvider = enable_fmt

  -- Load keymaps for buffer
  -- pcall(function()
  --   require(keymaps.where.are.they)(client, bufnr)
  -- end)
end

--- Config (global = * )
vim.lsp.config("*", {
  capabilities = capabilities,
  on_attach = on_attach,
  root_markers = { ".git" },
})

vim.lsp.enable({
  "ts_ls",
  "lua_ls",
  "bashls",
  "jsonls",
  -- "csharp_ls",
})
