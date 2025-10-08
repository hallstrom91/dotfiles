local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

return {
	s("ftpl", {
		t({ "-- Guard: run only once per buf", "if vim.b.did_ftplugin_" }),
		i(1, "NAME"),
		t({ " then", "  return", "end", "vim.b.did_ftplugin_" }),
		rep(1),
		t({
			" = true",
			"",
			"--Enable: extensions, plugins or require files",
			"pcall(vim.treesitter.start)",
			"",
			"--Opts: Buffer specific",
			"-- vim.opt_local.",
			"",
		}),
		i(0),
	}),

	s("ftplx", {
		t({ "-- Alias/Extend " }),
		i(1, "source_ft"),
		t({ " -> " }),
		i(2, "target_ft"),
		t({ "", "if vim.b.did_ftplugin_" }),
		rep(2),
		t({ " then", " return", "end", "vim.b.did_ftplugin_" }),
		rep(2),
		t({ " = true", "", 'vim.cmd("runtime! ftplugin/' }),
		rep(1),
		t({ '.lua")', "" }),
		i(0),
	}),
}

-- local function ft_name()
-- 	local path = vim.api.nvim_buf_get_name(0)
-- 	local ft = path:match("/ftplugin/([^/]+)%.lua$") or ""
-- 	if ft == "" then
-- 		ft = vim.bo.filetype or ""
-- 	end
-- 	return (ft ~= "" and ft) or "NAME"
-- end
--
-- local function in_ftplugin_dir()
-- 	local path = vim.api.nvim_buf_get_name(0)
-- 	return path:find("/ftplugin/") ~= nil
-- end
--
-- return {
-- 	s(
-- 		{ trig = "ftpl", desc = "ftplugin skeleton", condition = in_ftplugin_dir },
-- 		fmta(
-- 			[[
-- 	-- Guard: run only once per buf
-- vim.b.did_ftplugin_{} then
-- return
-- end
-- vim.b.did_ftplugin_{} = true
--
-- -- Enable: extensions, plugins or require files
-- vim.treesitter.start()
--
-- -- Opts: buffer specific
-- vim.opt_local.{}
-- 		]],
-- 			{
-- 				i(1, ft_name()),
-- 				rep(1),
-- 				i(0),
-- 			}
-- 		)
-- 	),
--
-- 	s(
-- 		{ trig = "ftplx", desc = "ftplugin extend/alias", condition = in_ftplugin_dir },
-- 		fmta(
-- 			[[
-- 		-- Alias/extend {} -> {}
-- 		if vim.b.did_ftplugin_{} then
-- 			return
-- 		end
-- 		vim.b.did_ftplugin_{} return
--
-- 		vim.cmd("runtime! ftplugin/{}.lua")
-- 		]],
-- 			{
-- 				i(1, "source_ft"), -- source (ex: "javascript")
-- 				i(2, ft_name()), -- target (ex: "javascriptreact")
-- 				rep(2),
-- 				rep(2),
-- 				rep(1),
-- 			}
-- 		)
-- 	),
-- }
