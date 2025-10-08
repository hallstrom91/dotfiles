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

local req = require("utils.req_utils")
local req_safe = req.safe_require
req.mason_bin_path() -- set mason path for lsp/fmts etc

req_safe("core.options", { desc = "core.options" }) -- global opts
-- req_safe("core.filetypes", { desc = "core.filetypes" }) --

-- load base keymaps
req_safe("core.keymaps", {
	desc = "core.keymaps",
	on_ok = function(m)
		if m.setup then
			m.setup()
		end
	end,
})

req_safe("core.lazy", { desc = "core.lazy" }) -- load all lazy-pkg-manager, load all plugins.
req_safe("core.autocmds", { desc = "core.autocmds" }) -- load autocmds
req_safe("core.lsp", { desc = "core.lsp" }) -- load lsp

-- set colorscheme
vim.cmd.colorscheme("vscode")
