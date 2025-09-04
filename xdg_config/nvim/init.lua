-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local function safe_require(module_name, description)
  local ok, mod = pcall(require, module_name)
  if not ok then
    vim.api.nvim_echo({ { description .. " not found", "WarningMsg" } }, true, {})
  else
    vim.notify("Loaded " .. description, vim.log.levels.TRACE)
  end
end

safe_require("core.options", "options.lua")
safe_require("core.keymaps", "keymaps.lua")
safe_require("core.autocmds", "autocmds.lua")
safe_require("config.lazy", "lazy.lua")
safe_require("core.lsp", "lsp.lua")
safe_require("core.filetypes", "filetypes.lua")

-- set colorscheme
vim.cmd.colorscheme("vscode")
