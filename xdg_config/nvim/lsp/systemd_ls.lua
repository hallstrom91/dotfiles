---@type vim.lsp.Config
return {
  cmd = { "systemd-language-server" },
  filetypes = { "systemd", "service" },
  root_markers = { ".git" },
  single_file_support = true,
  -- settings = {},
}
