-- local _apply_ts_ctx_hl = function()
-- 	local set = vim.api.nvim_set_hl
--
-- 	--> Base hl:
-- 	set(0, "TreesitterContext", { link = "PmenuSbar" }) -- or "NormalFloat" ? or "?"?
-- 	set(0, "TreesitterContextLineNumber", { link = "Identifier" }) -- or "LineNumber" ? or "?"?
-- 	-- set(0, "TreesitterContextSeparator", { link = "FloatBorder" }) -- or "?" -> opts.separator must be defined.
--
-- 	--> Bottom hl:
-- 	set(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
-- 	set(0, "TreesitterContextLineNumberBottom", { underline = true, sp = "Grey" })
-- end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- latest
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			-- install parsers
			ts.install({
				"bash",
				"csharp",
				"css",
				"dockerfile",
				"gitcommit",
				"git_config",
				"gitignore",
				"git_rebase",
				"html",
				"javascript",
				"json",
				"jsonc",
				"regex", -- for cmdline hl
				"tsx",
				"typescript",
				"yaml",
				"hyprlang",
				"qmljs",
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true,
			multiwindow = false,
			max_lines = 0, --> 0 => no limit
			min_window_height = 10, --> 0 => no limit
			line_numbers = true,
			multiline_threshold = 20, --> max-num of lines to show for a single context
			trim_scope = "outer", --> alt: 'inner'
			mode = "cursor", --> alt: 'topline'
			separator = nil, -- single char string, like: '-'
			-- separator = "_",
			zindex = 20,
			on_attach = nil, --> (fun(buf: int): boolean) -> return false to disable attach
		},
		config = function(_, opts)
			local ts_ctx = require("treesitter-context")
			ts_ctx.setup(opts)

			-- _apply_ts_ctx_hl()

			vim.keymap.set("n", "[c", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { silent = true, desc = "Go to context" })

			-- 	vim.api.nvim_create_autocmd("ColorScheme", {
			-- 		group = vim.api.nvim_create_augroup("usr_hl_ts_ctx", {
			-- 			clear = true,
			-- 		}),
			-- 		desc = "Re-apply TS-Context highlights at theme switch",
			-- 		callback = _apply_ts_ctx_hl,
			-- 	})
		end,
	},

	-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		enabled = false,
		opts = {
			move = {
				enable = true,
				set_jumps = true,
			},
		},
		config = function(_, opts)
			local ts_txtobj = require("nvim-treesitter-textobjects")
			ts_txtobj.setup(opts)

			-- TODO: move to `attach.lua` and check installed TS-parser for buf 'ft'
			-- add supported move-actions for buf active ts-parser/lng

			-- @function
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[F", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
			end)

			-- @class
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[C", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
			end)
		end,
	},

	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},

	"windwp/nvim-ts-autotag",
	ft = { "html", "xml", "javascript", "typescript", "typescriptreact", "javascriptreact" },
	opts = {
		opts = { enable_close = true, enable_rename = false, enable_close_on_slash = true },
	},
}
