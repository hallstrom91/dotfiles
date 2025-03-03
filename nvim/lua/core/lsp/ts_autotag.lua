local M = {}

M.setup = function()
  local status, autotag = pcall(require, 'nvim-ts-autotag')
  if not status then
    return
  end

  autotag.setup({
    enable = true,
    filetypes = { 'html', 'xml', 'javascript', 'typescript', 'typescriptreact', 'javascriptreact' },
    opts = {
      enable_close = true,
      enable_rename = false,
      enable_close_on_slash = true,
    },
  })
end

return M
