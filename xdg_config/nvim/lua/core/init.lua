local M = {}
local U = require("core.util")

function M.init()
  U.mason_bin_path()

  U.safe_require("core.options", { desc = "core.options" })
  U.safe_require("core.filetypes", { desc = "core.filetypes" })
  U.safe_require("core.keymaps", {
    desc = "core.keymaps",
    on_ok = function(m)
      if m.setup then
        m.setup()
      end
    end,
  })

  U.safe_require("core.autocmds", { desc = "core.autocmds" })
  --bootstrap lazy => all files in plugins/ and config/
  U.safe_require("config.lazy", { desc = "config.lazy" })
end

return M
