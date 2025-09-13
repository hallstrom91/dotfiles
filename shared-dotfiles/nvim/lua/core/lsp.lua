local M = {}

--- Diagnostics (global)
vim.diagnostic.config({
  -- virtual_lines = true,
  -- virtual_text = { current_line = true },
  virtual_text = true,

  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
  -- signs = {
  --   text = {
  --     [vim.diagnostic.severity.ERROR] = "",
  --  [vim.diagnostic.severity.WARN] = "",
  --     [vim.diagnostic.severity.INFO] = "",
  --     [vim.diagnostic.severity.HINT ] = "",
  --   },
  -- },
})

-- vim.lsp.util.open_floating_preview({ border = hl?})

--- Config (global = * )
vim.lsp.config("*", {
  capabilities = M.capabilities,
  on_attach = M.on_attach,
  root_markers = { ".git" },
})

--- Capabilities (global)

local ok, cmp = pcall(require, "cmp_nvim_lsp")
M.capabilities = ok and cmp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

--- on_attach (global)
function M.on_attach(client, bufnr)
  -- Load keymaps for buffer
  pcall(function()
    require("core.lsp-keymaps").setup(client, bufnr)
  end)
end

local function deep_merge(a, b)
  return vim.tbl_deep_extend("force", a or {}, b or {})
end



-- To see the capabilities for a given server, try this in a LSP-enabled buffer: >vim
--
function M.load_server_cfg(name)
  local ok_cfg, cfg = pcall(require, "lsp." .. name)
  if not ok_cfg then
    vim.notify(("LSP cfg '%s' load error"):format(name, cfg), vim.log.levels.ERROR)
    return nil
  end
  if type(cfg) ~= "table" then
    vim.notify(("LSP cfg '%s' did not return a table"):format(name, cfg), vim.log.levels.ERROR)
    return nil
  end
  return cfg
end

function M.start(cfg, opts)
  opts = opts or {}
  cfg.on_attach = cfg.on_attach or M.on_attach
  cfg.capabilities = cfg.capabilities or M.capabilities

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

  return vim.lsp.start(cfg, {
    reuse_client = opts.reuse_client,
    silent = opts.silent,
  })
end

-- LspDetach / Autostop
local timers = {} -- client_id -> uv_timer_t

function M.is_orphan(client)
  for bufnr in pairs(client.attached_buffers or {}) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      return false
    end
  end
  return true
end

-- Kill client IF orphan after * delay_ms
function M.kill_or_spare_client(client_id, delay_ms)
  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return
  end

  if timers[client_id] then
    timers[client_id]:stop()
    timers[client_id]:close()
    timers[client_id] = nil
  end

  local t = vim.uv.new_timer()
  timers[client_id] = t

  t:start(delay_ms or 1500, 0, function()
    vim.schedule(function()
      local c = vim.lsp.get_client_by_id(client_id)
      if c and M.is_orphan(c) then
        pcall(function()
          c:stop()
        end)
      end

      if timers[client_id] then
        timers[client_id]:stop()
        timers[client_id]:close()
        timers[client_id] = nil
      end
    end)
  end)
end

return M

-- To see the capabilities for a given server, try this in a LSP-enabled buffer:
--     :lua =vim.lsp.get_clients()[1].server_capabilities
