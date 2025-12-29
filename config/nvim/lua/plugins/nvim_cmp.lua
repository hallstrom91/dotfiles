return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip", -- LuaSnip integration in CMP
			-- "roginfarrer/cmp-css-variables", -- CSS variables without LSP (css_variables) attached
		},

		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("kjs.cmp_md", { clear = true }),
				desc = "Start treesitter for `cmp_docs`, as markdown.",
				pattern = { "cmp_docs", "cmp_menu" }, -- add cmp_menu
				callback = function(args)
					vim.treesitter.start(args.buf, "markdown")
				end,
			})
		end,

		opts = function()
			local cmp = require("cmp")
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

			-- LSP capabilities for a given server, try this in a LSP-enabled buffer:
			--     :lua =vim.lsp.get_clients()[1].server_capabilities
			-- vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
			-- return {

			cmp.setup({
				preselect = cmp.PreselectMode.item,
				keyword_length = 2,

				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- luasnip
					end,
				},

				window = {
					documentation = {
						border = "rounded",
						-- winhighlight = "Normal:CmpItemMenu,FloatBorder:Pmenu,CursorLine:CmpSelSoft,Search:None",
					},
					completion = {
						border = "rounded",
						-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:CmpSelSoft,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
				},

				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
					["C-Space"] = cmp.mapping.complete({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
					["C-d"] = cmp.mapping.scroll_docs(-4),
					["C-f"] = cmp.mapping.scroll_docs(4),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp", max_item_count = 12, keyword_length = 2 },
				}, {
					{ name = "luasnip", max_item_count = 5, keyword_length = 2 },
					{
						name = "buffer",
						max_item_count = 5,
						keyword_length = 3,
						option = {
							-- get 'buffer' completion from all open bufs
							get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
					},
					{ name = "path", max_item_count = 5, keyword_length = 4 },
				}),

				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind =
							require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (strings[1] or "") .. " "
						kind.menu = "    (" .. (strings[2] or "") .. ")"

						return kind
					end,
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer", max_item_count = 10 },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path", max_item_count = 10 },
					{ name = "cmdline", max_item_count = 10 },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})
		end,
	},

	----| snippet support |----
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		build = "make install_jsregexp",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })
		end,
	},
	----| colorizer |----
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
		--lazy = true,
		event = "VeryLazy",
		opts = {
			color_square_width = 2,
		},
	},

	{
		"roginfarrer/cmp-css-variables",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "css" },
		lazy = true,
	},
}
