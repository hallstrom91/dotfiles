return {

	----| Rainbow delimiters (brackets etc colors) |----
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					javascript = "rainbow-parens",
					typescript = "rainbow-parens",
					tsx = "rainbow-parens",
					lua = "rainbow-blocks",
				},
				priority = {
					[""] = 110,
					lua = 210,
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},

	----| hlchunck - indent |----
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("config.indents")
		end,
	},

	----| Spectre (Find & Replace Text) |----
	{
		"nvim-pack/nvim-spectre",
		keys = {
			{
				"<leader>sw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Spectre Search Current Word",
				mode = "n",
			},
			{
				"<leader>sw",
				function()
					require("spectre").open_visual()
				end,
				desc = "Spectre Search Current Word (visual)",
				mode = "v",
			},
			{
				"<leader>sp",
				function()
					require("spectre").open_file_search({ select_word = true })
				end,
				desc = "Spectre Search in file",
			},
		},
	},

	----| Noice |----
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					hover = {
						enabled = true,
					},
					signature = {
						enabled = true,
					},
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = false,
					command_palette = false,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = false,
				},
				-- remove routes ? err fixed in plugins?
				routes = {
					{
						filter = {
							event = "notify",
							find = "vim%.deprecated",
						},
						opts = { skip = true },
					},
				},
			})
		end,
	},

	----| Bufferline (document 'tabs') |----
	{
		"akinsho/bufferline.nvim",
		version = "*",
		enabled = true,
		dependencies = {
			"famiu/bufdelete.nvim",
		},
		event = "BufWinEnter",
		config = function()
			require("config.bufferline")
		end,
	},

	----| Lualine (statusbar, winbar) |----
	{
		"nvim-lualine/lualine.nvim",
		event = "BufWinEnter",
		dependencies = "Mofiqul/vscode.nvim",
		config = function()
			require("config.lualine")
		end,
	},

	----| Markdown |----
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		-- ft = { "markdown", "mdx" }, -- test
		ft = "markdown",
		config = function()
			require("render-markdown").setup({
				latex = { enabled = false },
				heading = {
					icons = { " 󰲡 ", " 󰲣 ", " 󰲥 ", " 󰲧 ", " 󰲩 ", " 󰲫 " },
					signs = { "󰜴 " },
					border = true,
					above = "▄",
					below = "▀",
				},
			})
		end,
	},

	----| Gitsigns  |----
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("config.gitsigns")
			-- require("scrollbar.handlers.gitsigns").setup()
		end,
	},

	----| comment |----
	{
		"nvim-mini/mini.comment",
		version = "*",
		event = "InsertEnter",
		config = function()
			require("mini.comment").setup()
		end,
	},

	----| surround |----
	{
		"nvim-mini/mini.surround",
		version = "*",
		event = "InsertEnter",
		config = function()
			require("mini.surround").setup()
		end,
	},

	----| cursorword (marker) |----
	-- {
	--   "nvim-mini/mini.cursorword",
	--   version = "*",
	--   event = "InsertEnter",
	--   config = function()
	--     _G.cursorword_blocklist = function()
	--       local curword = vim.fn.expand("<cword>")
	--       local filetype = vim.bo.filetype
	--
	--       -- Add any disabling global or filetype-specific logic here
	--       local blocklist = {}
	--       if filetype == "lua" then
	--         blocklist = { "local", "require" }
	--       elseif filetype == "javascript" then
	--         blocklist = { "import" }
	--       end
	--
	--       vim.b.minicursorword_disable = vim.tbl_contains(blocklist, curword)
	--     end
	--
	--     vim.cmd("au CursorMoved * lua _G.cursorword_blocklist()")
	--     require("mini.cursorword").setup()
	--   end,
	-- },

	----| Neotree (File explorer) |----
	{
		"nvim-neo-tree/neo-tree.nvim",
		-- branch = "v3.*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"s1n7ax/nvim-window-picker",
		},

		config = function()
			require("config.neotree")
		end,
	},

	----| Window Picker |----
	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
		config = function()
			vim.keymap.set("n", "<leader>w", function()
				local picked_window_id = require("window-picker").pick_window()
				if picked_window_id then
					vim.api.nvim_set_current_win(picked_window_id)
				else
					print("Aborted - No window picked!")
				end
			end, { desc = "Window Picker" })
			require("window-picker").setup({
				hint = "floating-big-letter",
				selection_chars = "FJDKSLA;CMRUEIWOQP",

				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					bo = {
						filetype = { "neo-tree-popup", "notify", "telescope" },
						buftype = { "terminal", "quickfix", "spectre", "bqf", "telescope" },
					},
				},
			})
		end,
	},

	{
		"Mofiqul/vscode.nvim",
		opts = {
			style = "dark",
			transparent = false,
			italic_comments = true,
			italic_inlayhints = true,
			disable_nvimtree_bg = true,
		},
		config = function(_, opts)
			require("vscode").setup(opts)
		end,
	},

	--{ "danilamihailov/beacon.nvim" },
	{
		"NvChad/nvim-colorizer.lua",
		ft = { "css", "lua", "typescriptreact", "javascriptreact" },
		config = function()
			require("colorizer").setup({
				user_default_options = {
					RGB = true,
					RRGGBB = true,
					names = false,
					css = true,
					css_fn = true,
					mode = "background",
					tailwind = true,
					always_update = true,
					virtualtext = "■",
				},
			})
		end,
	},
}
