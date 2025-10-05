local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local function ft_name()
	local path = vim.api.nvim_buf_get_name(0)
	local ft = path:match("/ftplugin/([^/]+)%.lua$") or ""
	if ft == "" then
		ft = vim.bo.filetype or ""
	end
	return (ft ~= "" and ft) or "NAME"
end

local function in_ftplugin_dir()
	local path = vim.api.nvim_buf_get_name(0)
	return path:find("/ftplugin/") ~= nil
end

return {
	s(
		{ trig = "ftpl", desc = "ftplugin skeleton", condition = in_ftplugin_dir },
		fmt(
			[[
	-- Guard: run only once per buf
vim.b.did_ftplugin_{} then
return
end
vim.b.did_ftplugin_{} = true

-- Enable: extensions, plugins or require files
vim.treesitter.start()

-- Opts: buffer specific
vim.opt_local.{}
		]],
			{
				i(1, ft_name()),
				rep(1),
				i(0),
			}
		)
	),

	s(
		{ trig = "ftplx", desc = "ftplugin extend/alias", condition = in_ftplugin_dir },
		fmt(
			[[
		-- Alias/extend {} -> {}
		if vim.b.did_ftplugin_{} then
			return
		end
		vim.b.did_ftplugin_{} return

		vim.cmd("runtime! ftplugin/{}.lua")
		]],
			{
				i(1, "source_ft"), -- source (ex: "javascript")
				i(2, ft_name()), -- target (ex: "javascriptreact")
			}
		)
	),
}
