-- skip special bufs (prompt, nofile, help etc)
if vim.bo.buftype ~= "" then
  return
end
-- skip unlisted (telescope preview )
if vim.fn.buflisted(0) == 0 then
  return
end

-- skip if not modifiable (preview such as telescope or help)
if not vim.bo.modifiable then
  return
end

if vim.b._lsp_started then
  return
end
vim.b._lsp_started = true

vim.treesitter.start()
require("lsp.init").start({
  name = "marksman",
  cmd = { "marksman", "server" },
  root_markers = { ".marksman.toml", "package.json", ".git" },
  disable_fmt = true,
  replace_on_attach = false,
  --  on_attach = function(client, bufnr) end,
})
