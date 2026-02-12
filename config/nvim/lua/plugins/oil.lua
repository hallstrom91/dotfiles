return {
	---@module 'oil'
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	lazy = false,
	keys = {
		{
			"<leader>-",
			function()
				require("oil").toggle_float()
			end,
			desc = "Toggle Oil (float)",
		},
	},
	-- https://github.com/stevearc/oil.nvim
	opts = function()
		local float_size = { width = 0.5, height = 0.6 }
		local confirm_size = { width = 0.4, height = 0.25 }
		local utils_screen = require("utils.screen")
		local float = utils_screen.scale_size(float_size)
		local prompt = utils_screen.scale_size(confirm_size)

		return {
			default_file_explorer = true,
			watch_for_changes = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,

			float = {
				max_height = float.height,
				max_width = float.width,
				padding = 4,
				border = "rounded",
				preview_split = "right",
			},

			columns = {
				"icon",
				-- "size",
				-- "mtime",
			},

			view_options = {
				show_hidden = true,
				--- default func, definition of 'hidden'
				-- is_hidden_file = function(name, bufnr)
				-- 	local m = name:match("^%.")
				-- 	return m ~= nil
				-- end,
				is_always_hidden = function(name, _)
					return name == "node_modules" or name == ".git"
					-- return false
				end,
				---@class oil.SortSpec[]
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			confirmation = {
				max_height = prompt.height,
				max_width = prompt.width,
				border = "rounded",
			},
			keymaps = {
				["q"] = { "actions.close", mode = "n" },
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["<C-s>"] = { "actions.select", opts = { vertical = true } },
				["<C-h>"] = { "actions.select", opts = { horizontal = true } },
				["<C-t>"] = { "actions.select", opts = { tab = true } },
				["<C-p>"] = "actions.preview",
				["<C-l>"] = "actions.refresh",
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = "actions.open_external",
				["gd"] = function()
					require("oil").set_columns({ "icon" })
				end,
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
			},
			use_default_keymaps = false,
			keymaps_help = {
				border = "rounded",
			},
			git = {
				-- Return true to automatically git add/mv/rm files
				add = function(path)
					return false
				end,
				mv = function(src_path, dest_path)
					return true
				end,
				rm = function(path)
					return false
				end,
			},
		}
	end,
}
