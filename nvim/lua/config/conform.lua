require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    markdown = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    yaml = { "prettierd " },
    -- csharp = { 'csharpier' },
  },

  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
  options = {
    prefer_local = ".prettierrc", -- priority local (project) prettier config
  },
})

-- local excluded_projects = {
--   "/media/veracrypt2/wellr/repos/wellr-sanity",
-- }
--
-- local function is_excluded_project()
--   local cwd = vim.fn.getcwd()
--   for _, path in ipairs(excluded_projects) do
--     if cwd:find(path, 1, true) then
--       return true
--     end
--   end
--   return false
-- end
--
-- require("conform").setup({
--   formatters_by_ft = {
--     lua = { "stylua" },
--     python = { "isort", "black" },
--     javascript = not is_excluded_project() and { "prettierd" } or nil,
--     javascriptreact = not is_excluded_project() and { "prettierd" } or nil,
--     typescript = not is_excluded_project() and { "prettierd" } or nil,
--     typescriptreact = not is_excluded_project() and { "prettierd" } or nil,
--     html = { "prettierd" },
--     css = { "prettierd" },
--     markdown = { "prettierd" },
--     json = { "prettierd" },
--     jsonc = { "prettierd" },
--     -- csharp = { 'csharpier' },
--   },
--
--   format_on_save = {
--     timeout_ms = 1000,
--     lsp_format = "fallback",
--   },
--   options = {
--     prefer_local = ".prettierrc", -- priority local (project) prettier config
--   },
-- })
