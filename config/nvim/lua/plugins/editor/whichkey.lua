return {
	{
		-- based on LazyVim setup: https://www.lazyvim.org/plugins/editor
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix", -- "classic" | "modern" | "helix"
			show_help = false, -- no help-msg in cmdline
			--		show_keys = true,
			spec = {
				{
					mode = { "n", "x" },
					{ "<leader>b", group = "buffers" },
					{ "<leader>f", group = "find" },
					{ "<leader>g", group = "git" },
					{ "<leader>G", group = "LSP pickers" },
					{ "<leader>s", group = "search" },
					{ "<leader>su", group = "surround" },
					-- { "<leader>gh", group = "hunks" },
					{ "<leader><tab>", group = "tabs" },
					-- { "<leader>q", group = "quit/session" },
					{ "<leader>m", group = "motions" },
					{ "<leader>-", group = "Oil" },
					{ "gr", group = "LSP goto/actions" },
					{ "z", group = "fold" },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "gx", desc = "Open with system app" },
					{
						"<leader>w",
						group = "windows",

						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
				},
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Show Buf Keymaps",
			},
			{
				"<c-w><space>",
				function()
					require("which-key").show({ keys = "c-w", loop = true })
				end,
				desc = "Show Window Keymaps",
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
		end,
	},
}
