return {
	----| autocomplete/intellisense |----
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"roginfarrer/cmp-css-variables",
		},
		opts = function()
			local ok_cmp, cmp = pcall(require, "cmp")
			if not ok_cmp then
				return
			end
			local cmpkind = require("utils.icons_utils").cmpkind_icons

			-- pcall other plugins needed
			local ok_snip, luasnip = pcall(require, "luasnip")
			if ok_snip then
				local data = vim.fn.stdpath("data")
				local conf = vim.fn.stdpath("config")
				require("luasnip.loaders.from_vscode").lazy_load({ paths = data .. "/lazy/friendly-snippets/" })
				require("luasnip.loaders.from_lua").load({ paths = conf .. "/lua/snippets/" })
			end

			local function tailwind_fmt(entry, item)
				local ok, tw = pcall(require, "tailwind-colorizer-cmp")
				if ok and tw and tw.formatter then
					return tw.formatter(entry, item)
				end
				return item
			end

			-- helper fn `set`
			local function set(list)
				local t = {}
				for _, v in ipairs(list) do
					t[v] = true
				end
				return t
			end

			local disabled_ft = set({ "text", "gitcommit", "gitrebase", "csv", "log" })
			local disabled_bt = set({ "prompt", "terminal" })

			local function in_comment(context)
				local ok1 = pcall(context.in_treesitter_capture, "comment")
				if ok1 and context.in_treesitter_capture("comment") then
					return true
				end
				local ok2 = pcall(context.in_syntax_group, "Comment")
				if ok2 and context.in_syntax_group("Comment") then
					return true
				end
				return false
			end

			return {
				completion = {
					autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
					completeopt = "menu,menuone,preview,noinsert",
				},
				experimental = {
					ghost_text = false,
				},
				performance = {
					max_view_entries = 20,
					debounce = 60,
					trottle = 30,
					fetching_timeout = 200,
				},
				window = {
					completion = {
						border = "rounded",
					},
					documentation = {
						border = "rounded",
					},
				},
				snippet = {
					expand = function(args)
						if ok_snip then
							luasnip.lsp_expand(args.body)
						else
							vim.notify("LuaSnip not available", vim.log.levels.WARN)
						end
					end,
				},

				formatting = {
					format = function(entry, vim_item)
						-- icon
						local icon = cmpkind[vim_item.kind] or ""
						vim_item.kind = string.format("%s %s", icon, vim_item.kind) -- concat icon + name

						-- menu/list
						local m_map = {
							nvim_lsp = "[LSP]",
							luasnip = "[LuaSnip]",
							buffer = "[BUF]",
							path = "[PATH]",
							nvim_lua = "[LUA]",
						}
						vim_item.menu = m_map[entry.source.name] or ("[" .. entry.source.name .. "]")

						-- tailwind color: no-op if deactivated / disabled / non-existing.
						vim_item = tailwind_fmt(entry, vim_item)
						return vim_item
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							require("luasnip").expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							require("luasnip").jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				sources = cmp.config.sources({
					-- order of sources determines-> completion order
					-- higher group_index value -> dont show if lower exist
					{ name = "nvim_lsp", keyword_length = 1, group_index = 1 },
					{ name = "css-variables", group_index = 1 },
					{ name = "luasnip", keyword_length = 2, group_index = 2 },
					{ name = "buffer", keyword_length = 3, group = 1 },
					{ name = "path", keyword_length = 3, group = 1 },
				}),

				enabled = function()
					-- disable on: comment-row, prompt, and specific files.
					local context = require("cmp.config.context")

					if vim.api.nvim_get_mode().mode == "c" then
						return true
					end

					-- FT/BUF disable
					if disabled_ft[vim.bo.buftype] then
						return false
					end
					if disabled_ft[vim.bo.filetype] then
						return false
					end
					if vim.bo.modifiable == false then
						return false
					end

					-- in comment - disable
					return not in_comment(context)
				end,

				cmp.setup.cmdline(":", {
					-- cmdline cfg
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = "path", keyword_length = 1 },
						{ name = "cmdline" },
					}),
					matching = { disallow_symbol_nonprefix_matching = false },
				}),

				cmp.setup.cmdline({ "/", "?" }, {
					-- search
					mapping = cmp.mapping.preset.cmdline(),
					sources = {
						{
							name = "buffer",
							option = {
								keyword_length = 2,
							},
						},
					},
				}),
			}
		end,
	},

	----| snippet support |----
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		build = "make install_jsregexp",
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
