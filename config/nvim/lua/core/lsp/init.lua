local dx = require("core.lsp.diagnostic")

return {

	--- LspAttach Event
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kjs.lspattach", { clear = true }),
		desc = "LspAttach: add LSP keymaps/settings to relevant buf",
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			require("core.lsp.attach").lsp_buf_maps(client, ev.buf)
		end,
	}),

	--- LspDetach Event
	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("kjs.lspdetach", { clear = true }),
		desc = "LspDetach: clear LSP keymaps/settings from relevant buffer",
		callback = function(ev)
			-- If buffer dont has any LSP-clients, clear bufmaps.
			local remaining = vim.lsp.get_clients({ bufnr = ev.buf })
			if #remaining == 0 then
				require("core.lsp.attach").clear_lsp_buf_maps(ev.buf)
				-- attach.clear_lsp_buf_maps(ev.buf)
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
	}),

	--- Custom Diagnostic UI
	vim.diagnostic.config({
		virtual_text = dx.dx_vtext, -- virtual text, next to dx-line
		signs = dx.dx_signs, -- icons (prefix) next to linenr column
		float = dx.dx_float, -- hover dx
	}),

	vim.lsp.config("*", {
		capabilities = vim.lsp.protocol.make_client_capabilities(),
	}),
}
