local M = {}

local has_telescope = pcall(require, "telescope")
local builtin = has_telescope and require("telescope.builtin") or nil

local function map_with_capability(client, bufnr)
  ---@param lhs string
  ---@param rhs function|string
  ---@param o {desc?: string, requires?: string, mode?: string|string[]}
  return function(lhs, rhs, o)
    o = o or {}
    local desc = o.desc and ("LSP » " .. o.desc) or nil
    local modes = o.mode or "n"
    local opts = { buffer = bufnr, silent = true, noremap = true, desc = desc }

    if o.requires and not client:supports_method(o.requires) then
      vim.keymap.set(modes, lhs, function()
        vim.notify(("LSP: %s not supported: %s"):format(o.requires, client.name), vim.log.levels.WARN)
      end, opts)
      return
    end

    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

function M.setup(client, bufnr)
  local map = map_with_capability(client, bufnr)

  -- add "desc" for defaults
  map("K", vim.lsp.buf.hover, { desc = "Hover Info", requires = "textDocument/hover" })
  map(
    "<leader>e",
    vim.diagnostic.open_float,
    { desc = "Show Diagnostic", requires = "textDocument/publishDiagnostics" }
  )

  -- telescope lsp pickers
  if has_telescope and builtin then
    map("<leader>gd", builtin.lsp_definitions, { desc = "Go to Definition", requires = "textDocument/definition" })
    map("<leader>gr", builtin.lsp_references, { desc = "Find References", requires = "textDocument/references" })
    map(
      "<leader>gi",
      builtin.lsp_implementations,
      { desc = "Go to Implementations", requires = "textDocument/implementations" }
    )
    --map("<leader>", builtin.lsp_, { desc = "", requires = "" })

    -- if client.name == "chsarp_ls" and has_telescope then
    ---- ADD csharp_ls support for lsp-pickers
    --end
  end
end

return M
