return {
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
	opts = function()
		-- LSP capabilities for a given server, try this in a LSP-enabled buffer:
		-- :lua =vim.lsp.get_clients()[1].server_capabilities
		local cmp = require("cmp")
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
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
				},
				completion = {
					border = "rounded",
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
				{ name = "luasnip", max_item_count = 5, keyword_length = 2 },
				{
					name = "buffer",
					max_item_count = 5,
					keyword_length = 3,
					-- -- get 'buffer' completion from all open bufs
					-- option = {
					-- 	get_bufnrs = function()
					-- 		local bufs = {}
					-- 		for _, win in ipairs(vim.api.nvim_list_wins()) do
					-- 			bufs[vim.api.nvim_win_get_buf(win)] = true
					-- 		end
					-- 		return vim.tbl_keys(bufs)
					-- 	end,
					-- },
				},
				{ name = "path", max_item_count = 5, keyword_length = 4 },
			}),

			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
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
				{ name = "cmdline", max_item_count = 10 },
				{ name = "path", max_item_count = 10 },
			}),
			matching = { disallow_symbol_nonprefix_matching = false },
		})
	end,
}
