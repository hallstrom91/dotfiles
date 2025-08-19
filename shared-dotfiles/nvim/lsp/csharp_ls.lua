---@type vim.lsp.Config
--- https://github.com/razzmatazz/csharp-language-server
--- Install csharp-ls with `dotnet tool install --global csharp-ls` - NOT MASON!

--local util = require("lspconfig.util")
-- fix later
return {
  cmd = { "csharp-ls" },
  -- root_dir = function(bufnr, on_dir)
  --   local fname = vim.api.nvim_buf_get_name(bufnr)
  --   on_dir(
  --     util.root_pattern("*.sln")(fname) or util.root_pattern("*.slnx")(fname) or util.root_pattern("*.csproj")(fname)
  --   )
  -- end,
  filetypes = { "cs" },
  init_options = { AutomaticWorkspaceInit = true },
}
