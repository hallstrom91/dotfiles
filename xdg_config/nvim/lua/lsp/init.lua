local M = {}
------------------------
---- LSP
------------------------
-- To see the capabilities for a given server, try this in a LSP-enabled buffer:
--     :lua =vim.lsp.get_clients()[1].server_capabilities

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

-- capabilities
do
  local base = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  M.capabilities = ok and cmp.default_capabilities(base) or base
end

-- baseline on_attach
function M.on_attach(client, bufnr)
  local mod = require("lsp.modules")
  -- base keymaps
  mod.set_lsp_keymap(client, bufnr, "K", vim.lsp.buf.hover, { desc = "Hover", requires = "textDocument/hover" })
  mod.set_lsp_keymap(
    client,
    bufnr,
    "<leader>e",
    vim.diagnostic.open_float,
    { desc = "Diagnostic", requires = "textDocument/publishDiagnostics" }
  )

  -- basic telescope lsp pickers
  local ok_t, builtin = pcall(require, "telescope.builtin")
  if ok_t then
    mod.set_lsp_keymap(
      client,
      bufnr,
      "<leader>gd",
      builtin.lsp_definitions,
      { desc = "Definition", requires = "textDocument/definition" }
    )
    mod.set_lsp_keymap(
      client,
      bufnr,
      "<leader>gr",
      builtin.lsp_references,
      { desc = "References", requires = "textDocument/references" }
    )
    mod.set_lsp_keymap(
      client,
      bufnr,
      "<leader>gi",
      builtin.lsp_implementations,
      { desc = "Implementations", requires = "textDocument/implementations" }
    )
    mod.set_lsp_keymap(
      client,
      bufnr,
      "<leader>gt",
      builtin.lsp_type_definitions,
      { desc = "Type Definition", requires = "textDocument/typeDefinition" }
    )
  end
end

-- baseline cfg for all lsp servers
vim.lsp.config("*", {
  capabilities = M.capabilities,
  on_attach = M.on_attach,
  root_markers = { ".git" },
})

-- helper for M.start()
local function wrap_on_attach(cfg)
  local user_on_attach = cfg.on_attach
  local replace = cfg.replace_on_attach -- nil/false => global + usr_on_attach
  local disable_fmt = cfg.disable_fmt -- disable lsp format

  cfg.on_attach = function(client, bufnr)
    if disable_fmt then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      client.server_capabilities.documentOnTypeFormattingProvider = nil
    end

    if not replace then
      -- load global baseline on_attach
      pcall(function()
        M.on_attach(client, bufnr)
      end)
    end

    if type(user_on_attach) == "function" then
      user_on_attach(client, bufnr)
    end
  end
end

-- function to be called in ftplugin/filetype.lua
function M.start(cfg, opts)
  opts = opts or {}
  cfg.capabilities = cfg.capabilities or M.capabilities
  wrap_on_attach(cfg)
  -- cfg.on_attach = cfg.on_attach or M.on_attach

  if not cfg.root_dir then
    local markers = cfg.root_markers or { ".git" }
    cfg.root_dir = vim.fs.root(0, markers) or vim.fn.getcwd()
  end

  if type(cfg.cmd) == "string" then
    cfg.cmd = { cfg.cmd }
  end

  if type(cfg.cmd) ~= "table" or not cfg.cmd[1] then
    vim.notify("LSP cfg missing 'cmd' for: " .. (cfg.name or "unknown"), vim.log.levels.WARN)
    return
  end

  cfg.name = cfg.name or cfg.cmd[1]

  -- avoid duplicates
  for _, c in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if c.name == cfg.name then
      return c
    end
  end

  return vim.lsp.start(cfg, {
    reuse_client = opts.reuse_client,
    silent = opts.silent,
  })
end

return M
