return {
  setup = function()
    --> deactivate lsp-timeout with:
    if vim.g.lsp_timeout_enabled == false then
      return
    end

    vim.g.lspTimeoutConfig = {
      stopTimeout = 1000 * 60 * 25,
      startTimeout = 1000 * 5,
      silent = false,
      filetypes = {
        ignore = { "markdown", "plaintext" },
      },
    }
    local Config = require("lsp-timeout.config").Config
    Config:new(vim.g.lspTimeoutConfig):validate()
  end,
}
