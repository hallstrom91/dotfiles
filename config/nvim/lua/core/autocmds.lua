local cmd = vim.api.nvim_create_autocmd

local grp = function(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

cmd("BufWritePre", {
	group = grp("kjs.text.fmt"),
	desc = "format buf with conform",
	pattern = "*",
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			lsp_format = "fallback",
			timeout_ms = 500,
			stop_after_first = true,
			async = false,
		})
	end,
})

cmd("TextYankPost", {
	group = grp("sh.text.hlyank"),
	desc = "highlight on yank (copy)",
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

cmd("FileType", {
	group = grp("kjs.filetype.closeft"),
	desc = "close specific bufs with 'q'",
	pattern = {
		"checkhealth",
		"gitsigns-blame",
		"help",
		"lspinfo",
		"notify",
		"spectre_panel",
		"startuptime",
		"TelescopePrompt",
		"neo-tree",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("quit!")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

cmd("FileType", {
	group = grp("kjs.filetype.nocomment"),
	desc = "no comment on new line",
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

--> display macro recording status
cmd("RecordingEnter", {
	group = grp("kjs.macros.enter"),
	desc = "display notification when macro recording start",
	callback = function()
		local reg = vim.fn.reg_recording()
		vim.notify("Macro recording started @" .. reg, vim.log.levels.INFO, { title = "Macro Start" })
	end,
})

cmd("RecordingLeave", {
	group = grp("kjs.macros.exit"),
	desc = "display notification when macro recording ends",
	callback = function()
		vim.notify("Macro recording terminated", vim.log.levels.INFO, { title = "Macro Ended" })
	end,
})
