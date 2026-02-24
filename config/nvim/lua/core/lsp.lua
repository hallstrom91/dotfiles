vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kjs.lspattach", { clear = true }),
	desc = "LspAttach: LSP keymaps/settings to relevant buf",
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		if client and client:supports_method("textDocument/documentHighlight", ev.buf) then
			local highlight_augroup = vim.api.nvim_create_augroup("lsp.highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = ev.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = ev.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})
		end
		-- 	vim.api.nvim_create_autocmd("LspDetach", {
		-- 		group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
		-- 		callback = function(event2)
		-- 			vim.lsp.buf.clear_references()
		-- 			vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
		-- 		end,
		-- 	})
		-- end

		-- require("core.lsp.attach").lsp_buf_maps(client, ev.buf)
	end,
})

--- LspDetach Event
vim.api.nvim_create_autocmd("LspDetach", {
	group = vim.api.nvim_create_augroup("kjs.lspdetach", { clear = true }),
	desc = "LspDetach: clear LSP keymaps/settings from relevant buffer",
	callback = function(ev)
		local remaining = vim.lsp.get_clients({ bufnr = ev.buf })
		if #remaining == 0 then
			require("core.lsp.attach").clear_lsp_buf_maps(ev.buf)
		end

		-- Stop/Kill (w force) if no bufs is connected.
		vim.schedule(function()
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			if not next(client.attached_buffers or {}) then
				client:stop(true) -- force shutdown
			end
		end)
	end,
})
