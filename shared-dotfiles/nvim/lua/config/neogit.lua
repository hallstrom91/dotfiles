local neogit = require("neogit")

neogit.setup({
  disable_hint = false,
  disable_context_highlighting = false,
  disable_signs = false,
  disable_insert_on_commit = "auto",
  filewatcher = {
    interval = 1000,
    enabled = true,
  },
  kind = "tab",
  use_default_keymaps = true,
  auto_refresh = true,
  integrations = {
    telescope = true,
    diffview = true,
  },
})
