local M = {}

function M.patch_make_position_params()
  ---@diagnostic disable-next-line duplicate-field
  vim.lsp.util.make_position_params = function(win)
    local pos = vim.api.nvim_win_get_cursor(win or 0)
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(),
      position = {
        line = pos[1] - 1,
        character = pos[2],
      },
    }

    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
    if client and client.offset_encoding then
      params.positionEncodingKind = client.offset_encoding
    else
      params.positionEncodingKind = "utf-16" -- fallback
    end

    return params
  end
end

return M
