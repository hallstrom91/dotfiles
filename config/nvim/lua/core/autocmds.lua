local autocmd = vim.api.nvim_create_autocmd

-----------------------------------------
--- Highlight

autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("kjs.hl_yank", { clear = true }),
	desc = "highlight on yank",
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 300 })
	end,
})

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
autocmd({ "InsertLeave", "WinEnter" }, {
	group = vim.api.nvim_create_augroup("kjs.hl_cursorline_show", { clear = true }),
	desc = "show cursor/column-line highlight",
	callback = function()
		vim.o.cursorline = true
		-- vim.o.cursorcolumn = true
	end,
})

-- or `:h cursorline | :h cursorcolumn`
autocmd({ "InsertEnter", "WinLeave" }, {
	group = vim.api.nvim_create_augroup("kjs.hl_cursorline_hide", { clear = true }),
	desc = "hide cursor/column-line highlight",
	callback = function()
		vim.o.cursorline = false
		-- vim.o.cursorcolumn = false
	end,
})

-----------------------------------------
--- Filetype

autocmd("FileType", {
	group = vim.api.nvim_create_augroup("kjs.close_ft", { clear = true }),
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

autocmd("FileType", {
	group = vim.api.nvim_create_augroup("kjs.conceal_lvl", { clear = true }),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.wo.conceallevel = 0
	end,
})

autocmd("FileType", {
	group = vim.api.nvim_create_augroup("kjs.nonew_comment", { clear = true }),
	desc = "no comment on new line",
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

autocmd("FileType", {
	group = vim.api.nvim_create_augroup("kjs.help_vertsplit", { clear = true }),
	pattern = "help",
	command = "wincmd L ",
})

-----------------------------------------
--- Macro

--> display macro recording status started/terminated
autocmd("RecordingEnter", {
	group = vim.api.nvim_create_augroup("kjs.macro_rec_start", { clear = true }),
	desc = "display notification when macro recording start",
	callback = function()
		local reg = vim.fn.reg_recording()
		vim.notify("Macro recording started @" .. reg, vim.log.levels.INFO, { title = "Macro Start" })
	end,
})

autocmd("RecordingLeave", {
	group = vim.api.nvim_create_augroup("kjs.macro_rec_end", { clear = true }),
	desc = "display notification when macro recording ends",
	callback = function()
		vim.notify("Macro recording terminated", vim.log.levels.INFO, { title = "Macro Ended" })
	end,
})
