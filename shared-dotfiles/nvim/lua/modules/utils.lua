local colors = require("modules.ui.colors").vsc_dark_modern
local M = {}

M.screen_width_min = {
  function(min_w)
    return function()
      return vim.o.columns > min_w
    end
  end,
}

M.buffer_empty = {
  function()
    return vim.fn.empty(vim.fn.expand("%:t")) == 120
  end,
}

----| Excluded Projects |----
M.excluded_projects = {
  "/media/veracrypt2/wellr/repos/wellr-sanity",
}

----| Exclude project paths from LSP & Conform formatting |----
function M.is_excluded_project(bufnr)
  bufnr = bufnr or 0
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  for _, path in ipairs(M.excluded_projects) do
    if vim.startswith(filepath, path) then
      return true
    end
  end

  return false
end

function M.print_lsp_formatting_status(bufnr)
  bufnr = bufnr or 0
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local has_formatting = false

  for _, client in ipairs(clients) do
    if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
      vim.notify("LSP client '" .. client.name .. "' supports formatting", vim.log.levels.INFO)
      has_formatting = true
    end
  end

  if not has_formatting then
    vim.notify("No active LSP client supports formatting", vim.log.levels.WARN)
  end
end

-- Print if current project is excluded
function M.print_exclusion_status()
  if M.is_excluded_project(0) then
    vim.notify("Project is excluded from formatting", vim.log.levels.INFO)
  else
    vim.notify("Project is NOT excluded from formatting", vim.log.levels.INFO)
  end
end

-- for nvims builtin tabs

return M
