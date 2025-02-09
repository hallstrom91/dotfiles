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

-- Load options
local options_path = vim.fn.stdpath("config") .. "/lua/core/options.lua"
if vim.fn.filereadable(options_path) == 1 then
	dofile(options_path)
else
	vim.api.nvim_echo({ { "options.lua file not found", "WarningMsg" } }, true, {})
end

-- Load mappings
local keymaps_path = vim.fn.stdpath("config") .. "/lua/core/keymaps.lua"
if vim.fn.filereadable(keymaps_path) == 1 then
	dofile(keymaps_path)
else
	vim.api.nvim_echo({ { "mappings.lua file not found", "WarningMsg" } }, true, {})
end

-- Load autocmds
local autocmds_path = vim.fn.stdpath("config") .. "/lua/core/autocmds.lua"
if vim.fn.filereadable(autocmds_path) == 1 then
	dofile(autocmds_path)
else
	vim.api.nvim_echo({ { "autocmds.lua file not found", "WarningMsg" } }, true, {})
end

require("config.lazy")
