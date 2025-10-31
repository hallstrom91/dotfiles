local M = {}

--  Let Conform handle formatting
-- local DISABLE_FMT = {
-- 	vtsls = true,
-- 	ts_ls = true,
-- 	lua_ls = true,
-- 	bash_ls = true,
-- }

-- Turn off (range)formatting for specific lsp
-- function M.disable_lsp_fmt( client)
-- 	if DISABLE_FMT[client.name] then
-- 		local caps = client.server_capabilities or {}
-- 		caps.documentFormattingProvider = false
-- 		caps.documentRangeFormattingProvider = false
-- 	end
-- end

function M.lsp_methods_map(client, bufnr)
	---@param lhs string
	---@param rhs function|string
	---@param o {desc?: string, requires?: string, mode?: string|string[]}
	return function(lhs, rhs, o)
		o = o or {}
		local desc = o.desc and ("LSP  " .. o.desc) or nil
		local mode = o.mode or "n"
		local opts = { buffer = bufnr, silent = true, desc = desc }

		if o.requires and not client:supports_method(o.requires) then
			vim.schedule(function()
				vim.notify(("LSP '%s' not supported: %s"):format(o.requires, client.name), vim.log.levels.WARN)
			end)
			return
		end

		-- requires matches client:supports_method - set keymap to buf
		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

-- LSP Pickers: Telescope Builtin, Diagnostics
function M.lsp_pickers_map(client, bufnr)
	local map = M.lsp_methods_map(client, bufnr)
	local ok, builtin = pcall(require, "telescope.builtin")

	-- floating diagnostic
	map(
		"<leader>e",
		vim.diagnostic.open_float,
		{ desc = "Show diagnostics", requires = "textDocument/publishDiagnostics" }
	)

	-- Hover Documentation (border not working)

	map("K", function()
		vim.lsp.buf.hover({
			border = "rounded",
			max_height = 2,
			max_width = 120,
			close_events = { "CursorMoved", "BufLeave", "WinLeave", "LspDetach" },
		})
	end, {
		desc = "Hover Documentation",
		requires = "textDocument/hover",
	})

	if ok then
		map("<leader>gd", builtin.lsp_definitions, { desc = "Go to Definition", requires = "textDocument/definition" })
		map("<leader>gr", builtin.lsp_references, { desc = "Find References", requires = "textDocument/references" })
		map(
			"<leader>gi",
			builtin.lsp_implementations,
			{ desc = "Go to Implementations", "textDocument/implementations" }
		)
		map(
			"<leader>gtd",
			builtin.lsp_type_definitions,
			{ desc = "Go to Type Definitions", "textDocument/typeDefinition" }
		)
	end
end

return M
