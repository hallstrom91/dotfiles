local sep = package.config:sub(1, 1)

local function exists(p)
  return p and vim.uv.fs_stat(p) ~= nil
end

local function join(...)
  return table.concat({ ... }, sep)
end

local function get_root(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  return vim.fs.root(fname, { "package.json" }) or vim.fs.root(fname, { ".git" }) or vim.fn.getcwd()
end

local function find_tsdk(root_dir)
  local project_tsdk = join(root_dir, "node_modules", "typescript", "lib")
  if exists(project_tsdk) then
    return project_tsdk
  end

  return nil
end

---@type vim.lsp.Config
return {
  cmd = { "mdx-language-server", "--stdio" },
  filetypes = { "mdx" },
  root_markers = { "package.json" },
  settings = {},
  init_options = {
    typescript = {},
  },
}
