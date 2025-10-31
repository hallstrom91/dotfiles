return {
	----| File Explorer/Tree |----
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		init = function()
			vim.keymap.set("n", "<C-n>", ":Neotree<CR>", { desc = "File Explorer" })
			-- vim.keymap.set("n", "<C-n>", ":Neotree toggle reveal_force_cwd=true<CR>", { desc = "File Explorer" })
		end,
		lazy = false,
		opts = {
			close_if_last_window = false,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			enable_modified_markers = true,
			enable_opened_markers = true,
			enable_refresh_on_write = true,
			enable_cursor_hijack = true,
			git_status_async = true,
			log_level = "info", -- "trace", "debug", "info", "warn", "error", "fatal"
			open_files_in_last_window = true, -- false = open files in top left window
			open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy", "help", "spectre" }, -- when opening files, do not use windows containing these filetypes or buftypes

			use_popups_for_input = false, -- If false, inputs will use vim.ui.input() instead of custom floats.
			use_default_mappings = true,
			default_component_configs = {
				name = {
					trailing_slash = false,
				},
				symlink_target = {
					enabled = false, -- default
					text_format = " -> %s", -- %s will be replaced by target path
				},
			},
			filesystem = {
				filtered_items = {
					visible = false, -- if true = show different style
					hide_dotfiles = false, -- hide if dotprefix (.name)
					hide_gitignored = true, -- only windows ?
					hide_hidden = true,
					hide_by_name = {
						"node_modules",
						"next",
						".git",
						".yarn",
					},
					always_show = {
						".gitignored",
						"*.log",
					},
					always_show_by_pattern = {
						".env*",
					},
				},
				follow_current_file = {
					enabled = true, -- ?
					leave_dirs_open = false,
				},
			},

			source_selector = {
				winbar = true,
				statusline = false,
			},

			window = {
				position = "float",
				width = 40,
				popup = {
					size = {
						height = "80%",
						width = "50%",
					},
					position = "50%",
					popup_border_style = "rounded", -- Border style for popups (rounded, single, double)
					title = function(state) -- format the text that appears at the top of a popup window
						return "Neo-tree " .. state.name:gsub("^%l", string.upper)
					end,
					-- you can also specify border here, if you want a different setting from
					-- the global popup_border_style.
				},
				mappings = {
					["<esc>"] = "cancel", -- close preview or floating neo-tree window
					["P"] = {
						"toggle_preview",
						config = {
							use_float = true,
							use_snacks_image = true,
							use_image_nvim = true,
							title = "Preview", -- You can define a custom title for the preview floating window.
						},
					},
					["<CR>"] = { desc = "open (new tab)", "open_tabnew" },
					["o"] = "open",
					["/"] = "none", -- remove fuzzyfind in neotree menu
				},
			},
		},
	},
}
