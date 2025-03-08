local M = {}

M.on_attach = function(client, bufnr)
  local exclude_formatting = {
    'ts_ls',
    'html',
    'cssls',
    'lua_ls',
    'pyright',
    'yamlls',
    'marksman',
    'jsonls',
    'quick_lint_js',
    'omnisharp',
  }

  local included_projects = {
    '/media/veracrypt2/wellr/repos/wellr-frontend',
  }

  local function is_included_project()
    local cwd = vim.fn.getcwd()
    for _, path in ipairs(included_projects) do
      if cwd:find(path, 1, true) then
        return true
      end
    end
    return false
  end

  if is_included_project() then
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.document_range_formatting = true
  elseif vim.tbl_contains(exclude_formatting, client.name) then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.document_range_formatting = false
  else
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.document_range_formatting = false
  end

  require('core.lsp.keymaps').setup(bufnr)
end

return M
