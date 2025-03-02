local builtin = require("telescope.builtin")

return function(client, bufnr)
  local map = vim.keymap.set
  local function opts(desc)
    return { buffer = bufnr, noremap = true, silent = true, desc = desc }
  end

  -- C# special
  if client.name == "csharp_ls" then
    map("n", "<leader>cd", "<cmd>Telescope csharpls_definition<cr>", opts("CSharp » Definition (Extended)"))
  end

  -- Standard Telescope pickers
  map("n", "<leader>gd", builtin.lsp_definitions, opts("LSP » Go to Definition"))
  map("n", "<leader>gr", builtin.lsp_references, opts("LSP » Find References"))
  map("n", "<leader>gi", builtin.lsp_implementations, opts("LSP » Go to Implementation"))

  -- Standard LSP methods
  map("n", "K", vim.lsp.buf.hover, opts("LSP » Hover Documentation"))
  map("n", "gt", vim.lsp.buf.type_definition, opts("LSP » Type Definition"))
  map("n", "<leader>e", vim.diagnostic.open_float, opts("LSP » Show Diagnostic"))
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, opts("LSP » Format Buffer"))

  -- Extra commands
  map("n", "<leader>li", "<cmd>LspInfo<CR>", opts("LSP » Info"))
  map("n", "<leader>gac", function()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    vim.notify((vim.inspect(clients)))
  end, opts("LSP » Buffer Clients"))
end
