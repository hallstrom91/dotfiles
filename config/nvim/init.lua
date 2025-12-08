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

local sreq = require("utils.req")
require("utils.path").mason_bin_path()

sreq("core.options", { desc = "core.options" })
sreq("core.keymaps", { desc = "core.keymaps" })
sreq("core.lazy", { desc = "core.lazy" })
sreq("core.lsp", { desc = "core.lsp" })
sreq("core.autocmds", { desc = "core.autocmds" })
-- sreq("core.folds", { desc = "core.folds" })

vim.filetype.add({
	filename = {
		[".bash_functions"] = "bash",
		[".bash_aliases"] = "bash",
		[".bash_exports"] = "bash",
		["bash_functions"] = "bash",
		["bash_aliases"] = "bash",
		["bash_exports"] = "bash",
	},
})

-- set colorscheme
-- vim.cmd.colorscheme("vscode")
-- vim.cmd.colorscheme("nordic")
-- vim.cmd.colorscheme("onedark")
